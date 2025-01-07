package jackboxgames.talkshow.core
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.text.TextField;
   import jackboxgames.logger.Logger;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.talkshow.api.IPreloader;
   import jackboxgames.talkshow.events.PlaybackEngineEvent;
   
   public class PlaybackFactory extends MovieClip
   {
      private static const FILE_DEFAULT_PRELOADER:String = "loadui.swf";
      
      private var _trace:TextField;
      
      private var dbg:Sprite;
      
      private var _app:Object;
      
      private var _preloaded:Boolean;
      
      private var _usingPreloader:Boolean;
      
      private var _ldr:Loader;
      
      private var _preloader:IPreloader;
      
      private var _preloadManager:PreloadManager;
      
      public function PlaybackFactory(engine:Object)
      {
         super();
         this._app = engine;
         stop();
         this._ldr = null;
         this._preloaded = false;
         this._usingPreloader = false;
         this._preloadManager = new PreloadManager();
         this.fetchPreloader();
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(framesLoaded == totalFrames && this._preloaded)
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            nextFrame();
            this.initEngine();
            this._preloadManager.setEngineBytes(root.loaderInfo.bytesTotal);
            this._preloadManager.playbackLoad(root.loaderInfo.bytesTotal,root.loaderInfo.bytesTotal);
         }
         else
         {
            this._preloadManager.playbackLoad(root.loaderInfo.bytesLoaded,root.loaderInfo.bytesTotal);
         }
      }
      
      private function initEngine() : void
      {
         this._app.initEngine();
         this._app.addEventListener(PlaybackEngineEvent.CONFIG_FINISHED,this.configHandler);
         this._app.ts.setPreloadManager(this._preloadManager);
         this._app.ts.g.platform = Platform.instance.PlatformId;
         if(!(this._preloader is IPreloader))
         {
            this.buildPreloadUI();
         }
         this._preloadManager.setPreloadUi(this._preloader as IPreloader);
         var loaderInfoParametersToUse:Object = Boolean(this.loaderInfo) ? this.loaderInfo.parameters : {};
         this._app.initConfig(loaderInfoParametersToUse);
      }
      
      private function fetchPreloader() : void
      {
         var loaderInfoParametersToUse:Object = Boolean(this.loaderInfo) ? this.loaderInfo.parameters : {};
         this.buildPreloadUI();
      }
      
      private function buildPreloadUI() : void
      {
         this._preloader = new DefaultPreloader();
         this._preloadManager.setPreloadUi(this._preloader);
         this._preloaded = true;
         addChild(this._preloader as DefaultPreloader);
      }
      
      private function setupLoader() : void
      {
         this._ldr = new Loader();
         this._ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,this.preloaderLoadHandler);
         this._ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.preloaderProgressHandler);
         this._ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.preloaderIOErrorHandler);
      }
      
      private function disposeLoaderHandlers() : void
      {
         this._ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.preloaderLoadHandler);
         this._ldr.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.preloaderProgressHandler);
         this._ldr.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.preloaderIOErrorHandler);
      }
      
      private function preloaderLoadHandler(e:Event) : void
      {
         Logger.info("Preloader Loaded","Bootstrap");
         this.disposeLoaderHandlers();
         this._preloader = e.target.content;
         this._preloaded = true;
         this._preloadManager.setPreloadUi(this._preloader);
      }
      
      private function preloaderIOErrorHandler(e:IOErrorEvent) : void
      {
         this.disposeLoaderHandlers();
         this.buildPreloadUI();
      }
      
      private function preloaderProgressHandler(e:ProgressEvent) : void
      {
      }
      
      private function configHandler(e:PlaybackEngineEvent) : void
      {
         this._app.removeEventListener(PlaybackEngineEvent.CONFIG_FINISHED,this.configHandler);
         this._app.startEngine();
      }
   }
}

