package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.MapFold;
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.GameConstants;
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.wheel.DoSpinResultParam;
   import jackboxgames.thewheel.wheel.ISliceEffect;
   import jackboxgames.thewheel.wheel.Slice;
   import jackboxgames.thewheel.wheel.SpinResult;
   import jackboxgames.thewheel.wheel.Wheel;
   import jackboxgames.thewheel.wheel.slicedata.BonusSliceData;
   import jackboxgames.thewheel.wheel.slicedata.PlayerSliceData;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.PromiseUtil;
   
   public class ChainStealEffect implements ISliceEffect
   {
      private var _wheel:Wheel;
      
      private var _stealingPlayer:Player;
      
      private var _chosenSlice:Slice;
      
      private var _chosenChain:Chain;
      
      public function ChainStealEffect()
      {
         super();
      }
      
      public function get wheel() : Wheel
      {
         return this._wheel;
      }
      
      public function get chosenSlice() : Slice
      {
         return this._chosenSlice;
      }
      
      public function set chosenSlice(val:Slice) : void
      {
         this._chosenSlice = val;
         this._recalculateChain();
      }
      
      public function get affectedSlices() : Array
      {
         return this._chosenChain.affectedSlices;
      }
      
      public function get affectedPlayer() : Player
      {
         return this._chosenChain.player;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._wheel = param.wheel;
         this._stealingPlayer = BonusSliceData(param.spunSlice.params.data).owner;
      }
      
      private function _tryToAddToChain(chain:Chain, s:Slice) : void
      {
         var adjacent:Slice = null;
         if(ArrayUtil.arrayContainsElement(chain.affectedSlices,s))
         {
            return;
         }
         if(s.params.type != GameConstants.SLICE_TYPE_PLAYER)
         {
            return;
         }
         if(PlayerSliceData(s.params.data).getNumStakesForPlayer(chain.player) == 0)
         {
            return;
         }
         chain.add(s);
         for each(adjacent in this._wheel.getSlicesAdjacentTo(s))
         {
            this._tryToAddToChain(chain,adjacent);
         }
      }
      
      private function _recalculateChain() : void
      {
         var longestChains:Array;
         var chains:Array = null;
         var longestChainLength:int = 0;
         chains = [];
         PlayerSliceData(this._chosenSlice.params.data).playersWithStake.filter(function(p:Player, ... args):Boolean
         {
            return p != _stealingPlayer;
         }).forEach(function(p:Player, ... args):void
         {
            var newChain:Chain = new Chain(p);
            _tryToAddToChain(newChain,_chosenSlice);
            chains.push(newChain);
         });
         longestChainLength = MapFold.process(chains,function(chain:Chain, ... args):int
         {
            return chain.affectedSlices.length;
         },MapFold.FOLD_MAX);
         longestChains = chains.filter(function(chain:Chain, ... args):Boolean
         {
            return chain.affectedSlices.length == longestChainLength;
         });
         this._chosenChain = ArrayUtil.getRandomElement(longestChains);
      }
      
      public function evaluate() : Promise
      {
         var s:Slice = null;
         var data:PlayerSliceData = null;
         for each(s in this._chosenChain.affectedSlices)
         {
            data = PlayerSliceData(s.params.data);
            while(data.getNumStakesForPlayer(this._chosenChain.player) > 0)
            {
               data.removeStakeForPlayer(this._chosenChain.player);
               data.addStakeForPlayer(this._stealingPlayer);
            }
            s.updateVisuals();
         }
         return PromiseUtil.RESOLVED();
      }
   }
}

import jackboxgames.thewheel.Player;
import jackboxgames.thewheel.wheel.Slice;

class Chain
{
   private var _player:Player;
   
   private var _affectedSlices:Array;
   
   public function Chain(p:Player)
   {
      super();
      this._player = p;
      this._affectedSlices = [];
   }
   
   public function get player() : Player
   {
      return this._player;
   }
   
   public function get affectedSlices() : Array
   {
      return this._affectedSlices;
   }
   
   public function add(s:Slice) : void
   {
      this._affectedSlices.push(s);
   }
}

