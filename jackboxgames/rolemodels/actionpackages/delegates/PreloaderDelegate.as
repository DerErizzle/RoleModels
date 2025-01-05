package jackboxgames.rolemodels.actionpackages.delegates
{
   import flash.display.MovieClip;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.utils.*;
   
   public class PreloaderDelegate
   {
       
      
      private var _preloader:MovieClipPreloader;
      
      public function PreloaderDelegate(mc:MovieClip)
      {
         super();
         this._preloader = new MovieClipPreloader(mc);
      }
      
      public function reset() : void
      {
         this._preloader.reset();
      }
      
      public function handleActionSetPreloaded(ref:IActionRef, params:Object) : void
      {
         this._preloader.setPreloaded(params.name,params.isPreloaded,TSUtil.createRefEndFn(ref));
      }
   }
}
