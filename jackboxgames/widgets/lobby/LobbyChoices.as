package jackboxgames.widgets.lobby
{
   import flash.display.MovieClip;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public class LobbyChoices
   {
      protected var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _startGamepadBehaviors:MovieClipShower;
      
      private var _cancelGamepadBehaviors:MovieClipShower;
      
      private var _pressBehaviors:TextFieldShower;
      
      private var _everybodysInTf:ExtendableTextField;
      
      public function LobbyChoices(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._getTopLevelMC());
         this._startGamepadBehaviors = new MovieClipShower(this._getStartGamepadMC());
         this._cancelGamepadBehaviors = new MovieClipShower(this._getCancelGamepadMC());
         this._pressBehaviors = new TextFieldShower(this._getPressMC(),false);
         this._everybodysInTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._getEverybodysInMC());
      }
      
      protected function _getTopLevelMC() : MovieClip
      {
         return this._mc.everybodysInActions;
      }
      
      protected function _getStartGamepadMC() : MovieClip
      {
         return this._getTopLevelMC().everybodysInContainer.gamepadContainer.startActions;
      }
      
      protected function _getCancelGamepadMC() : MovieClip
      {
         return this._getTopLevelMC().everybodysInContainer.gamepadContainer.cancelActions;
      }
      
      protected function _getPressMC() : MovieClip
      {
         return this._getTopLevelMC().everybodysInContainer.gamepadContainer.pressActions;
      }
      
      protected function _getEverybodysInMC() : MovieClip
      {
         return this._getTopLevelMC().everybodysInContainer.everybodysIn;
      }
      
      public function dispose() : void
      {
         if(!this._mc)
         {
            return;
         }
         this._mc = null;
         this._everybodysInTf = null;
         JBGUtil.dispose([this._shower,this._startGamepadBehaviors,this._cancelGamepadBehaviors,this._pressBehaviors]);
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower,this._startGamepadBehaviors,this._cancelGamepadBehaviors,this._pressBehaviors]);
      }
      
      public function setEverybodysInText(vipName:String) : void
      {
         this._everybodysInTf.text = LocalizationUtil.getPrintfText("EVERYBODYS_IN",vipName);
      }
      
      public function setShown(shown:Boolean, choice:String = "", doneFn:Function = null) : void
      {
         var showStartGameButton:Boolean = false;
         if(shown)
         {
            showStartGameButton = SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val;
            this._pressBehaviors.setShown(showStartGameButton,null,Nullable.NULL_FUNCTION);
            if(choice == "TO_START")
            {
               this._startGamepadBehaviors.setShown(showStartGameButton,Nullable.NULL_FUNCTION);
               this._cancelGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
            }
            else
            {
               this._startGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
               this._cancelGamepadBehaviors.setShown(showStartGameButton,Nullable.NULL_FUNCTION);
            }
            JBGUtil.gotoFrame(this._getTopLevelMC().everybodysInContainer,showStartGameButton ? "GAMEPAD" : "MOBILE");
         }
         else
         {
            this._pressBehaviors.setShown(false);
            this._startGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
            this._cancelGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
         }
         this._shower.setShown(shown,doneFn != null ? doneFn : Nullable.NULL_FUNCTION);
      }
   }
}

