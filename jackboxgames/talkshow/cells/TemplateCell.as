package jackboxgames.talkshow.cells
{
   import flash.events.Event;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.ITemplate;
   import jackboxgames.talkshow.api.ITemplateHandler;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.events.ExportEvent;
   import jackboxgames.talkshow.templates.Template;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.talkshow.utils.VariableUtil;
   
   public class TemplateCell extends AbstractCell
   {
       
      
      private var _childId:uint;
      
      private var _templateId:uint;
      
      private var _values:Array;
      
      private var _loadData:ILoadData;
      
      public function TemplateCell(f:IFlowchart, id:uint, target:String, childId:uint, templateId:uint)
      {
         super(f,id,target,Constants.CELL_TEMPLATE);
         this._childId = childId;
         this._templateId = templateId;
         this._values = new Array();
      }
      
      override public function toString() : String
      {
         return "[TemplateCell id=" + _id + " tpl=" + this.template + "]";
      }
      
      public function addParameterValue(value:String) : void
      {
         this._values.push(value);
      }
      
      public function getParameterValue(index:uint) : String
      {
         return this._values[index];
      }
      
      public function get child() : ICell
      {
         return _f.getCellByID(this._childId);
      }
      
      public function get template() : ITemplate
      {
         return _f.getParentExport().getTemplate(this._templateId) as ITemplate;
      }
      
      internal function get params() : Object
      {
         var p:String = null;
         var t:ITemplate = this.template;
         var result:Object = {};
         var i:uint = 0;
         for each(p in t.params)
         {
            if(p != null && p.length > 0)
            {
               result[p] = VariableUtil.replaceVariables(this._values[i++]);
            }
         }
         return result;
      }
      
      override public function start() : void
      {
         var t:ITemplate = this.template;
         if(t == null)
         {
            Logger.error("Template Cell: " + this + ": Template doesn\'t exist","Cell");
            if(this._childId == 0)
            {
               return;
            }
            _f.getCellByID(this._childId).start();
            return;
         }
         var p:Object = this.params;
         if(!t.isLoaded())
         {
            Logger.warning("Template Cell: " + this + ": Can\'t start. Template isn\'t loaded.","Load");
            PlaybackEngine.getInstance().loadPause(this,t);
            this.registerStartCallback(t);
            t.load(new LoadData(0));
         }
         else if(t.handler != null && !t.handler.isRecordLoaded(p))
         {
            Logger.warning("Template Cell: " + this + ": Can\'t start. Record isn\'t loaded.","Load");
            PlaybackEngine.getInstance().loadPause(this,t);
            t.handler.addEventListener(Event.COMPLETE,this.recordStartCallback,false,1);
         }
         else
         {
            super.start();
            if(t.handler != null)
            {
               (t as Template).setActiveRecord(p);
            }
            else
            {
               Logger.warning("Template Cell: " + this + " no handler.  Skipping cell.","Cell");
            }
            if(this._childId == 0)
            {
               return;
            }
            _f.getCellByID(this._childId).start();
         }
      }
      
      override public function load(data:ILoadData = null) : void
      {
         Logger.debug("TemplateCell.load()");
         if(data == null || data.level == 0 || !data.add(this))
         {
            Logger.error("Template Cell: " + this + ": data does not exist or failed to add!","Template");
            return;
         }
         var t:ITemplate = this.template;
         if(t == null)
         {
            Logger.error("Template Cell: " + this + ": Template doesn\'t exist","Template");
            return;
         }
         if(!t.isLoaded())
         {
            Logger.warning("Template Cell: Template handler isn\'t loaded. Try to load: " + t,"Template");
            this.registerLoadCallback(t);
            data.remove(this);
            t.load(data);
            return;
         }
         if(t.handler == null)
         {
            Logger.error("Template Cell: " + this + ": Template handler doesn\'t exist","Template");
            return;
         }
         var p:Object = this.params;
         Logger.debug("TemplateCell - loaded and stuff");
         if(!t.handler.isRecordLoaded(p))
         {
            Logger.debug("TemplateCell - Load record");
            this._loadData = new LoadData(data.level,data.volatile);
            t.handler.addEventListener(Event.COMPLETE,this.recordCallback);
            t.handler.loadRecord(p);
            return;
         }
      }
      
      override public function isLoaded() : Boolean
      {
         var t:ITemplate = null;
         if(_loadStatus != LoadStatus.STATUS_FAILED)
         {
            t = this.template;
            if(t != null && Boolean(t.isLoaded()))
            {
               return t.handler.isRecordLoaded(this.params);
            }
         }
         return false;
      }
      
      override public function get loadStatus() : int
      {
         if(_loadStatus != LoadStatus.STATUS_FAILED)
         {
            if(this.isLoaded())
            {
               _loadStatus = LoadStatus.STATUS_LOADED;
            }
            else
            {
               _loadStatus = LoadStatus.STATUS_INVALIDATED;
            }
         }
         return _loadStatus;
      }
      
      protected function registerStartCallback(t:ITemplate) : void
      {
         t.addEventListener(ExportEvent.TEMPLATE_LOADED,this.startCallback);
         t.addEventListener(ExportEvent.TEMPLATE_ERROR,this.startCallback);
      }
      
      protected function unregisterStartCallback(t:ITemplate) : void
      {
         t.removeEventListener(ExportEvent.TEMPLATE_LOADED,this.startCallback);
         t.removeEventListener(ExportEvent.TEMPLATE_ERROR,this.startCallback);
      }
      
      protected function registerLoadCallback(t:ITemplate) : void
      {
         t.addEventListener(ExportEvent.TEMPLATE_LOADED,this.loadCallback);
         t.addEventListener(ExportEvent.TEMPLATE_ERROR,this.loadCallback);
      }
      
      protected function unregisterLoadCallback(t:ITemplate) : void
      {
         t.removeEventListener(ExportEvent.TEMPLATE_LOADED,this.loadCallback);
         t.removeEventListener(ExportEvent.TEMPLATE_ERROR,this.loadCallback);
      }
      
      protected function startCallback(e:ExportEvent) : void
      {
         if(this._templateId == e.id.fcInternalID)
         {
            switch(e.type)
            {
               case ExportEvent.TEMPLATE_ERROR:
                  this.unregisterStartCallback(e.target as ITemplate);
                  _loadStatus = LoadStatus.STATUS_FAILED;
                  break;
               case ExportEvent.TEMPLATE_LOADED:
                  this.unregisterStartCallback(e.target as ITemplate);
                  PlaybackEngine.getInstance().loadResume(this);
                  this.start();
            }
         }
      }
      
      protected function loadCallback(e:ExportEvent) : void
      {
         if(this._templateId == e.id.fcInternalID)
         {
            switch(e.type)
            {
               case ExportEvent.TEMPLATE_ERROR:
                  this.unregisterLoadCallback(e.target as ITemplate);
                  _loadStatus = LoadStatus.STATUS_FAILED;
                  Logger.error("TEMPLATE CELL loadCallback-> target template load failed");
                  break;
               case ExportEvent.TEMPLATE_LOADED:
                  this.unregisterLoadCallback(e.target as ITemplate);
                  this.load(e.data as ILoadData);
            }
         }
      }
      
      protected function recordCallback(e:Event) : void
      {
         if(!this.template)
         {
            Logger.debug("TemplateCell:  template is NULL");
         }
         if(!this.template.handler)
         {
            Logger.debug("TemplateCell:  template.handler is NULL");
         }
         if(!this._loadData)
         {
            Logger.debug("TemplateCell:  loadData is NULL.");
         }
         if(this.template.handler == e.target && e.type == Event.COMPLETE)
         {
            (e.target as ITemplateHandler).removeEventListener(Event.COMPLETE,this.recordCallback);
            this.load(this._loadData);
            this._loadData = null;
         }
         else
         {
            Logger.debug("TemplateCell:  load failed.");
         }
      }
      
      protected function recordStartCallback(e:Event) : void
      {
         Logger.info("TEMPLATECELL: Start template cell after record load: handler=" + this.template.handler + " type=" + Event.COMPLETE);
         if(this.template.handler == e.target && e.type == Event.COMPLETE)
         {
            this.load(new LoadData(1,true));
            PlaybackEngine.getInstance().loadResume(this);
            (e.target as ITemplateHandler).removeEventListener(Event.COMPLETE,this.recordStartCallback);
            this.start();
         }
      }
   }
}
