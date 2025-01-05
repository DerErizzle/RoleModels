package jackboxgames.rolemodels.widgets.lobby
{
   import flash.display.MovieClip;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.Duration;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.Nullable;
   
   public class LobbyEyesWidget
   {
       
      
      private var _eyes:MovieClip;
      
      private var _animCanceller:Function;
      
      private const _animations:Array = ["Blink"];
      
      public function LobbyEyesWidget(eyes:MovieClip)
      {
         super();
         this._eyes = eyes;
         this._animCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function reset() : void
      {
         this._animCanceller();
         this._animCanceller = Nullable.NULL_FUNCTION;
         JBGUtil.gotoFrame(this._eyes,"Park");
      }
      
      public function goIdle() : void
      {
         this._animCanceller();
         this._animCanceller = Nullable.NULL_FUNCTION;
         JBGUtil.gotoFrame(this._eyes,"Idle");
      }
      
      public function showEyes() : void
      {
         this._animCanceller();
         this._animCanceller = Nullable.NULL_FUNCTION;
         JBGUtil.gotoFrame(this._eyes,"Appear");
      }
      
      public function loopAnimations(minTimeBetweenAnimations:Duration, maxTimeBetweenAnimations:Duration) : void
      {
         JBGUtil.gotoFrame(this._eyes,"Idle");
         this._animCanceller = JBGUtil.runFunctionAfter(function():void
         {
            JBGUtil.gotoFrameWithFn(_eyes,ArrayUtil.getRandomElement(_animations),MovieClipEvent.EVENT_ANIMATION_DONE,function():void
            {
               loopAnimations(minTimeBetweenAnimations,maxTimeBetweenAnimations);
            });
         },Duration.between(minTimeBetweenAnimations,maxTimeBetweenAnimations));
      }
   }
}
