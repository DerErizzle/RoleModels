package jackboxgames.rolemodels.gameplay
{
   public interface IResultVoteHandler
   {
       
      
      function get resultVoteText() : String;
      
      function get resultVoteKeys() : Array;
      
      function get resultVoteChoices() : Array;
      
      function applyResultVote(param1:Object) : void;
   }
}
