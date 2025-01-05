package jackboxgames.talkshow.actions
{
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.cells.ActionCell;
   import jackboxgames.talkshow.timing.Timing;
   import jackboxgames.talkshow.utils.LoadStatus;
   
   public class StartNextActionRef extends ActionRef
   {
       
      
      private var START_NEXT_ID:int = -99999;
      
      protected var _tFlowchart:uint;
      
      protected var _tCell:uint;
      
      private var _activated:Boolean;
      
      private var _started:Boolean;
      
      private var _targetCell:ActionCell;
      
      public function StartNextActionRef(targetFlowchart:uint, targetCell:uint, timing:Timing)
      {
         super(new Action(this.START_NEXT_ID,"StartNext",null),timing);
         this._tCell = targetCell;
         this._tFlowchart = targetFlowchart;
         this._activated = false;
         this._started = false;
      }
      
      override public function toString() : String
      {
         return "[StartNextActionRef nextCell=" + this._tCell + " timing=" + _timing + "]";
      }
      
      override public function start(isPrimary:Boolean = false) : void
      {
         parent.runChildren();
         this._started = true;
         if(this._activated)
         {
            this.fire();
         }
      }
      
      public function activate(cell:ActionCell) : void
      {
         this._activated = true;
         this._targetCell = cell;
         if(this._started)
         {
            this.fire();
         }
      }
      
      private function fire() : void
      {
         this._activated = false;
         this._started = false;
         this._targetCell.play();
      }
      
      public function get targetCell() : ActionCell
      {
         return this._targetCell;
      }
      
      public function get targetCellID() : uint
      {
         return this._tCell;
      }
      
      public function get targetFlowchartID() : uint
      {
         return this._tFlowchart;
      }
      
      override public function load(data:ILoadData = null) : void
      {
      }
      
      override public function isLoaded() : Boolean
      {
         return true;
      }
      
      override public function get loadStatus() : int
      {
         return LoadStatus.STATUS_LOADED;
      }
   }
}
