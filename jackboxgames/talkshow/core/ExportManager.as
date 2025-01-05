package jackboxgames.talkshow.core
{
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import jackboxgames.talkshow.events.ExportEvent;
   import jackboxgames.talkshow.export.Export;
   import jackboxgames.talkshow.utils.ConfigInfo;
   import jackboxgames.utils.PausableEventDispatcher;
   
   internal class ExportManager extends PausableEventDispatcher
   {
       
      
      protected var _config:ConfigInfo;
      
      protected var _exports:Object;
      
      protected var _rootContainer:Sprite;
      
      protected var _activeExport:Export;
      
      public function ExportManager(cfg:ConfigInfo, rootClip:Sprite)
      {
         super();
         this._exports = new Object();
         this._config = cfg;
         this._rootContainer = rootClip;
         this._activeExport = null;
      }
      
      protected function registerExportLoadListeners(e:Export) : void
      {
         var key:Namespace = PlaybackEngine.getInstance().getPrivateNamespace(this);
         var eng:PlaybackEngine = PlaybackEngine.getInstance();
         e.addEventListener(ExportEvent.STARTFILE_LOADED,eng.exportStartFileLoadHandler);
         e.addEventListener(ExportEvent.STARTFILE_PROGRESS,eng.exportStartFileProgressHandler);
         e.addEventListener(ExportEvent.STARTFILE_ERROR,eng.exportStartFileErrorHandler);
      }
      
      protected function registerExportEventListeners(e:Export) : void
      {
         var key:Namespace = PlaybackEngine.getInstance().getPrivateNamespace(this);
         var eng:PlaybackEngine = PlaybackEngine.getInstance();
         e.addEventListener(ExportEvent.STARTFLOWCHART_LOADED,eng.exportFlowchartLoadHandler);
         e.addEventListener(ExportEvent.STARTFLOWCHART_PROGRESS,eng.exportFlowchartProgressHandler);
         e.addEventListener(ExportEvent.STARTFLOWCHART_ERROR,eng.exportFlowchartErrorHandler);
         e.addEventListener(ExportEvent.FLOWCHART_LOADED,eng.exportFlowchartLoadHandler);
         e.addEventListener(ExportEvent.FLOWCHART_PROGRESS,eng.exportFlowchartProgressHandler);
         e.addEventListener(ExportEvent.FLOWCHART_ERROR,eng.exportFlowchartErrorHandler);
      }
      
      public function addExport(info:ConfigInfo) : Export
      {
         var ex:Export = null;
         var id:String = null;
         if(info != null)
         {
            id = Export.createIDFromPath(this._config.getValue(ConfigInfo.START_FILE));
            if(this._exports[id] == null)
            {
               ex = new Export(id,info);
               if(ex != null)
               {
                  this._exports[id] = ex;
                  this.registerExportLoadListeners(ex);
                  this.registerExportEventListeners(ex);
               }
               return this._exports[id];
            }
            throw new IllegalOperationError("Export with id: " + id + " already exists.");
         }
         return null;
      }
      
      public function loadExport(id:String) : void
      {
         var ex:Export = this.getExportByID(id);
         if(ex != null)
         {
            if(!ex.isLoaded())
            {
               ex.load();
               return;
            }
            throw new IllegalOperationError("Export already loaded");
         }
         throw new ArgumentError("Export with id: " + id + " could not be resolved");
      }
      
      public function getExportByID(id:String) : Export
      {
         if(this._exports[id] != null)
         {
            return this._exports[id];
         }
         return null;
      }
      
      public function getExportByPath(path:String) : Export
      {
         var id:String = Export.createIDFromPath(path);
         if(this._exports[id] != null)
         {
            return this._exports[id];
         }
         return null;
      }
      
      public function setActiveExport(id:String) : Export
      {
         if(this._exports[id] != null)
         {
            this._activeExport = this._exports[id];
            return this._activeExport;
         }
         return null;
      }
      
      public function get activeExport() : Export
      {
         return this._activeExport;
      }
      
      public function unregisterExportLoadListeners(id:String) : void
      {
         var key:Namespace = null;
         var eng:PlaybackEngine = null;
         var ex:Export = this.getExportByID(id);
         if(ex != null)
         {
            key = PlaybackEngine.getInstance().getPrivateNamespace(this);
            eng = PlaybackEngine.getInstance();
            ex.removeEventListener(ExportEvent.STARTFILE_LOADED,eng.exportStartFileLoadHandler);
            ex.removeEventListener(ExportEvent.STARTFILE_PROGRESS,eng.exportStartFileProgressHandler);
            ex.removeEventListener(ExportEvent.STARTFILE_ERROR,eng.exportStartFileErrorHandler);
            return;
         }
         throw new ArgumentError("Export with id: " + id + " could not be resolved");
      }
      
      public function unregisterExportEventListeners(id:String) : void
      {
         var key:Namespace = null;
         var eng:PlaybackEngine = null;
         var ex:Export = this.getExportByID(id);
         if(ex != null)
         {
            key = PlaybackEngine.getInstance().getPrivateNamespace(this);
            eng = PlaybackEngine.getInstance();
            return;
         }
         throw new ArgumentError("Export with id: " + id + " could not be resolved");
      }
      
      public function unregisterFlowchartEventListeners(id:String) : void
      {
         var key:Namespace = null;
         var eng:PlaybackEngine = null;
         var ex:Export = this.getExportByID(id);
         if(ex != null)
         {
            key = PlaybackEngine.getInstance().getPrivateNamespace(this);
            eng = PlaybackEngine.getInstance();
            ex.removeEventListener(ExportEvent.FLOWCHART_LOADED,eng.exportFlowchartLoadHandler);
            ex.removeEventListener(ExportEvent.FLOWCHART_PROGRESS,eng.exportFlowchartProgressHandler);
            ex.removeEventListener(ExportEvent.FLOWCHART_ERROR,eng.exportFlowchartErrorHandler);
            return;
         }
         throw new ArgumentError("Export with id: " + id + " could not be resolved");
      }
      
      public function unregisterStartFlowchartEventListeners(id:String) : void
      {
         var key:Namespace = null;
         var eng:PlaybackEngine = null;
         var ex:Export = this.getExportByID(id);
         if(ex != null)
         {
            key = PlaybackEngine.getInstance().getPrivateNamespace(this);
            eng = PlaybackEngine.getInstance();
            ex.removeEventListener(ExportEvent.STARTFLOWCHART_LOADED,eng.exportFlowchartLoadHandler);
            ex.removeEventListener(ExportEvent.STARTFLOWCHART_PROGRESS,eng.exportFlowchartProgressHandler);
            ex.removeEventListener(ExportEvent.STARTFLOWCHART_ERROR,eng.exportFlowchartErrorHandler);
            return;
         }
         throw new ArgumentError("Export with id: " + id + " could not be resolved");
      }
   }
}
