package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.localizy.LocalizedTextFieldManager;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class PostGameChoices
   {
       
      
      private var _startGamepadBehaviors:ButtonCallout;
      
      private var _cancelGamepadBehaviors:ButtonCallout;
      
      private var _shower:MovieClipShower;
      
      private var _pressBehaviors:TextFieldShower;
      
      private var _mc:MovieClip;
      
      public function PostGameChoices(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._startGamepadBehaviors = new ButtonCallout(this._mc.choices.gamepad.startGamepad,["SELECT","A"]);
         this._cancelGamepadBehaviors = new ButtonCallout(this._mc.choices.gamepad.cancelGamepad,["BACK","B"]);
         this._pressBehaviors = new TextFieldShower(this._mc.choices.gamepad.tfPress,false);
         LocalizedTextFieldManager.instance.add([this._mc.choices.gamepad.tfPress.container.tf,this._mc.choices.newPlayers.container.tf,this._mc.choices.samePlayers.container.tf]);
         if(this._mc.hasOwnProperty("title"))
         {
            LocalizedTextFieldManager.instance.add([this._mc.title.tf]);
         }
         if(mc.hasOwnProperty("choiceOr"))
         {
            LocalizedTextFieldManager.instance.add([this._mc.choiceOr.tf]);
         }
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower,this._startGamepadBehaviors,this._cancelGamepadBehaviors,this._pressBehaviors]);
      }
      
      public function setShown(shown:Boolean, choice:String = "", doneFn:Function = null) : void
      {
         var showStartGameButton:Boolean = false;
         if(shown)
         {
            showStartGameButton = SettingsManager.instance.getValue(SettingsConstants.SETTING_GAMEPAD_START).val;
            this._pressBehaviors.setShown(showStartGameButton,null,Nullable.NULL_FUNCTION);
            if(choice == "TO_START_GAME")
            {
               this._startGamepadBehaviors.setShown(showStartGameButton,"TO_START_GAME");
               this._cancelGamepadBehaviors.setShown(false);
            }
            else
            {
               this._startGamepadBehaviors.setShown(false);
               this._cancelGamepadBehaviors.setShown(showStartGameButton,"TO_CANCEL_GAME");
            }
            JBGUtil.gotoFrame(this._mc.choices,showStartGameButton ? "GAMEPAD" : "MOBILE");
         }
         else
         {
            this._pressBehaviors.setShown(false);
            this._startGamepadBehaviors.setShown(false);
            this._cancelGamepadBehaviors.setShown(false);
         }
         this._shower.setShown(shown,doneFn != null ? doneFn : Nullable.NULL_FUNCTION);
      }
   }
}
