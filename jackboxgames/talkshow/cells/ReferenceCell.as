package jackboxgames.talkshow.cells
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.IBranch;
   import jackboxgames.talkshow.api.IBranchingCell;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.events.BranchEvent;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.utils.VariableUtil;
   
   public class ReferenceCell extends AbstractCell implements IBranchingCell
   {
      private var _refVar:String;
      
      private var _branches:Array;
      
      public function ReferenceCell(f:IFlowchart, id:uint, target:String, variable:String)
      {
         super(f,id,target,Constants.CELL_REFERENCE);
         this._refVar = variable;
         this._branches = new Array();
      }
      
      override public function toString() : String
      {
         return "[Reference Cell id=" + _id + " fid=" + _f.id + "]";
      }
      
      public function get referenceVariable() : String
      {
         return this._refVar;
      }
      
      public function get branches() : Array
      {
         return this._branches;
      }
      
      public function addBranch(branch:IBranch) : void
      {
         this._branches.push(branch);
      }
      
      public function pickBranch(input:*) : IBranch
      {
         var branch:ReferenceBranch = null;
         for each(branch in this._branches)
         {
            if(branch.evaluate(input))
            {
               return branch;
            }
         }
         return null;
      }
      
      override public function start() : void
      {
         super.start();
         var branch:IBranch = this.pickBranch(VariableUtil.getVariableValue(this._refVar));
         if(branch == null)
         {
            Logger.error("No matching branch for reference cell: " + this);
            PlaybackEngine.getInstance().dispatchEvent(new CellEvent(CellEvent.NO_REF_BRANCH,this));
            return;
         }
         PlaybackEngine.getInstance().dispatchEvent(new BranchEvent(BranchEvent.BRANCH_STARTED,branch,null,VariableUtil.getVariableValue(this._refVar)));
         _f.getCellByID(branch.targetId).start();
      }
      
      override public function load(data:ILoadData = null) : void
      {
         if(data == null || !data.add(this))
         {
            return;
         }
         var branch:IBranch = this.pickBranch(VariableUtil.getVariableValue(this._refVar));
         var child:ICell = null;
         if(branch != null && !data.volatile)
         {
            child = _f.getCellByID(branch.targetId);
            if(child != null)
            {
               child.load(data);
            }
         }
         else if(this._branches.length < LoadData.MAX_VOLATILE)
         {
            for each(branch in this._branches)
            {
               child = _f.getCellByID(branch.targetId);
               if(child != null)
               {
                  child.load(data.clone());
               }
            }
         }
      }
   }
}

