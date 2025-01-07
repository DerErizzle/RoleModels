package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.data.TappingListData;
   
   public interface ITappingListBehaviorDelegate
   {
      function get content() : TappingListData;
      
      function getAnswers(param1:Player) : Array;
      
      function setAnswer(param1:Player, param2:int, param3:Boolean) : void;
      
      function onPlayerIsDone(param1:Player) : void;
   }
}

