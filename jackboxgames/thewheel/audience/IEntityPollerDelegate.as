package jackboxgames.thewheel.audience
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.ecast.messages.Reply;
   
   public interface IEntityPollerDelegate
   {
      function poll() : Promise;
      
      function onPollReply(param1:Reply) : void;
   }
}

