package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class RainbowSliceEffect implements ISliceEffectWithSubWheel
   {
      private var _owner:Player;
      
      private var _rainbowWheel:Wheel;
      
      public function RainbowSliceEffect()
      {
         super();
      }
      
      public function get spinningPlayer() : Player
      {
         return this._owner;
      }
      
      public function get rainbowWheel() : Wheel
      {
         return this._rainbowWheel;
      }
      
      public function setup(param:DoSpinResultParam, spinResult:SpinResult) : void
      {
         this._owner = BonusSliceData(param.spunSlice.params.data).owner;
      }
      
      public function evaluate() : Promise
      {
         return PromiseUtil.RESOLVED();
      }
      
      public function get bgClassName() : String
      {
         return "rainbowWheelBg";
      }
      
      public function get flapperClassName() : String
      {
         return "miniFlapper";
      }
      
      public function fillWheel(w:Wheel) : void
      {
         var otherPlayers:Array = null;
         var otherPlayerIndex:int = 0;
         this._rainbowWheel = w;
         otherPlayers = GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return p != _owner;
         });
         otherPlayers.sort(function(a:Player, b:Player):int
         {
            return b.score.val - a.score.val;
         });
         otherPlayerIndex = 0;
         w.slicePositions.forEach(function(pos:int, i:int, a:Array):void
         {
            var newSliceOwner:Player = null;
            if(i % 2 == 0)
            {
               newSliceOwner = _owner;
            }
            else
            {
               newSliceOwner = otherPlayers[otherPlayerIndex];
               ++otherPlayerIndex;
               if(otherPlayerIndex >= otherPlayers.length)
               {
                  otherPlayerIndex = 0;
               }
            }
            w.addSlice(SliceParameters.CREATE_WITH_OWNER(GameConstants.SLICE_TYPE_POINTS_FOR_PLAYER,newSliceOwner),pos);
         });
      }
   }
}

