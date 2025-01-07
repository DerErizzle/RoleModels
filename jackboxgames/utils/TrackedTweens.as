package jackboxgames.utils
{
   import jackboxgames.animation.tween.JBGTween;
   import jackboxgames.events.EventWithData;
   
   public class TrackedTweens
   {
      private static var _tweens:Array = [];
      
      public function TrackedTweens()
      {
         super();
      }
      
      public static function reset() : void
      {
         var t:JBGTween = null;
         for each(t in _tweens)
         {
            t.dispose();
         }
         _tweens = [];
      }
      
      public static function track(t:JBGTween) : void
      {
         _tweens.push(t);
         t.addEventListener(JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
         {
            ArrayUtil.removeElementFromArray(_tweens,t);
         });
      }
   }
}

