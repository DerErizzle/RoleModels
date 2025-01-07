package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class PointsSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      public function PointsSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         var points:int = PointsSliceData(params.data).value;
         this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.text);
         this._tf.text = TheWheelTextUtil.formattedPointsSliceAmount(points);
         JBGUtil.gotoFrame(this._mc.shape,"Points" + points);
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
   }
}

