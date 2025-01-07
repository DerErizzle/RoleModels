package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.Promise;
   import jackboxgames.thewheel.GameConstants;
   import jackboxgames.thewheel.GameState;
   import jackboxgames.thewheel.wheel.AudienceBinaryChoiceEffect;
   import jackboxgames.thewheel.wheel.Slice;
   import jackboxgames.thewheel.wheel.Wheel;
   import jackboxgames.thewheel.wheel.slicedata.PlayerSliceData;
   import jackboxgames.utils.Counter;
   import jackboxgames.utils.PromiseUtil;
   
   public class AudienceSkullSwapperEffect extends AudienceBinaryChoiceEffect
   {
      public function AudienceSkullSwapperEffect()
      {
         super();
      }
      
      override protected function get _nameKey() : String
      {
         return "SLICE_EFFECT_AUDIENCESKULLSWAPPER_NAME";
      }
      
      override protected function get _promptKey() : String
      {
         return "SLICE_EFFECT_AUDIENCESKULLSWAPPER_PROMPT";
      }
      
      override protected function get _optionAKey() : String
      {
         return "AUDIENCE_SKULL_SWAPPER_OPTION_SINGLE";
      }
      
      override protected function get _optionBKey() : String
      {
         return "AUDIENCE_SKULL_SWAPPER_OPTION_MULTIPLE";
      }
      
      private function _turnToSkulls(filterFn:Function) : Promise
      {
         var p:Promise = null;
         var c:Counter = null;
         var slicesToTurn:Array = _param.wheel.getAllSlices().filter(filterFn);
         if(slicesToTurn.length == 0)
         {
            return PromiseUtil.RESOLVED();
         }
         p = new Promise();
         c = new Counter(slicesToTurn.length,function():void
         {
            p.resolve(null);
         });
         slicesToTurn.forEach(function(s:Slice, ... args):void
         {
            _param.wheel.replaceSliceWithNewSlice(s,GameState.instance.generateBadSlice(),Wheel.REPLACE_TYPE_FLIP,c.generateDoneFn());
         });
         return p;
      }
      
      override protected function _evaluateOptionA() : Promise
      {
         return this._turnToSkulls(function(s:Slice, ... args):Boolean
         {
            return s.params.type == GameConstants.SLICE_TYPE_PLAYER && PlayerSliceData(s.params.data).playersWithStake.length == 1;
         });
      }
      
      override protected function _evaluateOptionB() : Promise
      {
         return this._turnToSkulls(function(s:Slice, ... args):Boolean
         {
            return s.params.type == GameConstants.SLICE_TYPE_PLAYER && PlayerSliceData(s.params.data).playersWithStake.length > 1;
         });
      }
   }
}

