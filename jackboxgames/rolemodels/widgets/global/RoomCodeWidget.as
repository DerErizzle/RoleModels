package jackboxgames.rolemodels.widgets.global
{
   import flash.display.MovieClip;
   import jackboxgames.events.EventWithData;
   import jackboxgames.rolemodels.GameState;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.text.ExtendableTextField;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.LocalizationUtil;
   import jackboxgames.utils.MovieClipShower;
   import jackboxgames.utils.Nullable;
   import jackboxgames.utils.WatchableValue;
   
   public class RoomCodeWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _audienceHeadShower:MovieClipShower;
      
      private var _background:MovieClip;
      
      private var _roomCodeTf:ExtendableTextField;
      
      private var _audienceTf:ExtendableTextField;
      
      public function RoomCodeWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._background = this._mc.roomCode.bg;
         this._audienceHeadShower = new MovieClipShower(this._mc.roomCode.audienceIcon);
         this._roomCodeTf = new ExtendableTextField(this._mc.roomCode.roomCodeTF,[],[]);
         this._audienceTf = new ExtendableTextField(this._mc.roomCode.audienceTF,[],[]);
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this._audienceHeadShower.reset();
         GameState.instance.gameAudience.numAudienceMembers.removeEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onAudienceCountChanged);
      }
      
      public function setup(roomCode:String) : void
      {
         GameState.instance.gameAudience.numAudienceMembers.addEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onAudienceCountChanged);
         this._roomCodeTf.text = roomCode;
         JBGUtil.gotoFrame(this._background,SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val ? "AudienceOn" : "AudienceOff");
         this._audienceHeadShower.setShown(SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val,Nullable.NULL_FUNCTION);
      }
      
      private function setAudienceText() : void
      {
         if(SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
         {
            if(GameState.instance.gameAudience.numAudienceMembers.val > 0 || GameState.instance.gameAudience.hasEverBeenAudience.val)
            {
               this._audienceTf.text = String(GameState.instance.gameAudience.numAudienceMembers.val);
            }
            else
            {
               this._audienceTf.text = LocalizationUtil.getPrintfText("JOIN");
            }
         }
         else
         {
            this._audienceTf.text = "";
         }
      }
      
      private function _onAudienceCountChanged(evt:EventWithData) : void
      {
         this.setAudienceText();
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this.setAudienceText();
         this._shower.setShown(isShown,doneFn);
      }
   }
}
