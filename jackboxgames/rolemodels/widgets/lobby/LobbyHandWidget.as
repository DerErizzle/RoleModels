package jackboxgames.rolemodels.widgets.lobby
{
   import flash.display.MovieClip;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.Duration;
   import jackboxgames.utils.JBGUtil;
   import jackboxgames.utils.MovieClipUtil;
   import jackboxgames.utils.Nullable;
   
   public class LobbyHandWidget
   {
       
      
      private var _hand:MovieClip;
      
      private var _animCanceller:Function;
      
      private const _animations:Array = ["Move1","Move2","Move3","Move4","Move5"];
      
      public function LobbyHandWidget(hand:MovieClip)
      {
         super();
         this._hand = hand;
         this._animCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function reset() : void
      {
         this._animCanceller();
         this._animCanceller = Nullable.NULL_FUNCTION;
         JBGUtil.gotoFrame(this._hand,"Park");
      }
      
      public function showHand() : void
      {
         this._animCanceller();
         this._animCanceller = Nullable.NULL_FUNCTION;
         JBGUtil.gotoFrame(this._hand,"Appear");
      }
      
      public function goIdle() : void
      {
         this._animCanceller();
         this._animCanceller = Nullable.NULL_FUNCTION;
         JBGUtil.gotoFrame(this._hand,"Idle");
      }
      
      public function loopAnimations(minTimeBetweenAnimations:Duration, maxTimeBetweenAnimations:Duration) : void
      {
         this._animCanceller = JBGUtil.runFunctionAfter(function():void
         {
            var availableAnimations:* = _animations.filter(function(frame:String, ... args):Boolean
            {
               return MovieClipUtil.frameExists(_hand,frame);
            });
            JBGUtil.gotoFrameWithFn(_hand,ArrayUtil.getRandomElement(availableAnimations),MovieClipEvent.EVENT_ANIMATION_DONE,function():void
            {
               loopAnimations(minTimeBetweenAnimations,maxTimeBetweenAnimations);
            });
         },Duration.between(minTimeBetweenAnimations,maxTimeBetweenAnimations));
      }
   }
}
