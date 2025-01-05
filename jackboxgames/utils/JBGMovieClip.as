package jackboxgames.utils
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   
   public class JBGMovieClip extends PausableEventDispatcher
   {
       
      
      protected var _mc:MovieClip;
      
      public function JBGMovieClip(mc:MovieClip = null)
      {
         super();
         this._mc = mc;
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      public function set mc(value:MovieClip) : void
      {
         this._mc = value;
      }
      
      public function get height() : Number
      {
         return this._mc.height;
      }
      
      public function set height(value:Number) : void
      {
         this._mc.height = value;
      }
      
      public function get numChildren() : int
      {
         return this._mc.numChildren;
      }
      
      public function get stage() : Stage
      {
         return this._mc.stage;
      }
      
      public function set visible(value:Boolean) : void
      {
         this.mc.visible = value;
      }
      
      public function get visible() : Boolean
      {
         return this.mc.visible;
      }
      
      public function get width() : Number
      {
         return this._mc.width;
      }
      
      public function set width(value:Number) : void
      {
         this._mc.width = value;
      }
      
      public function get x() : Number
      {
         return this._mc.x;
      }
      
      public function set x(value:Number) : void
      {
         this._mc.x = value;
      }
      
      public function get y() : Number
      {
         return this._mc.y;
      }
      
      public function set y(value:Number) : void
      {
         this._mc.y = value;
      }
      
      public function get scaleX() : Number
      {
         return this._mc.scaleX;
      }
      
      public function set scaleX(value:Number) : void
      {
         this._mc.scaleX = value;
      }
      
      public function get scaleY() : Number
      {
         return this._mc.scaleY;
      }
      
      public function set scaleY(value:Number) : void
      {
         this._mc.scaleY = value;
      }
      
      public function contains(obj:DisplayObject) : Boolean
      {
         return this._mc.contains(obj);
      }
      
      public function addChild(obj:DisplayObject) : void
      {
         this._mc.addChild(obj);
      }
      
      public function addChildAt(obj:DisplayObject, index:int) : void
      {
         this._mc.addChildAt(obj,index);
      }
      
      public function removeChild(obj:DisplayObject) : void
      {
         if(this._mc.contains(obj))
         {
            this._mc.removeChild(obj);
         }
      }
      
      public function removeChildAt(index:int) : void
      {
         if(this._mc.numChildren > index)
         {
            this._mc.removeChildAt(index);
         }
      }
      
      public function gotoAndPlay(label:String) : void
      {
         this._mc.gotoAndPlay(label);
      }
      
      public function gotoAndStop(label:String) : void
      {
         this._mc.gotoAndStop(label);
      }
      
      public function dispose() : void
      {
         SpriteUtil.removeAllChildren(this._mc);
         this._mc = null;
      }
      
      override public function dispatchEvent(event:Event) : Boolean
      {
         return this._mc.dispatchEvent(event);
      }
      
      override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         this._mc.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         this._mc.removeEventListener(type,listener,useCapture);
      }
   }
}
