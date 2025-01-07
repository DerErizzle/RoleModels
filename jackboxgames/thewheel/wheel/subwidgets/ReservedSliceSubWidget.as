package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class ReservedSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _params:SliceParameters;
      
      public function ReservedSliceSubWidget(mc:MovieClip, params:SliceParameters)
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
         var frame:String = TextUtils.capitalizeFirstCharacter(ReservedSliceData(this._params.data).reservedFor);
         JBGUtil.gotoFrame(this._mc.shape.icon,frame);
      }
   }
}

