package jackboxgames.utils
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   import flash.utils.*;
   import jackboxgames.events.*;
   
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
      
      public static function hasChildOfType(mc:MovieClip, className:String) : Boolean
      {
         return getChildrenOfType(mc,className).length > 0;
      }
      
      public static function getChildrenOfType(mc:MovieClip, className:String) : Array
      {
         var child:* = undefined;
         var children:Array = [];
         for(var i:int = 0; i < mc.numChildren; i++)
         {
            child = mc.getChildAt(i);
            if(className == "TextField")
            {
               if(!(child is TextField))
               {
                  continue;
               }
               if(child.name.indexOf("instance") == 0)
               {
                  continue;
               }
            }
            else if(getQualifiedClassName(child) != className)
            {
               continue;
            }
            children.push(child);
         }
         return children;
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
      
      public static function resizeKeepRatio(mc:MovieClip, center:Boolean = true) : void
      {
         if(!mc.parent)
         {
            return;
         }
         if(!mc.parent.hasOwnProperty("size"))
         {
            return;
         }
         var sizeMc:MovieClip = mc.parent["size"];
         var sizeAspect:Number = sizeMc.width / sizeMc.height;
         var mcAspect:Number = mc.width / mc.height;
         if(mcAspect >= sizeAspect)
         {
            mc.width = sizeMc.width;
            mc.height = mc.width / mcAspect;
         }
         else
         {
            mc.height = sizeMc.height;
            mc.width = mc.height * mcAspect;
         }
         if(center)
         {
            mc.x = sizeMc.x + sizeMc.width / 2 - mc.width / 2;
            mc.y = sizeMc.y + sizeMc.height / 2 - mc.height / 2;
         }
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
      
      public static function getEndingEventForBehavior(behavior:String) : String
      {
         if(behavior == "Appear")
         {
            return MovieClipEvent.EVENT_APPEAR_DONE;
         }
         if(behavior == "Disappear")
         {
            return MovieClipEvent.EVENT_DISAPPEAR_DONE;
         }
         return MovieClipEvent.EVENT_ANIMATION_DONE;
      }
   }
}

