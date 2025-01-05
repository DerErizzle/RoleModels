package jackboxgames.talkshow.export
{
   import flash.display.Loader;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.IAction;
   import jackboxgames.talkshow.api.IActionPackageRef;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IConfigInfo;
   import jackboxgames.talkshow.api.IExport;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.IMedia;
   import jackboxgames.talkshow.api.ITemplate;
   import jackboxgames.talkshow.api.QualifiedID;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.events.ExportEvent;
   import jackboxgames.talkshow.media.AbstractMedia;
   import jackboxgames.talkshow.utils.ConfigInfo;
   import jackboxgames.talkshow.utils.ExportDictionary;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.TraceUtil;
   
   public class Export extends PausableEventDispatcher implements IExport
   {
      
      private static const DELIMITER:String = "^";
      
      private static const DELIMITER_DATA:String = "|";
      
      private static const INTERNAL_ACTION_ID_MAX:int = 999;
       
      
      protected var _config:ConfigInfo;
      
      protected var _id:String;
      
      protected var _startCellId:uint;
      
      protected var _startFlowchartId:uint;
      
      protected var _workspaceName:String;
      
      protected var _projectName:String;
      
      protected var _timeStamp:Number;
      
      protected var _flowcharts:Object;
      
      protected var _media:Object;
      
      protected var _actions:Object;
      
      protected var _templates:Object;
      
      protected var _actionPackages:Object;
      
      protected var _projects:Object;
      
      protected var _mediaLoaded:Object;
      
      protected var _loadStatus:int;
      
      protected var _startFileLoaded:Boolean;
      
      protected var _firstFlowLoaded:Boolean;
      
      protected var _startLoader:Loader;
      
      protected var _flowchartLoader:Loader;
      
      private var _jump:Object;
      
      protected var _internalCodeSpace:CodeSpace;
      
      public function Export(id:String, cfg:ConfigInfo)
      {
         super();
         if(cfg != null)
         {
            this._id = id;
            this._config = cfg;
            this._startFileLoaded = false;
            this._firstFlowLoaded = false;
            this._loadStatus = LoadStatus.STATUS_NONE;
            this.setupContainers();
            this.setupStartLoader();
            return;
         }
         throw new ArgumentError("param cfg must be a valid instance of ConfigInfo, not null");
      }
      
      public static function createIDFromPath(path:String) : String
      {
         path = path.replace("(\\\\|\\/)","_");
         path = path.replace("[^\\w\\$]","");
         return "$" + path;
      }
      
      public function addMedia(media:IMedia) : void
      {
         this._media["m" + media.id] = media;
      }
      
      public function onMediaLoaded(media:IMedia, fl:IFlowchart) : void
      {
         var key:String = fl == null ? "Start" : "F" + fl.id;
         if(!this._mediaLoaded.hasOwnProperty(key))
         {
            this._mediaLoaded[key] = [];
         }
         this._mediaLoaded[key].push(media);
      }
      
      public function getLoadedMedia() : Array
      {
         var key:String = null;
         var loadedMedia:Array = [];
         for(key in this._mediaLoaded)
         {
            loadedMedia = loadedMedia.concat(this._mediaLoaded[key]);
         }
         return loadedMedia;
      }
      
      public function mediaWasLoadedByFlowchart(m:AbstractMedia, fl:IFlowchart) : Boolean
      {
         var key:String = "F" + fl.id;
         return this._mediaLoaded.hasOwnProperty(key) && this._mediaLoaded[key].indexOf(m) >= 0;
      }
      
      public function unloadMedia(m:AbstractMedia) : void
      {
         var key:String = null;
         for(key in this._mediaLoaded)
         {
            this._mediaLoaded[key] = this._mediaLoaded[key].filter(function(otherM:AbstractMedia, ... args):Boolean
            {
               return m != otherM;
            });
         }
         m.unloadAllVersions();
      }
      
      public function unloadAllMedia() : void
      {
         var key:String = null;
         var i:int = 0;
         var m:AbstractMedia = null;
         for(key in this._mediaLoaded)
         {
            Logger.debug("Export::unloadAllMedia () for \"" + key + "\"");
            for(i = 0; i < this._mediaLoaded[key].length; i++)
            {
               m = AbstractMedia(this._mediaLoaded[key][i]);
               Logger.debug("Export::unloadAllMedia () _mediaLoaded[\"" + key + "\"][" + i + "] = " + m.type + ": " + m.id);
               if(m.type != "text")
               {
                  m.unloadAllVersions();
               }
            }
            this._mediaLoaded[key] = [];
         }
      }
      
      public function filterAllMediaForLocale(newLocale:String) : void
      {
         var key:String = null;
         for(key in this._media)
         {
            AbstractMedia(this._media[key]).filterVersionsForLocale(newLocale);
         }
      }
      
      public function addProject(project:Project) : void
      {
         this._projects[Project.createID(project.getId())] = project;
      }
      
      public function addAction(action:IAction) : void
      {
         this._actions["a" + (action.id < 0 ? "_" + Math.abs(action.id) : action.id)] = action;
      }
      
      public function addActionPackage(pkg:IActionPackageRef, projectId:int) : void
      {
         if(pkg.id > INTERNAL_ACTION_ID_MAX)
         {
            this._actionPackages["p" + pkg.id] = pkg;
            this.getProject(projectId).addActionPackage(pkg);
         }
      }
      
      public function addTemplate(tpl:ITemplate, projectId:int) : void
      {
         this._templates["t" + tpl.id] = tpl;
      }
      
      public function reset() : void
      {
         this.setupContainers();
      }
      
      public function load(data:ILoadData = null) : void
      {
         if(this._loadStatus == LoadStatus.STATUS_NONE)
         {
            this._loadStatus = LoadStatus.STATUS_LOADING;
            this._startLoader.addEventListener(IOErrorEvent.IO_ERROR,function(evt:IOErrorEvent):void
            {
               Logger.debug(TraceUtil.objectRecursive(evt,"Event"));
            });
            this._startLoader.load(new URLRequest(this._config.getValue(ConfigInfo.START_FILE)));
         }
      }
      
      public function isLoaded() : Boolean
      {
         return this._startFileLoaded && this._firstFlowLoaded;
      }
      
      public function get loadStatus() : int
      {
         return this._loadStatus;
      }
      
      public function createFlowchart(f:String, dict:ExportDictionary) : IFlowchart
      {
         var fobj:Flowchart = null;
         var data:Array = f.split(DELIMITER_DATA);
         var id:String = Flowchart.createID(data[0]);
         if(this.getFlowchart(id) != null)
         {
            return null;
         }
         if(data[2] == 1)
         {
            fobj = new Subroutine(this,data[0],this._config,dict.lookup(data[1]),data[3]);
         }
         else
         {
            fobj = new Flowchart(this,data[0],this._config,dict.lookup(data[1]),data[3]);
         }
         this._flowcharts[id] = fobj;
         this.registerFlowchartLoadListeners(fobj);
         this.getProject(data[3]).addFlowchart(fobj);
         return fobj;
      }
      
      public function getFlowchart(id:*) : IFlowchart
      {
         var f:Flowchart = null;
         if(id is String)
         {
            f = this._flowcharts[id as String];
         }
         else if(id is uint)
         {
            f = this._flowcharts[Flowchart.createID(id as uint)];
         }
         return f;
      }
      
      public function getFlowchartByPath(path:String) : IFlowchart
      {
         var items:Array = path.split(":");
         if(items.length < 2)
         {
            return null;
         }
         var prj:Project = this.getProjectByName(items[0]);
         if(prj == null)
         {
            return null;
         }
         return prj.getFlowchart(items[1]);
      }
      
      public function get workspaceName() : String
      {
         return this._workspaceName;
      }
      
      public function get projectName() : String
      {
         return this._projectName;
      }
      
      public function get timeStamp() : Number
      {
         return this._timeStamp;
      }
      
      public function getMedia(id:int) : IMedia
      {
         return this._media["m" + id];
      }
      
      public function getAction(id:int) : IAction
      {
         return this._actions["a" + (id < 0 ? "_" + Math.abs(id) : id)];
      }
      
      public function getAllProjects() : Array
      {
         var p:Object = null;
         var projects:Array = [];
         for each(p in this._projects)
         {
            projects.push(p);
         }
         return projects;
      }
      
      public function getProject(id:int) : Project
      {
         return this._projects[Project.createID(id)];
      }
      
      internal function getProjectByName(name:String) : Project
      {
         var p:Object = null;
         var proj:Project = null;
         for each(p in this._projects)
         {
            proj = p as Project;
            if(proj.getName() == name)
            {
               return proj;
            }
         }
         return null;
      }
      
      public function getActionPackage(id:*) : IActionPackageRef
      {
         if(id as int <= INTERNAL_ACTION_ID_MAX)
         {
            return PlaybackEngine.getInstance().internalActionPackage;
         }
         return this._actionPackages["p" + id];
      }
      
      public function getActionPackageByPath(path:String) : IActionPackageRef
      {
         var items:Array = path.split(":");
         var prj:Project = items.length == 2 ? this.getProjectByName(items[0]) : null;
         if(prj == null)
         {
            return null;
         }
         return prj.getActionPackage(items.length == 2 ? String(items[1]) : String(items[0]));
      }
      
      public function getTemplate(id:*) : ITemplate
      {
         return this._templates["t" + id];
      }
      
      public function getTemplateByName(name:String) : ITemplate
      {
         var t:ITemplate = null;
         for each(t in this._templates)
         {
            if(t.name == name)
            {
               return t;
            }
         }
         return null;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get configInfo() : IConfigInfo
      {
         return this._config;
      }
      
      public function get startCellID() : uint
      {
         return this._startCellId;
      }
      
      public function get startFlowchartID() : uint
      {
         return this._startFlowchartId;
      }
      
      public function getStartCell() : ICell
      {
         return this.getFlowchart(this._startFlowchartId).getCellByID(this._startCellId);
      }
      
      public function setJump(jump:Object) : void
      {
         this._jump = jump;
      }
      
      public function onReturnFromFlowchart(f:IFlowchart) : void
      {
      }
      
      public function destroy() : void
      {
         var flId:String = null;
         var i:int = 0;
         var m:AbstractMedia = null;
         for(flId in this._mediaLoaded)
         {
            for(i = 0; i < this._mediaLoaded[flId].length; i++)
            {
               m = AbstractMedia(this._mediaLoaded[flId][i]);
               m.unloadAllVersions();
            }
            this._mediaLoaded[flId] = [];
         }
         this.reset();
      }
      
      public function get g() : Object
      {
         return null;
      }
      
      public function get l() : Object
      {
         return null;
      }
      
      protected function setupContainers() : void
      {
         this._flowcharts = new Object();
         this._media = new Object();
         this._actions = new Object();
         this._projects = new Object();
         this._actionPackages = new Object();
         this._templates = new Object();
         this._internalCodeSpace = new CodeSpace();
         this._mediaLoaded = new Object();
      }
      
      protected function setupStartLoader() : void
      {
         this._startLoader = new Loader();
         this._startLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.exportLoadHandler);
         this._startLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.exportProgressHandler);
         this._startLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.exportIOErrorHandler);
         PlaybackEngine.getInstance().loadMonitor.registerItem(this._startLoader.contentLoaderInfo);
      }
      
      protected function disposeStartLoader() : void
      {
         this._startLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.exportLoadHandler);
         this._startLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.exportProgressHandler);
         this._startLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.exportIOErrorHandler);
         this._startLoader = null;
      }
      
      protected function registerFlowchartLoadListeners(f:Flowchart) : void
      {
         f.addEventListener(ExportEvent.FLOWCHART_LOADED,this.flowchartLoadHandler);
         f.addEventListener(ExportEvent.FLOWCHART_PROGRESS,this.flowchartProgressHandler);
         f.addEventListener(ExportEvent.FLOWCHART_ERROR,this.flowchartIOErrorHandler);
      }
      
      protected function unregisterFlowchartLoadListeners(fcid:uint) : void
      {
         var f:Flowchart = this._flowcharts[Flowchart.createID(fcid)];
         if(f != null)
         {
            f.removeEventListener(ExportEvent.FLOWCHART_LOADED,this.flowchartLoadHandler);
            f.removeEventListener(ExportEvent.FLOWCHART_PROGRESS,this.flowchartProgressHandler);
            f.removeEventListener(ExportEvent.FLOWCHART_ERROR,this.flowchartIOErrorHandler);
            return;
         }
         throw new IllegalOperationError("could not resolve flowchart with id: " + fcid);
      }
      
      protected function registerFlowchartEventListeners(f:Flowchart) : void
      {
      }
      
      protected function unregisterFlowchartEventListeners(fcid:uint) : void
      {
      }
      
      protected function parseStartData(startData:Object) : void
      {
         var p:String = null;
         var flowcharts:Array = null;
         var f:String = null;
         var fc:IFlowchart = null;
         var data:Array = null;
         var fobj:IFlowchart = null;
         if(this._jump != null && this._jump.c && Boolean(this._jump.f))
         {
            this._startCellId = this._jump.c;
            this._startFlowchartId = this._jump.f;
            this._jump = null;
         }
         else
         {
            this._startCellId = startData.c;
            this._startFlowchartId = startData.f;
         }
         var dict:ExportDictionary = new ExportDictionary(startData.dict);
         this._workspaceName = dict.lookup(int(startData.w));
         this._projectName = dict.lookup(int(startData.p));
         this._timeStamp = Number(startData.timeStamp);
         if(startData.media != null && (startData.media as String).length > 0)
         {
            MediaFactory.buildMedia(this,startData.media,dict,null);
         }
         Logger.debug("Export::parseStartData ()");
         Logger.debug("projects = " + startData.projects);
         var projects:Array = startData.projects.split(DELIMITER);
         for each(p in projects)
         {
            data = p.split(DELIMITER_DATA);
            this.addProject(new Project(this,int(data[0]),dict.lookup(uint(data[1]))));
         }
         Logger.debug("flowcharts = " + startData.flowcharts);
         flowcharts = startData.flowcharts.split(DELIMITER);
         for each(f in flowcharts)
         {
            fobj = this.createFlowchart(f,dict);
         }
         Logger.debug("packages = " + startData.packages);
         ActionFactory.buildActions(this,startData.packages,startData.actions,dict);
         Logger.debug("actions = " + startData.actions);
         Logger.debug("templates = " + startData.templates);
         TemplateFactory.buildTemplates(this,startData.templates,dict);
         fc = this.getFlowchart(this._startFlowchartId);
         fc.load();
         this.disposeStartLoader();
         this._startFileLoaded = true;
         this._loadStatus = LoadStatus.STATUS_INVALIDATED;
         dispatchEvent(new ExportEvent(ExportEvent.STARTFILE_LOADED,new QualifiedID(this._id),"Start File Loaded"));
      }
      
      protected function exportLoadHandler(e:Event) : void
      {
         this.parseStartData(e.target.content);
      }
      
      protected function exportProgressHandler(e:ProgressEvent) : void
      {
         dispatchEvent(new ExportEvent(ExportEvent.STARTFILE_PROGRESS,new QualifiedID(this._id),"Start File Progress",{
            "bytesLoaded":e.bytesLoaded,
            "bytesTotal":e.bytesTotal
         }));
      }
      
      protected function exportIOErrorHandler(e:IOErrorEvent) : void
      {
         this._loadStatus = LoadStatus.STATUS_FAILED;
         this.disposeStartLoader();
         dispatchEvent(new ExportEvent(ExportEvent.STARTFILE_ERROR,new QualifiedID(this._id),"Start File IO error"));
      }
      
      protected function flowchartLoadHandler(e:ExportEvent) : void
      {
         Logger.debug("Export loaded..." + e.target);
         this.unregisterFlowchartLoadListeners(Flowchart(e.target).id);
         this.registerFlowchartEventListeners(e.target as Flowchart);
         if(Flowchart(e.target).id == this._startFlowchartId)
         {
            this._firstFlowLoaded = true;
            if(this._startFileLoaded)
            {
               this._loadStatus = LoadStatus.STATUS_LOADED;
            }
            dispatchEvent(new ExportEvent(ExportEvent.STARTFLOWCHART_LOADED,e.id,"Start Flowchart File Ready",e.data));
         }
         else
         {
            dispatchEvent(e);
         }
      }
      
      protected function flowchartProgressHandler(e:ExportEvent) : void
      {
         if(Flowchart(e.target).id == this._startFlowchartId)
         {
            dispatchEvent(new ExportEvent(ExportEvent.STARTFLOWCHART_PROGRESS,e.id,"Start Flowchart Progress",e.data));
         }
         else
         {
            dispatchEvent(e);
         }
      }
      
      protected function flowchartIOErrorHandler(e:ExportEvent) : void
      {
         this.unregisterFlowchartLoadListeners(Flowchart(e.target).id);
         if(Flowchart(e.target).id == this._startFlowchartId)
         {
            this._loadStatus = LoadStatus.STATUS_FAILED;
            dispatchEvent(new ExportEvent(ExportEvent.STARTFLOWCHART_ERROR,e.id,"Start Flowchart File IO Error",e.data));
         }
         else
         {
            dispatchEvent(e);
         }
      }
   }
}
