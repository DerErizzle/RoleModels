package jackboxgames.nativeoverride
{
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.external.ExternalInterface;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class Gamepad extends EventDispatcher
   {
      
      public static const EVENT_UPDATE_RECIEVED:String = "Gamepad.UpdateReceived";
      
      public static const EVENT_RECEIVED_INPUT:String = "Gamepad.ReceivedInput";
      
      public static const EVENT_RECEIVED_INPUT_PAUSED:String = "Gamepad.ReceivedInputPaused";
      
      private static var _instance:Gamepad;
      
      private static const DIGITAL_INPUTS_WE_CARE_ABOUT:Array = [{
         "input":"A",
         "outputInput":"A"
      },{
         "input":"B",
         "outputInput":"B"
      },{
         "input":"X",
         "outputInput":"X"
      },{
         "input":"Y",
         "outputInput":"Y"
      },{
         "input":"START",
         "outputInput":"START"
      },{
         "input":"SELECT",
         "outputInput":"SELECT"
      },{
         "input":"L1",
         "outputInput":"L1"
      },{
         "input":"R1",
         "outputInput":"R1"
      },{
         "input":"L3",
         "outputInput":"L3"
      },{
         "input":"R3",
         "outputInput":"R3"
      },{
         "input":"DPAD_UP",
         "outputInput":"DPAD_UP"
      },{
         "input":"DPAD_DOWN",
         "outputInput":"DPAD_DOWN"
      },{
         "input":"DPAD_LEFT",
         "outputInput":"DPAD_LEFT"
      },{
         "input":"DPAD_RIGHT",
         "outputInput":"DPAD_RIGHT"
      },{
         "input":"MENU",
         "outputInput":"MENU"
      },{
         "input":"BACK",
         "outputInput":"BACK"
      },{
         "input":"ENTER",
         "outputInput":"ENTER"
      }];
      
      private static const ANALOG_INPUTS_WE_CARE_ABOUT:Array = [{
         "input":"L2_ANALOG",
         "outputInput":"L2",
         "min":0.5,
         "max":1
      },{
         "input":"R2_ANALOG",
         "outputInput":"R2",
         "min":0.5,
         "max":1
      },{
         "input":"LEFT_STICK_ANALOG_X",
         "outputInput":"LEFT_STICK_LEFT",
         "min":-1,
         "max":-0.3
      },{
         "input":"LEFT_STICK_ANALOG_X",
         "outputInput":"LEFT_STICK_RIGHT",
         "min":0.3,
         "max":1
      },{
         "input":"LEFT_STICK_ANALOG_Y",
         "outputInput":"LEFT_STICK_UP",
         "min":0.3,
         "max":1
      },{
         "input":"LEFT_STICK_ANALOG_Y",
         "outputInput":"LEFT_STICK_DOWN",
         "min":-1,
         "max":-0.3
      },{
         "input":"RIGHT_STICK_ANALOG_X",
         "outputInput":"RIGHT_STICK_LEFT",
         "min":-1,
         "max":-0.3
      },{
         "input":"RIGHT_STICK_ANALOG_X",
         "outputInput":"RIGHT_STICK_RIGHT",
         "min":0.3,
         "max":1
      },{
         "input":"RIGHT_STICK_ANALOG_Y",
         "outputInput":"RIGHT_STICK_UP",
         "min":0.3,
         "max":1
      },{
         "input":"RIGHT_STICK_ANALOG_Y",
         "outputInput":"RIGHT_STICK_DOWN",
         "min":-1,
         "max":-0.3
      }];
       
      
      private var _controllers:Array;
      
      private var _previousUpdates:Dictionary;
      
      public var ctorNative:Function = null;
      
      public var getNumberOfJoysticksNative:Function = null;
      
      public var getLastInputTypeNative:Function = null;
      
      private var _keyboardObserver:Stage;
      
      private var _keysDown:Dictionary;
      
      public function Gamepad()
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","Gamepad",this);
         }
         if(this.ctorNative != null)
         {
            this.ctorNative();
         }
         this._controllers = [];
         this._previousUpdates = new Dictionary();
      }
      
      public static function Initialize() : void
      {
         Gamepad.instance;
      }
      
      public static function get instance() : Gamepad
      {
         if(!_instance)
         {
            _instance = new Gamepad();
         }
         return _instance;
      }
      
      public function get controllers() : Array
      {
         return this._controllers;
      }
      
      public function destroy() : void
      {
         if(Boolean(this._keyboardObserver))
         {
            this._keyboardObserver.removeEventListener(KeyboardEvent.KEY_DOWN,this._onKeyDown,false);
            this._keyboardObserver.removeEventListener(KeyboardEvent.KEY_UP,this._onKeyUp,false);
            this._keyboardObserver = null;
         }
         this._keysDown = new Dictionary();
      }
      
      public function getNumberOfJoysticks() : int
      {
         if(this.getNumberOfJoysticksNative != null)
         {
            return this.getNumberOfJoysticksNative();
         }
         return 0;
      }
      
      public function getLastInputType() : int
      {
         if(this.getLastInputTypeNative != null)
         {
            return this.getLastInputTypeNative();
         }
         return 0;
      }
      
      public function onUpdate(update:*) : void
      {
         var o:Object = null;
         var inputsReceived:Array = null;
         var currentUpdate:Dictionary = null;
         var previousUpdate:Dictionary = null;
         var previous:Boolean = false;
         var digital:Object = null;
         var analog:Object = null;
         var input:String = null;
         dispatchEvent(new EventWithData(EVENT_UPDATE_RECIEVED,update));
         var playerIndex:int = 0;
         for each(o in update.gamepads)
         {
            inputsReceived = [];
            currentUpdate = new Dictionary();
            previousUpdate = this._previousUpdates[o.ID];
            for each(digital in DIGITAL_INPUTS_WE_CARE_ABOUT)
            {
               currentUpdate[digital.outputInput] = o[digital.input];
               previous = Boolean(previousUpdate) ? Boolean(previousUpdate[digital.outputInput]) : false;
               if(!previous && Boolean(currentUpdate[digital.outputInput]))
               {
                  inputsReceived.push(digital.outputInput);
               }
            }
            for each(analog in ANALOG_INPUTS_WE_CARE_ABOUT)
            {
               currentUpdate[analog.outputInput] = o[analog.input] >= analog.min && o[analog.input] <= analog.max;
               previous = Boolean(previousUpdate) ? Boolean(previousUpdate[analog.outputInput]) : false;
               if(!previous && Boolean(currentUpdate[analog.outputInput]))
               {
                  inputsReceived.push(analog.outputInput);
               }
            }
            this._previousUpdates[o.ID] = currentUpdate;
            if(inputsReceived.length > 0)
            {
               dispatchEvent(new EventWithData(EVENT_RECEIVED_INPUT,{
                  "index":playerIndex,
                  "id":o.ID,
                  "inputs":inputsReceived
               }));
               for each(input in inputsReceived)
               {
                  dispatchEvent(new EventWithData(input,{
                     "index":playerIndex,
                     "id":o.ID
                  }));
               }
            }
            playerIndex++;
         }
      }
      
      public function resetPreviousInput(i:*) : void
      {
         var previousUpdate:Dictionary = null;
         var input:String = null;
         var inputs:Array = ArrayUtil.makeArrayIfNecessary(i);
         for each(previousUpdate in this._previousUpdates)
         {
            for each(input in inputs)
            {
               if(Boolean(previousUpdate[input]))
               {
                  delete previousUpdate[input];
               }
            }
         }
      }
      
      public function setKeyboardObserver(stage:Stage) : void
      {
         if(Boolean(this._keyboardObserver))
         {
            this._keyboardObserver.removeEventListener(KeyboardEvent.KEY_DOWN,this._onKeyDown,false);
            this._keyboardObserver.removeEventListener(KeyboardEvent.KEY_UP,this._onKeyUp,false);
         }
         this._keyboardObserver = stage;
         this._keyboardObserver.addEventListener(KeyboardEvent.KEY_DOWN,this._onKeyDown,false,int.MAX_VALUE - 2);
         this._keyboardObserver.addEventListener(KeyboardEvent.KEY_UP,this._onKeyUp,false,int.MAX_VALUE - 2);
         this._keysDown = new Dictionary();
      }
      
      private function _onKeyDown(evt:KeyboardEvent) : void
      {
         var inputs:Array = null;
         var input:String = null;
         var code:uint = evt.keyCode;
         if(!this._keysDown[code])
         {
            this._keysDown[code] = true;
            inputs = this._checkForKeyboardCodesWeCareAbout(code);
            if(inputs.length > 0)
            {
               evt.preventDefault();
               dispatchEvent(new EventWithData(EVENT_RECEIVED_INPUT,{
                  "index":0,
                  "id":0,
                  "inputs":inputs
               }));
               for each(input in inputs)
               {
                  dispatchEvent(new EventWithData(input,{
                     "index":0,
                     "id":0
                  }));
               }
            }
         }
      }
      
      private function _onKeyUp(evt:KeyboardEvent) : void
      {
         var inputs:Array = null;
         var code:uint = evt.keyCode;
         if(Boolean(this._keysDown[code]))
         {
            this._keysDown[code] = false;
            inputs = this._checkForKeyboardCodesWeCareAbout(code);
            if(inputs.length > 0)
            {
               evt.preventDefault();
            }
         }
      }
      
      private function _checkForKeyboardCodesWeCareAbout(keyCode:uint) : Array
      {
         var inputs:Array = new Array();
         switch(keyCode)
         {
            case Keyboard.ENTER:
            case Keyboard.NUMPAD_ENTER:
               inputs.push("A");
               break;
            case Keyboard.ESCAPE:
            case Keyboard.BACK:
            case Keyboard.BACKSPACE:
               inputs.push("BACK");
               break;
            case Keyboard.LEFT:
               inputs.push("DPAD_LEFT");
               break;
            case Keyboard.RIGHT:
               inputs.push("DPAD_RIGHT");
               break;
            case Keyboard.UP:
               inputs.push("DPAD_UP");
               break;
            case Keyboard.DOWN:
               inputs.push("DPAD_DOWN");
               break;
            case Keyboard.SPACE:
               inputs.push("SPACE");
               break;
            case Keyboard.TAB:
               inputs.push("TAB");
               break;
            case Keyboard.DELETE:
               inputs.push("DELETE");
         }
         return inputs;
      }
   }
}
