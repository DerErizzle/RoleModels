package jackboxgames.thewheel.data
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.utils.*;
   
   public class GameConfig implements IJsonData
   {
      private var _data:Object;
      
      private var _startingSliceConfigs:Array;
      
      public function GameConfig()
      {
         super();
      }
      
      public function load(data:Object) : Promise
      {
         this._data = data;
         return PromiseUtil.RESOLVED(true);
      }
      
      public function get baseStartingPot() : int
      {
         return this._data.baseStartingPot;
      }
      
      public function get startingPotIncreasePerRound() : int
      {
         return this._data.startingPotIncreasePerRound;
      }
      
      public function get basePotIncreasePerRevolution() : int
      {
         return this._data.basePotIncreasePerRevolution;
      }
      
      public function get potIncreasePerRevolutionIncreasePerRound() : int
      {
         return this._data.potIncreasePerRevolutionIncreasePerRound;
      }
      
      public function get finalSpinPotIncreaseFactor() : Number
      {
         return this._data.finalSpinPotIncreaseFactor;
      }
      
      public function get pointsRequiredToWinGame() : int
      {
         return this._data.pointsRequiredToWinGame;
      }
      
      public function get numBadSlicesOnWinWheel() : int
      {
         return this._data.numBadSlicesOnWinWheel[Math.min(GameState.instance.numWinWheelSpins,this._data.numBadSlicesOnWinWheel.length - 1)];
      }
      
      public function get playTimerAudioWhenLessThan() : Duration
      {
         return Duration.fromSec(this._data.playTimerAudioWhenLessThanSec);
      }
      
      public function get sliceSize() : int
      {
         return this._data.sliceSize;
      }
      
      public function get sliceSizeMiniWheel() : int
      {
         return this._data.sliceSizeMiniWheel;
      }
      
      public function getPlayerSliceMultiplierForNumStakes(numStakes:int) : Number
      {
         var multiplier:Number = 0;
         for(var i:int = 0; i < numStakes; i++)
         {
            multiplier += this._data.playerSliceMultiplierIncreases[Math.min(i,this._data.playerSliceMultiplierIncreases.length - 1)];
         }
         return multiplier;
      }
      
      public function get playerSliceInitialStake() : Number
      {
         return this._data.playerSliceInitialStake;
      }
      
      public function get playerSliceStakeIncrease() : Number
      {
         return this._data.playerSliceStakeIncreases;
      }
      
      public function get placeExtraSlicesNumSlices() : int
      {
         return this._data.placeExtraSlicesNumSlices;
      }
      
      public function get stealFromPlayerSliceAmount() : int
      {
         return this._data.stealFromPlayerSliceAmount;
      }
      
      public function get pointsForPlayerSliceAmount() : int
      {
         return this._data.pointsForPlayerSliceAmount;
      }
      
      public function get tappingListChoicesCount() : int
      {
         return this._data.tappingListChoicesCount;
      }
      
      public function get matchingNumAnswers() : int
      {
         return this._data.matchingNumAnswers;
      }
      
      public function get matchingFreezeTime() : Duration
      {
         return Duration.fromSec(this._data.matchingFreezeTimeInSec);
      }
      
      public function get matchingCycleTime() : Duration
      {
         return Duration.fromSec(this._data.matchingCycleTimeInSec);
      }
      
      public function get rapidFireNumChoices() : int
      {
         return this._data.rapidFireNumChoices;
      }
      
      public function get rapidFireFreezeTime() : Duration
      {
         return Duration.fromSec(this._data.rapidFireFreezeTimeInSec);
      }
      
      public function get rapidFireTimeBeforePreviewReveal() : Duration
      {
         return Duration.fromSec(this._data.rapidFireTimeBeforePreviewRevealInSec);
      }
      
      public function get rapidFireTimeBeforeNextPreview() : Duration
      {
         return Duration.fromSec(this._data.rapidFireTimeBeforeNextPreviewInSec);
      }
      
      public function getPointsForTriviaPlaceIndex(i:int) : int
      {
         var sourceArray:Array = this._data.pointsForTriviaPlaceIndex[GameState.instance.players.length];
         Assert.assert(Boolean(sourceArray) && sourceArray.length == GameState.instance.players.length);
         Assert.assert(i >= 0 && i < sourceArray.length);
         return sourceArray[i];
      }
      
      public function get audienceReplaceSlicesNumSlices() : int
      {
         return this._data.audienceReplaceSlicesNumSlices;
      }
      
      public function get audienceNeighborNumPoints() : int
      {
         return this._data.audienceNeighborNumPoints;
      }
      
      public function get audienceSliceCountNumPoints() : int
      {
         return this._data.audienceSliceCountNumPoints;
      }
      
      public function get hostAudioMeterData() : Object
      {
         return this._data.hostAudioMeterData;
      }
      
      public function getPointsSliceAmountsForCurrentRound() : Array
      {
         var index:int = Math.min(GameState.instance.roundIndex,this._data.pointsSliceAmounts.length - 1);
         return this._data.pointsSliceAmounts[index];
      }
      
      public function getBadSplitAmountForCurrentRound() : int
      {
         var index:int = Math.min(GameState.instance.roundIndex,this._data.badSplitAmounts.length - 1);
         return this._data.badSplitAmounts[index];
      }
   }
}

