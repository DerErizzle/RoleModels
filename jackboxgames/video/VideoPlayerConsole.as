package jackboxgames.video
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.media.SoundTransform;
   import flash.media.Video;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import jackboxgames.engine.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class VideoPlayerConsole extends VideoPlayerBase implements IVideoPlayer
   {
       
      
      private var _flashVideo:Video;
      
      private var _videoX:Number;
      
      private var _videoY:Number;
      
      private var _connection:NetConnection;
      
      private var _stream:NetStream;
      
      private var _seekToPausedTime:Number;
      
      private var _timerHack:PausableTimer;
      
      public function VideoPlayerConsole(videoframe:MovieClip = null, parent:DisplayObjectContainer = null)
      {
         var videoClient:Object;
         super(videoframe,parent);
         Logger.debug("VideoPlayerConsole Initializing new flash.media.Video");
         this._timerHack = new PausableTimer(15000,1);
         this._timerHack.addEventListener(TimerEvent.TIMER_COMPLETE,function(evt:TimerEvent):void
         {
            Logger.debug("VideoPlayerConsole::VideoPlayerConsole () init timeout!");
            handleError(null);
            _timerHack = null;
         });
         this._timerHack.start();
         if(videoframe != null)
         {
            this._flashVideo = new Video(videoframe.width,videoframe.height);
            this._flashVideo.x = videoframe.x;
            this._flashVideo.y = videoframe.y;
            this._videoX = videoframe.x;
            this._videoY = videoframe.y;
         }
         else
         {
            this._flashVideo = new Video(StageRef.stageWidth,StageRef.stageHeight);
            this._videoX = 0;
            this._videoY = 0;
         }
         if(EnvUtil.isDebug())
         {
            Logger.debug("VideoPlayer::VideoPlayer () " + this._flashVideo.x + ", " + this._flashVideo.y + ", " + this._flashVideo.width + ", " + this._flashVideo.height);
         }
         this._connection = new NetConnection();
         this._connection.addEventListener(NetStatusEvent.NET_STATUS,this.handleNetStatus);
         this._connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
         this._connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.handleError);
         this._connection.addEventListener(IOErrorEvent.IO_ERROR,this.handleError);
         this._connection.connect(null);
         this._stream = new NetStream(this._connection);
         this._stream.addEventListener(NetStatusEvent.NET_STATUS,this.handleNetStatus);
         this._stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.handleError);
         this._stream.addEventListener(IOErrorEvent.IO_ERROR,this.handleError);
         _length = -1;
         _duration = 0;
         videoClient = new Object();
         videoClient.onMetaData = this.onMetaData;
         this._stream.client = videoClient;
         this._flashVideo.attachNetStream(this._stream);
         this._stream.bufferTime = 0;
         this._flashVideo.smoothing = true;
         Logger.debug("VideoPlayerConsole::VideoPlayerConsole() ended " + this._flashVideo.width + " x " + this._flashVideo.height);
      }
      
      public function get video() : Video
      {
         return this._flashVideo;
      }
      
      override public function load(url:String, loop:Boolean = false, background:Boolean = false) : void
      {
         super.load(url + BuildConfig.instance.configVal("video-extension"),loop,background);
         Logger.debug("VideoPlayer::load (" + url + ", " + loop + ") calling _stream.play");
         this._stream.play(_url);
         Logger.debug("VideoPlayer::load (" + url + ", " + loop + ") called _stream.play");
      }
      
      override public function play(loop:Boolean = false) : void
      {
         super.play(loop);
         if(!_ready)
         {
            return;
         }
         this._flashVideo.x = this._videoX;
         this._flashVideo.y = this._videoY;
         this._stream.resume();
         if(Parent != null)
         {
            Parent.addChild(this._flashVideo);
         }
         else
         {
            Logger.debug("VideoPlayerConsole::play no parent set");
         }
         (this._stream as Object).loop = _loop;
         GameEngine.instance.addEventListener("pause",this._pauseListener);
      }
      
      private function _pauseListener(event:Event) : void
      {
         if(this.pause())
         {
            this._seekToPausedTime = this._stream.time;
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
            this._stream.seek(this._seekToPausedTime);
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
         this._stream.pause();
         return true;
      }
      
      override public function resume() : Boolean
      {
         if(!super.resume())
         {
            return false;
         }
         this._stream.resume();
         return true;
      }
      
      override public function stop() : void
      {
         super.stop();
         if(this._stream != null && this._flashVideo != null)
         {
            GameEngine.instance.removeEventListener("reboot",this._resumeListener);
            GameEngine.instance.removeEventListener("kill",this._resumeListener);
            GameEngine.instance.removeEventListener("resume",this._resumeListener);
            GameEngine.instance.removeEventListener("pause",this._pauseListener);
            if(!_paused)
            {
               this._stream.pause();
            }
            _loop = false;
            _looping = false;
            if(Parent != null)
            {
               if(Parent.contains(this._flashVideo))
               {
                  Parent.removeChild(this._flashVideo);
               }
            }
            _autoPlay = false;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._timerHack != null)
         {
            this._timerHack.stop();
            this._timerHack = null;
         }
         if(this._flashVideo != null)
         {
            this._flashVideo.clear();
            this._flashVideo.attachNetStream(null);
            this._flashVideo = null;
         }
         if(this._stream != null)
         {
            this._stream.removeEventListener(NetStatusEvent.NET_STATUS,this.handleNetStatus);
            this._stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,this.handleError);
            this._stream.removeEventListener(IOErrorEvent.IO_ERROR,this.handleError);
            this._stream.close();
            this._stream = null;
         }
         if(this._connection != null)
         {
            this._connection.removeEventListener(NetStatusEvent.NET_STATUS,this.handleNetStatus);
            this._connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
            this._connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,this.handleError);
            this._connection.removeEventListener(IOErrorEvent.IO_ERROR,this.handleError);
            this._connection.close();
            this._connection = null;
         }
      }
      
      override public function get volume() : Number
      {
         if(!this._stream)
         {
            return 0;
         }
         return this._stream.soundTransform.volume;
      }
      
      override public function set volume(val:Number) : void
      {
         Logger.debug("VideoPlayerConsole::VideoPlayerConsole() settings volume to: " + val);
         if(!this._stream)
         {
            return;
         }
         var newTransform:SoundTransform = new SoundTransform(val,0);
         this._stream.soundTransform = newTransform;
         Logger.debug("VideoPlayerConsole::VideoPlayerConsole() Done setting volume");
      }
      
      private function handleError(event:Event) : void
      {
         Logger.debug("VideoPlayerConsole::handleError");
         if(this._timerHack != null)
         {
            this._timerHack.stop();
            this._timerHack = null;
         }
         dispatchEvent(new Event("onError"));
      }
      
      private function handleNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case "NetStream.Play.Start":
               Logger.debug("VideoPlayerConsole: Netstream.Play.Start. autoPlay=" + _autoPlay + " ready=" + _ready);
               Logger.debug("VideoPlayerConsole: Video dimensions : (" + this._flashVideo.videoWidth + "x" + this._flashVideo.videoHeight + ")");
               if(this._timerHack != null)
               {
                  Logger.debug("VideoPlayerConsole::handleNetStatus stopping _timerHack");
                  this._timerHack.stop();
                  this._timerHack = null;
               }
               if(!_autoPlay)
               {
                  if(!_ready)
                  {
                     this._stream.pause();
                     _ready = true;
                  }
               }
               else
               {
                  this._stream.resume();
                  if(Parent != null)
                  {
                     Parent.addChild(this._flashVideo);
                  }
                  _ready = true;
               }
               if(_length != -1)
               {
                  dispatchEvent(new Event("VideoLoaded"));
               }
               break;
            case "NetStream.Buffer.Empty":
               Logger.debug("VideoPlayerConsole: NetStream.Buffer.Empty.");
               if(_loop)
               {
                  _looping = true;
                  Logger.debug("VideoPlayerConsole: NetStream.Buffer.Empty loop seek (0).");
                  this._stream.seek(0);
               }
               break;
            case "NetStream.Play.Stop":
               Logger.debug("VideoPlayerConsole: Netstream.Play.Stop. _loop =" + _loop);
               if(_loop)
               {
                  this._stream.play(_url);
               }
               else
               {
                  if(Parent != null)
                  {
                     Parent.removeChild(this._flashVideo);
                  }
                  dispatchEvent(new Event(Event.COMPLETE));
               }
               break;
            case "NetConnection.Connect.Success":
               Logger.debug("VideoPlayerConsole: NetConnection.Connect.Success.");
               break;
            case "NetStream.Play.StreamNotFound":
               _failed = true;
               Logger.debug("VideoPlayerConsole: Unable to locate video: " + _url);
               this.handleError(null);
               break;
            case "NetStream.Seek.Notify":
               _looping = false;
               Logger.debug("VideoPlayerConsole: Seeking.");
               break;
            default:
               Logger.debug("VideoPlayerConsole: Unhandled status \"" + event.info.code + "\"");
         }
      }
      
      private function onMetaData(metadata:Object) : void
      {
         _length = int(metadata.duration * 1000) + 1;
         _duration = metadata.duration;
         Logger.debug("VideoPlayerConsole:onMetaData(): Length of video from metadata = " + _length);
         if(_ready && _looping == false)
         {
            dispatchEvent(new Event("VideoLoaded"));
         }
      }
   }
}
