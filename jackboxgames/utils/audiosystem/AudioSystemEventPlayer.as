package jackboxgames.utils.audiosystem
{
   import flash.geom.*;
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class AudioSystemEventPlayer extends PausableEventDispatcher
   {
      private var _eventName:String;
      
      private var _event:AudioEvent;
      
      private var _isLoaded:Boolean;
      
      private var _triggerCancellors:Array;
      
      public function AudioSystemEventPlayer(eventName:String)
      {
         this._triggerCancellors = [];
         super();
         this._eventName = eventName;
         this._event = AudioSystem.instance.createEventFromName(this._eventName);
         this._isLoaded = false;
      }
      
      public function dispose() : void
      {
         this._triggerCancellors.forEach(function(cancellor:Function, i:int, arr:Array):void
         {
            cancellor();
         });
         this._triggerCancellors = [];
         AudioSystem.instance.disposeEvent(this._event);
         this._event = null;
      }
      
      public function setLoaded(isLoaded:Boolean, completeFn:Function) : void
      {
         if(this._isLoaded == isLoaded)
         {
            completeFn(true);
            return;
         }
         this._isLoaded = isLoaded;
         if(this._isLoaded)
         {
            this._event.load(completeFn);
         }
         else
         {
            this._event.unload(completeFn);
         }
      }
      
      public function play(doneFn:Function = null) : void
      {
         JBGUtil.eventOnce(this._event,AudioEvent.EVENT_PLAYBACK_DONE,function(evt:EventWithData):void
         {
            if(doneFn != null)
            {
               doneFn();
            }
            dispatchEvent(evt);
         });
         this._event.play();
      }
      
      public function get isPlaying() : Boolean
      {
         return this._event.playbackState == AudioEvent.PLAYBACK_STATE_PLAYING;
      }
      
      public function stop() : void
      {
         this._event.stop();
      }
      
      public function triggerOnTimelineMarker(marker:String, triggerFn:Function) : void
      {
         var triggerCancellor:Function = null;
         var listenForMarker:Function = null;
         triggerCancellor = function():void
         {
            _event.removeEventListener(AudioEvent.EVENT_TIMELINE_MARKER,listenForMarker);
         };
         listenForMarker = function(evt:EventWithData):void
         {
            if(evt.data.name != marker)
            {
               return;
            }
            _event.removeEventListener(AudioEvent.EVENT_TIMELINE_MARKER,listenForMarker);
            if(_triggerCancellors.indexOf(triggerCancellor) >= 0)
            {
               _triggerCancellors.splice(_triggerCancellors.indexOf(triggerCancellor),1);
            }
            triggerCancellor();
            triggerFn();
         };
         this._event.addEventListener(AudioEvent.EVENT_TIMELINE_MARKER,listenForMarker);
         this._triggerCancellors.push(triggerCancellor);
      }
      
      public function setParameterValue(name:String, val:Number) : void
      {
         this._event.setParameterValue(name,val);
      }
      
      public function triggerCue() : void
      {
         this._event.triggerCue();
      }
      
      public function setLocation(flashLocation:Point) : void
      {
         AudioSystemUtil.setLocation(this._event,flashLocation);
      }
   }
}

