package jackboxgames.loader
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import jackboxgames.logger.Logger;
   import jackboxgames.nativeoverride.JSON;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.TraceUtil;
   
   public class DataLoader extends PausableEventDispatcher implements ILoader
   {
      protected var _loader:URLLoader;
      
      protected var _url:String;
      
      public function DataLoader(requestUrl:String)
      {
         super();
         this._url = requestUrl;
         this._loader = new URLLoader();
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
         var _dataLoader:DataLoader = null;
         var loadComplete:Function = null;
         var loadError:Function = null;
         loadComplete = function(event:Event):void
         {
            if(callback != null)
            {
               callback({
                  "success":true,
                  "loader":_dataLoader
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
         _dataLoader = this;
         this._loader.addEventListener(Event.COMPLETE,loadComplete);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,loadError);
         this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,loadError);
         this._loader.load(new URLRequest(this._url));
      }
      
      public function loadFallback() : void
      {
         this._loader.load(new URLRequest(this._url));
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
         var xmlContent:XML = null;
         if(this._loader.dataFormat != URLLoaderDataFormat.TEXT)
         {
            return null;
         }
         try
         {
            xmlContent = new XML(this.content);
         }
         catch(err:Error)
         {
            Logger.debug("ERROR: DataLoader::contentAsXML => content is not valid XML");
            Logger.debug(TraceUtil.objectRecursive(err,"Error"));
         }
         return xmlContent;
      }
      
      public function get contentAsJSON() : Object
      {
         if(this._loader.dataFormat != URLLoaderDataFormat.TEXT)
         {
            return null;
         }
         var jsonContent:Object = JSON.deserialize(String(this.content));
         if(!jsonContent)
         {
            Logger.debug("ERROR: DataLoader::contentAsJSON => content is not valid JSON");
            Logger.debug(String(this.content));
         }
         return jsonContent;
      }
      
      public function get contentAsString() : String
      {
         if(this._loader.dataFormat != URLLoaderDataFormat.TEXT)
         {
            return null;
         }
         return String(this.content);
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

