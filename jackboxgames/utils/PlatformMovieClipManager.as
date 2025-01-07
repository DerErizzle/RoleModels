package jackboxgames.utils
{
   import flash.display.MovieClip;
   import jackboxgames.loader.JBGLoader;
   import jackboxgames.loader.MediaLoader;
   
   public class PlatformMovieClipManager
   {
      private static var _instance:PlatformMovieClipManager;
      
      private var _swfLoad:MediaLoader;
      
      public function PlatformMovieClipManager()
      {
         super();
      }
      
      public static function get instance() : PlatformMovieClipManager
      {
         return Boolean(_instance) ? _instance : (_instance = new PlatformMovieClipManager());
      }
      
      public function init(complete:Function) : void
      {
         if(Boolean(this._swfLoad) && this._swfLoad.loaded)
         {
            complete(true);
            return;
         }
         this._swfLoad = JBGLoader.instance.loadFile("platform.swf",function(result:Object):void
         {
            complete(result.success);
         }) as MediaLoader;
      }
      
      public function hasMovieClip(name:String) : Boolean
      {
         var c:Class = this._swfLoad.getClass(name);
         return c != null;
      }
      
      public function getMovieClip(name:String) : MovieClip
      {
         var c:Class = this._swfLoad.getClass(name);
         return new c();
      }
   }
}

