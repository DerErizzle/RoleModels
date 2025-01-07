package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class AudienceNeighborEffect extends AudienceBinaryChoiceEffect
   {
      private var _targetedSliceType:SliceType;
      
      private var _targetedSlices:Array;
      
      private var _playersAffected:Array;
      
      public function AudienceNeighborEffect()
      {
         super();
      }
      
      public function get playersAffected() : Array
      {
         return this._playersAffected;
      }
      
      override protected function get _nameKey() : String
      {
         return "SLICE_EFFECT_AUDIENCE_NEIGHBOR_" + this._targetedSliceType.id.toUpperCase() + "_NAME";
      }
      
      override protected function get _promptKey() : String
      {
         return "SLICE_EFFECT_AUDIENCE_NEIGHBOR_" + this._targetedSliceType.id.toUpperCase() + "_PROMPT";
      }
      
      override protected function get _optionAKey() : String
      {
         return "SLICE_EFFECT_AUDIENCE_NEIGHBOR_" + this._targetedSliceType.id.toUpperCase() + "_GIVE";
      }
      
      override protected function get _optionBKey() : String
      {
         return "SLICE_EFFECT_AUDIENCE_NEIGHBOR_" + this._targetedSliceType.id.toUpperCase() + "_TAKE";
      }
      
      override protected function _doSetup() : void
      {
         var t:SliceType = null;
         var slices:Array = null;
         var potentialTypes:Array = [GameConstants.SLICE_TYPE_BONUS,GameConstants.SLICE_TYPE_BAD];
         for each(t in potentialTypes)
         {
            slices = _param.wheel.getSlicesWithType(t);
            if(slices.length > 0)
            {
               this._targetedSliceType = t;
               this._targetedSlices = slices;
               break;
            }
         }
         Assert.assert(this._targetedSlices != null);
      }
      
      private function _doScoreChangeForNeighboringPlayers(amount:int) : void
      {
         var s:Slice = null;
         var p:Player = null;
         var neighbors:Array = null;
         var neighboringSlice:Slice = null;
         this._playersAffected = [];
         for each(s in this._targetedSlices)
         {
            neighbors = _param.wheel.getSlicesAdjacentTo(s);
            for each(neighboringSlice in neighbors)
            {
               if(neighboringSlice.params.type == GameConstants.SLICE_TYPE_PLAYER)
               {
                  this._playersAffected = this._playersAffected.concat(PlayerSliceData(neighboringSlice.params.data).playersWithStake);
               }
            }
         }
         this._playersAffected = ArrayUtil.deduplicated(this._playersAffected);
         for each(p in this._playersAffected)
         {
            p.addScoreChange(new ScoreChange().withAmount(amount));
         }
      }
      
      override protected function _evaluateOptionA() : Promise
      {
         this._doScoreChangeForNeighboringPlayers(GameState.instance.jsonData.gameConfig.audienceNeighborNumPoints);
         return PromiseUtil.RESOLVED();
      }
      
      override protected function _evaluateOptionB() : Promise
      {
         this._doScoreChangeForNeighboringPlayers(-GameState.instance.jsonData.gameConfig.audienceNeighborNumPoints);
         return PromiseUtil.RESOLVED();
      }
   }
}

