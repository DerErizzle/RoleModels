package jackboxgames.talkshow.api
{
   public interface IBranch
   {
      function get targetId() : int;
      
      function get type() : uint;
      
      function get branchId() : int;
      
      function evaluate(param1:*) : Boolean;
      
      function get parentCell() : IBranchingCell;
      
      function start() : void;
   }
}

