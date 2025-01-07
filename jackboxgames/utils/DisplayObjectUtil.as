package jackboxgames.utils
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import jackboxgames.nativeoverride.Platform;
   
   public final class DisplayObjectUtil
   {
      public function DisplayObjectUtil()
      {
         super();
      }
      
      public static function getGlobalPosition(d:DisplayObject) : Point
      {
         if(!d.parent)
         {
            return new Point(d.x,d.y);
         }
         return d.parent.localToGlobal(new Point(d.x,d.y));
      }
      
      public static function getInstancePath(d:DisplayObject) : String
      {
         var path:String = d.name;
         var parent:DisplayObjectContainer = d.parent;
         while(parent != null)
         {
            path = parent.name + "." + path;
            parent = parent.parent;
         }
         return path;
      }
      
      public static function removeFromParent(d:DisplayObject) : void
      {
         if(!d.parent)
         {
            return;
         }
         d.parent.removeChild(d);
      }
      
      public static function getPathTo(d:DisplayObject) : String
      {
         if(d.root == null)
         {
            return d.name;
         }
         if(d.parent == d.root)
         {
            return d.parent.name + "." + d.name;
         }
         return getPathTo(MovieClip(d.parent)) + "." + d.name;
      }
      
      public static function shake(target:DisplayObject, duration:Duration, magnitude:Number, frequency:int, doneFn:Function) : Function
      {
         var originalX:Number = NaN;
         var originalY:Number = NaN;
         var startTime:uint = 0;
         var endTime:uint = 0;
         var frameCount:int = 0;
         var frameTick:Function = null;
         var end:Function = null;
         frameTick = function(evt:Event):void
         {
            var currentTime:uint = Platform.instance.getTimer();
            if(currentTime >= endTime || currentTime < startTime)
            {
               end();
               doneFn();
               return;
            }
            ++frameCount;
            if(frameCount >= frequency)
            {
               frameCount = 0;
               var x:Number = NumberUtil.getRandomInRange(-1,1) * magnitude;
               var y:Number = NumberUtil.getRandomInRange(-1,1) * magnitude;
               target.x = x;
               target.y = y;
               return;
            }
         };
         end = function():void
         {
            StageRef.removeEventListener(Event.ENTER_FRAME,frameTick);
            target.x = originalX;
            target.y = originalY;
         };
         originalX = target.x;
         originalY = target.y;
         StageRef.addEventListener(Event.ENTER_FRAME,frameTick);
         startTime = Platform.instance.getTimer();
         endTime = startTime + duration.inMs;
         frameCount = 0;
         return end;
      }
   }
}

