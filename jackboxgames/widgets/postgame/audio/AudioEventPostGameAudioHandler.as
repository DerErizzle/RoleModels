package jackboxgames.widgets.postgame.audio
{
   import jackboxgames.utils.audiosystem.AudioSystemEventCollection;
   
   public class AudioEventPostGameAudioHandler implements IPostGameAudioHandler
   {
      private var _events:AudioSystemEventCollection;
      
      public function AudioEventPostGameAudioHandler()
      {
         super();
      }
      
      public function dispose() : void
      {
         this.shutdown();
      }
      
      public function reset() : void
      {
         this.shutdown();
      }
      
      public function shutdown() : void
      {
         if(Boolean(this._events))
         {
            this._events.dispose();
            this._events = null;
         }
      }
      
      public function setup(params:Object) : void
      {
         this.shutdown();
         this._events = new AudioSystemEventCollection(params);
         this._events.setLoaded(true,function(success:Boolean):void
         {
         });
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
      
      public function playChoiceMadeAudio(doneFn:Function) : void
      {
         this._events.play("choiceMade");
         doneFn();
      }
      
      public function playBackAudio(doneFn:Function) : void
      {
         this._events.play("back");
         doneFn();
      }
      
      public function playSettingsPopUpAudio(doneFn:Function) : void
      {
         this._events.play("settingsPopUp");
         doneFn();
      }
   }
}

