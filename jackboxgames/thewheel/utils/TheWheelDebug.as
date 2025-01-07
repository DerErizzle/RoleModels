package jackboxgames.thewheel.utils
{
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import jackboxgames.events.EventWithData;
   import jackboxgames.thewheel.GameState;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.Duration;
   import jackboxgames.utils.EnvUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.StageRef;
   
   public class TheWheelDebug extends PausableEventDispatcher
   {
      public static const EVENT_END_TIMER:String = "endTimer";
      
      public static const EVENT_SKIP:String = "skip";
      
      private var _forcedTriviaTypeId:String;
      
      private var _forcedTriviaTypeNumTimes:int;
      
      private var _forcedTriviaContentId:String;
      
      private var _forcedBonusEffectId:String;
      
      private var _forcedAudienceEffectId:String;
      
      private var _forcedStartingSliceConfigId:String;
      
      private var _victoryThresholdOverride:int;
      
      private var _fastTimersMode:Boolean;
      
      private var _spinTargetMode:Boolean;
      
      private var _fixedSpinAmount:int;
      
      private var _skipEntireGame:Boolean;
      
      private var _skipTrivia:Boolean;
      
      public function TheWheelDebug()
      {
         super();
         this.reset();
         if(EnvUtil.isDebug())
         {
            StageRef.addEventListener(KeyboardEvent.KEY_DOWN,this._onKeyboard);
         }
      }
      
      public function reset() : void
      {
         this._forcedTriviaTypeId = null;
         this._forcedTriviaContentId = null;
         this._forcedBonusEffectId = null;
         this._forcedAudienceEffectId = null;
         this._forcedStartingSliceConfigId = null;
         this._victoryThresholdOverride = -1;
         this._fastTimersMode = false;
         this._spinTargetMode = false;
         this._fixedSpinAmount = -1;
         this._skipEntireGame = false;
         this._skipTrivia = false;
      }
      
      public function forceTrivia(id:String, numTimes:int = 1, contentId:String = null) : void
      {
         this._forcedTriviaTypeId = id;
         this._forcedTriviaTypeNumTimes = numTimes;
         this._forcedTriviaContentId = contentId;
      }
      
      public function get forcedTriviaTypeId() : String
      {
         return this._forcedTriviaTypeId;
      }
      
      public function get forcedTriviaTypeNumTimes() : int
      {
         return this._forcedTriviaTypeNumTimes;
      }
      
      public function get forcedTriviaContentId() : String
      {
         return this._forcedTriviaContentId;
      }
      
      public function forceBonusEffectId(id:String) : void
      {
         this._forcedBonusEffectId = id;
      }
      
      public function get forcedBonusEffectId() : String
      {
         return this._forcedBonusEffectId;
      }
      
      public function forceAudienceEffectId(id:String) : void
      {
         this._forcedAudienceEffectId = id;
      }
      
      public function get forcedAudienceEffectId() : String
      {
         return this._forcedAudienceEffectId;
      }
      
      public function forceStartingSliceConfigId(id:String) : void
      {
         this._forcedStartingSliceConfigId = id;
      }
      
      public function get forcedStartingSliceConfigId() : String
      {
         return this._forcedStartingSliceConfigId;
      }
      
      public function setSpinTargetMode(enabled:Boolean) : void
      {
         this._spinTargetMode = enabled;
      }
      
      public function get spinTargetMode() : Boolean
      {
         return this._spinTargetMode;
      }
      
      public function setFixedSpinAmount(val:int) : void
      {
         this._fixedSpinAmount = val;
      }
      
      public function get fixedSpinAmount() : int
      {
         return this._fixedSpinAmount;
      }
      
      public function setVictoryThreshold(score:int) : void
      {
         this._victoryThresholdOverride = score;
      }
      
      public function get victoryThresholdIsOverridden() : Boolean
      {
         return this._victoryThresholdOverride > -1;
      }
      
      public function get victoryThresholdOverride() : int
      {
         return this._victoryThresholdOverride;
      }
      
      public function setFastTimers(fast:Boolean) : void
      {
         this._fastTimersMode = fast;
      }
      
      public function get fastTimersMode() : Boolean
      {
         return this._fastTimersMode;
      }
      
      public function get fastSpinDuration() : Duration
      {
         return Duration.fromSec(2);
      }
      
      public function setSkipEntireGame(val:Boolean) : void
      {
         this._skipEntireGame = val;
      }
      
      public function get skipEntireGame() : Boolean
      {
         return this._skipEntireGame;
      }
      
      public function setSkipTrivia(val:Boolean) : void
      {
         this._skipTrivia = val;
      }
      
      public function get skipTrivia() : Boolean
      {
         return this._skipTrivia;
      }
      
      public function runTriviaResultTest(... args) : void
      {
         var numberArgs:Array = ArrayUtil.shuffled(args.map(function(s:*, ... args):int
         {
            return int(s);
         }));
         GameState.instance.runTriviaResultTest(numberArgs);
      }
      
      private function _onKeyboard(evt:KeyboardEvent) : void
      {
         if(Boolean(evt.controlKey) && evt.keyCode == Keyboard.T)
         {
            dispatchEvent(new EventWithData(EVENT_END_TIMER,null));
         }
         else if(Boolean(evt.controlKey) && evt.keyCode == Keyboard.S)
         {
            dispatchEvent(new EventWithData(EVENT_SKIP,null));
         }
      }
   }
}

