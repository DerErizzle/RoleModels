package jackboxgames.talkshow.api
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.EnvUtil;
   import jackboxgames.utils.Nullable;
   
   public class SWFActionPackage implements IActionPackage
   {
       
      
      protected var _sourceURL:String;
      
      protected var _loader:Loader;
      
      protected var _loadCancellor:Function;
      
      protected var _mc:MovieClip;
      
      protected var _ts:IEngineAPI;
      
      protected var _init:Boolean;
      
      public function SWFActionPackage(sourceURL:String)
      {
         var skipPath:String = null;
         super();
         if(EnvUtil.isAIR() && BuildConfig.instance.configVal("isBundle"))
         {
            skipPath = "games/" + BuildConfig.instance.configVal("gameName") + "/";
            sourceURL = sourceURL.substr(skipPath.length);
         }
         this._sourceURL = sourceURL;
         this._init = false;
         this._loadCancellor = Nullable.NULL_FUNCTION;
      }
      
      public function get isLoaded() : Boolean
      {
         return this._mc != null;
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function init(ts:IEngineAPI, ... initInfo) : void
      {
         if(!this._init)
         {
            this._ts = ts;
            this._init = true;
            (this._ts as IEventDispatcher).addEventListener(CellEvent.CELL_JUMP,this.handleJump,false,0,true);
            Logger.info("Init Action Package: " + this,"Action Package");
            this.doInit();
         }
      }
      
      protected function handleJump(evt:CellEvent) : void
      {
      }
      
      protected function doInit() : void
      {
      }
      
      public function get ts() : IEngineAPI
      {
         return this._ts;
      }
      
      public function get g() : Object
      {
         return this._ts.g;
      }
      
      public function get l() : Object
      {
         return this._ts.l;
      }
      
      public function get type() : String
      {
         return ActionPackageType.TYPE_SWF;
      }
      
      public function isInit() : Boolean
      {
         return this._init;
      }
      
      public function handleAction(ref:IActionRef, params:Object) : void
      {
      }
      
      public function getDuration(ref:IActionRef) : uint
      {
         return ActionPackage.getDefaultDuration(ref);
      }
      
      public function getDisplayObject(ref:IActionRef, params:Object, isRuntime:Boolean = false) : DisplayObject
      {
         return null;
      }
      
      private function get _isLoaded() : Boolean
      {
         return this._loader != null;
      }
      
      private function _load(doneFn:Function) : void
      {
         var context:LoaderContext;
         var onLoadComplete:Function = null;
         var onLoadError:Function = null;
         onLoadComplete = function(evt:Event):void
         {
            _mc = _loader.content as MovieClip;
            doneFn();
         };
         onLoadError = function(evt:Event):void
         {
            doneFn();
         };
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,onLoadError);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         this._loadCancellor = function():void
         {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
            _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.NETWORK_ERROR,onLoadError);
            _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         };
         context = new LoaderContext();
         context.checkPolicyFile = true;
         context.applicationDomain = ApplicationDomain.currentDomain;
         this._loader.load(new URLRequest(this._sourceURL),context);
      }
      
      private function _unload() : void
      {
         this._loadCancellor();
         this._loadCancellor = Nullable.NULL_FUNCTION;
         this._loader.unloadAndStop(true);
         this._loader = null;
      }
      
      protected function _setLoaded(isLoaded:Boolean, doneFn:Function) : void
      {
         if(isLoaded == this._isLoaded)
         {
            doneFn();
            return;
         }
         if(isLoaded)
         {
            this._load(function():void
            {
               _createReferences();
               doneFn();
            });
         }
         else
         {
            if(Boolean(this._mc))
            {
               this._disposeOfReferences();
            }
            this._unload();
            this._mc = null;
            doneFn();
         }
      }
      
      protected function _createReferences() : void
      {
      }
      
      protected function _disposeOfReferences() : void
      {
      }
   }
}
