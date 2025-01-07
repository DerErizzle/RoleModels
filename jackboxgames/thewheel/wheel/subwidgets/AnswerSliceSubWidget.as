package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class AnswerSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      public function AnswerSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.text);
         this._tf.text = AnswerSliceData(params.data).answer;
         var frames:Array = MovieClipUtil.getFramesThatStartWith(this._mc.shape,"Color");
         JBGUtil.gotoFrame(this._mc.shape,frames[AnswerSliceData(params.data).index % frames.length]);
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
   }
}

