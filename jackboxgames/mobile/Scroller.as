package jackboxgames.mobile
{
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.geom.Rectangle;
   
   public class Scroller
   {
       
      
      private var _mc:MovieClip;
      
      private var _stage:Stage;
      
      private var _scrollableArea:Rectangle;
      
      private var _fnLowerBound:Function;
      
      private var _accelerator:Accelerator;
      
      private var _bufferSize:Number;
      
      private var _onScrolledFn:Function;
      
      private var _isActive:Boolean;
      
      public function Scroller(mc:MovieClip, stage:Stage, scrollableArea:Rectangle, onScrolledFn:Function, fnLowerBound:Function)
      {
         super();
         this._mc = mc;
         this._stage = stage;
         this._scrollableArea = scrollableArea;
         this._fnLowerBound = fnLowerBound;
         this._bufferSize = 0;
         this._accelerator = new Accelerator(this._mc,this._stage,this._scrollableArea,this._getTop,this._getBottom,this._getUpperBound,this._getLowerBound,this._scroll);
         this._onScrolledFn = onScrolledFn;
         this._isActive = true;
      }
      
      public function set isActive(val:Boolean) : void
      {
         if(val == this._isActive)
         {
            return;
         }
         this._isActive = val;
         this._accelerator.isActive = this._isActive;
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      private function _scroll(offset:Number) : void
      {
         if(!this._isActive)
         {
            return;
         }
         this._mc.y += offset;
         this._onScrolledFn();
      }
      
      private function _getTop() : Number
      {
         return this._mc.y;
      }
      
      private function _getBottom() : Number
      {
         return this._mc.y + this._mc.height;
      }
      
      private function _getUpperBound() : Number
      {
         return this._scrollableArea.y;
      }
      
      private function _getLowerBound() : Number
      {
         return this._fnLowerBound();
      }
   }
}
