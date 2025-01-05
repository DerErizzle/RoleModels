package jackboxgames.talkshow.api
{
   import flash.events.IEventDispatcher;
   
   public interface IPauseManager extends IEventDispatcher
   {
       
      
      function userPause() : void;
      
      function userResume() : void;
      
      function loadPause() : void;
      
      function loadResume() : void;
      
      function addItem(param1:IPausable) : void;
      
      function removeItem(param1:IPausable) : void;
      
      function disableUserPause() : void;
      
      function enableUserPause() : void;
      
      function get isPaused() : Boolean;
   }
}
