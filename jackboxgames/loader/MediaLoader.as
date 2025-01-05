package jackboxgames.loader
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class MediaLoader extends PausableEventDispatcher implements ILoader
   {
       
      
      protected var _loader:Loader;
      
      protected var _context:LoaderContext;
      
      protected var _url:String;
      
      public function MediaLoader(requestUrl:String, domain:ApplicationDomain = null)
      {
         super();
         this._url = requestUrl;
         this._loader = new Loader();
         this._context = new LoaderContext();
         this._context.checkPolicyFile = true;
         this._context.applicationDomain = domain != null ? domain : ApplicationDomain.currentDomain;
      }
      
      public function get content() : *
      {
         return this._loader.content;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get loaded() : Boolean
      {
         return this._loader.contentLoaderInfo.bytesLoaded == this._loader.contentLoaderInfo.bytesTotal;
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
                  "data":content,
                  "contentAsBitmap":contentAsBitmap,
                  "contentAsBitmapData":contentAsBitmapData,
                  "contentAsMovieClip":contentAsMovieClip,
                  "bytes":(Boolean(_loader.loaderInfo) ? _loader.loaderInfo.bytes : _loader.contentLoaderInfo.bytes),
                  "getClass":getClass
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
         Logger.debug("MediaLoad::load url => " + this._url);
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadError);
         this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,loadError);
         this._loader.load(new URLRequest(this._url),this._context);
      }
      
      public function loadUnzipped(bytes:ByteArray) : void
      {
         JBGUtil.runFunctionAfter(function():void
         {
            if(_context == null)
            {
               _context = new LoaderContext(false,ApplicationDomain.currentDomain);
            }
            _context.allowLoadBytesCodeExecution = true;
            _context.allowCodeImport = true;
            _context.checkPolicyFile = false;
            _loader.loadBytes(bytes,_context);
         },Duration.fromMs(33));
      }
      
      public function loadFallback() : void
      {
         this._loader.load(new URLRequest(this._url),this._context);
      }
      
      public function loadComplete() : void
      {
         this._loader.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function stop() : void
      {
         this._loader.unloadAndStop();
         this._loader = null;
      }
      
      public function dispose() : void
      {
         if(Boolean(this._loader))
         {
            try
            {
               this._loader.close();
            }
            catch(error:Error)
            {
            }
            try
            {
               this._loader.unloadAndStop(true);
            }
            catch(error:Error)
            {
            }
            this._loader = null;
         }
      }
      
      public function get contentAsBitmap() : Bitmap
      {
         if(this.content is Bitmap)
         {
            return new Bitmap(this.content.bitmapData,"auto",true);
         }
         if(this.content is BitmapData)
         {
            return new Bitmap(BitmapData(this.content),"auto",true);
         }
         return null;
      }
      
      public function get contentAsBitmapData() : BitmapData
      {
         if(this.content is Bitmap)
         {
            return this.content.bitmapData;
         }
         if(this.content is BitmapData)
         {
            return BitmapData(this.content);
         }
         return null;
      }
      
      public function get contentAsMovieClip() : MovieClip
      {
         if(this.content is MovieClip)
         {
            return MovieClip(this.content);
         }
         return null;
      }
      
      public function getClass(className:String) : Class
      {
         if(this._loader.contentLoaderInfo.applicationDomain.hasDefinition(className))
         {
            return this._loader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
         }
         return null;
      }
   }
}
