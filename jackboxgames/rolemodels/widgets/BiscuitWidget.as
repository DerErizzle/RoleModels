package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class BiscuitWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _isAnimating:Boolean;
      
      public function BiscuitWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function get isAnimating() : Boolean
      {
         return this._isAnimating;
      }
      
      public function reset() : void
      {
         this._shower.reset();
         this._isAnimating = false;
      }
      
      public function setup() : void
      {
         JBGUtil.gotoFrame(this._mc.colors,ArrayUtil.getRandomElement(MovieClipUtil.getFramesThatStartWith(this._mc.colors,"Color")));
      }
      
      public function doAnimation(doneFn:Function) : void
      {
         if(this._isAnimating)
         {
            doneFn();
            return;
         }
         this._isAnimating = true;
         JBGUtil.gotoFrameWithFn(this._mc,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,function():void
         {
            JBGUtil.gotoFrameWithFn(_mc,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
            {
               _isAnimating = false;
               doneFn();
            });
         });
      }
   }
}
