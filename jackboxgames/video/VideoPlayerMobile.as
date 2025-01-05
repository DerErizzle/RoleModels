package jackboxgames.video
{
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.media.*;
   import jackboxgames.engine.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class VideoPlayerMobile extends VideoPlayerBase implements IVideoPlayer
   {
       
      
      private var _nativeVideo:jackboxgames.nativeoverride.Video;
      
      public function VideoPlayerMobile(videoframe:MovieClip = null, parent:DisplayObjectContainer = null)
      {
         var topLevelVideoFrame:Rectangle = null;
         var screenDimensions:Object = null;
         var scaleX:Number = NaN;
         var scaleY:Number = NaN;
         var scale:Number = NaN;
         super(videoframe,parent);
         Logger.debug("Initializing new jackboxgames.nativeoverride.Video");
         this._nativeVideo = new jackboxgames.nativeoverride.Video();
         if(videoframe != null)
         {
            topLevelVideoFrame = videoframe.getBounds(StageRef);
            if(EnvUtil.isDebug())
            {
               Logger.debug("topLevelVideoFrame = " + topLevelVideoFrame.x + ", " + topLevelVideoFrame.y + ", " + topLevelVideoFrame.width + ", " + topLevelVideoFrame.height);
               Logger.debug("topLevelVideoFrame top left = " + (topLevelVideoFrame.x - topLevelVideoFrame.width / 2) + ", " + (topLevelVideoFrame.y - topLevelVideoFrame.height / 2) + ", " + topLevelVideoFrame.width + ", " + topLevelVideoFrame.height);
            }
            screenDimensions = Platform.instance.screenDimensions;
            scaleX = screenDimensions.width / StageRef.stageWidth;
            scaleY = screenDimensions.height / StageRef.stageHeight;
            scale = Math.min(scaleX,scaleY);
            _mVideoFrameArray = new Array();
            _mVideoFrameArray.push(int(Math.ceil(scale * Number(topLevelVideoFrame.x))));
            _mVideoFrameArray.push(int(Math.ceil(scale * Number(topLevelVideoFrame.y))));
            _mVideoFrameArray.push(int(Math.ceil(scale * Number(topLevelVideoFrame.width))));
            _mVideoFrameArray.push(int(Math.ceil(scale * Number(topLevelVideoFrame.height))));
         }
         else
         {
            _mVideoFrameArray = null;
         }
         if(EnvUtil.isDebug())
         {
            Logger.debug("StageRef.stageWidth = " + StageRef.stageWidth + ", StageRef.stageHeight = " + StageRef.stageHeight + ", scaleX = " + scaleX + ", scaleY = " + scaleY);
            Logger.debug(TraceUtil.objectRecursive(screenDimensions,"screenDimensions"));
            Logger.debug(TraceUtil.objectRecursive(_mVideoFrameArray,"_mVideoFrameArray"));
         }
      }
      
      override public function load(url:String, loop:Boolean = false, background:Boolean = false) : void
      {
         super.load(url + BuildConfig.instance.configVal("video-extension"),loop,background);
         this._nativeVideo.addEventListener("VideoLoaded",this.handleLoaded);
         this._nativeVideo.addEventListener("onError",this.handleError);
         this._nativeVideo.load(_url,loop,_mVideoFrameArray,background);
         if(_autoPlay)
         {
            this._nativeVideo.play();
         }
      }
      
      override public function play(loop:Boolean = false) : void
      {
         super.play(loop);
         if(!_ready)
         {
            return;
         }
         this._nativeVideo.play();
         GameEngine.instance.addEventListener("pause",this._pauseListener);
      }
      
      private function _pauseListener(event:Event) : void
      {
         if(this.pause())
         {
            GameEngine.instance.removeEventListener("pause",this._pauseListener);
            GameEngine.instance.addEventListener("resume",this._resumeListener);
            GameEngine.instance.addEventListener("reboot",this._resumeListener);
            GameEngine.instance.addEventListener("kill",this._resumeListener);
         }
      }
      
      private function _resumeListener(event:Event) : void
      {
         if(this.resume())
         {
            GameEngine.instance.removeEventListener("reboot",this._resumeListener);
            GameEngine.instance.removeEventListener("kill",this._resumeListener);
            GameEngine.instance.removeEventListener("resume",this._resumeListener);
            GameEngine.instance.addEventListener("pause",this._pauseListener);
         }
      }
      
      override public function pause() : Boolean
      {
         if(!super.pause())
         {
            return false;
         }
         this._nativeVideo.pause();
         return true;
      }
      
      override public function resume() : Boolean
      {
         if(!super.resume())
         {
            return false;
         }
         this._nativeVideo.resume();
         return true;
      }
      
      override public function stop() : void
      {
         super.stop();
         if(Boolean(this._nativeVideo))
         {
            this._nativeVideo.stop();
         }
         GameEngine.instance.removeEventListener("reboot",this._resumeListener);
         GameEngine.instance.removeEventListener("kill",this._resumeListener);
         GameEngine.instance.removeEventListener("resume",this._resumeListener);
         GameEngine.instance.removeEventListener("pause",this._pauseListener);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._nativeVideo != null)
         {
            this._nativeVideo.removeEventListener("VideoLoaded",this.handleLoaded);
            this._nativeVideo.removeEventListener("onError",this.handleError);
            this._nativeVideo.removeEventListener(Event.COMPLETE,this.handleComplete);
            this._nativeVideo = null;
         }
         GameEngine.instance.removeEventListener("reboot",this._resumeListener);
         GameEngine.instance.removeEventListener("kill",this._resumeListener);
         GameEngine.instance.removeEventListener("resume",this._resumeListener);
         GameEngine.instance.removeEventListener("pause",this._pauseListener);
      }
      
      override public function get volume() : Number
      {
         if(!this._nativeVideo)
         {
            return 0;
         }
         return this._nativeVideo.volume;
      }
      
      override public function set volume(val:Number) : void
      {
         if(!this._nativeVideo)
         {
            return;
         }
         this._nativeVideo.volume = val;
      }
      
      private function handleError(event:Event) : void
      {
         Logger.debug("VideoPlayerMobile::handleError");
         if(this._nativeVideo != null)
         {
            this._nativeVideo.removeEventListener("VideoLoaded",this.handleLoaded);
            this._nativeVideo.removeEventListener("onError",this.handleError);
            this._nativeVideo.removeEventListener(Event.COMPLETE,this.handleComplete);
            dispatchEvent(new Event("onError"));
         }
      }
      
      private function handleLoaded(event:Event) : void
      {
         Logger.debug("VideoPlayerMobile::handleLoaded");
         _ready = true;
         this._nativeVideo.removeEventListener("VideoLoaded",this.handleLoaded);
         dispatchEvent(new Event("VideoLoaded"));
         this._nativeVideo.addEventListener(Event.COMPLETE,this.handleComplete);
         if(_autoPlay)
         {
            this._nativeVideo.play();
         }
      }
      
      private function handleComplete(event:Event) : void
      {
         Logger.debug("VideoPlayerMobile::handleComplete ()");
         this._nativeVideo.removeEventListener("onError",this.handleError);
         this._nativeVideo.removeEventListener(Event.COMPLETE,this.handleComplete);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}
