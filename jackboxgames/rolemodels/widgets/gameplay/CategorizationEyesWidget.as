package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.utils.JBGUtil;
   
   public class CategorizationEyesWidget
   {
       
      
      private var _mc:MovieClip;
      
      public function CategorizationEyesWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function doAnimation(animation:String, doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,animation,MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}
