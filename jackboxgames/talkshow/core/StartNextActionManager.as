package jackboxgames.talkshow.core
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.actions.StartNextActionRef;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IEngineAPI;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.cells.ActionCell;
   import jackboxgames.talkshow.cells.CallCell;
   import jackboxgames.talkshow.cells.InputCell;
   import jackboxgames.talkshow.cells.ReturnCell;
   
   public class StartNextActionManager
   {
       
      
      private var _ts:IEngineAPI;
      
      private var _keyCell:ActionCell;
      
      private var _potentials:Array;
      
      private var _selected:StartNextActionRef;
      
      private var _resetCount:int;
      
      public function StartNextActionManager(engine:IEngineAPI)
      {
         super();
         this._ts = engine;
         this._ts.addEventListener(CellEvent.CELL_STARTED,this.handleCellStarted);
         this._ts.addEventListener(CellEvent.ACTION_CELL_REACHED,this.handleActionCellReached);
         this._potentials = [];
         this._resetCount = 0;
      }
      
      public function toString() : String
      {
         return "[StartNextActionManager: key=" + this._keyCell + " selected=" + this._selected + "]";
      }
      
      private function handleCellStarted(evt:CellEvent) : void
      {
         if(evt.cell is ActionCell)
         {
            this.setupKeyCell(evt.cell as ActionCell);
         }
         else if(evt.cell is CallCell || evt.cell is ReturnCell || evt.cell is InputCell)
         {
            this.selectPotential(evt.cell);
         }
      }
      
      private function handleActionCellReached(evt:CellEvent) : void
      {
         if(this._keyCell == null)
         {
            this.reset();
            (evt.cell as ActionCell).play();
            return;
         }
         this.selectPotential(evt.cell);
         if(this._selected == null)
         {
            Logger.error("StartNextActionManager: Arrived at cell: " + evt.cell + " but no StartNextActionRef found","Cell");
         }
         else
         {
            this._selected.activate(evt.cell as ActionCell);
         }
      }
      
      private function setupKeyCell(cell:ActionCell) : void
      {
         this._keyCell = cell;
         this._potentials = [];
         this._selected = null;
      }
      
      public function check(ref:StartNextActionRef) : void
      {
         if(ref.parent != this._keyCell)
         {
            return;
         }
         this._potentials.push(ref);
      }
      
      private function selectPotential(cell:ICell) : void
      {
         var ref:StartNextActionRef = null;
         if(this._selected != null)
         {
            return;
         }
         for each(ref in this._potentials)
         {
            if(ref.targetCellID == cell.id && ref.targetFlowchartID == cell.flowchart.id)
            {
               this._selected = ref;
               break;
            }
         }
         this._potentials = [];
      }
      
      public function get stateSignature() : String
      {
         var sig:String = "";
         if(this._keyCell != null)
         {
            sig += this._keyCell.flowchart.id + ":" + this._keyCell.id;
         }
         sig += "_";
         if(this._selected != null)
         {
            sig += this._selected.targetFlowchartID + ":" + this._selected.targetCellID;
         }
         sig += "_" + this._resetCount;
         Logger.debug("StartNextActionMonager.stateSignature = " + sig);
         return sig;
      }
      
      public function reset() : void
      {
         ++this._resetCount;
         this._selected = null;
         this._potentials = [];
         this._keyCell = null;
      }
   }
}
