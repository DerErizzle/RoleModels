package jackboxgames.talkshow.cells
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.actions.TimeoutBranchActionRef;
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.IBranch;
   import jackboxgames.talkshow.api.IBranchingCell;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.events.BranchEvent;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.timing.Timing;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.talkshow.utils.VariableUtil;
   
   public class InputCell extends AbstractCell implements IBranchingCell
   {
      private var _ass:String;
      
      private var _fib:String;
      
      private var _branches:Array;
      
      private var _timeout:IBranch;
      
      public function InputCell(f:IFlowchart, id:uint, target:String, assVar:String, fibVar:String)
      {
         super(f,id,target,Constants.CELL_INPUT);
         this._ass = assVar;
         this._fib = fibVar;
         this._branches = new Array();
      }
      
      override public function toString() : String
      {
         return "[InputCell id=" + _id + " var=" + this._ass + "]";
      }
      
      public function get assignmentVar() : String
      {
         return this._ass;
      }
      
      public function get fibVar() : String
      {
         return this._fib;
      }
      
      public function get branches() : Array
      {
         return this._branches;
      }
      
      public function addBranch(branch:IBranch) : void
      {
         if(branch.type == Constants.BR_TIMEOUT)
         {
            this._timeout = branch;
         }
         else
         {
            this._branches.push(branch);
         }
      }
      
      public function pickBranch(input:*) : IBranch
      {
         var branch:IBranch = null;
         for each(branch in this._branches)
         {
            if(branch.evaluate(input))
            {
               return branch;
            }
         }
         return null;
      }
      
      public function startBranch(input:*, raw:* = null) : void
      {
         var branch:IBranch = this.pickBranch(input);
         if(branch == null)
         {
            Logger.error("InputCell: Couldn\'t find matching branch: " + this + " input=" + input);
            return;
         }
         var next:ICell = _f.getCellByID(branch.targetId);
         if(next == null)
         {
            Logger.error("InputCell: Invalid branch or missing target cell: " + this + " input=" + input);
            return;
         }
         PlaybackEngine.getInstance().inputManager.resetInput();
         PlaybackEngine.getInstance().startNextManager.reset();
         if(this._ass != null)
         {
            VariableUtil.setVariableValue(this._ass,(branch as InputBranch).input,true);
         }
         if(this._fib != null && branch.type == Constants.BR_FIB)
         {
            VariableUtil.setVariableValue(this._fib,raw);
         }
         PlaybackEngine.getInstance().dispatchEvent(new BranchEvent(BranchEvent.BRANCH_STARTED,branch,input,raw));
         next.start();
      }
      
      override public function start() : void
      {
         var aCell:ActionCell = null;
         var tSplits:Array = null;
         var ref:TimeoutBranchActionRef = null;
         super.start();
         if(PlaybackEngine.getInstance().inputManager.isInInputMode)
         {
            this.startBranch(PlaybackEngine.getInstance().inputManager.input,PlaybackEngine.getInstance().inputManager.raw);
            return;
         }
         if(this._timeout != null)
         {
            aCell = PlaybackEngine.getInstance().inputManager.lastActionCell;
            if(aCell != null)
            {
               tSplits = (this._timeout as InputBranch).input.split("!");
               ref = new TimeoutBranchActionRef(_f.getCellByID(this._timeout.targetId),new Timing(tSplits[0] == "S",Number(tSplits[1])));
               aCell.setTimeoutBranchActionRef(ref);
            }
         }
      }
      
      override public function load(data:ILoadData = null) : void
      {
         var branch:InputBranch = null;
         if(data == null || !data.add(this))
         {
            return;
         }
         for each(branch in this._branches)
         {
            if(branch.targetId != 0)
            {
               _f.getCellByID(branch.targetId).load(data.clone());
            }
         }
         if(this._timeout != null)
         {
            if(this._timeout.targetId != 0)
            {
               _f.getCellByID(this._timeout.targetId).load(data.clone());
            }
         }
      }
      
      override public function isLoaded() : Boolean
      {
         var branch:InputBranch = null;
         for each(branch in this._branches)
         {
            if(branch.targetId != 0)
            {
               if(!_f.getCellByID(branch.targetId).isLoaded())
               {
                  return false;
               }
            }
         }
         return true;
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
   }
}

