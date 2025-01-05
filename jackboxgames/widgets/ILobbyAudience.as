package jackboxgames.widgets
{
   public interface ILobbyAudience
   {
       
      
      function get showCountWithAudience() : Boolean;
      
      function set showCountWithAudience(param1:Boolean) : void;
      
      function reset() : void;
      
      function start(param1:int, param2:ILobbyAudioHandler) : void;
      
      function stop() : void;
      
      function dismiss() : void;
   }
}
