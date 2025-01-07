package jackboxgames.thewheel.wheel.subwidgets
{
   import flash.display.MovieClip;
   import jackboxgames.thewheel.wheel.ISliceSubWidget;
   import jackboxgames.thewheel.wheel.SliceParameters;
   
   public class NullSliceSubWidget implements ISliceSubWidget
   {
      public function NullSliceSubWidget(mc:MovieClip, params:SliceParameters)
      {
         super();
      }
      
      public function dispose() : void
      {
      }
      
      public function updateVisuals() : void
      {
      }
   }
}

