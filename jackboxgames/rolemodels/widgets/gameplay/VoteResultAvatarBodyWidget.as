package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.utils.JBGUtil;
   
   public class VoteResultAvatarBodyWidget
   {
      
      public static const VOTE_RESULT_ANIMATION_LABELS:Object = {
         "LOSE":"Lose",
         "WIN":"Win",
         "SUPER_WIN":"SuperWin"
      };
       
      
      private var _mc:MovieClip;
      
      public function VoteResultAvatarBodyWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc,"Park");
      }
      
      public function setup() : void
      {
         JBGUtil.gotoFrame(this._mc,"Idle");
      }
      
      public function doAnimation(frameLabel:String, doneFn:Function) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc,frameLabel,MovieClipEvent.EVENT_ANIMATION_DONE,function():void
         {
            doneFn();
            JBGUtil.gotoFrame(_mc,"Idle");
         });
      }
   }
}
