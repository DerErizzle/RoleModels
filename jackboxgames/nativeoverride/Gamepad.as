package jackboxgames.nativeoverride
{
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class Gamepad extends EventDispatcher
   {
      private static var _instance:Gamepad;
      
      public static const EVENT_UPDATE_RECIEVED:String = "Gamepad.UpdateReceived";
      
      public static const EVENT_RECEIVED_INPUT:String = "Gamepad.ReceivedInput";
      
      public static const EVENT_RECEIVED_INPUT_PAUSED:String = "Gamepad.ReceivedInputPaused";
      
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
      
      private var _catchUpNextUpdate:Boolean;
      
      public var ctorNative:Function = null;
      
      public var getNumberOfJoysticksNative:Function = null;
      
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
      }
      
      public function getNumberOfJoysticks() : int
      {
         if(this.getNumberOfJoysticksNative != null)
         {
            return this.getNumberOfJoysticksNative();
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
         if(!this._catchUpNextUpdate)
         {
            dispatchEvent(new EventWithData(EVENT_UPDATE_RECIEVED,update));
         }
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
            if(!this._catchUpNextUpdate)
            {
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
            }
            playerIndex++;
         }
         this._catchUpNextUpdate = false;
      }
      
      public function useNextUpdateAsCatchUp() : void
      {
         this._catchUpNextUpdate = true;
      }
   }
}

