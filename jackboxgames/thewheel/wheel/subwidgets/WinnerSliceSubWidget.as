package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class WinnerSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _shapeMc:MovieClip;
      
      private var _params:SliceParameters;
      
      public function WinnerSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         this._params = params;
         this._shapeMc = this._mc.shape;
         JBGUtil.gotoFrame(this._shapeMc,WinnerSliceData(this._params.data).playerThatWins.avatar.frame);
         this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.shape.text);
         this._tf.text = TheWheelTextUtil.formattedPlayerName(WinnerSliceData(this._params.data).playerThatWins) + "!";
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
   }
}

