package jackboxgames.widgets.lobby.audio
{
   import jackboxgames.model.JBGPlayer;
   import jackboxgames.utils.audiosystem.AudioSystemEventCollection;
   
   public class AudioEventLobbyAudioHandler implements ILobbyAudioHandler
   {
      protected var _events:AudioSystemEventCollection;
      
      private var _uniqueJoinedSounds:Boolean;
      
      public function AudioEventLobbyAudioHandler(uniqueJoinedSounds:Boolean)
      {
         super();
         this._uniqueJoinedSounds = uniqueJoinedSounds;
      }
      
      public function dispose() : void
      {
         this.shutdown();
      }
      
      public function reset() : void
      {
         this.shutdown();
      }
      
      public function setup(params:Object) : void
      {
         this.reset();
         this._events = new AudioSystemEventCollection(params);
         this._events.setLoaded(true,function(success:Boolean):void
         {
         });
      }
      
      public function shutdown() : void
      {
         if(Boolean(this._events))
         {
            this._events.dispose();
            this._events = null;
         }
      }
      
      public function playCountdownAudio(doneFn:Function) : void
      {
         this._events.play("countdown");
         doneFn();
      }
      
      public function stopCountdownAudio() : void
      {
         this._events.stop("countdown");
      }
      
      public function playEverybodysInOnAudio(doneFn:Function) : void
      {
         this._events.play("everybodysInOn");
         doneFn();
      }
      
      public function playEverybodysInOffAudio(doneFn:Function) : void
      {
         this._events.play("everybodysInOff");
         doneFn();
      }
      
      public function playRoomCodeDisappearAudio(doneFn:Function) : void
      {
         this._events.play("roomCodeDisappear");
         doneFn();
      }
      
      public function playPlayerJoinedAudio(p:JBGPlayer, doneFn:Function) : void
      {
         if(this._uniqueJoinedSounds)
         {
            this._events.play("playerJoined" + p.index.val);
         }
         else
         {
            this._events.play("playerJoined");
         }
         doneFn();
      }
      
      public function playLobbyBackAudio(doneFn:Function) : void
      {
         this._events.play("lobbyBack");
         doneFn();
      }
      
      public function playHideRoomCodeAudio(doneFn:Function) : void
      {
         this._events.play("hideRoomCode");
         doneFn();
      }
      
      public function playCensorAudio(doneFn:Function) : void
      {
         this._events.play("censor");
         doneFn();
      }
      
      public function playAudienceOnAudio(doneFn:Function) : void
      {
         this._events.play("audienceOn");
         doneFn();
      }
      
      public function playAudienceUpdateAudio(doneFn:Function) : void
      {
         this._events.play("audienceUpdate");
         doneFn();
      }
   }
}

