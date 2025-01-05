package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.utils.JBGUtil;
   
   public class BlinkTransitionWidget
   {
       
      
      private var _mc:MovieClip;
      
      public function BlinkTransitionWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function doTransition(eyesClosedFn:Function, doneFn:Function) : void
      {
         var _eyeClosed:Function = null;
         _eyeClosed = function(evt:MovieClipEvent):void
         {
            if(evt.data == "EyeClosed")
            {
               eyesClosedFn();
               _mc.removeEventListener(MovieClipEvent.EVENT_TRIGGER,_eyeClosed);
            }
         };
         this._mc.addEventListener(MovieClipEvent.EVENT_TRIGGER,_eyeClosed);
         JBGUtil.gotoFrameWithFn(this._mc,"Transition",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}
