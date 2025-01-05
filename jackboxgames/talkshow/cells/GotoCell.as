package jackboxgames.talkshow.cells
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.events.ExportEvent;
   import jackboxgames.talkshow.utils.LoadStatus;
   
   public class GotoCell extends AbstractCell
   {
       
      
      private var _tCell:uint;
      
      private var _tFlowchart:uint;
      
      public function GotoCell(f:IFlowchart, id:uint, target:String, targetCell:uint, targetFC:uint)
      {
         super(f,id,target,Constants.CELL_GOTO);
         this._tCell = targetCell;
         this._tFlowchart = targetFC;
      }
      
      override public function toString() : String
      {
         return "[GotoCell id=" + flowchart.flowchartName + ":" + _id + "(" + flowchart.id + ":" + _id + ")]";
      }
      
      override public function start() : void
      {
         var fc:IFlowchart = null;
         super.start();
         var c:ICell = null;
         if(this._tFlowchart == _f.id)
         {
            c = _f.getCellByID(this._tCell);
            if(c != null)
            {
               c.start();
            }
            else
            {
               Logger.warning("GotoCell: target cell is null or does not exist: " + this,"Cell");
               _loadStatus = LoadStatus.STATUS_FAILED;
            }
         }
         else
         {
            fc = this.targetFlowchart;
            if(fc != null && Boolean(fc.isLoaded()))
            {
               c = fc.getCellByID(this._tCell);
               if(c != null)
               {
                  c.start();
               }
               else
               {
                  Logger.warning("GotoCell: target cell is null or does not exist: " + this,"Cell");
                  _loadStatus = LoadStatus.STATUS_FAILED;
               }
            }
            else
            {
               if(fc == null)
               {
                  Logger.error("Goto Cell: " + this + ": Target flowchart doesn\'t exist","Cell");
                  return;
               }
               Logger.warning("Goto Cell: " + this + ": Can\'t start. Flowchart isn\'t loaded.","Load");
               PlaybackEngine.getInstance().loadPause(this,fc);
               this.registerStartCallback(fc);
               fc.load(new LoadData(0));
            }
         }
      }
      
      public function get targetFlowchart() : IFlowchart
      {
         var fc:IFlowchart = _f;
         if(this._tFlowchart != _f.id)
         {
            fc = _f.getParentExport().getFlowchart(this._tFlowchart);
         }
         return fc;
      }
      
      override public function load(data:ILoadData = null) : void
      {
         var c:ICell = null;
         var fc:IFlowchart = null;
         if(_loadStatus != LoadStatus.STATUS_FAILED)
         {
            if(data == null || data.level == 0 || !data.add(this))
            {
               return;
            }
            c = null;
            if(this._tFlowchart == _f.id)
            {
               c = _f.getCellByID(this._tCell);
               if(Boolean(c))
               {
                  c.load(data);
               }
               else
               {
                  _loadStatus = LoadStatus.STATUS_FAILED;
               }
            }
            else
            {
               fc = this.targetFlowchart;
               if(fc == null)
               {
                  Logger.error("Goto Cell: " + this + ": Target flowchart doesn\'t exist","Cell");
                  return;
               }
               if(!fc.isLoaded())
               {
                  this.registerLoadCallback(fc);
                  fc.load(data);
               }
               else
               {
                  c = fc.getCellByID(this._tCell);
                  if(Boolean(c))
                  {
                     c.load(data);
                  }
                  else
                  {
                     _loadStatus = LoadStatus.STATUS_FAILED;
                  }
               }
            }
         }
      }
      
      override public function isLoaded() : Boolean
      {
         var fc:IFlowchart = null;
         var c:ICell = null;
         if(_loadStatus != LoadStatus.STATUS_FAILED)
         {
            if(this._tFlowchart == _f.id)
            {
               return _f.getCellByID(this._tCell).isLoaded();
            }
            fc = this.targetFlowchart;
            if(fc != null && Boolean(fc.isLoaded()))
            {
               c = fc.getCellByID(this._tCell);
               if(Boolean(c))
               {
                  return c.isLoaded();
               }
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
      
      protected function registerStartCallback(f:IFlowchart) : void
      {
         f.addEventListener(ExportEvent.FLOWCHART_LOADED,this.startCallback);
         f.addEventListener(ExportEvent.FLOWCHART_ERROR,this.startCallback);
      }
      
      protected function unregisterStartCallback(f:IFlowchart) : void
      {
         f.removeEventListener(ExportEvent.FLOWCHART_LOADED,this.startCallback);
         f.removeEventListener(ExportEvent.FLOWCHART_ERROR,this.startCallback);
      }
      
      protected function registerLoadCallback(f:IFlowchart) : void
      {
         f.addEventListener(ExportEvent.FLOWCHART_LOADED,this.loadCallback);
         f.addEventListener(ExportEvent.FLOWCHART_ERROR,this.loadCallback);
      }
      
      protected function unregisterLoadCallback(f:IFlowchart) : void
      {
         f.removeEventListener(ExportEvent.FLOWCHART_LOADED,this.loadCallback);
         f.removeEventListener(ExportEvent.FLOWCHART_ERROR,this.loadCallback);
      }
      
      protected function startCallback(e:ExportEvent) : void
      {
         if(this._tFlowchart == e.id.fcInternalID)
         {
            switch(e.type)
            {
               case ExportEvent.FLOWCHART_ERROR:
                  this.unregisterStartCallback(e.target as IFlowchart);
                  _loadStatus = LoadStatus.STATUS_FAILED;
                  Logger.error("GOTO CELL startCallback-> target flowchart load failed");
                  break;
               case ExportEvent.FLOWCHART_LOADED:
                  this.unregisterStartCallback(e.target as IFlowchart);
                  PlaybackEngine.getInstance().loadResume(this);
                  this.start();
            }
         }
      }
      
      protected function loadCallback(e:ExportEvent) : void
      {
         if(this._tFlowchart == e.id.fcInternalID)
         {
            switch(e.type)
            {
               case ExportEvent.FLOWCHART_ERROR:
                  this.unregisterLoadCallback(e.target as IFlowchart);
                  _loadStatus = LoadStatus.STATUS_FAILED;
                  Logger.error("GOTO CELL loadCallback-> target flowchart load failed");
                  break;
               case ExportEvent.FLOWCHART_LOADED:
                  this.unregisterLoadCallback(e.target as IFlowchart);
                  this.load(e.data as ILoadData);
            }
         }
      }
   }
}
