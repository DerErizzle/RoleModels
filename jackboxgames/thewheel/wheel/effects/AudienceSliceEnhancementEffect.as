package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class AudienceSliceEnhancementEffect extends AudienceBinaryChoiceEffect
   {
      public function AudienceSliceEnhancementEffect()
      {
         super();
      }
      
      override protected function get _nameKey() : String
      {
         return "SLICE_EFFECT_AUDIENCESLICEENHANCEMENT_NAME";
      }
      
      override protected function get _promptKey() : String
      {
         return "SLICE_EFFECT_AUDIENCESLICEENHANCEMENT_PROMPT";
      }
      
      override protected function get _optionAKey() : String
      {
         return "AUDIENCE_SLICE_ENHANCEMENT_OPTION_MULTIPLIERS";
      }
      
      override protected function get _optionBKey() : String
      {
         return "AUDIENCE_SLICE_ENHANCEMENT_OPTION_RANDOMIZE";
      }
      
      override protected function _evaluateOptionA() : Promise
      {
         _param.wheel.getSlicesWithType(GameConstants.SLICE_TYPE_PLAYER).forEach(function(s:Slice, ... args):void
         {
            var p:Player = null;
            var data:PlayerSliceData = PlayerSliceData(s.params.data);
            for each(p in data.playersWithStake)
            {
               data.addStakeForPlayer(p);
            }
         });
         return PromiseUtil.RESOLVED();
      }
      
      override protected function _evaluateOptionB() : Promise
      {
         return PromiseUtil.ALL(_param.wheel.getSlicesWithType(GameConstants.SLICE_TYPE_PLAYER).map(function(s:Slice, ... args):Promise
         {
            var p:* = undefined;
            var otherPlayers:* = undefined;
            var newOwner:* = undefined;
            var i:* = undefined;
            var promise:* = new Promise();
            var existingData:* = PlayerSliceData(s.params.data);
            var newParam:* = SliceParameters.CREATE(GameConstants.SLICE_TYPE_PLAYER);
            var newData:* = PlayerSliceData(newParam.data);
            for each(p in existingData.playersWithStake)
            {
               otherPlayers = GameState.instance.players.filter(ArrayUtil.GENERATE_FILTER_EXCEPT(p));
               newOwner = ArrayUtil.getRandomElement(otherPlayers);
               for(i = 0; i < existingData.getNumStakesForPlayer(p); i++)
               {
                  newData.addStakeForPlayer(newOwner);
               }
            }
            _param.wheel.replaceSliceWithNewSlice(s,newParam,Wheel.REPLACE_TYPE_FLIP,PromiseUtil.doneFnResolved(promise,null));
            return promise;
         }));
      }
   }
}

