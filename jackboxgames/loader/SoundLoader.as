package jackboxgames.loader
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import jackboxgames.utils.Duration;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class SoundLoader extends PausableEventDispatcher implements ILoader
   {
       
      
      protected var _sound:Sound;
      
      protected var _context:SoundLoaderContext;
      
      protected var _url:String;
      
      public function SoundLoader(soundUrl:String)
      {
         super();
         this._url = soundUrl;
         this._context = new SoundLoaderContext();
      }
      
      public function get content() : *
      {
         return this._sound;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get loaded() : Boolean
      {
         return this._sound.bytesLoaded > 0;
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
                  "data":contentAsSound
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
         this._sound = new Sound();
         this._sound.addEventListener(Event.COMPLETE,loadComplete);
         this._sound.addEventListener(IOErrorEvent.IO_ERROR,loadError);
         this._sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR,loadError);
         this._sound.load(new URLRequest(this._url),this._context);
      }
      
      public function loadUnzipped(bytes:ByteArray) : void
      {
         this._sound.loadCompressedDataFromByteArray(bytes,bytes.length);
         JBGUtil.runFunctionAfter(function():void
         {
            _sound.dispatchEvent(new Event(Event.COMPLETE));
         },Duration.fromMs(33));
      }
      
      public function loadFallback() : void
      {
         this._sound.load(new URLRequest(this._url));
      }
      
      public function loadComplete() : void
      {
         this._sound.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function get contentAsSound() : Sound
      {
         return this._sound;
      }
      
      public function stop() : void
      {
         this._sound.close();
      }
      
      public function dispose() : void
      {
         try
         {
            this._sound.close();
         }
         catch(e:Error)
         {
         }
         this._sound = null;
      }
   }
}
