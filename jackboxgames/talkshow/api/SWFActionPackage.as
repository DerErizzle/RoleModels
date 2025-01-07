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
   import jackboxgames.localizy.LocalizedTextFieldManager;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.utils.ConfigInfo;
   import jackboxgames.userinput.ButtonCalloutManager;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.Nullable;
   
   public class SWFActionPackage implements IActionPackage
   {
      protected var _apRef:IActionPackageRef;
      
      protected var _loaded:Boolean;
      
      protected var _loader:Loader;
      
      protected var _loadCanceler:Function;
      
      protected var _mc:MovieClip;
      
      protected var _ts:IEngineAPI;
      
      protected var _init:Boolean;
      
      public function SWFActionPackage(apRef:IActionPackageRef)
      {
         super();
         this._apRef = apRef;
         this._init = false;
         this._loadCanceler = Nullable.NULL_FUNCTION;
      }
      
      protected function get _sourceURL() : String
      {
         return this._apRef.getExport().configInfo.getValue(ConfigInfo.ACTION_PATH) + this._apRef.id + ".swf";
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
         return this._loaded;
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
         var url:String = this._sourceURL;
         if(!url)
         {
            this._loaded = true;
            doneFn();
            return;
         }
         if(BuildConfig.instance.hasConfigVal("swfRoot"))
         {
            url = BuildConfig.instance.configVal("swfRoot") + "/" + url;
         }
         this._loader = new Loader();
         this._loaded = true;
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,onLoadError);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         this._loadCanceler = function():void
         {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
            _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.NETWORK_ERROR,onLoadError);
            _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
         };
         context = new LoaderContext();
         context.checkPolicyFile = true;
         context.applicationDomain = ApplicationDomain.currentDomain;
         this._loader.load(new URLRequest(url),context);
      }
      
      private function _unload() : void
      {
         this._loaded = false;
         this._loadCanceler();
         this._loadCanceler = Nullable.NULL_FUNCTION;
         if(Boolean(this._loader))
         {
            this._loader.unloadAndStop(true);
            this._loader = null;
         }
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
               _loadExtraResources(function():void
               {
                  _createReferences();
                  LocalizedTextFieldManager.instance.addFromRoot(_mc);
                  ButtonCalloutManager.instance.addFromRoot(_mc);
                  doneFn();
               });
            });
         }
         else
         {
            this._unloadExtraResources(function():void
            {
               if(Boolean(_mc))
               {
                  _disposeOfReferences();
               }
               _unload();
               _mc = null;
               doneFn();
            });
         }
      }
      
      protected function _loadExtraResources(doneFn:Function) : void
      {
         doneFn();
      }
      
      protected function _unloadExtraResources(doneFn:Function) : void
      {
         doneFn();
      }
      
      protected function _createReferences() : void
      {
      }
      
      protected function _disposeOfReferences() : void
      {
      }
   }
}

