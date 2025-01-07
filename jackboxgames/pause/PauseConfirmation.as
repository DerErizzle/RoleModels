package jackboxgames.pause
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.text.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class PauseConfirmation extends EventDispatcher
   {
      public static const PAUSE_CONFIRMATION_EVENT:String = "PauseConfirmation";
      
      public static const PAUSE_CONFIRMATION_CONFIRMED:String = "SelectionConfirmed";
      
      public static const PAUSE_CONFIRMATION_CANCELED:String = "SelectionCancelled";
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _backgroundShower:MovieClipShower;
      
      private var _questionText:ExtendableTextField;
      
      private var _showers:Array;
      
      public function PauseConfirmation(mc:MovieClip)
      {
         super();
         this._mc = mc;
         LocalizedTextFieldManager.instance.addFromRoot(mc,PauseMenuManager.PAUSE_MENU_NAME);
         ButtonCalloutManager.instance.addFromRoot(mc,PauseMenuManager.PAUSE_MENU_NAME);
         this._shower = this._createShowerForClip(mc);
         this._backgroundShower = this._createShowerForClip(mc.background);
         this._questionText = ETFHelperUtil.buildExtendableTextFieldFromRoot(mc.question);
         this._showers = [this._shower,this._backgroundShower].filter(function(shower:MovieClipShower, ... args):Boolean
         {
            return shower != null;
         });
      }
      
      private function _createShowerForClip(mc:MovieClip) : MovieClipShower
      {
         if(mc == null)
         {
            return null;
         }
         return new MovieClipShower(mc);
      }
      
      public function reset() : void
      {
         this.setShown(false,Nullable.NULL_FUNCTION);
         JBGUtil.reset(this._showers);
      }
      
      public function setup(questionKey:String, gameName:String) : void
      {
         this.reset();
         this._questionText.text = LocalizationManager.instance.getValueForKey(questionKey,PauseMenuManager.PAUSE_MENU_NAME);
         if(!this._backgroundShower)
         {
            return;
         }
         if(Boolean(gameName) && MovieClipUtil.frameExists(this._mc.background,"Appear" + gameName))
         {
            this._backgroundShower.behaviorTranslator = function(s:String):String
            {
               return s == "Appear" || s == "Disappear" ? s + gameName : s;
            };
         }
         else
         {
            this._backgroundShower.behaviorTranslator = null;
         }
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         MovieClipShower.setMultiple(this._showers,isShown,Duration.ZERO,function():void
         {
            if(isShown)
            {
               UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,_onGamepad);
            }
            else
            {
               UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,_onGamepad);
            }
            doneFn();
         });
      }
      
      private function _onGamepad(evt:EventWithData) : void
      {
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_BACK))
         {
            dispatchEvent(new EventWithData(PAUSE_CONFIRMATION_EVENT,{"value":PAUSE_CONFIRMATION_CANCELED}));
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_SELECT))
         {
            dispatchEvent(new EventWithData(PAUSE_CONFIRMATION_EVENT,{"value":PAUSE_CONFIRMATION_CONFIRMED}));
         }
      }
   }
}

