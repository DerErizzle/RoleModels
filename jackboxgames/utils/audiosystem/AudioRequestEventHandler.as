package jackboxgames.utils.audiosystem
{
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import jackboxgames.events.AudioRequestEvent;
   import jackboxgames.logger.Logger;
   
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
         Logger.debug("Received AudioRequestEvent with key = " + evt.eventKey);
         this._audioEventStack.play(evt.eventKey).then(function(player:AudioSystemEventPlayer):void
         {
            var sourceMc:MovieClip = null;
            var bounds:Rectangle = null;
            var point:Point = null;
            if(!player)
            {
               return;
            }
            if(evt.target is MovieClip)
            {
               sourceMc = MovieClip(evt.target);
               bounds = sourceMc.getBounds(sourceMc.stage);
               point = new Point(bounds.x + bounds.width / 2,bounds.y + bounds.height / 2);
               player.setLocation(point);
            }
         });
      }
   }
}

