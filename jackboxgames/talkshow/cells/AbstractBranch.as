package jackboxgames.talkshow.cells
{
   import jackboxgames.talkshow.api.IBranch;
   import jackboxgames.talkshow.api.IBranchingCell;
   import jackboxgames.talkshow.api.ICell;
   
   public class AbstractBranch implements IBranch
   {
       
      
      protected var _targetId:int;
      
      protected var _type:uint;
      
      protected var _branchId:uint;
      
      protected var _cell:IBranchingCell;
      
      public function AbstractBranch(cell:IBranchingCell, branchId:uint, targetId:int, type:uint)
      {
         super();
         this._branchId = branchId;
         this._targetId = targetId;
         this._type = type;
         this._cell = cell;
         cell.addBranch(this);
      }
      
      public function toString() : String
      {
         return "[Branch cell=" + this._cell + " target=" + this._targetId + "]";
      }
      
      public function get targetId() : int
      {
         return this._targetId;
      }
      
      public function get branchId() : int
      {
         return this._branchId;
      }
      
      public function get type() : uint
      {
         return this._type;
      }
      
      public function evaluate(x:*) : Boolean
      {
         return false;
      }
      
      public function get parentCell() : IBranchingCell
      {
         return this._cell;
      }
      
      public function start() : void
      {
         var target:ICell = this._cell.flowchart.getCellByID(this.targetId);
         if(target != null)
         {
            target.start();
         }
      }
   }
}
