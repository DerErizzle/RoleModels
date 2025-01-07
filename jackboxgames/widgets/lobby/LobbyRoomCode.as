package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class LobbyRoomCode
   {
      protected var _mc:MovieClip;
      
      private var _roomCodeTf:ExtendableTextField;
      
      private var _joinUrlTf:ExtendableTextField;
      
      protected var _hideTf:ExtendableTextField;
      
      protected var _hideRoomCodeBehaviors:MovieClipShower;
      
      protected var _roomCode:String;
      
      protected var _roomCodeHidden:Boolean;
      
      public function LobbyRoomCode(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._setupTextFields();
         this._hideRoomCodeBehaviors = this._createHideRoomCodeBehaviors();
      }
      
      protected function _getBaseMC() : MovieClip
      {
         return this._mc.roomInfoActions.roomInfoContainer;
      }
      
      protected function _setupTextFields() : void
      {
         this._roomCodeTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._getBaseMC().roomCodeContainer.roomCode);
         this._joinUrlTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._getBaseMC().joinUrl);
         this._hideTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._getBaseMC().hideActions.container);
      }
      
      protected function _createHideRoomCodeBehaviors() : MovieClipShower
      {
         return new MovieClipShower(this._getBaseMC().hideActions);
      }
      
      protected function _updateRoomCode() : void
      {
         this._roomCodeTf.text = this._roomCodeHidden ? LocalizationManager.instance.getText("HIDDEN_ROOM_CODE") : this._roomCode;
      }
      
      protected function _updateHidden() : void
      {
         JBGUtil.gotoFrame(this._getBaseMC().roomCodeContainer,this._roomCodeHidden ? "Hidden" : "Default");
         this._hideTf.text = LocalizationManager.instance.getText(this._roomCodeHidden ? "UNHIDE" : "HIDE");
      }
      
      protected function _updateJoinUrl() : void
      {
         this._joinUrlTf.text = LocalizationManager.instance.getText("GO_TO") + BuildConfig.instance.configVal("joinUrl");
      }
      
      protected function _updateShowHideCallout() : void
      {
      }
      
      public function dispose() : void
      {
         JBGUtil.dispose([this._hideRoomCodeBehaviors]);
         this._hideRoomCodeBehaviors = null;
         this._mc = null;
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc.roomInfoActions],"Park");
         JBGUtil.reset([this._hideRoomCodeBehaviors]);
      }
      
      public function setup(roomCode:String) : void
      {
         this._roomCode = roomCode;
         this._roomCodeHidden = SettingsManager.instance.getValue(SettingsConstants.SETTING_HIDE_ROOMCODE).val;
         this._updateRoomCode();
         this._updateHidden();
         this._updateJoinUrl();
         this.showHideCallout();
      }
      
      public function show(doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc.roomInfoActions,"Appear",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
      
      public function toggleRoomCodeHidden() : void
      {
         this._roomCodeHidden = !this._roomCodeHidden;
         this._updateRoomCode();
         this._updateHidden();
      }
      
      public function showHideCallout() : void
      {
         this._hideRoomCodeBehaviors.setShown(SettingsManager.instance.getValue(SettingsConstants.SETTING_HIDE_ROOMCODE).val,Nullable.NULL_FUNCTION);
      }
      
      public function dismissHideCallout() : void
      {
         this._hideRoomCodeBehaviors.setShown(false,Nullable.NULL_FUNCTION);
      }
   }
}

