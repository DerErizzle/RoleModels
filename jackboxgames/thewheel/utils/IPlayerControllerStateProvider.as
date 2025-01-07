package jackboxgames.thewheel.utils
{
   import jackboxgames.thewheel.Player;
   
   public interface IPlayerControllerStateProvider
   {
      function mutateState(param1:Player, param2:Object) : void;
   }
}

