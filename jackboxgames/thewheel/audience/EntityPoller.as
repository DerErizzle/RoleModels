package jackboxgames.thewheel.audience
{
   import jackboxgames.ecast.messages.Reply;
   import jackboxgames.utils.Duration;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.Nullable;
   
   public class EntityPoller
   {
      private var _delegate:IEntityPollerDelegate;
      
      private var _duration:Duration;
      
      private var _isPolling:Boolean;
      
      private var _pollCanceler:Function;
      
      public function EntityPoller(delegate:IEntityPollerDelegate, d:Duration)
      {
         super();
         this._delegate = delegate;
         this._duration = d.clone();
      }
      
      public function setIsPolling(val:Boolean) : void
      {
         if(this._isPolling == val)
         {
            return;
         }
         this._isPolling = val;
         if(this._isPolling)
         {
            this._scheduleNextPoll();
         }
         else
         {
            this._pollCanceler();
            this._pollCanceler = Nullable.NULL_FUNCTION;
         }
      }
      
      private function _scheduleNextPoll() : void
      {
         this._pollCanceler = JBGUtil.runFunctionAfter(function():void
         {
            _delegate.poll().then(function(re:Reply):void
            {
               if(!_isPolling)
               {
                  return;
               }
               _delegate.onPollReply(re);
               _scheduleNextPoll();
            },function(... args):void
            {
               if(!_isPolling)
               {
                  return;
               }
               _scheduleNextPoll();
            });
         },this._duration);
      }
   }
}

