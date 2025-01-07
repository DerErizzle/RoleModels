package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class BonusSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      private var _params:SliceParameters;
      
      public function BonusSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
         this._params = params;
         this.updateVisuals();
         var data:BonusSliceData = BonusSliceData(this._params.data);
         var playerFrame:String = data.owner.avatar.frame;
         JBGUtil.gotoFrame(this._mc.shape,playerFrame);
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
   }
}

