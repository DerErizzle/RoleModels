package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.thewheel.wheel.ISliceSubWidget;
   import jackboxgames.thewheel.wheel.SliceParameters;
   
   public class NeighborSliceSubWidget implements ISliceSubWidget
   {
      private var _mc:MovieClip;
      
      public function NeighborSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
         this._mc = mc;
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
   }
}

