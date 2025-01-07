package jackboxgames.thewheel.wheel.effects
{
   import jackboxgames.algorithm.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class AudienceSliceCountEffect extends AudienceBinaryChoiceEffect
   {
      public function AudienceSliceCountEffect()
      {
         super();
      }
      
      override protected function get _nameKey() : String
      {
         return "SLICE_EFFECT_AUDIENCESLICECOUNT_NAME";
      }
      
      override protected function get _promptKey() : String
      {
         return "SLICE_EFFECT_AUDIENCESLICECOUNT_PROMPT";
      }
      
      override protected function get _optionAKey() : String
      {
         return "AUDIENCE_SLICE_COUNT_OPTION_MOST_SLICES";
      }
      
      override protected function get _optionBKey() : String
      {
         return "AUDIENCE_SLICE_COUNT_OPTION_FEWEST_SLICES";
      }
      
      private function _givePoints(foldFn:Function) : Promise
      {
         var numSlices:PerPlayerContainer = null;
         var target:int = 0;
         numSlices = PerPlayerContainerUtil.MAP(GameState.instance.players,function(p:Player, ... args):int
         {
            var n:* = 0;
            _param.wheel.getAllSlices().forEach(function(s:Slice, ... args):void
            {
               if(s.params.type == GameConstants.SLICE_TYPE_BONUS && BonusSliceData(s.params.data).owner == p)
               {
                  ++n;
               }
               else if(s.params.type == GameConstants.SLICE_TYPE_PLAYER && PlayerSliceData(s.params.data).getNumStakesForPlayer(p) > 0)
               {
                  ++n;
               }
            });
            return n;
         });
         target = MapFold.process(GameState.instance.players,function(p:Player, ... args):int
         {
            return numSlices.getDataForPlayer(p);
         },foldFn);
         GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return numSlices.getDataForPlayer(p) == target;
         }).forEach(function(p:Player, ... args):void
         {
            p.addScoreChange(new ScoreChange().withAmount(GameState.instance.jsonData.gameConfig.audienceSliceCountNumPoints));
         });
         return PromiseUtil.RESOLVED();
      }
      
      override protected function _evaluateOptionA() : Promise
      {
         return this._givePoints(MapFold.FOLD_MAX);
      }
      
      override protected function _evaluateOptionB() : Promise
      {
         return this._givePoints(MapFold.FOLD_MIN);
      }
   }
}

