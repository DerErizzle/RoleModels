package jackboxgames.thewheel.wheel.slicedata
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class PlayerSliceData implements ISliceData
   {
      private var _playersWithStake:Array;
      
      private var _numStakes:PerPlayerContainer;
      
      private var _multiplier:Number;
      
      public function PlayerSliceData()
      {
         super();
      }
      
      public function get multiplier() : Number
      {
         return this._multiplier;
      }
      
      public function set multiplier(val:Number) : void
      {
         this._multiplier = val;
      }
      
      public function get multiplierPerPlayer() : PerPlayerContainer
      {
         return PerPlayerContainerUtil.MAP(this._playersWithStake,function(p:Player, ... args):Number
         {
            return GameState.instance.jsonData.gameConfig.getPlayerSliceMultiplierForNumStakes(_numStakes.getDataForPlayer(p));
         });
      }
      
      public function setup(owner:Player) : void
      {
         this._numStakes = new PerPlayerContainer();
         this._playersWithStake = new Array();
         if(Boolean(owner))
         {
            this.addStakeForPlayer(owner);
         }
         this._multiplier = 1;
      }
      
      public function addStakeForPlayer(p:Player) : void
      {
         if(!ArrayUtil.arrayContainsElement(this._playersWithStake,p))
         {
            this._playersWithStake.push(p);
            this._numStakes.setDataForPlayer(p,1);
         }
         else
         {
            this._numStakes.incrementDataForPlayer(p);
         }
      }
      
      public function removeStakeForPlayer(p:Player) : void
      {
         if(!ArrayUtil.arrayContainsElement(this._playersWithStake,p))
         {
            return;
         }
         this._numStakes.decrementDataForPlayer(p);
         if(this._numStakes.getDataForPlayer(p) == 0)
         {
            this._numStakes.removeDataForPlayer(p);
            ArrayUtil.removeElementFromArray(this._playersWithStake,p);
         }
      }
      
      public function get playersWithStake() : Array
      {
         return this._playersWithStake;
      }
      
      public function getMultiplierForPlayer(p:Player) : Number
      {
         return this._numStakes.hasDataForPlayer(p) ? GameState.instance.jsonData.gameConfig.getPlayerSliceMultiplierForNumStakes(this._numStakes.getDataForPlayer(p)) : 0;
      }
      
      public function getNumStakesForPlayer(p:Player) : int
      {
         return this._numStakes.getDataForPlayer(p);
      }
      
      private function get _anyWithStakeInWinnerMode() : Boolean
      {
         return MapFold.process(this._playersWithStake,function(p:Player, ... args):Boolean
         {
            return p.isInWinnerMode;
         },MapFold.FOLD_OR);
      }
      
      public function get isContested() : Boolean
      {
         return this._playersWithStake.length > 1 && this._anyWithStakeInWinnerMode;
      }
      
      public function get contestingPlayers() : Array
      {
         return this._playersWithStake.filter(function(p:Player, ... args):Boolean
         {
            return p.isInWinnerMode;
         });
      }
      
      public function get isShared() : Boolean
      {
         return this._playersWithStake.length > 1 && !this._anyWithStakeInWinnerMode;
      }
      
      public function get playersWhoWonJackpot() : Array
      {
         return this._playersWithStake;
      }
      
      public function get jackpotWinnersWithMultipleStake() : Array
      {
         return this.playersWhoWonJackpot.filter(function(p:Player, ... args):Boolean
         {
            return getNumStakesForPlayer(p) > 1;
         });
      }
      
      public function get name() : String
      {
         return LocalizationUtil.getPrintfText("SLICE_TYPE_PLAYER_NAME");
      }
      
      public function get description() : String
      {
         return "";
      }
      
      public function isSliceVisibleToController(p:Player, controllerMode:String) : Boolean
      {
         switch(controllerMode)
         {
            case GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT:
               return true;
            case GameConstants.WHEEL_CONTROLLER_MODE_SECRETIVE:
               return ArrayUtil.arrayContainsElement(this._playersWithStake,p);
            default:
               Assert.assert(false);
               return false;
         }
      }
      
      public function getControllerData(p:Player, controllerMode:String) : Object
      {
         var playersToSend:Array = null;
         switch(controllerMode)
         {
            case GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT:
               playersToSend = this._playersWithStake;
               break;
            case GameConstants.WHEEL_CONTROLLER_MODE_SECRETIVE:
               playersToSend = ArrayUtil.arrayContainsElement(this._playersWithStake,p) ? [p] : [];
               break;
            default:
               Assert.assert(false);
         }
         return {
            "playersWithStake":playersToSend.map(function(otherPlayer:Player, ... args):Object
            {
               return {
                  "id":otherPlayer.sessionId.val,
                  "stake":getMultiplierForPlayer(otherPlayer)
               };
            }),
            "multiplier":this._multiplier
         };
      }
      
      public function clone() : *
      {
         var newData:PlayerSliceData = new PlayerSliceData();
         newData._numStakes = this._numStakes.clone();
         newData._playersWithStake = ArrayUtil.copy(this._playersWithStake);
         newData._multiplier = this._multiplier;
         return newData;
      }
   }
}

