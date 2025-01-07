package jackboxgames.widgets.lobby.audio
{
   import jackboxgames.model.JBGPlayer;
   
   public class NullLobbyAudioHandler implements ILobbyAudioHandler
   {
      public function NullLobbyAudioHandler()
      {
         super();
      }
      
      public function setup(params:Object) : void
      {
      }
      
      public function shutdown() : void
      {
      }
      
      public function playCountdownAudio(doneFn:Function) : void
      {
      }
      
      public function stopCountdownAudio() : void
      {
      }
      
      public function playEverybodysInOnAudio(doneFn:Function) : void
      {
      }
      
      public function playEverybodysInOffAudio(doneFn:Function) : void
      {
      }
      
      public function playRoomCodeDisappearAudio(doneFn:Function) : void
      {
      }
      
      public function playPlayerJoinedAudio(p:JBGPlayer, doneFn:Function) : void
      {
      }
      
      public function playLobbyBackAudio(doneFn:Function) : void
      {
      }
      
      public function playHideRoomCodeAudio(doneFn:Function) : void
      {
      }
      
      public function playCensorAudio(doneFn:Function) : void
      {
      }
      
      public function playAudienceOnAudio(doneFn:Function) : void
      {
      }
      
      public function playAudienceUpdateAudio(doneFn:Function) : void
      {
      }
   }
}

