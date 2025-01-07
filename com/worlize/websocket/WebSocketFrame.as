package com.worlize.websocket
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class WebSocketFrame
   {
      private static const NEW_FRAME:int = 0;
      
      private static const WAITING_FOR_16_BIT_LENGTH:int = 1;
      
      private static const WAITING_FOR_64_BIT_LENGTH:int = 2;
      
      private static const WAITING_FOR_PAYLOAD:int = 3;
      
      private static const COMPLETE:int = 4;
      
      private static var _tempMaskBytes:Vector.<uint> = new Vector.<uint>(4);
      
      public var fin:Boolean;
      
      public var rsv1:Boolean;
      
      public var rsv2:Boolean;
      
      public var rsv3:Boolean;
      
      public var opcode:int;
      
      public var mask:Boolean;
      
      public var useNullMask:Boolean;
      
      private var _length:int;
      
      public var binaryPayload:ByteArray;
      
      public var closeStatus:int;
      
      public var protocolError:Boolean = false;
      
      public var frameTooLarge:Boolean = false;
      
      public var dropReason:String;
      
      private var parseState:int = 0;
      
      public function WebSocketFrame()
      {
         super();
      }
      
      public function get length() : int
      {
         return this._length;
      }
      
      public function addData(input:IDataInput, fragmentationType:int, config:WebSocketConfig) : Boolean
      {
         var firstByte:int = 0;
         var secondByte:int = 0;
         var firstHalf:uint = 0;
         if(input.bytesAvailable >= 2)
         {
            if(this.parseState === NEW_FRAME)
            {
               firstByte = int(input.readByte());
               secondByte = int(input.readByte());
               this.fin = Boolean(firstByte & 0x80);
               this.rsv1 = Boolean(firstByte & 0x40);
               this.rsv2 = Boolean(firstByte & 0x20);
               this.rsv3 = Boolean(firstByte & 0x10);
               this.mask = Boolean(secondByte & 0x80);
               this.opcode = firstByte & 0x0F;
               this._length = secondByte & 0x7F;
               if(this.mask)
               {
                  this.protocolError = true;
                  this.dropReason = "Received an illegal masked frame from the server.";
                  return true;
               }
               if(this.opcode > 7)
               {
                  if(this._length > 125)
                  {
                     this.protocolError = true;
                     this.dropReason = "Illegal control frame larger than 125 bytes.";
                     return true;
                  }
                  if(!this.fin)
                  {
                     this.protocolError = true;
                     this.dropReason = "Received illegal fragmented control message.";
                     return true;
                  }
               }
               if(this._length === 126)
               {
                  this.parseState = WAITING_FOR_16_BIT_LENGTH;
               }
               else if(this._length === 127)
               {
                  this.parseState = WAITING_FOR_64_BIT_LENGTH;
               }
               else
               {
                  this.parseState = WAITING_FOR_PAYLOAD;
               }
            }
            if(this.parseState === WAITING_FOR_16_BIT_LENGTH)
            {
               if(input.bytesAvailable >= 2)
               {
                  this._length = input.readUnsignedShort();
                  this.parseState = WAITING_FOR_PAYLOAD;
               }
            }
            else if(this.parseState === WAITING_FOR_64_BIT_LENGTH)
            {
               if(input.bytesAvailable >= 8)
               {
                  firstHalf = uint(input.readUnsignedInt());
                  if(firstHalf > 0)
                  {
                     this.frameTooLarge = true;
                     this.dropReason = "Unsupported 64-bit length frame received.";
                     return true;
                  }
                  this._length = input.readUnsignedInt();
                  this.parseState = WAITING_FOR_PAYLOAD;
               }
            }
            if(this.parseState === WAITING_FOR_PAYLOAD)
            {
               if(this._length > config.maxReceivedFrameSize)
               {
                  this.frameTooLarge = true;
                  this.dropReason = "Received frame size of " + this._length + "exceeds maximum accepted frame size of " + config.maxReceivedFrameSize;
                  return true;
               }
               if(this._length === 0)
               {
                  this.binaryPayload = new ByteArray();
                  this.parseState = COMPLETE;
                  return true;
               }
               if(input.bytesAvailable >= this._length)
               {
                  this.binaryPayload = new ByteArray();
                  this.binaryPayload.endian = Endian.BIG_ENDIAN;
                  input.readBytes(this.binaryPayload,0,this._length);
                  this.binaryPayload.position = 0;
                  this.parseState = COMPLETE;
                  return true;
               }
            }
         }
         return false;
      }
      
      private function throwAwayPayload(input:IDataInput) : void
      {
         var i:int = 0;
         if(input.bytesAvailable >= this._length)
         {
            for(i = 0; i < this._length; i++)
            {
               input.readByte();
            }
            this.parseState = COMPLETE;
         }
      }
      
      public function send(output:IDataOutput) : void
      {
         var maskKey:uint = 0;
         var data:ByteArray = null;
         var j:int = 0;
         var remaining:uint = 0;
         if(this.mask && !this.useNullMask)
         {
            maskKey = Math.ceil(Math.random() * 4294967295);
            _tempMaskBytes[0] = maskKey >> 24 & 0xFF;
            _tempMaskBytes[1] = maskKey >> 16 & 0xFF;
            _tempMaskBytes[2] = maskKey >> 8 & 0xFF;
            _tempMaskBytes[3] = maskKey & 0xFF;
         }
         var firstByte:int = 0;
         var secondByte:int = 0;
         if(this.fin)
         {
            firstByte |= 128;
         }
         if(this.rsv1)
         {
            firstByte |= 64;
         }
         if(this.rsv2)
         {
            firstByte |= 32;
         }
         if(this.rsv3)
         {
            firstByte |= 16;
         }
         if(this.mask)
         {
            secondByte |= 128;
         }
         firstByte |= this.opcode & 0x0F;
         if(this.opcode === WebSocketOpcode.CONNECTION_CLOSE)
         {
            data = new ByteArray();
            data.endian = Endian.BIG_ENDIAN;
            data.writeShort(this.closeStatus);
            if(Boolean(this.binaryPayload))
            {
               this.binaryPayload.position = 0;
               data.writeBytes(this.binaryPayload);
            }
            data.position = 0;
            this._length = data.length;
         }
         else if(Boolean(this.binaryPayload))
         {
            data = this.binaryPayload;
            data.endian = Endian.BIG_ENDIAN;
            data.position = 0;
            this._length = data.length;
         }
         else
         {
            data = new ByteArray();
            this._length = 0;
         }
         if(this.opcode >= 8)
         {
            if(this._length > 125)
            {
               throw new Error("Illegal control frame longer than 125 bytes");
            }
            if(!this.fin)
            {
               throw new Error("Control frames must not be fragmented.");
            }
         }
         if(this._length <= 125)
         {
            secondByte |= this._length & 0x7F;
         }
         else if(this._length > 125 && this._length <= 65535)
         {
            secondByte |= 126;
         }
         else if(this._length > 65535)
         {
            secondByte |= 127;
         }
         output.writeByte(firstByte);
         output.writeByte(secondByte);
         if(this._length > 125 && this._length <= 65535)
         {
            output.writeShort(this._length);
         }
         else if(this._length > 65535)
         {
            output.writeUnsignedInt(0);
            output.writeUnsignedInt(this._length);
         }
         if(this.mask)
         {
            if(this.useNullMask)
            {
               output.writeUnsignedInt(0);
               output.writeBytes(data,0,data.length);
            }
            else
            {
               output.writeUnsignedInt(maskKey);
               j = 0;
               remaining = data.bytesAvailable;
               while(remaining >= 4)
               {
                  output.writeUnsignedInt(data.readUnsignedInt() ^ maskKey);
                  remaining -= 4;
               }
               while(remaining > 0)
               {
                  output.writeByte(data.readByte() ^ _tempMaskBytes[j]);
                  j += 1;
                  remaining -= 1;
               }
            }
         }
         else
         {
            output.writeBytes(data,0,data.length);
         }
      }
   }
}

