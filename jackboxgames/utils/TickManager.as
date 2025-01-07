package jackboxgames.utils
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.Platform;
   
   public class TickManager extends EventDispatcher
   {
      private static var _instance:TickManager;
      
      public static const EVENT_TICK:String = "tick";
      
      private var _isActive:Boolean;
      
      private var _lastTime:int;
      
      public function TickManager()
      {
         super();
         this._isActive = false;
         this._lastTime = 0;
      }
      
      public static function get instance() : TickManager
      {
         return _instance;
      }
      
      public static function initialize() : void
      {
         if(Boolean(_instance))
         {
            return;
         }
         _instance = new TickManager();
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      public function set isActive(val:Boolean) : void
      {
         if(this._isActive == val)
         {
            return;
         }
         this._isActive = val;
         if(this._isActive)
         {
            StageRef.addEventListener(Event.ENTER_FRAME,this._onTick);
            this._lastTime = Platform.instance.getTimer();
         }
         else
         {
            StageRef.removeEventListener(Event.ENTER_FRAME,this._onTick);
         }
      }
      
      private function _onTick(evt:Event) : void
      {
         var thisTime:int = int(Platform.instance.getTimer());
         var elapsed:Duration = Duration.fromMs(thisTime - this._lastTime);
         this._lastTime = thisTime;
         if(Boolean(GameEngine.instance) && GameEngine.instance.isPaused)
         {
            return;
         }
         dispatchEvent(new EventWithData(EVENT_TICK,{"elapsed":elapsed}));
      }
   }
}

