package jackboxgames.audio
{
   import com.greensock.easing.SineOut;
   import jackboxgames.animation.tween.JBGTween;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.Duration;
   import jackboxgames.utils.JBGUtil;
   
   public class JBGLoopingSoundPlayer
   {
       
      
      private var _playingUrl:String;
      
      private var _currentSound:JBGSound;
      
      private var _previousSound:JBGSound;
      
      private var _faderTween:JBGTween;
      
      private var _volumeTween:JBGTween;
      
      public function JBGLoopingSoundPlayer()
      {
         super();
      }
      
      public function get volume() : Number
      {
         return this._currentSound.volume;
      }
      
      public function set volume(val:Number) : void
      {
         this._currentSound.volume = val;
      }
      
      public function get position() : Number
      {
         return this._currentSound.position;
      }
      
      public function play(urlNoExtension:String, volume:Number = 1, crossFadeTime:Number = 0, position:Number = 0) : void
      {
         if(urlNoExtension == this._playingUrl)
         {
            if(Boolean(this._currentSound))
            {
               this._currentSound.volume = volume;
            }
            return;
         }
         this._cancelCrossFade();
         this._cancelVolumeFade();
         this._previousSound = this._currentSound;
         this._currentSound = null;
         this._playingUrl = urlNoExtension;
         this._currentSound = JBGSoundPlayer.instance.createFromUrl(this._playingUrl,true,true,function():Number
         {
            return position;
         },function():void
         {
            if(position > 0)
            {
               if(Boolean(_previousSound))
               {
                  _previousSound.stop();
                  _previousSound.dispose();
                  _previousSound = null;
               }
            }
         });
         if(crossFadeTime > 0)
         {
            this._faderTween = new JBGTween(new JBGCrossFader(this._previousSound,this._currentSound,volume),Duration.fromSec(crossFadeTime),{"fadeAmount":1},SineOut);
            JBGUtil.eventOnce(this._faderTween,JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
            {
               _cancelCrossFade();
            });
            this._currentSound.volume = 0;
         }
         else
         {
            if(position == 0)
            {
               if(Boolean(this._previousSound))
               {
                  this._previousSound.stop();
                  this._previousSound.dispose();
                  this._previousSound = null;
               }
            }
            this._currentSound.volume = volume;
         }
      }
      
      private function _cancelCrossFade() : void
      {
         if(Boolean(this._previousSound))
         {
            this._previousSound.stop();
            this._previousSound.dispose();
            this._previousSound = null;
         }
         if(Boolean(this._faderTween))
         {
            this._faderTween.dispose();
            this._faderTween = null;
         }
      }
      
      public function fadeVolume(newVolume:Number, fadeTime:Number, callback:Function = null) : void
      {
         this._volumeTween = new JBGTween(this._currentSound,Duration.fromSec(fadeTime),{"volume":newVolume},SineOut);
         JBGUtil.eventOnce(this._volumeTween,JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
         {
            _cancelVolumeFade();
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      private function _cancelVolumeFade() : void
      {
         if(Boolean(this._volumeTween))
         {
            this._volumeTween.dispose();
            this._volumeTween = null;
         }
      }
      
      public function stop() : void
      {
         this._playingUrl = null;
         if(Boolean(this._currentSound))
         {
            this._currentSound.stop();
            this._currentSound.dispose();
            this._currentSound = null;
         }
         this._cancelCrossFade();
         this._cancelVolumeFade();
      }
   }
}
