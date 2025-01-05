package com.laiyonghao
{
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class Uuid
   {
      
      private static const ALPHA_CHAR_CODES:Array = [48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70];
       
      
      private var str:String;
      
      private var buff:ByteArray;
      
      public function Uuid()
      {
         super();
         update();
      }
      
      public function update() : Uuid
      {
         str = null;
         var r:uint = uint(new Date().time);
         buff = new ByteArray();
         buff.writeUnsignedInt(System.totalMemory ^ r);
         buff.writeInt(getTimer() ^ r);
         buff.writeDouble(Math.random() * r);
         return this;
      }
      
      public function bytes(ba:ByteArray) : void
      {
         buff.position = 0;
         buff.readBytes(ba);
      }
      
      public function toString() : String
      {
         var b:int = 0;
         if(Boolean(str))
         {
            return str;
         }
         buff.position = 0;
         var chars:Array = new Array(36);
         var index:uint = 0;
         for(var i:uint = 0; i < 16; i++)
         {
            if(i == 4 || i == 6 || i == 8 || i == 10)
            {
               var _loc5_:* = index++;
               chars[_loc5_] = 45;
            }
            b = buff.readByte();
            _loc5_ = index++;
            chars[_loc5_] = ALPHA_CHAR_CODES[(b & 240) >>> 4];
            var _loc6_:* = index++;
            chars[_loc6_] = ALPHA_CHAR_CODES[b & 15];
         }
         str = String.fromCharCode.apply(null,chars);
         return str;
      }
   }
}
