package jackboxgames.flash
{
   import bitmasq.Gamepad;
   import bitmasq.GamepadEvent;
   import flash.display.Stage;
   import flash.utils.Dictionary;
   import jackboxgames.engine.*;
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.Gamepad;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class InputManager extends PausableEventDispatcher
   {
      
      public static const INPUT_TYPE_GAMEPAD:String = "InputType.Gamepad";
      
      public static const INPUT_TYPE_KEYBOARD:String = "InputType.Keyboard";
      
      public static const INPUT_TYPE_MOUSE:String = "InputType.Mouse";
      
      public static const INPUT_TYPE_MOBILE:String = "InputType.Mobile";
      
      private static var _instance:InputManager;
       
      
      private var _gamepad:bitmasq.Gamepad;
      
      private var _gamepadKeyMap:Dictionary;
      
      private var _downKeys:Dictionary;
      
      public function InputManager()
      {
         super();
      }
      
      public static function get instance() : InputManager
      {
         return Boolean(_instance) ? _instance : (_instance = new InputManager());
      }
      
      public function get gamepadsConnected() : Boolean
      {
         return this._gamepad.numDevices > 1;
      }
      
      public function init(stage:Stage) : void
      {
         var createEvent:Function = function():EventWithData
         {
            return new EventWithData(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,{
               "message":"HasJoystickConnected",
               "parameter":gamepadsConnected
            });
         };
         if(Boolean(this._gamepadKeyMap))
         {
            return;
         }
         this._downKeys = new Dictionary();
         this._gamepadKeyMap = new Dictionary();
         this._gamepad = Gamepad.init(stage);
         this._gamepad.addEventListener(GamepadEvent.CHANGE,this.onChange);
         if(this.gamepadsConnected)
         {
            Platform.instance.dispatchEvent(createEvent());
         }
         this._gamepad.addEventListener(GamepadEvent.DEVICE_ADDED,function(evt:GamepadEvent):void
         {
            Platform.instance.dispatchEvent(createEvent());
         });
         this._gamepad.addEventListener(GamepadEvent.DEVICE_REMOVED,function(evt:GamepadEvent):void
         {
            Platform.instance.dispatchEvent(createEvent());
         });
      }
      
      public function pause() : void
      {
         this._gamepad.pause();
      }
      
      public function resume() : void
      {
         this._gamepad.resume();
      }
      
      private function onChange(evt:GamepadEvent) : void
      {
         var input:String = null;
         var index:Number = evt.deviceIndex;
         var id:String = String(evt.device.name);
         var inputs:Array = [];
         var value:Number = evt.value;
         var control:Number = evt.control;
         var type:String = id == "keyboard" ? INPUT_TYPE_KEYBOARD : INPUT_TYPE_GAMEPAD;
         var immediate:Boolean = false;
         var controlId:String = this.mapControlToJBGInputIfActive(evt.control,value);
         if(controlId == "")
         {
            return;
         }
         if(value == 1)
         {
            if(!this._downKeys[controlId])
            {
               this._downKeys[controlId] = true;
               inputs.push(controlId);
               if(controlId == "BACK" || controlId == "SELECT")
               {
                  immediate = true;
               }
            }
         }
         else if(value == 0)
         {
            delete this._downKeys[controlId];
         }
         if(inputs.length == 0)
         {
            return;
         }
         var inputType:String = GameEngine.instance.isPaused ? Gamepad.EVENT_RECEIVED_INPUT_PAUSED : Gamepad.EVENT_RECEIVED_INPUT;
         Gamepad.instance.dispatchEvent(new EventWithData(inputType,{
            "index":0,
            "id":id,
            "type":type,
            "inputs":inputs
         }));
         for each(input in inputs)
         {
            Gamepad.instance.dispatchEvent(new EventWithData(input,{
               "index":0,
               "id":id,
               "type":type
            }));
         }
      }
      
      private function mapControlToJBGInputIfActive(control:Number, value:Number) : String
      {
         var input:String = "";
         switch(control)
         {
            case Gamepad.D_DOWN:
               input = "DPAD_DOWN";
               break;
            case Gamepad.D_UP:
               input = "DPAD_UP";
               break;
            case Gamepad.D_LEFT:
               input = "DPAD_LEFT";
               break;
            case Gamepad.D_RIGHT:
               input = "DPAD_RIGHT";
               break;
            case Gamepad.BUTTON_O:
               input = "A";
               break;
            case Gamepad.BUTTON_U:
               input = "X";
               break;
            case Gamepad.BUTTON_Y:
               input = "Y";
               break;
            case Gamepad.BUTTON_A:
               input = "B";
               break;
            case Gamepad.MENU:
               input = "START";
               break;
            case Gamepad.SELECT:
               input = "SELECT";
               break;
            case Gamepad.BACK:
               input = "BACK";
               break;
            case Gamepad.SPACE:
               input = "SPACE";
               break;
            case Gamepad.LT:
               input = "L1";
               break;
            case Gamepad.LB:
               input = "L2";
               break;
            case Gamepad.LSTICK:
               input = "L3";
               break;
            case Gamepad.RT:
               input = "R1";
               break;
            case Gamepad.RB:
               input = "R2";
               break;
            case Gamepad.RSTICK:
               input = "R3";
               break;
            case Gamepad.H:
               input = "H";
               break;
            case Gamepad.P:
               input = "P";
               break;
            case Gamepad.Q:
               input = "Q";
         }
         return input;
      }
   }
}
