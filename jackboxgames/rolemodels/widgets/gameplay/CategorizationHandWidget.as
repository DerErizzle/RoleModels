package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.utils.JBGUtil;
   
   public class CategorizationHandWidget
   {
       
      
      private var _mc:MovieClip;
      
      public function CategorizationHandWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function doAnimation(animation:String, chosenCategoryIndex:int, doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,animation + String(chosenCategoryIndex),MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}
