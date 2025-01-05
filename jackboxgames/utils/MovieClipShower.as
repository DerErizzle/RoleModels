package jackboxgames.utils
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   
   public class MovieClipShower extends PausableEventDispatcher
   {
      
      public static const EVENT_SHOWN_CHANGED:String = "ShownChanged";
      
      public static const EVENT_SHOWN_ANIMATION_COMPLETE:String = "ShownAnimationComplete";
       
      
      protected var _mc:MovieClip = null;
      
      private var _shown:Boolean = false;
      
      private var _behaviorTranslator:Function;
      
      public function MovieClipShower(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._behaviorTranslator = null;
      }
      
      public static function setMultiple(a:Array, shown:Boolean, d:Duration, doneFn:Function) : void
      {
         var createShowerFn:Function;
         var i:int;
         var numDone:int = 0;
         if(a.length == 0)
         {
            doneFn();
            return;
         }
         createShowerFn = function(s:MovieClipShower):Function
         {
            return function():void
            {
               s.setShown(shown,function():void
               {
                  ++numDone;
                  if(numDone >= a.length)
                  {
                     doneFn();
                  }
               });
            };
         };
         numDone = 0;
         for(i = 0; i < a.length; i++)
         {
            JBGUtil.runFunctionAfter(createShowerFn(a[i]),Duration.scale(d,i));
         }
      }
      
      public function reset() : void
      {
         if(Boolean(this._mc))
         {
            JBGUtil.gotoFrame(this._mc,"Park");
         }
         this._shown = false;
      }
      
      public function dispose() : void
      {
         this._behaviorTranslator = null;
         if(Boolean(this._mc))
         {
            this.reset();
            this._mc = null;
         }
      }
      
      public function set behaviorTranslator(val:Function) : void
      {
         this._behaviorTranslator = val;
      }
      
      public function get isShown() : Boolean
      {
         return this._shown;
      }
      
      public function setShown(shown:Boolean, doneFn:Function) : Boolean
      {
         var baseBehavior:String;
         if(shown == this._shown)
         {
            doneFn();
            return false;
         }
         this._shown = shown;
         dispatchEvent(new EventWithData(EVENT_SHOWN_CHANGED,{"shown":shown}));
         baseBehavior = this._shown ? "Appear" : "Disappear";
         JBGUtil.gotoFrameWithFn(this._mc,this._behaviorTranslator != null ? this._behaviorTranslator(baseBehavior) : baseBehavior,this._shown ? MovieClipEvent.EVENT_APPEAR_DONE : MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
         {
            dispatchEvent(new EventWithData(EVENT_SHOWN_ANIMATION_COMPLETE,{"shown":shown}));
            doneFn();
         });
         return true;
      }
      
      public function doAnimation(behavior:String, doneFn:Function) : Boolean
      {
         if(!this._shown)
         {
            doneFn();
            return false;
         }
         JBGUtil.gotoFrameWithFn(this._mc,this._behaviorTranslator != null ? this._behaviorTranslator(behavior) : behavior,MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
         return true;
      }
      
      public function waitForTrigger(doneFn:Function) : Boolean
      {
         JBGUtil.eventOnce(this._mc,MovieClipEvent.EVENT_TRIGGER,doneFn);
         return true;
      }
   }
}
