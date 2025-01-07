package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.model.*;
   import jackboxgames.modules.*;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.lobby.audio.*;
   
   public class LobbyAudience
   {
      protected var _mc:MovieClip;
      
      protected var _shower:MovieClipShower;
      
      protected var _gs:JBGGameState;
      
      protected var _audioHandler:ILobbyAudioHandler;
      
      private var _audienceCountTf:ExtendableTextField;
      
      private var _audienceTf:ExtendableTextField;
      
      private var _isStarted:Boolean;
      
      private var _lastAudienceCountSeen:int;
      
      private var _lastAudienceCountSet:int;
      
      public function LobbyAudience(mc:MovieClip, gs:JBGGameState, audioHandler:ILobbyAudioHandler)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc.audienceActions);
         this._gs = gs;
         this._audioHandler = audioHandler;
         this._setupTextFields();
         this._lastAudienceCountSeen = 0;
         this._lastAudienceCountSet = -1;
      }
      
      protected function _setupTextFields() : void
      {
         this._audienceCountTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.audienceActions.audienceCount);
      }
      
      protected function _setAudienceCountText(count:int) : void
      {
         this._audienceCountTf.text = String(count);
      }
      
      protected function _doUpdateCounterAnimation() : void
      {
         this._shower.doAnimation("UpdateNum",Nullable.NULL_FUNCTION);
      }
      
      public function dispose() : void
      {
         this.reset();
         this._mc = null;
         this._shower = null;
         this._gs = null;
         this._audioHandler = null;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this.setStarted(false);
         this._lastAudienceCountSeen = 0;
         this._lastAudienceCountSet = -1;
      }
      
      public function setStarted(isStarted:Boolean) : void
      {
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
         {
            return;
         }
         if(this._isStarted == isStarted)
         {
            return;
         }
         this._isStarted = isStarted;
         if(this._isStarted)
         {
            this._gs.addEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
            this._gs.audience.addEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,this._onAudienceCountChanged);
            this._lastAudienceCountSeen = 0;
            this._lastAudienceCountSet = -1;
         }
         else
         {
            this._gs.removeEventListener(JBGGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
            this._gs.audience.removeEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,this._onAudienceCountChanged);
         }
      }
      
      private function _onAudienceCountChanged(evt:EventWithData) : void
      {
         this._lastAudienceCountSeen = evt.data;
         this._updateShown();
      }
      
      private function _onPlayersChanged(evt:EventWithData) : void
      {
         this._updateShown();
      }
      
      private function _updateShown() : void
      {
         var shouldShowAudiencePrompt:Boolean = false;
         shouldShowAudiencePrompt = (function():Boolean
         {
            if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
            {
               return false;
            }
            if(_lastAudienceCountSeen == 0 && _gs.players.length < _gs.maxPlayers)
            {
               return false;
            }
            return true;
         })();
         var shouldUpdateAudienceCount:Boolean = (function():Boolean
         {
            if(!shouldShowAudiencePrompt)
            {
               return false;
            }
            if(!_shower.isShown)
            {
               return false;
            }
            return _lastAudienceCountSeen != _lastAudienceCountSet;
         })();
         if(shouldShowAudiencePrompt && !this._shower.isShown)
         {
            this._setAudienceCountText(this._lastAudienceCountSeen);
            this._shower.setShown(true,Nullable.NULL_FUNCTION);
            this._audioHandler.playAudienceOnAudio(Nullable.NULL_FUNCTION);
         }
         else if(shouldUpdateAudienceCount)
         {
            this._lastAudienceCountSet = this._lastAudienceCountSeen;
            this._setAudienceCountText(this._lastAudienceCountSet);
            this._doUpdateCounterAnimation();
            this._audioHandler.playAudienceUpdateAudio(Nullable.NULL_FUNCTION);
         }
      }
      
      public function dismiss() : void
      {
         this._shower.setShown(false,Nullable.NULL_FUNCTION);
      }
   }
}

