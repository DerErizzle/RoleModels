package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class PointsForPlayerSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _overlayShower:MovieClipShower;
      
      public function PointsForPlayerSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         var data:PointsForPlayerSliceData = PointsForPlayerSliceData(params.data);
         JBGUtil.gotoFrame(this._mc.shape,data.player.avatar.frame);
         this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.shape.text);
         this._tf.text = TheWheelTextUtil.formattedPlayerName(data.player);
         this._overlayShower = new MovieClipShower(this._mc.overlay);
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
      
      public function setupOverlay(p:Player) : void
      {
         JBGUtil.gotoFrame(this._mc.overlay.color,p.avatar.frame);
      }
      
      public function setOverlayShown(val:Boolean) : void
      {
         this._overlayShower.setShown(val,Nullable.NULL_FUNCTION);
      }
   }
}

