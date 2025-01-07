package jackboxgames.thewheel.data
{
   import jackboxgames.algorithm.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class TimerConfig implements IJsonData
   {
      private var _data:Object;
      
      private var _normalDuration:Duration;
      
      private var _extendedDuration:Duration;
      
      private var _stepDuration:Duration;
      
      public function TimerConfig()
      {
         super();
      }
      
      public function load(data:Object) : Promise
      {
         this._data = data;
         Assert.assert(this._data.hasOwnProperty("normalDurationInSec"));
         this._normalDuration = Duration.fromSec(this._data.normalDurationInSec);
         this._extendedDuration = !!this._data.hasOwnProperty("extendedDurationInSec") ? Duration.fromSec(this._data.extendedDurationInSec) : null;
         this._stepDuration = !!this._data.hasOwnProperty("stepDurationInSec") ? Duration.fromSec(this._data.stepDurationInSec) : Duration.fromSec(1);
         return PromiseUtil.RESOLVED();
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function get totalDuration() : Duration
      {
         if(Boolean(this._extendedDuration) && SettingsManager.instance.getValue(SettingsConstants.SETTING_EXTENDED_TIMERS).val)
         {
            return this._extendedDuration;
         }
         return this._normalDuration;
      }
      
      public function get stepDuration() : Duration
      {
         return this._stepDuration;
      }
   }
}

