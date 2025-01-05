package jackboxgames.mobile
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class ExternalDisplayManager extends PausableEventDispatcher
   {
      
      private static var _instance:ExternalDisplayManager;
      
      public static const EVENT_SCREEN_STATE_CHANGED:String = "ExternalDisplayManager.ScreenStateChanged";
       
      
      private var _isOnExternalDisplay:Boolean = true;
      
      public function ExternalDisplayManager()
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("SetScreenStateCallback",this._screenStateCallback);
         }
      }
      
      public static function get instance() : ExternalDisplayManager
      {
         if(!_instance)
         {
            _instance = new ExternalDisplayManager();
         }
         return _instance;
      }
      
      public function get isOnExternalDisplay() : Boolean
      {
         return this._isOnExternalDisplay;
      }
      
      private function _screenStateCallback(isOnExternalDisplay:Boolean) : void
      {
         this._isOnExternalDisplay = isOnExternalDisplay;
         dispatchEvent(new EventWithData(EVENT_SCREEN_STATE_CHANGED,this._isOnExternalDisplay));
      }
   }
}
