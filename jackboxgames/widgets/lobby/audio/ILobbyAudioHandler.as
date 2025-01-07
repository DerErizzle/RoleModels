package jackboxgames.widgets.lobby.audio
{
   import jackboxgames.model.JBGPlayer;
   
   public interface ILobbyAudioHandler
   {
      function setup(param1:Object) : void;
      
      function shutdown() : void;
      
      function playCountdownAudio(param1:Function) : void;
      
      function stopCountdownAudio() : void;
      
      function playEverybodysInOnAudio(param1:Function) : void;
      
      function playEverybodysInOffAudio(param1:Function) : void;
      
      function playRoomCodeDisappearAudio(param1:Function) : void;
      
      function playPlayerJoinedAudio(param1:JBGPlayer, param2:Function) : void;
      
      function playLobbyBackAudio(param1:Function) : void;
      
      function playHideRoomCodeAudio(param1:Function) : void;
      
      function playCensorAudio(param1:Function) : void;
      
      function playAudienceOnAudio(param1:Function) : void;
      
      function playAudienceUpdateAudio(param1:Function) : void;
   }
}

