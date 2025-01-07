package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.Nullable;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AudioEvent extends PausableEventDispatcher
   {
      public static const EVENT_PLAYBACK_DONE:String = "PlaybackDone";
      
      public static const EVENT_TIMELINE_MARKER:String = "TimelineMarker";
      
      public static const EVENT_BEAT:String = "Beat";
      
      public static const PLAYBACK_STATE_PLAYING:String = "playing";
      
      public static const PLAYBACK_STATE_SUSTAINING:String = "sustaining";
      
      public static const PLAYBACK_STATE_STOPPED:String = "stopped";
      
      public static const PLAYBACK_STATE_STARTING:String = "starting";
      
      public static const PLAYBACK_STATE_STOPPING:String = "stopping";
      
      public static const PLAYBACK_STATE_INVALID:String = "invalid";
      
      private var _name:String;
      
      private var _onLoadCompleteCallback:Function;
      
      private var _onUnloadCompleteCallback:Function;
      
      public var ctorNative:Function;
      
      public var disposeNative:Function;
      
      public var loadNative:Function;
      
      public var unloadNative:Function;
      
      public var playNative:Function = null;
      
      public var stopNative:Function = null;
      
      public var setPausedNative:Function = null;
      
      public var getPausedNative:Function = null;
      
      public var triggerCueNative:Function = null;
      
      public var setVolumeNative:Function = null;
      
      public var getVolumeNative:Function = null;
      
      public var setPositionNative:Function = null;
      
      public var getPositionNative:Function = null;
      
      public var setParameterValueNative:Function = null;
      
      public var getParameterValueNative:Function = null;
      
      public var getPlaybackStateNative:Function = null;
      
      public function AudioEvent(name:String, path:String = null)
      {
         super();
         this._name = name;
         this._onLoadCompleteCallback = Nullable.NULL_FUNCTION;
         this._onUnloadCompleteCallback = Nullable.NULL_FUNCTION;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","AudioEvent",this);
            if(this.ctorNative != null)
            {
               this.ctorNative(name,path);
            }
         }
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function dispose() : void
      {
         this._name = null;
         this._onLoadCompleteCallback = Nullable.NULL_FUNCTION;
         this._onUnloadCompleteCallback = Nullable.NULL_FUNCTION;
         if(this.disposeNative != null)
         {
            this.disposeNative();
            this.disposeNative = null;
         }
         this.ctorNative = null;
         this.loadNative = null;
         this.unloadNative = null;
         this.playNative = null;
         this.stopNative = null;
         this.setPausedNative = null;
         this.getPausedNative = null;
         this.triggerCueNative = null;
         this.setVolumeNative = null;
         this.getVolumeNative = null;
         this.setPositionNative = null;
         this.getPositionNative = null;
         this.setParameterValueNative = null;
         this.getParameterValueNative = null;
         this.getPlaybackStateNative = null;
      }
      
      public function get isValid() : Boolean
      {
         return this.ctorNative != null;
      }
      
      public function load(loadComplete:Function) : void
      {
         if(this.loadNative == null)
         {
            loadComplete(false);
            return;
         }
         this._onLoadCompleteCallback = loadComplete;
         this.loadNative();
      }
      
      public function onLoadComplete(success:Boolean) : void
      {
         var callMe:Function = this._onLoadCompleteCallback;
         this._onLoadCompleteCallback = Nullable.NULL_FUNCTION;
         callMe(success);
      }
      
      public function unload(unloadComplete:Function) : void
      {
         if(this.unloadNative == null)
         {
            unloadComplete(false);
            return;
         }
         this._onUnloadCompleteCallback = unloadComplete;
         this.unloadNative();
      }
      
      public function onUnloadComplete(success:Boolean) : void
      {
         var callMe:Function = this._onUnloadCompleteCallback;
         this._onUnloadCompleteCallback = Nullable.NULL_FUNCTION;
         callMe(success);
      }
      
      public function play() : void
      {
         if(this.playNative != null)
         {
            this.playNative();
         }
         else
         {
            this.onPlaybackDone(false);
         }
      }
      
      public function stop() : void
      {
         if(this.stopNative != null)
         {
            this.stopNative();
         }
         else
         {
            this.onPlaybackDone(true);
         }
      }
      
      public function set paused(val:Boolean) : void
      {
         if(this.setPausedNative != null)
         {
            this.setPausedNative(val);
         }
      }
      
      public function get paused() : Boolean
      {
         return this.getPausedNative != null ? this.getPausedNative() : false;
      }
      
      public function triggerCue() : void
      {
         if(this.triggerCueNative != null)
         {
            this.triggerCueNative();
         }
      }
      
      public function set volume(val:Number) : void
      {
         if(this.setVolumeNative != null)
         {
            this.setVolumeNative(val);
         }
      }
      
      public function get volume() : Number
      {
         return this.getVolumeNative != null ? this.getVolumeNative() : 0;
      }
      
      public function set position(val:int) : void
      {
         if(this.setPositionNative != null)
         {
            this.setPositionNative(val);
         }
      }
      
      public function get position() : int
      {
         return this.getPositionNative != null ? this.getPositionNative() : int(0);
      }
      
      public function setParameterValue(name:String, val:Number) : void
      {
         if(this.setParameterValueNative != null)
         {
            this.setParameterValueNative(name,val);
         }
      }
      
      public function getParameterValue(name:String) : Number
      {
         return this.getParameterValueNative != null ? this.getParameterValueNative(name) : 0;
      }
      
      public function get playbackState() : String
      {
         return this.getPlaybackStateNative != null ? this.getPlaybackStateNative() : PLAYBACK_STATE_INVALID;
      }
      
      public function onPlaybackDone(stoppedManually:Boolean) : void
      {
         dispatchEvent(new EventWithData(EVENT_PLAYBACK_DONE,stoppedManually));
      }
      
      public function onTimelineMarker(data:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_TIMELINE_MARKER,data));
      }
      
      public function onBeat(data:Object) : void
      {
         dispatchEvent(new EventWithData(EVENT_BEAT,data));
      }
   }
}

