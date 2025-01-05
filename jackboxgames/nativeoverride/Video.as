package jackboxgames.nativeoverride
{
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class Video extends PausableEventDispatcher
   {
       
      
      public var loadNative:Function = null;
      
      public var playNative:Function = null;
      
      public var pauseNative:Function = null;
      
      public var resumeNative:Function = null;
      
      public var stopNative:Function = null;
      
      public var timeNative:Function = null;
      
      public var durationNative:Function = null;
      
      public var getVolumeNative:Function = null;
      
      public var setVolumeNative:Function = null;
      
      public function Video()
      {
         super();
         ExternalInterface.call("InitializeNativeOverride","Video",this);
      }
      
      public static function Initialize() : void
      {
      }
      
      public function load(str:String, loop:Boolean, videoframearray:Array = null, background:Boolean = false) : Number
      {
         if(this.loadNative != null)
         {
            this.loadNative(str,loop,videoframearray,background);
         }
         else
         {
            dispatchEvent(new Event("onError"));
         }
         return 0;
      }
      
      public function play() : void
      {
         if(this.playNative != null)
         {
            this.playNative();
         }
         else
         {
            dispatchEvent(new Event("onError"));
         }
      }
      
      public function pause() : void
      {
         if(this.pauseNative != null)
         {
            this.pauseNative();
         }
      }
      
      public function resume() : void
      {
         if(this.resumeNative != null)
         {
            this.resumeNative();
         }
      }
      
      public function stop() : void
      {
         if(this.stopNative != null)
         {
            this.stopNative();
         }
      }
      
      public function time() : Number
      {
         if(this.timeNative != null)
         {
            return this.timeNative();
         }
         return 0;
      }
      
      public function duration() : Number
      {
         if(this.durationNative != null)
         {
            return this.durationNative();
         }
         return 0;
      }
      
      public function get volume() : Number
      {
         if(this.getVolumeNative == null)
         {
            return 0;
         }
         return this.getVolumeNative();
      }
      
      public function set volume(val:Number) : void
      {
         if(this.setVolumeNative != null)
         {
            this.setVolumeNative(val);
         }
      }
      
      public function onLoaded() : void
      {
         dispatchEvent(new Event("VideoLoaded"));
      }
      
      public function onComplete() : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function onError() : void
      {
         dispatchEvent(new Event("onError"));
      }
   }
}
