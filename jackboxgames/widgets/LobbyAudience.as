package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.blobcast.model.BlobCastGameState;
   import jackboxgames.blobcast.modules.Audience;
   import jackboxgames.events.EventWithData;
   import jackboxgames.localizy.LocalizedTextFieldManager;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class LobbyAudience implements ILobbyAudience
   {
       
      
      private var _mc:MovieClip;
      
      private var _maxPlayers:int;
      
      private var _audienceCountTf:ExtendableTextField;
      
      private var _audienceTf:ExtendableTextField;
      
      private var _audiencePromptIsShown:Boolean;
      
      private var _audienceCountIsShown:Boolean;
      
      private var _lastAudienceCountSeen:int;
      
      private var _lastAudienceCountSet:int;
      
      private var _audioHandler:ILobbyAudioHandler;
      
      private var _gameState:BlobCastGameState;
      
      private var _showCountWithAudience:Boolean = false;
      
      public function LobbyAudience(mc:MovieClip, gameState:BlobCastGameState)
      {
         super();
         this._mc = mc;
         this._gameState = gameState;
         this._audienceCountTf = new ExtendableTextField(this._mc.counter.AudNum,[],[PostEffectFactory.createDynamicResizerEffect(1)]);
         this._audiencePromptIsShown = false;
         this._audienceCountIsShown = false;
         this._lastAudienceCountSeen = 0;
         this._lastAudienceCountSet = -1;
         this._gameState.audience.removeEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,this._onAudienceCountChanged);
         if(Boolean(this._mc.audience) && Boolean(this._mc.audience.container))
         {
            this._audienceTf = new ExtendableTextField(this._mc.audience.container,[],[PostEffectFactory.createDynamicResizerEffect(1),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
            LocalizedTextFieldManager.instance.add([this._mc.audience.container.tf]);
         }
      }
      
      public function get showCountWithAudience() : Boolean
      {
         return this._showCountWithAudience;
      }
      
      public function set showCountWithAudience(value:Boolean) : void
      {
         this._showCountWithAudience = value;
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc.audience,this._mc.counter],"Park");
         this._gameState.removeEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         this._gameState.audience.removeEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,this._onAudienceCountChanged);
         this._audiencePromptIsShown = false;
         this._audienceCountIsShown = false;
         this._lastAudienceCountSeen = 0;
         this._lastAudienceCountSet = -1;
      }
      
      public function start(maxPlayers:int, audioHandler:ILobbyAudioHandler) : void
      {
         this._maxPlayers = maxPlayers;
         this._audioHandler = audioHandler;
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
         {
            this._gameState.addEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
            this._gameState.audience.addEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,this._onAudienceCountChanged);
            this._gameState.sessions.startPolling(this._gameState.audience,{},Nullable.NULL_FUNCTION);
            this._lastAudienceCountSeen = 0;
            this._lastAudienceCountSet = -1;
         }
      }
      
      public function stop() : void
      {
         this._gameState.removeEventListener(BlobCastGameState.EVENT_PLAYERS_CHANGED,this._onPlayersChanged);
         this._gameState.audience.removeEventListener(Audience.EVENT_AUDIENCE_COUNT_CHANGED,this._onAudienceCountChanged);
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
            if(_lastAudienceCountSeen == 0 && _gameState.players.length < _maxPlayers)
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
            if(!_audiencePromptIsShown && _showCountWithAudience)
            {
               return true;
            }
            return _lastAudienceCountSeen != _lastAudienceCountSet;
         })();
         if(shouldShowAudiencePrompt && !this._audiencePromptIsShown)
         {
            JBGUtil.gotoFrame(this._mc.audience,"Appear");
            this._audiencePromptIsShown = true;
            this._audioHandler.playAudienceOnAudio(Nullable.NULL_FUNCTION);
         }
         if(shouldUpdateAudienceCount)
         {
            this._lastAudienceCountSet = this._lastAudienceCountSeen;
            this._audienceCountTf.text = String(this._lastAudienceCountSet);
            JBGUtil.gotoFrame(this._mc.counter,this._audienceCountIsShown ? "UpdateNum" : "Appear");
            this._audienceCountIsShown = true;
            this._audioHandler.playAudienceUpdateAudio(Nullable.NULL_FUNCTION);
         }
      }
      
      public function dismiss() : void
      {
         if(this._audiencePromptIsShown)
         {
            this._audiencePromptIsShown = false;
            JBGUtil.gotoFrame(this._mc.audience,"Disappear");
         }
         if(this._audienceCountIsShown)
         {
            this._audienceCountIsShown = false;
            JBGUtil.gotoFrame(this._mc.counter,"Disappear");
         }
      }
   }
}
