package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.localizy.LocalizedTextFieldManager;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class LobbyChoices
   {
       
      
      private var _startGamepadBehaviors:ButtonCallout;
      
      private var _cancelGamepadBehaviors:ButtonCallout;
      
      private var _shower:MovieClipShower;
      
      private var _pressBehaviors:TextFieldShower;
      
      private var _mc:MovieClip;
      
      public function LobbyChoices(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._startGamepadBehaviors = new ButtonCallout(this._mc.start.gamepad.startGamepad,["SELECT","A"]);
         this._cancelGamepadBehaviors = new ButtonCallout(this._mc.start.gamepad.cancelGamepad,["BACK","B"]);
         this._pressBehaviors = new TextFieldShower(this._mc.start.gamepad.tfPress,false);
         LocalizedTextFieldManager.instance.add([this._mc.start.gamepad.tfPress.container.tf,this._mc.start.everybodysIn.tf]);
      }
      
      public function dispose() : void
      {
         if(!this._mc)
         {
            return;
         }
         this._mc = null;
         JBGUtil.dispose([this._shower,this._startGamepadBehaviors,this._cancelGamepadBehaviors,this._pressBehaviors]);
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
            if(choice == "TO_START")
            {
               this._startGamepadBehaviors.setShown(showStartGameButton,"TO_START");
               this._cancelGamepadBehaviors.setShown(false);
            }
            else
            {
               this._startGamepadBehaviors.setShown(false);
               this._cancelGamepadBehaviors.setShown(showStartGameButton,"TO_CANCEL");
            }
            JBGUtil.gotoFrame(this._mc.start,showStartGameButton ? "GAMEPAD" : "MOBILE");
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
