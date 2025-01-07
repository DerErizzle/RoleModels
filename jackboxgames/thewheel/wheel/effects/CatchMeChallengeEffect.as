package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.GameState;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.Wheel;
   import jackboxgames.thewheel.wheel.slicedata.BonusSliceData;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.PromiseUtil;
   
   public class CatchMeChallengeEffect implements ISliceEffect
   {
      private var _param:DoSpinResultParam;
      
      private var _wheel:Wheel;
      
      private var _playersTryingToCatch:Array;
      
      private var _ownerHid:Boolean;
      
      private var _ownerWasFound:Boolean;
      
      private var _playersThatGetTheBonus:Array;
      
      public function CatchMeChallengeEffect()
      {
         super();
      }
      
      public function get wheel() : Wheel
      {
         return this._wheel;
      }
      
      public function get ownerHid() : Boolean
      {
         return this._ownerHid;
      }
      
      public function get ownerWasFound() : Boolean
      {
         return this._ownerWasFound;
      }
      
      public function get playersTryingToCatch() : Array
      {
         return this._playersTryingToCatch;
      }
      
      public function get playersThatGetTheBonus() : Array
      {
         return this._playersThatGetTheBonus;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._param = param;
         this._wheel = this._param.wheel;
         this._playersTryingToCatch = GameState.instance.players.filter(ArrayUtil.GENERATE_FILTER_EXCEPT(BonusSliceData(param.spunSlice.params.data).owner));
      }
      
      public function setResultToOwnerDidNotHide() : void
      {
         this._ownerHid = false;
         this._ownerWasFound = false;
         this._playersThatGetTheBonus = ArrayUtil.copy(this._playersTryingToCatch);
      }
      
      public function setResultToOwnerNotFound() : void
      {
         this._ownerHid = true;
         this._ownerWasFound = false;
         this._playersThatGetTheBonus = [BonusSliceData(this._param.spunSlice.params.data).owner];
      }
      
      public function setResultToOwnerFound() : void
      {
         this._ownerHid = true;
         this._ownerWasFound = true;
         this._playersThatGetTheBonus = ArrayUtil.copy(this._playersTryingToCatch);
      }
      
      public function evaluate() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
   }
}

