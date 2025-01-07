package jackboxgames.talkshow.cells
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.ISubroutine;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.events.ExportEvent;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.talkshow.utils.VariableUtil;
   
   public class CallCell extends AbstractCell
   {
      private var _childId:uint;
      
      private var _subroutineId:uint;
      
      private var _returnVariable:String;
      
      private var _values:Array;
      
      public function CallCell(f:IFlowchart, id:uint, target:String, childId:uint, subroutineId:uint, returnVariable:String = null)
      {
         super(f,id,target,Constants.CELL_CALL);
         this._childId = childId;
         this._subroutineId = subroutineId;
         this._returnVariable = returnVariable;
         this._values = new Array();
      }
      
      override public function toString() : String
      {
         return "[CallCell id=" + _id + " sub=" + this.subroutine + "]";
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
      
      public function get subroutine() : ISubroutine
      {
         return _f.getParentExport().getFlowchart(this._subroutineId) as ISubroutine;
      }
      
      public function get returnVariable() : String
      {
         return this._returnVariable;
      }
      
      override public function start() : void
      {
         var localVars:Object = null;
         var params:Array = null;
         var i:uint = 0;
         var sub:ISubroutine = this.subroutine;
         if(sub == null)
         {
            Logger.error("Call Cell: " + this + ": Subroutine doesn\'t exist","Cell");
            return;
         }
         if(!sub.isLoaded())
         {
            Logger.warning("Call Cell: " + this + ": Can\'t start. Subroutine isn\'t loaded.","Load");
            PlaybackEngine.getInstance().loadPause(this,sub);
            this.registerStartCallback(sub);
            sub.load(new LoadData(0));
         }
         else
         {
            super.start();
            if(Boolean(this.subroutine.firstCell))
            {
               PlaybackEngine.getInstance().callStack.push(this,true);
               localVars = PlaybackEngine.getInstance().callStack.l;
               params = this.subroutine.getSubroutineParams();
               for(i = 0; i < params.length; i++)
               {
                  localVars[params[i]] = VariableUtil.replaceVariables(this._values[i]);
               }
               this.subroutine.firstCell.start();
            }
            else
            {
               Logger.error("Call Cell: " + this + ": Subroutine first cell is null or doesn\'t exist.","Cell");
               _loadStatus = LoadStatus.STATUS_FAILED;
            }
         }
      }
      
      override public function load(data:ILoadData = null) : void
      {
         if(data == null || data.level == 0 || !data.add(this))
         {
            return;
         }
         var sub:ISubroutine = this.subroutine;
         if(sub == null)
         {
            Logger.error("Call Cell: " + this + ": Subroutine doesn\'t exist","Cell");
            return;
         }
         if(!sub.isLoaded())
         {
            this.registerLoadCallback(sub);
            sub.load(data);
         }
         else if(Boolean(sub.firstCell))
         {
            PlaybackEngine.getInstance().callStack.push(this);
            sub.firstCell.load(data);
            PlaybackEngine.getInstance().callStack.pop();
         }
         else
         {
            _loadStatus = LoadStatus.STATUS_FAILED;
         }
      }
      
      override public function isLoaded() : Boolean
      {
         var c:ICell = null;
         if(_loadStatus != LoadStatus.STATUS_FAILED)
         {
            if(this.subroutine != null && Boolean(this.subroutine.isLoaded()))
            {
               c = this.subroutine.firstCell;
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
      
      protected function registerStartCallback(s:ISubroutine) : void
      {
         s.addEventListener(ExportEvent.FLOWCHART_LOADED,this.startCallback);
         s.addEventListener(ExportEvent.FLOWCHART_ERROR,this.startCallback);
      }
      
      protected function unregisterStartCallback(s:ISubroutine) : void
      {
         s.removeEventListener(ExportEvent.FLOWCHART_LOADED,this.startCallback);
         s.removeEventListener(ExportEvent.FLOWCHART_ERROR,this.startCallback);
      }
      
      protected function registerLoadCallback(s:ISubroutine) : void
      {
         s.addEventListener(ExportEvent.FLOWCHART_LOADED,this.loadCallback);
         s.addEventListener(ExportEvent.FLOWCHART_ERROR,this.loadCallback);
      }
      
      protected function unregisterLoadCallback(s:ISubroutine) : void
      {
         s.removeEventListener(ExportEvent.FLOWCHART_LOADED,this.loadCallback);
         s.removeEventListener(ExportEvent.FLOWCHART_ERROR,this.loadCallback);
      }
      
      protected function startCallback(e:ExportEvent) : void
      {
         if(this._subroutineId == e.id.fcInternalID)
         {
            switch(e.type)
            {
               case ExportEvent.FLOWCHART_ERROR:
                  this.unregisterStartCallback(this.subroutine);
                  _loadStatus = LoadStatus.STATUS_FAILED;
                  break;
               case ExportEvent.FLOWCHART_LOADED:
                  this.unregisterStartCallback(this.subroutine);
                  PlaybackEngine.getInstance().loadResume(this);
                  this.start();
            }
         }
      }
      
      protected function loadCallback(e:ExportEvent) : void
      {
         if(this._subroutineId == e.id.fcInternalID)
         {
            switch(e.type)
            {
               case ExportEvent.FLOWCHART_ERROR:
                  this.unregisterLoadCallback(this.subroutine);
                  _loadStatus = LoadStatus.STATUS_FAILED;
                  break;
               case ExportEvent.FLOWCHART_LOADED:
                  this.unregisterLoadCallback(this.subroutine);
                  this.load(e.data as ILoadData);
            }
         }
      }
   }
}

