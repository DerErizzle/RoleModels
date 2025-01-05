package jackboxgames.mobile
{
   import flash.display.MovieClip;
   import jackboxgames.utils.MovieClipUtil;
   
   public class ButtonLogic
   {
       
      
      private var _mc:MovieClip;
      
      private var _touchLogic:TouchableMovieClip;
      
      private var _downCallback:Function;
      
      private var _upCallback:Function;
      
      private var _enabled:Boolean;
      
      private var _data:*;
      
      public function ButtonLogic(mc:MovieClip, downCallback:Function, upCallback:Function, data:*, stopPropogation:Boolean = false)
      {
         super();
         this._mc = mc;
         this._touchLogic = new TouchableMovieClip(this._mc,stopPropogation);
         this._touchLogic.touchDownFn = this._touchDown;
         this._touchLogic.touchUpFn = this._touchUp;
         this._touchLogic.touchCancelled = this._touchCancelled;
         this._touchLogic.activeTouchWentOutsideFn = this._touchWentOutside;
         this._touchLogic.activeTouchWentInsideFn = this._touchWentInside;
         this._touchLogic.overFn = this._mouseOver;
         this._touchLogic.outFn = this._mouseOut;
         this._downCallback = downCallback;
         this._upCallback = upCallback;
         this._enabled = true;
         this._data = data;
      }
      
      public function clear() : void
      {
         if(Boolean(this._touchLogic))
         {
            this._touchLogic.clear();
         }
         this._touchLogic = null;
         this._mc = null;
         this._upCallback = null;
         this._downCallback = null;
         this._enabled = false;
         this._data = null;
      }
      
      public function skin(skinName:String) : void
      {
         MovieClipUtil.gotoFrameIfExists(this._mc.pressed,skinName);
         MovieClipUtil.gotoFrameIfExists(this._mc.released,skinName);
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(value:Boolean) : void
      {
         if(this._enabled == value)
         {
            return;
         }
         this._enabled = value;
         if(this._enabled)
         {
            MovieClipUtil.gotoFrameIfExists(this._mc,"Out");
         }
         else
         {
            MovieClipUtil.gotoFrameIfExists(this._mc,"Disabled");
         }
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function get mc() : MovieClip
      {
         return this._mc;
      }
      
      private function _touchDown(mc:MovieClip) : void
      {
         if(!this._enabled)
         {
            return;
         }
         MovieClipUtil.gotoFrameIfExists(this._mc,"Pressed");
         this._downCallback(this);
      }
      
      private function _touchUp(mc:MovieClip, inside:Boolean) : void
      {
         if(!this._enabled)
         {
            return;
         }
         if(inside)
         {
            MovieClipUtil.gotoFrameIfExists(this._mc,"Released");
         }
         this._upCallback(this,inside);
      }
      
      private function _touchCancelled(mc:MovieClip) : void
      {
         if(!this._enabled)
         {
            return;
         }
         MovieClipUtil.gotoFrameIfExists(this._mc,"Released");
      }
      
      private function _touchWentOutside(mc:MovieClip) : void
      {
         if(!this._enabled)
         {
            return;
         }
         MovieClipUtil.gotoFrameIfExists(this._mc,"Released");
      }
      
      private function _touchWentInside(mc:MovieClip) : void
      {
         if(!this._enabled)
         {
            return;
         }
         MovieClipUtil.gotoFrameIfExists(this._mc,"Pressed");
      }
      
      private function _mouseOver(mc:MovieClip) : void
      {
         if(!this._enabled)
         {
            return;
         }
         MovieClipUtil.gotoFrameIfExists(this._mc,"Over");
      }
      
      private function _mouseOut(mc:MovieClip) : void
      {
         if(!this._enabled)
         {
            return;
         }
         MovieClipUtil.gotoFrameIfExists(this._mc,"Out");
      }
   }
}
