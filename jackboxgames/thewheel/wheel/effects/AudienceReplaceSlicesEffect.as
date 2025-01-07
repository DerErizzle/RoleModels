package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class AudienceReplaceSlicesEffect extends AudienceBinaryChoiceEffect
   {
      public function AudienceReplaceSlicesEffect()
      {
         super();
      }
      
      override protected function get _nameKey() : String
      {
         return "SLICE_EFFECT_AUDIENCEREPLACESLICES_NAME";
      }
      
      override protected function get _promptKey() : String
      {
         return "SLICE_EFFECT_AUDIENCEREPLACESLICES_PROMPT";
      }
      
      override protected function get _optionAKey() : String
      {
         return "AUDIENCE_REPLACE_SLICES_OPTION_BAD_SLICES";
      }
      
      override protected function get _optionBKey() : String
      {
         return "AUDIENCE_REPLACE_SLICES_OPTION_BONUS_SLICES";
      }
      
      private function _doReplace(newSliceGenerateFn:Function) : Promise
      {
         var replaceableSlices:Array = _param.wheel.getAllSlices().filter(function(s:Slice, ... args):Boolean
         {
            return s != _param.spunSlice && s.params.type != GameConstants.SLICE_TYPE_BONUS && s.params.type != GameConstants.SLICE_TYPE_AUDIENCE;
         });
         var slicesToReplace:Array = ArrayUtil.getRandomElements(replaceableSlices,Math.min(GameState.instance.jsonData.gameConfig.audienceReplaceSlicesNumSlices,replaceableSlices.length));
         slicesToReplace.forEach(function(s:Slice, ... args):void
         {
            _param.wheel.replaceSliceWithNewSlice(s,newSliceGenerateFn(),Wheel.REPLACE_TYPE_FLIP,Nullable.NULL_FUNCTION);
         });
         return PromiseUtil.RESOLVED();
      }
      
      override protected function _evaluateOptionA() : Promise
      {
         return this._doReplace(function():SliceParameters
         {
            return GameState.instance.generateBadSlice();
         });
      }
      
      override protected function _evaluateOptionB() : Promise
      {
         return this._doReplace(function():SliceParameters
         {
            return GameState.instance.currentRoundData.bonusSlice;
         });
      }
   }
}

