package jackboxgames.rolemodels.actionpackages.delegates
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class AudienceVote
   {
       
      
      private var _audienceVoteStopFn:Function;
      
      private var _audienceVoteApplyFn:Function;
      
      public function AudienceVote()
      {
         super();
      }
      
      public function reset() : void
      {
         this._audienceVoteStopFn = Nullable.NULL_FUNCTION;
         this._audienceVoteApplyFn = Nullable.NULL_FUNCTION;
      }
      
      public function handleActionSetAudienceVoteActive(ref:IActionRef, params:Object) : void
      {
         var startFn:Function;
         var tempFn:Function = null;
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
         {
            ref.end();
            return;
         }
         if(Boolean(params.isActive))
         {
            startFn = function(stopFn:Function):void
            {
               _audienceVoteStopFn = stopFn;
               ref.end();
            };
            if(this._audienceVoteStopFn != Nullable.NULL_FUNCTION)
            {
               ref.end();
               return;
            }
            GameState.instance.gameAudience.startResultVote(params.type,startFn);
         }
         else
         {
            if(this._audienceVoteStopFn == Nullable.NULL_FUNCTION)
            {
               ref.end();
               return;
            }
            tempFn = this._audienceVoteStopFn;
            this._audienceVoteStopFn = Nullable.NULL_FUNCTION;
            tempFn(function(applyFn:Function):void
            {
               _audienceVoteApplyFn = applyFn;
               ref.end();
            });
         }
      }
      
      public function handleActionApplyAudienceVotes(ref:IActionRef, params:Object) : void
      {
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
         {
            ref.end();
            return;
         }
         var tempFn:Function = this._audienceVoteApplyFn;
         this._audienceVoteApplyFn = Nullable.NULL_FUNCTION;
         tempFn();
         ref.end();
      }
   }
}
