package jackboxgames.talkshow.core
{
   internal class DefaultPreloader extends MovieClip implements IPreloader
   {
      public function DefaultPreloader()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.handleAdded);
      }
      
      override public function toString() : String
      {
         return "[Default Preloader]";
      }
      
      private function handleAdded(e:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.handleAdded);
      }
      
      public function preloadPercent(percent:Number) : void
      {
         Logger.debug(this + " preloadPercent=" + percent);
      }
      
      public function preloadDone() : void
      {
         Logger.debug(this + " preloadDone");
      }
      
      public function bufferOn() : void
      {
      }
      
      public function bufferPercent(percent:Number) : void
      {
         Logger.debug(this + " bufferPercent=" + percent);
      }
      
      public function bufferDone() : void
      {
         Logger.debug(this + " bufferDone");
      }
   }
}

