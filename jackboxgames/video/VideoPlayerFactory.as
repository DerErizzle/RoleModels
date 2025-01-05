package jackboxgames.video
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import jackboxgames.utils.EnvUtil;
   
   public final class VideoPlayerFactory
   {
      
      public static var Parent:DisplayObjectContainer = null;
       
      
      public function VideoPlayerFactory()
      {
         super();
      }
      
      public static function videoPlayer(frame:MovieClip) : IVideoPlayer
      {
         if(EnvUtil.isAIR())
         {
            return new VideoPlayerFlash(frame,Parent);
         }
         if(EnvUtil.isConsole() || EnvUtil.isPC())
         {
            return new VideoPlayerConsole(frame,Parent);
         }
         if(EnvUtil.isMobile())
         {
            return new VideoPlayerMobile(frame,Parent);
         }
         return new VideoPlayerBase(frame,Parent);
      }
   }
}
