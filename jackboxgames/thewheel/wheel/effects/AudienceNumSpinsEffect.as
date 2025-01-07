package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public class AudienceNumSpinsEffect extends AudienceBinaryChoiceEffect
   {
      public function AudienceNumSpinsEffect()
      {
         super();
      }
      
      override protected function get _nameKey() : String
      {
         return "SLICE_EFFECT_AUDIENCENUMSPINS_NAME";
      }
      
      override protected function get _promptKey() : String
      {
         return "SLICE_EFFECT_AUDIENCENUMSPINS_PROMPT";
      }
      
      override protected function get _optionAKey() : String
      {
         return "AUDIENCE_NUM_SPINS_OPTION_ZERO";
      }
      
      override protected function get _optionBKey() : String
      {
         return "AUDIENCE_NUM_SPINS_OPTION_FULL";
      }
      
      private function _setNumSpinsAndWait(newNumSpins:int, d:Duration) : Promise
      {
         _param.spinDelegate.setNumSpinsAndAnimateSpinMeter(newNumSpins,d);
         return PromiseUtil.wait(d);
      }
      
      override protected function _evaluateOptionA() : Promise
      {
         return this._setNumSpinsAndWait(0,Duration.fromSec(1));
      }
      
      override protected function _evaluateOptionB() : Promise
      {
         return this._setNumSpinsAndWait(GameState.instance.currentRoundData.setup.numSpinsBeforeFinal,Duration.fromSec(1));
      }
   }
}

