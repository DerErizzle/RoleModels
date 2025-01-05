package jackboxgames.rolemodels.widgets.menu
{
   import flash.display.MovieClip;
   import jackboxgames.utils.MovieClipShower;
   
   public class CubeWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      public function CubeWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         this._shower.reset();
      }
   }
}
