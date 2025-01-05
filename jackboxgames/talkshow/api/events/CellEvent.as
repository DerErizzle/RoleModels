package jackboxgames.talkshow.api.events
{
   import flash.events.Event;
   import jackboxgames.talkshow.api.ICell;
   
   public class CellEvent extends Event
   {
      
      public static const CELL_STARTED:String = "started";
      
      public static const CELL_JUMP:String = "cellJump";
      
      public static const CELL_JUMPED:String = "cellJumped";
      
      public static const NO_REF_BRANCH:String = "noRefBranch";
      
      public static const ACTION_CELL_REACHED:String = "actionCellReached";
       
      
      private var _cell:ICell;
      
      public function CellEvent(type:String, cell:ICell = null)
      {
         super(type,false,false);
         this._cell = cell;
      }
      
      public function get cell() : ICell
      {
         return this._cell;
      }
   }
}
