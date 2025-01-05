package jackboxgames.utils.audiosystem
{
   import flash.events.IEventDispatcher;
   import jackboxgames.events.AudioRequestEvent;
   
   public class AudioRequestEventHandler
   {
       
      
      private var _dispatcher:IEventDispatcher;
      
      private var _audioEventStack:AudioEventRegistrationStack;
      
      public function AudioRequestEventHandler(dispatcher:IEventDispatcher, audioEventStack:AudioEventRegistrationStack)
      {
         super();
         this._dispatcher = dispatcher;
         this._audioEventStack = audioEventStack;
         this._dispatcher.addEventListener(AudioRequestEvent.PLAY_AUDIO_EVENT,this._playAudio);
      }
      
      public function dispose() : void
      {
         this._dispatcher.removeEventListener(AudioRequestEvent.PLAY_AUDIO_EVENT,this._playAudio);
      }
      
      private function _playAudio(evt:AudioRequestEvent) : void
      {
         this._audioEventStack.play(evt.eventKey);
      }
   }
}
