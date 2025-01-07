package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class AudienceSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      public function AudienceSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.text);
         this._tf.text = "AUDIENCE";
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
   }
}

