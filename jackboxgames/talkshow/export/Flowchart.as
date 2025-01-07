package jackboxgames.talkshow.export
{
   internal class Flowchart extends PausableEventDispatcher implements IFlowchart
   {
      protected var _cells:Object;
      
      protected var _cellNames:Object;
      
      protected var _loadStatus:int;
      
      protected var _id:uint;
      
      protected var _config:ConfigInfo;
      
      protected var _export:Export;
      
      protected var _code:Object;
      
      protected var _name:String;
      
      protected var _proj:int;
      
      protected var _qid:QualifiedID;
      
      protected var _fileLoader:Loader;
      
      private var _loadData:ILoadData;
      
      public function Flowchart(exp:Export, id:uint, cfg:ConfigInfo, name:String, pid:int)
      {
         super();
         if(exp != null && cfg != null)
         {
            this._id = id;
            this._config = cfg;
            this._export = exp;
            this._loadStatus = LoadStatus.STATUS_NONE;
            this._name = name;
            this._proj = pid;
            this.initObjects();
            return;
         }
         throw new ArgumentError("Export and ConfigInfo references must not be null");
      }
      
      public static function createID(internalID:uint) : String
      {
         return "F_" + internalID;
      }
      
      override public function toString() : String
      {
         return "[Flowchart id=" + this._id + " name=" + this._name + "]";
      }
      
      internal function addCell(cell:ICell) : void
      {
         this._cells["c" + cell.id] = cell;
         if(cell.target != null)
         {
            this._cellNames[cell.target] = cell;
         }
      }
      
      internal function getProjectId() : int
      {
         return this._proj;
      }
      
      protected function initObjects() : void
      {
         this._cells = new Object();
         this._cellNames = new Object();
      }
      
      protected function parseFlowchartData(data:Object) : void
      {
         var dict:ExportDictionary = new ExportDictionary(data.dict);
         if(data.media != null && (data.media as String).length > 0)
         {
            MediaFactory.buildMedia(this._export,data.media,dict,this);
         }
         this._code = data.getCode(PlaybackEngine.getInstance());
         this._name = data.fname;
         Logger.debug("Flowchart::parseFlowchartData (" + data.pname + "::" + this._name + ")");
         CellFactory.buildCells(this,data.cells,dict);
         this.parseAdditionalData(data,dict);
         this._loadStatus = LoadStatus.STATUS_LOADED;
         this.disposeFileLoader();
         dispatchEvent(new ExportEvent(ExportEvent.FLOWCHART_LOADED,this.qualifiedID,"Flowchart loaded and parsed",this._loadData));
      }
      
      protected function parseAdditionalData(data:Object, dict:ExportDictionary) : void
      {
      }
      
      protected function setupFileLoader() : void
      {
         this._fileLoader = new Loader();
         this._fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.fileLoadHandler);
         this._fileLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.fileProgressHandler);
         this._fileLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.fileIOErrorHandler);
         PlaybackEngine.getInstance().loadMonitor.registerItem(this._fileLoader.contentLoaderInfo);
      }
      
      protected function disposeFileLoader() : void
      {
         this._fileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.fileLoadHandler);
         this._fileLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.fileProgressHandler);
         this._fileLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.fileIOErrorHandler);
         this._fileLoader = null;
      }
      
      protected function fileLoadHandler(e:Event) : void
      {
         this.parseFlowchartData(this._fileLoader.content);
      }
      
      protected function fileProgressHandler(e:ProgressEvent) : void
      {
         dispatchEvent(new ExportEvent(ExportEvent.FLOWCHART_PROGRESS,this.qualifiedID,"Flowchart Progress",{
            "bytesLoaded":e.bytesLoaded,
            "bytesTotal":e.bytesTotal
         }));
      }
      
      protected function fileIOErrorHandler(e:IOErrorEvent) : void
      {
         Logger.error("Error Loading: " + this,"Load");
         this._loadStatus == LoadStatus.STATUS_FAILED;
         this.disposeFileLoader();
         dispatchEvent(new ExportEvent(ExportEvent.FLOWCHART_ERROR,this.qualifiedID,"Flowchart File Error"));
      }
      
      public function load(data:ILoadData = null) : void
      {
         if(this._loadStatus == LoadStatus.STATUS_NONE)
         {
            this.setupFileLoader();
            this._loadData = data;
            this._loadStatus = LoadStatus.STATUS_LOADING;
            this._fileLoader.addEventListener(IOErrorEvent.IO_ERROR,function(evt:IOErrorEvent):void
            {
               Logger.debug(TraceUtil.objectRecursive(evt,"Event"));
            });
            this._fileLoader.load(new URLRequest(this._config.getValue(ConfigInfo.DATA_PATH) + this.fileName));
            Logger.debug("Flowchart::load (" + this.fileName + ")");
         }
      }
      
      public function isLoaded() : Boolean
      {
         return this._loadStatus == LoadStatus.STATUS_LOADED;
      }
      
      public function get loadStatus() : int
      {
         return this._loadStatus;
      }
      
      public function getParentExport() : IExport
      {
         return this._export;
      }
      
      public function get qualifiedID() : QualifiedID
      {
         if(this._qid == null)
         {
            this._qid = new QualifiedID(this._export.id,this.fileID,this.id);
         }
         return this._qid;
      }
      
      public function get fileName() : String
      {
         return this.fileID + ".swf";
      }
      
      public function get fileID() : String
      {
         return createID(this._id);
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get flowchartName() : String
      {
         return this._name;
      }
      
      public function getCell(name:String) : ICell
      {
         if(isNaN(Number(name)))
         {
            return this._cellNames[name];
         }
         return this._cells["c" + name];
      }
      
      public function getCellByID(id:uint) : ICell
      {
         return this._cells["c" + id];
      }
      
      public function evalCell(id:uint) : void
      {
         try
         {
            this._code["C_" + id]();
         }
         catch(error:Error)
         {
            Logger.warning("Error evaluating code cell:" + id + " error=" + error,"Code");
         }
      }
      
      public function evalBranch(id:uint, branch:uint, value:*) : Boolean
      {
         return this._code["B_" + id + "_" + branch](value);
      }
   }
}

