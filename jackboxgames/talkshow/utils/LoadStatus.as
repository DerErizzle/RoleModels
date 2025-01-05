package jackboxgames.talkshow.utils
{
   public final class LoadStatus
   {
      
      public static const STATUS_NONE:int = 0;
      
      public static const STATUS_LOADING:int = 1;
      
      public static const STATUS_LOADED:int = 2;
      
      public static const STATUS_INVALIDATED:int = 3;
      
      public static const STATUS_PLAYING:int = 4;
      
      public static const STATUS_FAILED:int = -1;
       
      
      public function LoadStatus()
      {
         super();
      }
   }
}
