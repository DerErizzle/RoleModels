package jackboxgames.video
{
   import flash.display.*;
   import flash.events.*;
   import flash.media.*;
   import flash.net.*;
   import jackboxgames.engine.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class VideoPlayerFlash extends VideoPlayerBase implements IVideoPlayer
   {
      private static var VIDEOS:Array = [];
      
      private static var ALL_PAUSED:Boolean = false;
      
      private var _flashVideo:Video;
      
      private var _videoX:Number;
      
      private var _videoY:Number;
      
      private var _connection:NetConnection;
      
      private var _stream:NetStream;
      
      private var _timerHack:PausableTimer;
      
      public function VideoPlayerFlash(videoframe:MovieClip = null, parent:DisplayObjectContainer = null)
      {
         var videoClient:Object;
         super(videoframe,parent);
         this._timerHack = new PausableTimer(15000,1);
         this._timerHack.addEventListener(TimerEvent.TIMER_COMPLETE,function(evt:TimerEvent):void
         {
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
      }
      
      public static function pauseAll() : void
      {
         var v:VideoPlayerFlash = null;
         if(ALL_PAUSED)
         {
            return;
         }
         ALL_PAUSED = true;
         for each(v in VIDEOS)
         {
            v.pause();
         }
      }
      
      public static function resumeAll() : void
      {
         var v:VideoPlayerFlash = null;
         if(!ALL_PAUSED)
         {
            return;
         }
         ALL_PAUSED = false;
         for each(v in VIDEOS)
         {
            v.resume();
         }
      }
      
      public function get video() : Video
      {
         return this._flashVideo;
      }
      
      override public function load(url:String, loop:Boolean = false, background:Boolean = false) : void
      {
         super.load(url + BuildConfig.instance.configVal("video-extension"),loop,background);
         this._stream.play(_url);
      }
      
      override public function play(loop:Boolean = false) : void
      {
         var v:* = undefined;
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
         if(_loop)
         {
            this._flashVideo.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         for each(v in VIDEOS)
         {
            if(v == this)
            {
               return;
            }
         }
         VIDEOS.push(this);
      }
      
      private function _pauseListener(event:Event) : void
      {
         if(this.pause())
         {
         }
      }
      
      private function _resumeListener(event:Event) : void
      {
         if(this.resume())
         {
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
            if(_loop)
            {
               this._flashVideo.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            }
            this._stream.pause();
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
         for(var i:uint = 0; i < VIDEOS.length; i++)
         {
            if(VIDEOS[i] == this)
            {
               VIDEOS.splice(i,1);
               return;
            }
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
         if(!this._stream)
         {
            return;
         }
         var newTransform:SoundTransform = new SoundTransform(val,0);
         this._stream.soundTransform = newTransform;
      }
      
      private function handleError(event:Event) : void
      {
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
               if(this._timerHack != null)
               {
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
                  if(ALL_PAUSED)
                  {
                     this._stream.pause();
                     return;
                  }
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
               if(_loop)
               {
                  _looping = true;
                  this._stream.seek(0);
               }
               break;
            case "NetStream.Play.Stop":
               if(_loop)
               {
                  _looping = true;
                  this._stream.seek(0);
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
               break;
            case "NetStream.Play.StreamNotFound":
               _failed = true;
               this.handleError(null);
               break;
            case "NetStream.Seek.Notify":
               _looping = false;
         }
      }
      
      private function onMetaData(metadata:Object) : void
      {
         _length = int(metadata.duration * 1000) + 1;
         _duration = metadata.duration;
         if(_ready && _looping == false)
         {
            dispatchEvent(new Event("VideoLoaded"));
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(_looping == false && _duration > 0 && this._stream != null && this._stream.time > _duration - 0.05)
         {
            _looping = true;
            this._stream.seek(0);
         }
      }
   }
}

