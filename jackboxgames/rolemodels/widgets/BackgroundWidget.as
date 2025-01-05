package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class BackgroundWidget
   {
      
      public static const BACKGROUND_STATES:Object = {
         "yellow":"Yellow",
         "blue":"Blue",
         "red":"Red",
         "pink":"Pink"
      };
       
      
      private var _mc:MovieClip;
      
      private var _backgroundState:String;
      
      public function BackgroundWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._backgroundState = BACKGROUND_STATES.yellow;
      }
      
      public function get backgroundState() : String
      {
         return this._backgroundState;
      }
      
      public function appear() : void
      {
         JBGUtil.gotoFrame(this._mc,"Appear");
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
         this._backgroundState = BACKGROUND_STATES.yellow;
      }
      
      public function transitionBackground(newBackgroundState:String, doneFn:Function) : void
      {
         var frameToGoTo:String = null;
         if(ArrayUtil.arrayContainsElement(ObjectUtil.getValues(BACKGROUND_STATES),newBackgroundState) && newBackgroundState != this._backgroundState)
         {
            frameToGoTo = "Appear" + this._backgroundState + "To" + newBackgroundState;
            this._backgroundState = newBackgroundState;
            GameState.instance.audioRegistrationStack.play("RoomShiftTransition",Nullable.NULL_FUNCTION);
            JBGUtil.gotoFrameWithFn(this._mc,frameToGoTo,MovieClipEvent.EVENT_APPEAR_DONE,doneFn);
         }
         else
         {
            doneFn();
         }
      }
   }
}
