package jackboxgames.loader
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequestHeader;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   import flash.utils.CompressionAlgorithm;
   import jackboxgames.nativeoverride.JSON;
   import jackboxgames.net.NetUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class RequestLoader extends PausableEventDispatcher implements ILoader
   {
      
      public static const OUTGOING_DATA_FORMAT_DEFAULT:String = "DEFAULT";
      
      public static const OUTGOING_DATA_FORMAT_JSON:String = "JSON";
      
      public static const OUTGOING_DATA_FORMAT_JSON_COMPRESSED:String = "JSON_COMPRESSED";
       
      
      protected var _loader:*;
      
      protected var _request:*;
      
      protected var _url:String;
      
      public function RequestLoader(requestUrl:String, incomingDataFormat:String, methodType:String, outgoingData:Object, outgoingDataFormat:String, additionalHeaders:Array = null)
      {
         var data:* = undefined;
         var urlVariables:URLVariables = null;
         var key:String = null;
         var s:String = null;
         var b:ByteArray = null;
         super();
         this._url = requestUrl;
         this._loader = NetUtil.createURLLoader();
         this._loader.dataFormat = incomingDataFormat;
         this._request = NetUtil.createURLRequest(this._url);
         this._request.method = methodType;
         if(Boolean(outgoingData) && Boolean(outgoingDataFormat))
         {
            data = null;
            if(outgoingDataFormat == OUTGOING_DATA_FORMAT_DEFAULT)
            {
               urlVariables = new URLVariables();
               for(key in outgoingData)
               {
                  urlVariables[key] = outgoingData[key];
               }
               this._request.data = urlVariables;
            }
            else if(outgoingDataFormat == OUTGOING_DATA_FORMAT_JSON || outgoingDataFormat == OUTGOING_DATA_FORMAT_JSON_COMPRESSED)
            {
               s = JSON.serialize(outgoingData);
               b = new ByteArray();
               b.writeUTFBytes(s);
               this._request.requestHeaders = [new URLRequestHeader("Content-Type","application/json")];
               if(outgoingDataFormat == OUTGOING_DATA_FORMAT_JSON_COMPRESSED)
               {
                  b.compress(CompressionAlgorithm.ZLIB);
                  this._request.requestHeaders.push(new URLRequestHeader("Content-Encoding","deflate"));
               }
               this._request.data = b;
            }
         }
         if(Boolean(additionalHeaders) && additionalHeaders.length > 0)
         {
            this._request.requestHeaders = this._request.requestHeaders.concat(additionalHeaders);
         }
      }
      
      public function get content() : *
      {
         return this._loader.data;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get loaded() : Boolean
      {
         return this._loader.bytesLoaded == this._loader.bytesTotal;
      }
      
      public function load(callback:Function = null) : void
      {
         var loadComplete:Function = null;
         var loadError:Function = null;
         loadComplete = function(event:Event):void
         {
            if(callback != null)
            {
               callback({
                  "success":true,
                  "data":_loader.data
               });
            }
         };
         loadError = function(event:Event):void
         {
            if(callback != null)
            {
               callback({
                  "success":false,
                  "error":event
               });
            }
         };
         this._loader.addEventListener(Event.COMPLETE,loadComplete);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,loadError);
         this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,loadError);
         this._loader.load(this._request);
      }
      
      public function loadUnzipped(bytes:ByteArray) : void
      {
      }
      
      public function loadFallback() : void
      {
         this._loader.load(this._request);
      }
      
      public function loadComplete() : void
      {
         this._loader.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function get contentAsByteArray() : ByteArray
      {
         if(this._loader.dataFormat != URLLoaderDataFormat.BINARY)
         {
            return null;
         }
         return this._loader.data as ByteArray;
      }
      
      public function get contentAsXML() : XML
      {
         if(this._loader.dataFormat != URLLoaderDataFormat.TEXT)
         {
            return null;
         }
         return new XML(this.content);
      }
      
      public function get contentAsJSON() : Object
      {
         if(this._loader.dataFormat != URLLoaderDataFormat.TEXT)
         {
            return null;
         }
         return JSON.deserialize(String(this.content)) as Object;
      }
      
      public function stop() : void
      {
         try
         {
            this._loader.close();
         }
         catch(err:Error)
         {
         }
      }
      
      public function dispose() : void
      {
         try
         {
            this._loader.close();
         }
         catch(err:Error)
         {
         }
      }
   }
}
