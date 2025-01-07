package jackboxgames.widgets.postgame
{
   import flash.display.MovieClip;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public class PostGameChoices
   {
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      protected var _startGamepadBehaviors:MovieClipShower;
      
      protected var _cancelGamepadBehaviors:MovieClipShower;
      
      protected var _pressBehaviors:TextFieldShower;
      
      public function PostGameChoices(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._getMainMC());
         this._setupGamepadPrompt();
      }
      
      protected function _getMainMC() : MovieClip
      {
         return this._mc.postGameActions;
      }
      
      protected function _getChoicesMC() : MovieClip
      {
         return this._getMainMC().postGameContainer;
      }
      
      protected function _setupGamepadPrompt() : void
      {
         this._startGamepadBehaviors = new MovieClipShower(this._getChoicesMC().gamepadContainer.startActions);
         this._cancelGamepadBehaviors = new MovieClipShower(this._getChoicesMC().gamepadContainer.cancelActions);
         this._pressBehaviors = new TextFieldShower(this._getChoicesMC().gamepadContainer.pressActions,false);
      }
      
      protected function _setGamepadPromptShown(isShown:Boolean, choice:String) : void
      {
         var showStartGameButton:Boolean = false;
         if(isShown)
         {
            showStartGameButton = SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val;
            this._pressBehaviors.setShown(showStartGameButton,null,Nullable.NULL_FUNCTION);
            if(choice == "TO_START_GAME")
            {
               this._startGamepadBehaviors.setShown(showStartGameButton,Nullable.NULL_FUNCTION);
               this._cancelGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
            }
            else
            {
               this._startGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
               this._cancelGamepadBehaviors.setShown(showStartGameButton,Nullable.NULL_FUNCTION);
            }
            JBGUtil.gotoFrame(this._getChoicesMC(),showStartGameButton ? "GAMEPAD" : "MOBILE");
         }
         else
         {
            this._pressBehaviors.setShown(false);
            this._startGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
            this._cancelGamepadBehaviors.setShown(false,Nullable.NULL_FUNCTION);
         }
      }
      
      protected function _resetGamepadPrompt() : void
      {
         JBGUtil.reset([this._startGamepadBehaviors,this._cancelGamepadBehaviors,this._pressBehaviors]);
      }
      
      protected function _disposeGamepadPrompt() : void
      {
         JBGUtil.dispose([this._startGamepadBehaviors,this._cancelGamepadBehaviors,this._pressBehaviors]);
         this._startGamepadBehaviors = null;
         this._cancelGamepadBehaviors = null;
         this._pressBehaviors = null;
      }
      
      public function dispose() : void
      {
         this._disposeGamepadPrompt();
         JBGUtil.dispose([this._shower]);
         this._mc = null;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower]);
         this._resetGamepadPrompt();
      }
      
      public function setShown(shown:Boolean, choice:String = "", doneFn:Function = null) : void
      {
         this._setGamepadPromptShown(shown,choice);
         this._shower.setShown(shown,doneFn != null ? doneFn : Nullable.NULL_FUNCTION);
      }
   }
}

