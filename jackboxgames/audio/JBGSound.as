package jackboxgames.audio
{
   import flash.events.Event;
   import flash.events.SampleDataEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import jackboxgames.loader.*;
   import jackboxgames.logger.Logger;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class JBGSound extends PausableEventDispatcher
   {
      private const SAMPLE_RATE:Number = 44100;
      
      private const BUFFER_SIZE:int = 8192;
      
      private const FRAME_SIZE:int = 1152;
      
      private var _loadedSound:Sound;
      
      private var _ownsLoadedSound:Boolean;
      
      private var _outputSound:Sound;
      
      private var _ownsOutputSound:Boolean;
      
      private var _channel:SoundChannel;
      
      private var _pausePosition:int;
      
      private var _playing:Boolean;
      
      private var _loop:Boolean;
      
      private var _autoPlay:Boolean;
      
      private var _volume:Number;
      
      private var _useSampleData:Boolean;
      
      private var _samplePosition:Number;
      
      private var _sampleTarget:int;
      
      private var _sampleStartPosition:int;
      
      private var _sampleEndPosition:int;
      
      public function JBGSound(loop:Boolean = false, autoPlay:Boolean = true)
      {
         super();
         this._loop = loop;
         this._useSampleData = EnvUtil.isAIR() ? this._loop : false;
         this._autoPlay = autoPlay;
         this._volume = 1;
         this._pausePosition = 0;
         this._outputSound = new Sound();
         this._ownsOutputSound = true;
         this._ownsLoadedSound = false;
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function set volume(volume:Number) : void
      {
         this._volume = volume;
         this._applyVolume();
      }
      
      public function get isPlaying() : Boolean
      {
         return this._playing;
      }
      
      public function get position() : Number
      {
         var position:Number = Boolean(this._channel) ? this._channel.position : 0;
         var sourceSound:Sound = Boolean(this._loadedSound) ? this._loadedSound : this._outputSound;
         if(sourceSound.length == 0)
         {
            return 0;
         }
         while(position >= sourceSound.length)
         {
            position -= sourceSound.length;
         }
         return position;
      }
      
      public function loadFromSound(s:Sound, getPositionFn:Function = null, onLoadComplete:Function = null, onLoadError:Function = null) : void
      {
         this._loadedSound = s;
         this._ownsLoadedSound = false;
         this._finishLoad(getPositionFn,onLoadComplete,onLoadError);
      }
      
      public function loadFromUrl(url:String, getPositionFn:Function = null, onLoadComplete:Function = null, onLoadError:Function = null) : void
      {
         var soundLoad:SoundLoader = JBGLoader.instance.loadFile(url,function(result:Object):void
         {
            _loadedSound = result.data;
            _ownsLoadedSound = true;
            if(!_loadedSound)
            {
               Logger.debug("Error loading " + url + ".  Result was not a SoundLoad.");
               if(onLoadError != null)
               {
                  onLoadError();
               }
               return;
            }
            _finishLoad(getPositionFn,onLoadComplete,onLoadError);
         }) as SoundLoader;
      }
      
      private function _finishLoad(getPositionFn:Function, onLoadComplete:Function, onLoadError:Function) : void
      {
         var metadata:Object = null;
         var tempBytes:ByteArray = null;
         var totalSamples:int = 0;
         var samplesToCutFromEnd:int = 0;
         var samplesToCutFromStart:int = 0;
         if(this._useSampleData)
         {
            if(this._loadedSound.id3.comment != null)
            {
               try
               {
                  metadata = JSON.deserialize(this._loadedSound.id3.comment) as Object;
                  this._sampleTarget = Boolean(metadata) ? int(metadata.s) : 0;
               }
               catch(err:Error)
               {
               }
            }
            if(this._sampleTarget == 0)
            {
               this._sampleTarget = Math.floor(this.SAMPLE_RATE / 1000 * this._loadedSound.length);
               this._sampleStartPosition = 0;
               this._sampleEndPosition = this._sampleTarget;
            }
            else
            {
               tempBytes = new ByteArray();
               tempBytes.endian = Endian.LITTLE_ENDIAN;
               totalSamples = Math.floor(this._loadedSound.length * (this.SAMPLE_RATE / 1000));
               samplesToCutFromEnd = 1152;
               samplesToCutFromEnd += Math.floor(this._sampleTarget % this.FRAME_SIZE);
               samplesToCutFromStart = 1152;
               samplesToCutFromStart += Math.max(0,Math.floor(totalSamples - this._sampleTarget - this.FRAME_SIZE * 2 - this._sampleTarget % this.FRAME_SIZE));
               this._sampleStartPosition = Math.abs(samplesToCutFromStart);
               this._sampleEndPosition = totalSamples - samplesToCutFromEnd;
            }
         }
         else
         {
            if(this._outputSound != this._loadedSound)
            {
               this._outputSound = this._loadedSound;
               this._ownsOutputSound = this._ownsLoadedSound;
            }
            this._loadedSound = null;
            this._ownsLoadedSound = false;
         }
         if(this._autoPlay)
         {
            this.play(getPositionFn == null ? 0 : getPositionFn());
         }
         if(onLoadComplete != null)
         {
            onLoadComplete();
         }
      }
      
      public function play(position:Number = 0) : void
      {
         if(!this._outputSound)
         {
            return;
         }
         if(this._playing)
         {
            this.stop();
         }
         this._playing = true;
         if(this._useSampleData)
         {
            this._outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA,this.onSampleData);
            this._samplePosition = this._sampleStartPosition;
            this._samplePosition += this.SAMPLE_RATE * (position / 1000);
         }
         this._pausePosition = position;
         var st:SoundTransform = new SoundTransform(this._volume,0);
         this._channel = this._outputSound.play(position,this._loop ? int.MAX_VALUE : 0,st);
         if(!this._channel)
         {
            this._playing = false;
            dispatchEvent(new Event(Event.SOUND_COMPLETE));
            return;
         }
         this._channel.addEventListener(Event.SOUND_COMPLETE,this.onSfxComplete);
         this._applyVolume();
      }
      
      public function stop() : void
      {
         if(!this._playing)
         {
            return;
         }
         this._pausePosition = 0;
         this._playing = false;
         if(Boolean(this._channel))
         {
            if(this._useSampleData)
            {
               this._outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA,this.onSampleData);
            }
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.onSfxComplete);
            this._channel.stop();
            this._channel = null;
         }
      }
      
      public function pause() : void
      {
         if(Boolean(this._channel))
         {
            this._pausePosition = this._channel.position;
            if(this._useSampleData)
            {
               this._outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA,this.onSampleData);
            }
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.onSfxComplete);
            this._channel.stop();
         }
      }
      
      public function resume() : void
      {
         if(Boolean(this._outputSound))
         {
            if(this._useSampleData)
            {
               this._outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA,this.onSampleData);
            }
            this._channel = this._outputSound.play(this._pausePosition);
            if(!this._channel)
            {
               this.onSfxComplete(null);
               return;
            }
            this._channel.addEventListener(Event.SOUND_COMPLETE,this.onSfxComplete);
            this._applyVolume();
         }
      }
      
      public function dispose() : void
      {
         JBGSoundPlayer.instance.unregisterSound(this);
         if(Boolean(this._channel))
         {
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.onSfxComplete);
            this._channel.stop();
            this._channel = null;
         }
         if(Boolean(this._loadedSound))
         {
            if(this._ownsLoadedSound)
            {
               try
               {
                  this._loadedSound.close();
               }
               catch(err:Error)
               {
               }
            }
            this._loadedSound = null;
         }
         if(Boolean(this._outputSound))
         {
            if(this._useSampleData)
            {
               this._outputSound.removeEventListener(SampleDataEvent.SAMPLE_DATA,this.onSampleData);
            }
            if(this._ownsOutputSound)
            {
               try
               {
                  this._outputSound.close();
               }
               catch(err:Error)
               {
               }
            }
            this._outputSound = null;
         }
      }
      
      private function _applyVolume() : void
      {
         if(!this._channel)
         {
            return;
         }
         var st:SoundTransform = this._channel.soundTransform;
         st.volume = this._volume;
         this._channel.soundTransform = st;
      }
      
      private function onSfxComplete(e:Event) : void
      {
         if(Boolean(this._channel))
         {
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.onSfxComplete);
            this._channel = null;
         }
         if(this._loop)
         {
            this.play();
         }
         else
         {
            this.stop();
            dispatchEvent(new Event(Event.SOUND_COMPLETE));
         }
      }
      
      private function onSampleData(evt:SampleDataEvent) : void
      {
         var read:int = 0;
         var length:int = this.BUFFER_SIZE;
         var target:ByteArray = evt.data;
         while(length > 0)
         {
            if(this._samplePosition + length > this._sampleEndPosition)
            {
               read = this._sampleEndPosition - this._samplePosition;
               if(read > 0)
               {
                  this._loadedSound.extract(target,read,this._samplePosition);
                  this._samplePosition += read;
                  length -= read;
               }
               else
               {
                  this._samplePosition = this._sampleStartPosition;
               }
            }
            else
            {
               this._loadedSound.extract(target,length,this._samplePosition);
               this._samplePosition += length;
               length = 0;
            }
            if(this._samplePosition >= this._sampleEndPosition)
            {
               this._samplePosition = this._sampleStartPosition;
            }
         }
      }
   }
}

