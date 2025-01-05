package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.MovieClipUtil;
   
   public class WipeTransitionWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _transitions:Array;
      
      private var _availableTransitions:Array;
      
      public function WipeTransitionWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._transitions = MovieClipUtil.getFramesWithNameInOrder(this._mc,"Transition");
         this._availableTransitions = this._transitions.concat();
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function doTransition(doneFn:Function) : void
      {
         if(this._availableTransitions.length == 0)
         {
            this._availableTransitions = this._transitions.concat();
         }
         JBGUtil.gotoFrameWithFn(this._mc,ArrayUtil.getRandomElement(this._availableTransitions,true),MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
      }
   }
}
