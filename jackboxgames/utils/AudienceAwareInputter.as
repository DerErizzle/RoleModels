package jackboxgames.utils
{
   import jackboxgames.blobcast.modules.Audience;
   import jackboxgames.blobcast.modules.SessionManager;
   import jackboxgames.blobcast.modules.Voting;
   import jackboxgames.events.EventWithData;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.talkshow.input.TSInputHandler;
   
   public class AudienceAwareInputter
   {
       
      
      private var _audience:Audience;
      
      private var _voting:Voting;
      
      private var _input:String;
      
      private var _waitTime:Duration;
      
      private var _lastTotalSeen:int;
      
      private var _isActive:Boolean;
      
      private var _canceller:Function;
      
      public function AudienceAwareInputter(audience:Audience, voting:Voting, input:String, waitTime:Duration)
      {
         super();
         this._audience = audience;
         this._voting = voting;
         this._input = input;
         this._waitTime = waitTime;
         this._isActive = false;
         this._canceller = Nullable.NULL_FUNCTION;
      }
      
      public function reset() : void
      {
         this.isActive = false;
      }
      
      public function setWaitTime(waitTime:Duration) : void
      {
         Assert.assert(!this.isActive);
         this._waitTime = waitTime;
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      public function set isActive(val:Boolean) : void
      {
         if(this._isActive == val)
         {
            return;
         }
         this._isActive = val;
         if(this._isActive)
         {
            if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val || this._audience.audienceCount == 0)
            {
               this._doInput();
               this.reset();
               return;
            }
            this._voting.addEventListener(SessionManager.EVENT_GET_STATUS,this._onVotesChanged);
            this._lastTotalSeen = 0;
            this._rescheduleTimer();
         }
         else
         {
            this._voting.removeEventListener(SessionManager.EVENT_GET_STATUS,this._onVotesChanged);
            this._canceller();
            this._canceller = Nullable.NULL_FUNCTION;
         }
      }
      
      private function _onVotesChanged(evt:EventWithData) : void
      {
         var newTotal:int = ObjectUtil.getTotal(evt.data);
         if(newTotal == this._lastTotalSeen)
         {
            return;
         }
         this._lastTotalSeen = newTotal;
         this._rescheduleTimer();
      }
      
      private function _rescheduleTimer() : void
      {
         this._canceller();
         this._canceller = JBGUtil.runFunctionAfter(function():void
         {
            reset();
            _doInput();
         },this._waitTime);
      }
      
      private function _doInput() : void
      {
         TSInputHandler.instance.input(this._input);
      }
   }
}
