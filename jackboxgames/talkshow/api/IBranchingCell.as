package jackboxgames.talkshow.api
{
   public interface IBranchingCell extends ICell
   {
       
      
      function addBranch(param1:IBranch) : void;
      
      function pickBranch(param1:*) : IBranch;
      
      function get branches() : Array;
   }
}
