package jackboxgames.thewheel.entitybehaviors
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.utils.PerPlayerContainer;
   
   public interface IChooseSliceDelegate
   {
      function getChooseSlicePrompt(param1:Player) : String;
      
      function get showSelectedSlices() : Boolean;
      
      function canChooseSlice(param1:Player, param2:int) : Boolean;
      
      function onChooseSliceSubmitted(param1:Player, param2:int) : void;
      
      function onChooseSliceDone(param1:PerPlayerContainer, param2:Boolean) : void;
   }
}

