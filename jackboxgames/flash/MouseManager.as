package jackboxgames.flash
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.utils.PausableEventDispatcher;
   import jackboxgames.utils.StageRef;
   
   public class MouseManager extends PausableEventDispatcher
   {
      
      public static const EVENT_MOUSE_WHEEL:String = "MouseEvent.MouseWheel";
      
      public static const EVENT_MOUSE_MOVE:String = "MouseEvent.MouseMove";
      
      public static const EVENT_MOUSE_UP:String = "MouseEvent.MouseUp";
      
      private static var _instance:MouseManager;
      
      private static const IDLE_TIME:int = 5000;
      
      private static const IDLE_STATE_IDLE:int = 0;
      
      private static const IDLE_STATE_HIDDEN:int = 2;
       
      
      private var _idleState:int = 0;
      
      private var _moveIdleTime:int = 0;
      
      private var _gameIsFocused:Boolean = true;
      
      public function MouseManager()
      {
         super();
      }
      
      public static function get instance() : MouseManager
      {
         return Boolean(_instance) ? _instance : (_instance = new MouseManager());
      }
      
      public function start() : void
      {
         this._gameIsFocused = true;
         this._moveIdleTime = Platform.instance.getTimer();
         this._idleState = IDLE_STATE_IDLE;
         Mouse.cursor = MouseCursor.AUTO;
         Mouse.show();
         StageRef.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         StageRef.addEventListener(Event.ENTER_FRAME,this.onCheckIdleTime);
         StageRef.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         StageRef.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
      }
      
      public function end() : void
      {
         Mouse.show();
         this._idleState = IDLE_STATE_IDLE;
         StageRef.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         StageRef.removeEventListener(Event.ENTER_FRAME,this.onCheckIdleTime);
         StageRef.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         StageRef.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
      }
      
      private function _onNativeMessage(evt:EventWithData) : void
      {
         if(evt.data.message == "FocusStateChanged")
         {
            this._gameIsFocused = evt.data.parameter;
            if(this._gameIsFocused)
            {
               this._moveIdleTime = Platform.instance.getTimer();
            }
            else if(this._idleState == IDLE_STATE_HIDDEN)
            {
               Mouse.show();
            }
         }
      }
      
      private function onMouseMove(evt:MouseEvent) : void
      {
         if(this._idleState == IDLE_STATE_HIDDEN)
         {
            Mouse.show();
         }
         this._idleState = IDLE_STATE_IDLE;
         this._moveIdleTime = Platform.instance.getTimer();
         dispatchEvent(new EventWithData(EVENT_MOUSE_MOVE,evt));
      }
      
      private function onCheckIdleTime(evt:Event) : void
      {
         if(this._idleState == IDLE_STATE_HIDDEN || !this._gameIsFocused)
         {
            return;
         }
         var currentTime:int = int(Platform.instance.getTimer());
         if(currentTime - this._moveIdleTime > IDLE_TIME)
         {
            this._idleState = IDLE_STATE_HIDDEN;
            Mouse.hide();
         }
      }
      
      private function onMouseWheel(evt:MouseEvent) : void
      {
         dispatchEvent(new EventWithData(EVENT_MOUSE_WHEEL,{
            "wheelUp":evt.delta > 0,
            "wheelDown":evt.delta < 0,
            "delta":evt.delta
         }));
      }
      
      private function onMouseUp(evt:MouseEvent) : void
      {
         dispatchEvent(new EventWithData(EVENT_MOUSE_UP,evt));
      }
   }
}
