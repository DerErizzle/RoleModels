package jackboxgames.thewheel.utils
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   
   public class AudioMeterPropertyChanger
   {
      private static const DEFAULT_RMS_LEVEL_MAX:Number = 0.1;
      
      private static const DEFAULT_MIN:Number = 0;
      
      private static const DEFAULT_MAX:Number = 1;
      
      private static const DEFAULT_IDLE:Number = 0;
      
      private static const DEFAULT_MAX_DECAY:Number = 0.2;
      
      private var _target:Object;
      
      private var _property:String;
      
      private var _meterName:String;
      
      private var _rmsLevelMax:Number;
      
      private var _min:Number;
      
      private var _max:Number;
      
      private var _idle:Number;
      
      private var _maxDecay:Number;
      
      private var _isActive:Boolean;
      
      private var _meter:AudioMeter;
      
      public function AudioMeterPropertyChanger(target:Object, property:String, meterName:String, data:Object = null)
      {
         super();
         this._target = target;
         this._meterName = meterName;
         this._property = property;
         this._rmsLevelMax = Boolean(data) && Boolean(data.hasOwnProperty("rmsLevelMax")) ? Number(data.rmsLevelMax) : DEFAULT_RMS_LEVEL_MAX;
         this._min = Boolean(data) && Boolean(data.hasOwnProperty("min")) ? Number(data.min) : DEFAULT_MIN;
         this._max = Boolean(data) && Boolean(data.hasOwnProperty("max")) ? Number(data.max) : DEFAULT_MAX;
         this._idle = Boolean(data) && Boolean(data.hasOwnProperty("idle")) ? Number(data.idle) : DEFAULT_IDLE;
         this._maxDecay = Boolean(data) && Boolean(data.hasOwnProperty("maxDecay")) ? Number(data.maxDecay) : DEFAULT_MAX_DECAY;
      }
      
      public function reset() : void
      {
         this.setActive(false);
      }
      
      public function setActive(isActive:Boolean) : void
      {
         if(this._isActive == isActive)
         {
            return;
         }
         this._isActive = isActive;
         if(this._isActive)
         {
            this._meter = new AudioMeter("Host");
            this._meter.addEventListener(AudioMeter.EVENT_ON_UPDATE,this._onAudioMeterUpdate);
         }
         else
         {
            this._meter.removeEventListener(AudioMeter.EVENT_ON_UPDATE,this._onAudioMeterUpdate);
            this._meter.dispose();
            this._meter = null;
         }
      }
      
      private function _onAudioMeterUpdate(evt:EventWithData) : void
      {
         var propertyLevel:Number = NaN;
         var step:Number = NaN;
         var level:Number = Number(evt.data.maxRMSLevelInput);
         var ratio:Number = 0;
         var current:Number = Number(this._target[this._property]);
         if(level > 0)
         {
            propertyLevel = Math.max(this._min,Math.min(this._max,level / this._rmsLevelMax));
            if(current - propertyLevel > this._maxDecay)
            {
               this._target[this._property] = current - this._maxDecay;
            }
            else
            {
               this._target[this._property] = propertyLevel;
            }
         }
         else if(current > this._idle)
         {
            step = Math.max(0,Math.min(this._maxDecay,current - this._idle));
            this._target[this._property] = current - step;
         }
         else
         {
            this._target[this._property] = this._idle;
         }
      }
   }
}

