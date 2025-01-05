package jackboxgames.video
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import jackboxgames.logger.Logger;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class VideoPlayerBase extends PausableEventDispatcher implements IVideoPlayer
   {
       
      
      protected var Parent:DisplayObjectContainer = null;
      
      protected var _url:String;
      
      protected var _paused:Boolean;
      
      protected var _ready:Boolean;
      
      protected var _autoPlay:Boolean;
      
      protected var _failed:Boolean;
      
      protected var _loop:Boolean;
      
      protected var _looping:Boolean;
      
      protected var _length:int;
      
      protected var _duration:Number;
      
      protected var _mVideoFrameArray:Array;
      
      public function VideoPlayerBase(videoframe:MovieClip = null, parent:DisplayObjectContainer = null)
      {
         super();
         Logger.debug("VideoPlayerBase::VideoPlayerBase ()");
         this.Parent = parent;
         this._autoPlay = false;
         this._ready = false;
      }
      
      public function get length() : int
      {
         return this._length;
      }
      
      public function set autoPlay(autoplay:Boolean) : void
      {
         Logger.debug("VideoPlayerBase::autoPlay (" + autoplay + ")");
         this._autoPlay = autoplay;
      }
      
      public function load(url:String, loop:Boolean = false, background:Boolean = false) : void
      {
         Logger.debug("VideoPlayerBase::load (" + url + ", " + loop + ", " + background + ")");
         this._url = url;
         this._ready = false;
         this._failed = false;
         this._looping = false;
         this._loop = loop;
      }
      
      public function play(loop:Boolean = false) : void
      {
         Logger.debug("VideoPlayerBase:play: " + this._url + " ready=" + this._ready + " autoplay=" + this._autoPlay);
         this._loop = loop;
         if(!this._ready)
         {
            this._autoPlay = true;
            return;
         }
         if(this._failed)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function pause() : Boolean
      {
         Logger.debug("VideoPlayerBase::pause");
         if(this._paused)
         {
            return false;
         }
         this._paused = true;
         return true;
      }
      
      public function resume() : Boolean
      {
         Logger.debug("VideoPlayerBase::resume");
         if(!this._paused)
         {
            return false;
         }
         this._paused = false;
         return true;
      }
      
      public function stop() : void
      {
         Logger.debug("VideoPlayerBase::stop");
      }
      
      public function dispose() : void
      {
         Logger.debug("VideoPlayerBase::dispose");
         this._url = null;
         this._paused = false;
         this._ready = false;
         this._autoPlay = false;
         this._failed = false;
         this._loop = false;
         this._looping = false;
      }
      
      public function get volume() : Number
      {
         return 0;
      }
      
      public function set volume(val:Number) : void
      {
      }
   }
}
