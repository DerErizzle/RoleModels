package jackboxgames.widgets
{
   import jackboxgames.blobcast.model.BlobCastPlayer;
   
   public interface ILobbyAudioHandler
   {
       
      
      function setup(param1:Object) : void;
      
      function shutdown() : void;
      
      function playCountdownAudio(param1:Function) : void;
      
      function stopCountdownAudio() : void;
      
      function playEverybodysInOnAudio(param1:Function) : void;
      
      function playEverybodysInOffAudio(param1:Function) : void;
      
      function playRoomCodeDisappearAudio(param1:Function) : void;
      
      function playPlayerJoinedAudio(param1:BlobCastPlayer, param2:Function) : void;
      
      function playLobbyBackAudio(param1:Function) : void;
      
      function playHideRoomCodeAudio(param1:Function) : void;
      
      function playCensorAudio(param1:Function) : void;
      
      function playUGCOnAudio(param1:Function) : void;
      
      function playUGCOffAudio(param1:Function) : void;
      
      function playAudienceOnAudio(param1:Function) : void;
      
      function playAudienceUpdateAudio(param1:Function) : void;
   }
}
