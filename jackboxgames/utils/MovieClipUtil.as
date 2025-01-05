package jackboxgames.utils
{
   import flash.display.*;
   import flash.events.Event;
   import jackboxgames.algorithm.*;
   
   public final class MovieClipUtil
   {
       
      
      public function MovieClipUtil()
      {
         super();
      }
      
      public static function getChildrenWithNameInOrder(mc:MovieClip, name:String, startingIndex:int = 0) : Array
      {
         var returnMe:Array = new Array();
         var i:int = startingIndex;
         while(Boolean(mc[name + i]))
         {
            returnMe.push(mc[name + i]);
            i++;
         }
         return returnMe;
      }
      
      public static function getChildrenThatStartWithName(mc:MovieClip, name:String) : Array
      {
         var child:* = undefined;
         var returnMe:Array = new Array();
         for(var i:int = 0; i < mc.numChildren; i++)
         {
            child = mc.getChildAt(i);
            if(child.name.indexOf(name) == 0)
            {
               returnMe.push(child);
            }
         }
         return returnMe;
      }
      
      public static function getChildrenOfName(mc:MovieClip, name:String, startingIndex:int = 0) : Array
      {
         var returnMe:Array = new Array();
         var i:int = startingIndex;
         while(Boolean(mc[name + i]))
         {
            returnMe.push(mc[name + i]);
            i++;
         }
         return returnMe;
      }
      
      public static function frameExists(mc:MovieClip, frame:String) : Boolean
      {
         var label:FrameLabel = null;
         for each(label in mc.currentLabels)
         {
            if(label.name == frame)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function framesExist(mc:MovieClip, frames:Array) : Boolean
      {
         var frame:String = null;
         for each(frame in frames)
         {
            if(!frameExists(mc,frame))
            {
               return false;
            }
         }
         return true;
      }
      
      public static function getChildrenThatHaveFrames(mc:MovieClip, frames:Array) : Array
      {
         var mcs:Array = null;
         var process:Function = function(otherMC:MovieClip):void
         {
            var child:DisplayObject = null;
            if(framesExist(otherMC,frames))
            {
               mcs.push(otherMC);
            }
            for(var i:int = 0; i < otherMC.numChildren; i++)
            {
               child = otherMC.getChildAt(i);
               if(child is MovieClip)
               {
                  process(MovieClip(child));
               }
            }
         };
         mcs = [];
         process(mc);
         return mcs;
      }
      
      public static function gotoFrameIfExists(mc:MovieClip, frame:String, play:Boolean = true) : Boolean
      {
         var l:FrameLabel = null;
         if(!mc)
         {
            return false;
         }
         for each(l in mc.currentLabels)
         {
            if(l.name == frame)
            {
               if(play)
               {
                  mc.gotoAndPlay(l.name);
               }
               else
               {
                  mc.gotoAndStop(l.name);
               }
               return true;
            }
         }
         return false;
      }
      
      public static function gotoFrameUsingInt(mc:MovieClip, num:int, play:Boolean = true) : void
      {
         if(!mc)
         {
            return;
         }
         var frameName:String = (num >= 0 ? "Pos" : "Neg") + String(int(Math.abs(num)));
         gotoFrameIfExists(mc,frameName,play);
      }
      
      public static function addChildWithResizeKeepRatio(root:*, addMe:*, center:Boolean = true) : void
      {
         var xScale:Number = root.size.width / addMe.width;
         var yScale:Number = root.size.height / addMe.height;
         var scale:Number = Math.min(xScale,yScale);
         addMe.scaleX = scale;
         addMe.scaleY = scale;
         if(center)
         {
            addMe.x = root.size.x + root.size.width / 2 - addMe.width / 2;
            addMe.y = root.size.y + root.size.height / 2 - addMe.height / 2;
         }
         root.addChild(addMe);
      }
      
      public static function addChildWithResize(root:*, addMe:*) : void
      {
         addMe.width = root.size.width;
         addMe.height = root.size.height;
         root.addChild(addMe);
      }
      
      public static function addChildWithResizeIfNeeded(root:*, addMe:*) : void
      {
         if(!root.contains(addMe) && addMe != null)
         {
            addChildWithResize(root,addMe);
         }
      }
      
      public static function disableMouseInteractionForAllChildren(d:DisplayObject) : void
      {
         var c:DisplayObjectContainer = null;
         var i:int = 0;
         if(d is InteractiveObject)
         {
            InteractiveObject(d).mouseEnabled = false;
         }
         if(d is DisplayObjectContainer)
         {
            c = DisplayObjectContainer(d);
            c.mouseChildren = false;
            for(i = 0; i < c.numChildren; i++)
            {
               disableMouseInteractionForAllChildren(c.getChildAt(i));
            }
         }
      }
      
      public static function getFramesWithNameInOrder(mc:MovieClip, name:String, startingIndex:int = 0) : Array
      {
         var returnMe:Array = new Array();
         var i:int = startingIndex;
         while(frameExists(mc,name + i))
         {
            returnMe.push(name + i);
            i++;
         }
         return returnMe;
      }
      
      public static function getFramesThatStartWith(mc:MovieClip, s:String) : Array
      {
         return mc.currentLabels.filter(function(label:FrameLabel, ... args):Boolean
         {
            return label.name.indexOf(s) == 0;
         }).map(function(label:FrameLabel, ... args):String
         {
            return label.name;
         });
      }
      
      public static function getFrameNumberFromLabel(mc:MovieClip, frame:String) : int
      {
         var l:FrameLabel = null;
         var frameNumber:int = -1;
         for each(l in mc.currentLabels)
         {
            if(l.name == frame)
            {
               return l.frame;
            }
         }
         return -1;
      }
      
      public static function getFirstFrameThatExists(mc:MovieClip, frames:Array) : String
      {
         var f:String = null;
         for each(f in frames)
         {
            if(frameExists(mc,f))
            {
               return f;
            }
         }
         return null;
      }
      
      public static function playUntilFrame(mc:MovieClip, frameNum:int, doneFn:Function) : Function
      {
         var callback:Function = null;
         callback = function(evt:Event):void
         {
            if(mc.currentFrame < frameNum)
            {
               return;
            }
            mc.removeEventListener(Event.ENTER_FRAME,callback);
            mc.stop();
            doneFn();
         };
         if(mc.currentFrame >= frameNum)
         {
            doneFn();
            return Nullable.NULL_FUNCTION;
         }
         mc.addEventListener(Event.ENTER_FRAME,callback);
         mc.play();
         return function():void
         {
            mc.stop();
            mc.removeEventListener(Event.ENTER_FRAME,callback);
         };
      }
      
      public static function bringToFront(mc:MovieClip) : void
      {
         if(!mc.parent)
         {
            return;
         }
         mc.parent.setChildIndex(mc,mc.parent.numChildren - 1);
      }
      
      public static function pushToBack(mc:MovieClip) : void
      {
         if(!mc.parent)
         {
            return;
         }
         mc.parent.setChildIndex(mc,0);
      }
   }
}
