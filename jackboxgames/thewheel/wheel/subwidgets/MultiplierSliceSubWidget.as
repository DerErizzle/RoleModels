package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class MultiplierSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _params:SliceParameters;
      
      public function MultiplierSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         this._params = params;
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
         JBGUtil.gotoFrame(this._mc.shape.icon,"Multiplier");
      }
   }
}

