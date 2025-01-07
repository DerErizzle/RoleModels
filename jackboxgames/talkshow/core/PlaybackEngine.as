package jackboxgames.talkshow.core
{
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import jackboxgames.logger.LocalConnectionTarget;
   import jackboxgames.logger.Logger;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.talkshow.actions.ActionPackageRef;
   import jackboxgames.talkshow.actions.ActionRef;
   import jackboxgames.talkshow.actions.InternalActionPackage;
   import jackboxgames.talkshow.actions.ScreenManager;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.cells.LoadData;
   import jackboxgames.talkshow.debug.Debugger;
   import jackboxgames.talkshow.display.Canvas;
   import jackboxgames.talkshow.events.ExportEvent;
   import jackboxgames.talkshow.export.Export;
   import jackboxgames.talkshow.timing.TimingManager;
   import jackboxgames.talkshow.utils.ConfigInfo;
   import jackboxgames.talkshow.utils.LoadMonitor;
   import jackboxgames.talkshow.utils.VariableUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class PlaybackEngine extends PausableEventDispatcher implements IEngineAPI
   {
      private namespace engine_private;
      
      private static var _instance:PlaybackEngine;
      
      private static const INSTANCE_ERROR_MSG:String = "class PlaybackEngine is a singleton.  new instances may not be created using the \'new\' keyword";
      
      private static var _authorizedClassList:Array = [ExportManager,Export];
      
      private var _createTime:uint;
      
      private var _container:Sprite;
      
      private var _videos:ICanvas;
      
      private var _overlay:ICanvas;
      
      private var _foreground:ICanvas;
      
      private var _background:ICanvas;
      
      private var _init:Boolean;
      
      private var _configInfo:ConfigInfo;
      
      private var _exports:ExportManager;
      
      private var _loadMonitor:LoadMonitor;
      
      private var _pauser:PauseManager;
      
      private var _pluginManager:PluginManager;
      
      private var _timing:TimingManager;
      
      private var _inputManager:InputManager;
      
      private var _callStack:CallStack;
      
      private var _screenManager:ScreenManager;
      
      private var _g:Object;
      
      private var _l:Object;
      
      private var _plugins:Object;
      
      private var _defaultL:Object;
      
      private var _internalActionPackage:ActionPackageRef;
      
      private var _preloadManager:PreloadManager;
      
      private var _startNextManager:StartNextActionManager;
      
      private var _locale:String;
      
      private var _lcLogTarget:LocalConnectionTarget;
      
      private var _debugger:Debugger;
      
      private var _inputDelay:uint;
      
      public function PlaybackEngine(e:_enforcer_)
      {
         super();
         if(e == null || !(e is _enforcer_))
         {
            throw new IllegalOperationError(INSTANCE_ERROR_MSG);
         }
         this._init = false;
         this._createTime = Platform.instance.getTimer();
         this.buildObjects();
      }
      
      public static function addAuthorizedClass(c:Class) : void
      {
         _authorizedClassList.push(c);
      }
      
      public static function getInstance() : PlaybackEngine
      {
         if(_instance == null)
         {
            _instance = new PlaybackEngine(new _enforcer_());
            _instance._container = null;
         }
         return _instance;
      }
      
      public function getPrivateNamespace(requester:Object) : Namespace
      {
         var auth:Class = null;
         for each(auth in _authorizedClassList)
         {
            if(requester is auth)
            {
               return engine_private;
            }
         }
         return null;
      }
      
      public function jumpToCell(path:String) : void
      {
         var jumpFunction:Function = function(c:ICell):void
         {
            Logger.info("JUMP TO CELL: cell=" + c,"Engine");
            _startNextManager.reset();
            dispatchEvent(new CellEvent(CellEvent.CELL_JUMPED,c));
            c.start();
         };
         dispatchEvent(new CellEvent(CellEvent.CELL_JUMP,null));
         this.cellAction(path,"Jump To Cell",jumpFunction);
      }
      
      public function loadCell(path:String) : void
      {
         var loadFunction:Function = function(c:ICell):void
         {
            Logger.debug("Manually loading cell: " + c,"Load");
            c.load(new LoadData(1));
         };
         this.cellAction(path,"Load Cell",loadFunction);
      }
      
      public function getActionPackage(path:String) : Object
      {
         return this._exports.activeExport.getActionPackageByPath(path);
      }
      
      public function registerPlugin(id:String, plugin:Object) : void
      {
         if(plugin == null)
         {
            return;
         }
         if(this._plugins[id] != null)
         {
            Logger.error("Can\'t register plugin: " + id + " - a plugin with that id is already registered");
            return;
         }
         this._plugins[id] = plugin;
         if(plugin.hasOwnProperty("init"))
         {
            try
            {
               plugin.init(this);
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function getPlugin(id:String) : Object
      {
         return this._plugins[id];
      }
      
      public function unregisterPlugin(id:String) : void
      {
         if(this._plugins[id] == null)
         {
            return;
         }
         var plugin:Object = this._plugins[id];
         if(plugin.hasOwnProperty("dispose"))
         {
            try
            {
               plugin.dispose(this);
            }
            catch(e:Error)
            {
            }
         }
         delete this._plugins[id];
      }
      
      public function get flashVars() : Object
      {
         if(this._configInfo == null)
         {
            return {};
         }
         return this._configInfo.flashVars;
      }
      
      private function cellAction(path:String, name:String, action:Function) : void
      {
         var pathParts:Array;
         var cell:String = null;
         var f:IFlowchart = null;
         var c:ICell = null;
         var callback:Function = null;
         Logger.info("Perform cell action: " + name + ": " + path,"Engine");
         pathParts = path.split(":");
         cell = pathParts.pop();
         f = null;
         if(pathParts.length > 0)
         {
            f = this._exports.activeExport.getFlowchartByPath(pathParts.join(":"));
         }
         if(f == null)
         {
            Logger.error(name + ": Invalid flowchart path: " + path);
            return;
         }
         if(f.isLoaded())
         {
            c = f.getCell(cell);
            if(c == null)
            {
               Logger.error(name + ": Invalid cell " + path);
            }
            else
            {
               action(c);
            }
         }
         else
         {
            callback = function(e:ExportEvent):void
            {
               var c:ICell = null;
               if(f.qualifiedID.value == e.id.value)
               {
                  f.removeEventListener(ExportEvent.FLOWCHART_LOADED,callback);
                  f.removeEventListener(ExportEvent.FLOWCHART_ERROR,callback);
                  switch(e.type)
                  {
                     case ExportEvent.FLOWCHART_ERROR:
                        Logger.error(name + " Failed.  Couldn\'t load flowchart: " + path);
                        break;
                     case ExportEvent.FLOWCHART_LOADED:
                        c = f.getCell(cell);
                        if(c == null)
                        {
                           Logger.error(name + ": Invalid cell " + path);
                        }
                        else
                        {
                           action(c);
                        }
                  }
               }
            };
            f.addEventListener(ExportEvent.FLOWCHART_LOADED,callback,false,0,true);
            f.addEventListener(ExportEvent.FLOWCHART_ERROR,callback,false,0,true);
            f.load(new LoadData(1));
         }
      }
      
      public function ignitionOn(con:Sprite, cfg:ConfigInfo) : void
      {
         var pluginList:Array = null;
         var plugin:String = null;
         var e:Export = null;
         if(!this._init)
         {
            Logger.info("Engine: initializing engine config data");
            if(this._preloadManager != null)
            {
               this._loadMonitor.addLoadedBytes(this._preloadManager.engineBytes);
            }
            this._container = con;
            this._foreground = new Canvas();
            this._background = new Canvas();
            this._overlay = new Canvas();
            this._videos = new Canvas();
            this._screenManager = new ScreenManager();
            this._foreground.addChild(this._screenManager);
            this._container.addChild(this._background as Sprite);
            this._container.addChild(this._foreground as Sprite);
            this._container.addChild(this._overlay as Sprite);
            this._container.addChild(this._videos as Sprite);
            this._configInfo = cfg;
            this._debugger = new Debugger(this);
            this.registerPlugin("debugger",this._debugger);
            this._loadMonitor.purge();
            pluginList = ["ui"];
            this._pluginManager = new PluginManager(this);
            for each(plugin in pluginList)
            {
               this._pluginManager.loadPlugin(plugin);
            }
            this._pauser = new PauseManager(this);
            this._timing = new TimingManager();
            this._inputManager = new InputManager(this);
            dispatchEvent(new Event(Constants.EVENT_ENGINE_LOADED));
            this._exports = new ExportManager(this._configInfo,this._container);
            e = this._exports.addExport(this._configInfo);
            this._exports.setActiveExport(e.id);
            e.setJump({
               "c":this._configInfo.flashVars.jumpCell,
               "f":this._configInfo.flashVars.jumpFlowchart
            });
            e.load();
            this._init = true;
         }
      }
      
      public function ignitionOff() : void
      {
         this.unregisterPlugin("debugger");
      }
      
      public function resetContainers() : void
      {
         this._container.removeChild(this._videos as Sprite);
         this._container.removeChild(this._overlay as Sprite);
         this._container.removeChild(this._foreground as Sprite);
         this._container.removeChild(this._background as Sprite);
         this._foreground = new Canvas();
         this._background = new Canvas();
         this._overlay = new Canvas();
         this._videos = new Canvas();
         this._container.addChild(this._background as Sprite);
         this._container.addChild(this._foreground as Sprite);
         this._container.addChild(this._overlay as Sprite);
         this._container.addChild(this._videos as Sprite);
      }
      
      public function play() : void
      {
         var c:ICell = this._exports.activeExport.getStartCell();
         if(Boolean(c))
         {
            this.dispatchEvent(new Event(Constants.EVENT_BEGIN));
            c.start();
         }
      }
      
      public function exportStartFileLoadHandler(e:ExportEvent) : void
      {
         this._exports.unregisterExportLoadListeners(e.id.value);
      }
      
      public function exportStartFileProgressHandler(e:ExportEvent) : void
      {
         this._preloadManager.startLoad(e.data.bytesLoaded,e.data.bytesTotal);
      }
      
      public function exportStartFileErrorHandler(e:ExportEvent) : void
      {
         this._exports.unregisterExportLoadListeners(e.id.value);
      }
      
      public function exportFlowchartLoadHandler(e:ExportEvent) : void
      {
         var eid:String = e.id.eID;
         if(e.type == ExportEvent.STARTFLOWCHART_LOADED)
         {
            this._exports.unregisterStartFlowchartEventListeners(eid);
            this._loadMonitor.addEventListener(Event.COMPLETE,this.preloadMediaCompleteHandler);
            this._loadMonitor.addEventListener(ProgressEvent.PROGRESS,this.preloadMediaProgressHandler);
            this._exports.getExportByID(eid).getStartCell().load(new LoadData(LoadData.DEFAULT_LOAD_DEPTH));
         }
      }
      
      public function exportFlowchartProgressHandler(e:ExportEvent) : void
      {
         if(e.type == ExportEvent.STARTFLOWCHART_PROGRESS)
         {
            this._preloadManager.flowchartLoad(e.data.bytesLoaded,e.data.bytesTotal);
         }
      }
      
      public function exportFlowchartErrorHandler(e:ExportEvent) : void
      {
         Logger.error("Engine: ExportEvent-> fcid: " + e.id.fcFileID + " msg: " + e.msg);
         var eid:String = e.id.eID;
         if(e.type == ExportEvent.STARTFLOWCHART_LOADED)
         {
            this._exports.unregisterStartFlowchartEventListeners(eid);
         }
      }
      
      public function preloadMediaProgressHandler(e:ProgressEvent) : void
      {
         this._preloadManager.mediaLoad(e.bytesLoaded / e.bytesTotal);
      }
      
      public function preloadMediaCompleteHandler(e:Event) : void
      {
         this._preloadManager.mediaLoad(1);
         Logger.info("Preload media complete");
         dispatchEvent(new Event(Constants.EVENT_MEDIA_LOADED));
         this._loadMonitor.removeEventListener(Event.COMPLETE,this.preloadMediaCompleteHandler);
         this._loadMonitor.removeEventListener(ProgressEvent.PROGRESS,this.preloadMediaProgressHandler);
         this.play();
      }
      
      private function buildObjects() : void
      {
         this._lcLogTarget = new LocalConnectionTarget("_talkshow");
         this._loadMonitor = new LoadMonitor();
         this._callStack = new CallStack(this);
         this._plugins = new Object();
         this._startNextManager = new StartNextActionManager(this);
         this._g = new Object();
         this._defaultL = new Object();
         this._l = this._defaultL;
         this._internalActionPackage = this.buildInternalActionPackage();
      }
      
      internal function setLocalVariableObject(obj:Object) : void
      {
         if(obj == null)
         {
            this._l = this._defaultL;
         }
         else
         {
            this._l = obj;
         }
      }
      
      private function buildInternalActionPackage() : ActionPackageRef
      {
         var apr:ActionPackageRef = new ActionPackageRef(ActionPackageType.TYPE_INTERNAL,-1,"Internal");
         apr.setPackage(new InternalActionPackage());
         return apr;
      }
      
      internal function setPreloadManager(preloadManager:PreloadManager) : void
      {
         this._preloadManager = preloadManager;
      }
      
      override public function toString() : String
      {
         return "PlaybackEngine - uptime: " + this.uptime * 0.001 + "s";
      }
      
      public function get uptime() : uint
      {
         if(this._createTime != 0)
         {
            return Platform.instance.getTimer() - this._createTime;
         }
         return 0;
      }
      
      public function get container() : Sprite
      {
         return this._container;
      }
      
      public function get foreground() : ICanvas
      {
         return this._foreground;
      }
      
      public function get background() : ICanvas
      {
         return this._background;
      }
      
      public function get overlay() : ICanvas
      {
         return this._overlay;
      }
      
      public function get videos() : ICanvas
      {
         return this._videos;
      }
      
      public function get screenManager() : IScreenManager
      {
         return this._screenManager;
      }
      
      public function get g() : Object
      {
         return this._g;
      }
      
      public function get l() : Object
      {
         return this._l;
      }
      
      public function get locale() : String
      {
         return this._locale;
      }
      
      public function set locale(value:String) : void
      {
         if(this._locale == value)
         {
            return;
         }
         this._locale = value;
         if(this._exports == null)
         {
            return;
         }
         this.activeExport.filterAllMediaForLocale(this._locale);
      }
      
      public function getConfigInfo() : IConfigInfo
      {
         return this._configInfo;
      }
      
      public function get scriptBase() : String
      {
         if(this._configInfo != null)
         {
            return this._configInfo.getValue(ConfigInfo.SCRIPT_BASE);
         }
         return "";
      }
      
      public function input(value:String, raw:* = null) : void
      {
         this._inputManager.handleInput(value,raw);
      }
      
      public function setVariableValue(variable:String, value:*) : void
      {
         VariableUtil.setVariableValue(variable,value);
      }
      
      public function addExport(ex:ConfigInfo) : IExport
      {
         var handle:IExport = null;
         try
         {
            handle = this._exports.addExport(ex);
         }
         catch(e:IllegalOperationError)
         {
            return null;
         }
         return handle;
      }
      
      public function get pauser() : IPauseManager
      {
         return this._pauser;
      }
      
      public function get internalActionPackage() : IActionPackageRef
      {
         return this._internalActionPackage;
      }
      
      public function loadPause(caller:Object, objToLoad:ILoadable = null) : void
      {
         Logger.warning("PlaybackEngine -> loadPause requested by: " + caller,"Pause");
         this._pauser.loadPause();
      }
      
      public function loadResume(caller:Object) : void
      {
         Logger.warning("PlaybackEngine -> loadResume requested by: " + caller,"Pause");
         this._pauser.loadResume();
      }
      
      public function get loadMonitor() : Object
      {
         return this._loadMonitor;
      }
      
      public function get preloadManager() : Object
      {
         return this._preloadManager;
      }
      
      public function stopAllActions() : void
      {
         this._timing.clear();
         this._init = false;
         if(this._container != null)
         {
            this._container.removeChild(this._videos as Sprite);
            this._container.removeChild(this._overlay as Sprite);
            this._container.removeChild(this._foreground as Sprite);
            this._container.removeChild(this._background as Sprite);
         }
         this._startNextManager.reset();
      }
      
      public function get callStack() : CallStack
      {
         return this._callStack;
      }
      
      public function get activeExport() : IExport
      {
         return this._exports.activeExport;
      }
      
      public function queueActions(refs:Array, start:Boolean, primary:ActionRef = null) : void
      {
         this._timing.queueActionRefs(refs,start,primary);
      }
      
      internal function get timingManager() : TimingManager
      {
         return this._timing;
      }
      
      public function get inputManager() : InputManager
      {
         return this._inputManager;
      }
      
      public function get startNextManager() : StartNextActionManager
      {
         return this._startNextManager;
      }
   }
}

final class _enforcer_
{
   public function _enforcer_()
   {
      super();
   }
}

