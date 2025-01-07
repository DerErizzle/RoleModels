package jackboxgames.talkshow.api
{
   public interface IPreloader
   {
      function preloadPercent(param1:Number) : void;
      
      function preloadDone() : void;
      
      function bufferOn() : void;
      
      function bufferPercent(param1:Number) : void;
      
      function bufferDone() : void;
   }
}

