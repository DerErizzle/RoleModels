package bitmasq
{
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.system.Capabilities;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class Gamepad
   {
      
      public static const LSTICK:Number = 1;
      
      public static const LSTICK_X:Number = 2;
      
      public static const LSTICK_Y:Number = 3;
      
      public static const RSTICK:Number = 4;
      
      public static const RSTICK_X:Number = 5;
      
      public static const RSTICK_Y:Number = 6;
      
      public static const D_UP:Number = 7;
      
      public static const D_DOWN:Number = 8;
      
      public static const D_LEFT:Number = 9;
      
      public static const D_RIGHT:Number = 10;
      
      public static const A_UP:Number = 11;
      
      public static const A_DOWN:Number = 12;
      
      public static const A_LEFT:Number = 13;
      
      public static const A_RIGHT:Number = 14;
      
      public static const LB:Number = 15;
      
      public static const RB:Number = 16;
      
      public static const LT:Number = 17;
      
      public static const LT_X:Number = 18;
      
      public static const RT:Number = 19;
      
      public static const RT_X:Number = 20;
      
      public static const MENU:Number = 21;
      
      public static const BACK:Number = 22;
      
      public static const SELECT:Number = 23;
      
      public static const START:Number = 24;
      
      public static const SPACE:Number = 25;
      
      public static const C:Number = 103;
      
      public static const D:Number = 104;
      
      public static const E:Number = 105;
      
      public static const F:Number = 106;
      
      public static const G:Number = 107;
      
      public static const H:Number = 108;
      
      public static const I:Number = 109;
      
      public static const J:Number = 110;
      
      public static const K:Number = 111;
      
      public static const L:Number = 112;
      
      public static const M:Number = 113;
      
      public static const N:Number = 114;
      
      public static const O:Number = 115;
      
      public static const P:Number = 116;
      
      public static const Q:Number = 117;
      
      public static const R:Number = 118;
      
      public static const S:Number = 119;
      
      public static const T:Number = 120;
      
      public static const U:Number = 121;
      
      public static const V:Number = 122;
      
      public static const W:Number = 123;
      
      public static const Z:Number = 126;
      
      public static const BUTTON_O:Number = A_DOWN;
      
      public static const BUTTON_U:Number = A_LEFT;
      
      public static const BUTTON_Y:Number = A_UP;
      
      public static const BUTTON_A:Number = A_RIGHT;
      
      private static const profiles:Object = {
         "ouya/ouya":{
            "name":"ouya/ouya",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_106":LSTICK,
            "AXIS_11":RSTICK_X,
            "AXIS_14":RSTICK_Y,
            "BUTTON_107":RSTICK,
            "BUTTON_19":D_UP,
            "BUTTON_20":D_DOWN,
            "BUTTON_21":D_LEFT,
            "BUTTON_22":D_RIGHT,
            "BUTTON_96":A_DOWN,
            "BUTTON_99":A_LEFT,
            "BUTTON_100":A_UP,
            "BUTTON_97":A_RIGHT,
            "BUTTON_102":LB,
            "BUTTON_103":RB,
            "AXIS_17":LT_X,
            "BUTTON_104":LT,
            "AXIS_18":RT_X,
            "BUTTON_105":RT,
            "MUL":{},
            "A2DP":{},
            "A2DN":{},
            "D2AP":{},
            "D2AN":{}
         },
         "ouya/ps3":{
            "name":"ouya/ps3",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_106":LSTICK,
            "AXIS_11":RSTICK_X,
            "AXIS_14":RSTICK_Y,
            "BUTTON_107":RSTICK,
            "BUTTON_19":D_UP,
            "BUTTON_20":D_DOWN,
            "BUTTON_21":D_LEFT,
            "BUTTON_22":D_RIGHT,
            "BUTTON_96":A_DOWN,
            "BUTTON_99":A_LEFT,
            "BUTTON_100":A_UP,
            "BUTTON_97":A_RIGHT,
            "BUTTON_102":LB,
            "BUTTON_103":RB,
            "AXIS_17":LT_X,
            "BUTTON_104":LT,
            "AXIS_18":RT_X,
            "BUTTON_105":RT,
            "BUTTON_108":MENU,
            "MUL":{},
            "A2DP":{},
            "A2DN":{},
            "D2AP":{},
            "D2AN":{}
         },
         "ouya/xbox360":{
            "name":"ouya/xbox360",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_106":LSTICK,
            "AXIS_11":RSTICK_X,
            "AXIS_14":RSTICK_Y,
            "BUTTON_107":RSTICK,
            "BUTTON_19":D_UP,
            "BUTTON_20":D_DOWN,
            "BUTTON_21":D_LEFT,
            "BUTTON_22":D_RIGHT,
            "BUTTON_96":A_DOWN,
            "BUTTON_99":A_LEFT,
            "BUTTON_100":A_UP,
            "BUTTON_97":A_RIGHT,
            "BUTTON_102":LB,
            "BUTTON_103":RB,
            "AXIS_17":LT_X,
            "AXIS_18":RT_X,
            "BUTTON_108":MENU,
            "MUL":{},
            "A2DP":{
               "AXIS_2":LT,
               "AXIS_5":RT
            },
            "A2DN":{},
            "D2AP":{},
            "D2AN":{}
         },
         "ouya/xbox":{
            "name":"ouya/xbox",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_106":LSTICK,
            "AXIS_11":RSTICK_X,
            "AXIS_14":RSTICK_Y,
            "BUTTON_107":RSTICK,
            "BUTTON_96":A_DOWN,
            "BUTTON_99":A_LEFT,
            "BUTTON_100":A_UP,
            "BUTTON_97":A_RIGHT,
            "BUTTON_102":LB,
            "BUTTON_103":RB,
            "AXIS_17":LT_X,
            "AXIS_18":RT_X,
            "BUTTON_108":MENU,
            "MUL":{},
            "A2DP":{
               "AXIS_17":LT,
               "AXIS_18":RT,
               "AXIS_15":D_RIGHT,
               "AXIS_16":D_DOWN,
               "AXIS_0":D_RIGHT,
               "AXIS_1":D_DOWN
            },
            "A2DN":{
               "AXIS_15":D_LEFT,
               "AXIS_16":D_UP,
               "AXIS_0":D_LEFT,
               "AXIS_1":D_UP
            },
            "D2AP":{},
            "D2AN":{}
         },
         "windows/ps4":{
            "name":"windows/ps4",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_20":LSTICK,
            "AXIS_2":RSTICK_X,
            "AXIS_5":RSTICK_Y,
            "BUTTON_21":RSTICK,
            "BUTTON_6":D_UP,
            "BUTTON_7":D_DOWN,
            "BUTTON_8":D_LEFT,
            "BUTTON_9":D_RIGHT,
            "BUTTON_11":A_DOWN,
            "BUTTON_10":A_LEFT,
            "BUTTON_13":A_UP,
            "BUTTON_12":A_RIGHT,
            "BUTTON_14":LB,
            "BUTTON_15":RB,
            "BUTTON_18":MENU,
            "BUTTON_19":MENU,
            "BUTTON_22":MENU,
            "AXIS_3":LT_X,
            "BUTTON_16":LT,
            "AXIS_4":RT_X,
            "BUTTON_17":RT,
            "MUL":{
               "AXIS_1":-1,
               "AXIS_5":-1
            },
            "A2DP":{
               "AXIS_0":D_RIGHT,
               "AXIS_1":D_DOWN
            },
            "A2DN":{
               "AXIS_0":D_LEFT,
               "AXIS_1":D_UP
            },
            "D2AP":{},
            "D2AN":{}
         },
         "windows/xbox360":{
            "name":"windows/xbox360",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_14":LSTICK,
            "AXIS_2":RSTICK_X,
            "AXIS_3":RSTICK_Y,
            "BUTTON_15":RSTICK,
            "BUTTON_16":D_UP,
            "BUTTON_17":D_DOWN,
            "BUTTON_18":D_LEFT,
            "BUTTON_19":D_RIGHT,
            "BUTTON_4":A_DOWN,
            "BUTTON_6":A_LEFT,
            "BUTTON_7":A_UP,
            "BUTTON_5":A_RIGHT,
            "BUTTON_8":LB,
            "BUTTON_9":RB,
            "BUTTON_12":MENU,
            "BUTTON_13":MENU,
            "BUTTON_10":LT_X,
            "BUTTON_11":RT_X,
            "MUL":{
               "AXIS_1":-1,
               "AXIS_3":-1
            },
            "A2DP":{
               "BUTTON_10":LT,
               "BUTTON_11":RT,
               "AXIS_0":D_RIGHT,
               "AXIS_1":D_DOWN
            },
            "A2DN":{
               "AXIS_0":D_LEFT,
               "AXIS_1":D_UP
            },
            "D2AP":{},
            "D2AN":{}
         },
         "mac/xbox360":{
            "name":"mac/xbox360",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_12":LSTICK,
            "AXIS_3":RSTICK_X,
            "AXIS_4":RSTICK_Y,
            "BUTTON_13":RSTICK,
            "BUTTON_6":D_UP,
            "BUTTON_7":D_DOWN,
            "BUTTON_8":D_LEFT,
            "BUTTON_9":D_RIGHT,
            "BUTTON_17":A_DOWN,
            "BUTTON_19":A_LEFT,
            "BUTTON_20":A_UP,
            "BUTTON_18":A_RIGHT,
            "BUTTON_14":LB,
            "BUTTON_15":RB,
            "AXIS_2":LT_X,
            "AXIS_5":RT_X,
            "BUTTON_11":MENU,
            "BUTTON_10":MENU,
            "BUTTON_16":MENU,
            "MUL":{},
            "A2DP":{
               "AXIS_2":LT,
               "AXIS_5":RT,
               "AXIS_0":D_RIGHT,
               "AXIS_1":D_DOWN
            },
            "A2DN":{
               "AXIS_0":D_LEFT,
               "AXIS_1":D_UP
            },
            "D2AP":{},
            "D2AN":{}
         },
         "mac/ps3":{
            "name":"mac/ps3",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_5":LSTICK,
            "AXIS_2":RSTICK_X,
            "AXIS_3":RSTICK_Y,
            "BUTTON_6":RSTICK,
            "BUTTON_8":D_UP,
            "BUTTON_10":D_DOWN,
            "BUTTON_11":D_LEFT,
            "BUTTON_9":D_RIGHT,
            "BUTTON_18":A_DOWN,
            "BUTTON_19":A_LEFT,
            "BUTTON_16":A_UP,
            "BUTTON_17":A_RIGHT,
            "BUTTON_14":LB,
            "BUTTON_15":RB,
            "BUTTON_12":LT,
            "BUTTON_13":RT,
            "BUTTON_4":MENU,
            "BUTTON_7":MENU,
            "BUTTON_20":MENU,
            "MUL":{},
            "A2DP":{
               "AXIS_0":D_RIGHT,
               "AXIS_1":D_DOWN
            },
            "A2DN":{
               "AXIS_0":D_LEFT,
               "AXIS_1":D_UP
            },
            "D2AP":{
               "BUTTON_12":LT_X,
               "BUTTON_13":RT_X
            },
            "D2AN":{}
         },
         "windowsxp/xbox360":{
            "name":"windowsxp/xbox360",
            "AXIS_0":LSTICK_X,
            "AXIS_1":LSTICK_Y,
            "BUTTON_17":LSTICK,
            "AXIS_3":RSTICK_X,
            "AXIS_4":RSTICK_Y,
            "BUTTON_18":RSTICK,
            "BUTTON_5":D_UP,
            "BUTTON_6":D_DOWN,
            "BUTTON_7":D_LEFT,
            "BUTTON_8":D_RIGHT,
            "BUTTON_9":A_DOWN,
            "BUTTON_11":A_LEFT,
            "BUTTON_12":A_UP,
            "BUTTON_10":A_RIGHT,
            "BUTTON_13":LB,
            "BUTTON_14":RB,
            "BUTTON_15":MENU,
            "BUTTON_16":MENU,
            "MUL":{},
            "A2DP":{
               "AXIS_0":D_RIGHT,
               "AXIS_1":D_DOWN,
               "AXIS_2":LT
            },
            "A2DN":{
               "AXIS_0":D_LEFT,
               "AXIS_1":D_UP,
               "AXIS_2":RT
            },
            "D2AP":{},
            "D2AN":{}
         }
      };
      
      public static var traceFunction:Function = null;
      
      public static var inspectFunction:Function = null;
      
      public static var deadZone:Number = 0.11;
      
      private static var profileCache:Dictionary = new Dictionary();
      
      private static var emulationCache:Dictionary = new Dictionary();
      
      private static var stateCache:Dictionary = new Dictionary();
      
      private static var devices:Array = [];
      
      private static var dispatchers:Array = [];
      
      private static var gamepad:Gamepad;
      
      private static var stage:Stage;
       
      
      public function Gamepad()
      {
         super();
         if(Boolean(gamepad))
         {
            throw new Error("Gamepad has already been initialized. It may be fetched with Gamepad.get()");
         }
         if(!stage)
         {
            throw new Error("Gamepad must be initialized with Gamepad.init()");
         }
         if(traceFunction != null)
         {
            traceFunction("Gamepad() GameInput initialized");
         }
         dispatchers.push(new PausableEventDispatcher());
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
      }
      
      public static function init(_stage:Stage) : Gamepad
      {
         stage = _stage;
         if(Boolean(gamepad))
         {
            throw new Error("Gamepad has already been initialized.");
         }
         gamepad = new Gamepad();
         if(traceFunction != null)
         {
            traceFunction("Gamepad initialized");
         }
         return gamepad;
      }
      
      public static function get() : Gamepad
      {
         if(!gamepad)
         {
            throw new Error("Gamepad must first be initialized with Gamepad.init()");
         }
         return gamepad;
      }
      
      public function pause() : void
      {
         stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,true);
      }
      
      public function resume() : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler,true);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,true);
      }
      
      public function get numDevices() : uint
      {
         return devices.length;
      }
      
      public function addEventListener(ev:String, fn:Function) : void
      {
         dispatchers[dispatchers.length - 1].addEventListener(ev,fn);
      }
      
      public function removeEventListener(ev:String, fn:Function) : void
      {
         dispatchers[dispatchers.length - 1].removeEventListener(ev,fn);
      }
      
      public function dispatchEvent(type:String, controlCode:Number, value:Number, device:Object, deviceCode:Number) : void
      {
         if(traceFunction != null)
         {
            traceFunction("dispatchEvent");
         }
         if(type == GamepadEvent.CHANGE)
         {
            if(!stateCache[deviceCode])
            {
               stateCache[deviceCode] = new Dictionary();
            }
            stateCache[deviceCode][controlCode] = value;
         }
         if(traceFunction != null)
         {
            traceFunction("dispatching..");
         }
         dispatchers[dispatchers.length - 1].dispatchEventImmediate(new GamepadEvent(type,controlCode,value,device,deviceCode));
      }
      
      public function addKeyController(map:Dictionary) : void
      {
         devices.push(map);
         this.dispatchEvent(GamepadEvent.DEVICE_ADDED,0,0,null,1);
      }
      
      public function pushContext() : void
      {
         dispatchers.push(new PausableEventDispatcher());
      }
      
      public function popContext() : void
      {
         dispatchers.pop();
      }
      
      public function query(deviceCode:Number, controlCode:Number) : Number
      {
         if(!stateCache[deviceCode])
         {
            return 0;
         }
         if(Boolean(stateCache[deviceCode][controlCode]))
         {
            return stateCache[deviceCode][controlCode];
         }
         return 0;
      }
      
      private function keyDownHandler(event:KeyboardEvent) : void
      {
         if(event.keyCode == Keyboard.MENU)
         {
            this.dispatchEvent(GamepadEvent.CHANGE,MENU,1,devices[0],0);
            return;
         }
         for(var index:Number = 0; index < devices.length; index++)
         {
            if(devices[index] is Dictionary)
            {
               if(Boolean(devices[index][event.keyCode]))
               {
                  this.dispatchEvent(GamepadEvent.CHANGE,devices[index][event.keyCode],1,devices[index],index);
               }
            }
         }
      }
      
      private function keyUpHandler(event:KeyboardEvent) : void
      {
         if(event.keyCode == Keyboard.MENU)
         {
            this.dispatchEvent(GamepadEvent.CHANGE,MENU,0,devices[0],0);
            return;
         }
         for(var index:Number = 0; index < devices.length; index++)
         {
            if(devices[index] is Dictionary)
            {
               if(Boolean(devices[index][event.keyCode]))
               {
                  this.dispatchEvent(GamepadEvent.CHANGE,devices[index][event.keyCode],0,devices[index],index);
               }
            }
         }
      }
      
      private function _detectProfile(deviceName:String) : Object
      {
         var profile:Object = null;
         var _platform:String = Capabilities.version.substring(0,3);
         if(deviceName.indexOf("OUYA") >= 0)
         {
            profile = profiles["ouya/ouya"];
         }
         else if(deviceName.indexOf("Generic X-Box pad") >= 0)
         {
            if(_platform == "AND")
            {
               profile = profiles["ouya/xbox"];
            }
         }
         else if(deviceName.indexOf("360") >= 0)
         {
            if(_platform == "AND")
            {
               profile = profiles["ouya/xbox360"];
            }
            if(_platform == "MAC")
            {
               profile = profiles["mac/xbox360"];
            }
            if(_platform == "WIN")
            {
               profile = profiles["windows/xbox360"];
               if(Capabilities.os == "Windows XP" || Capabilities.os == "Windows XP 64")
               {
                  profile = profiles["windowsxp/xbox360"];
               }
            }
         }
         else if(deviceName.indexOf(")3") >= 0)
         {
            if(_platform == "AND")
            {
               profile = profiles["ouya/ps3"];
            }
            if(_platform == "MAC")
            {
               profile = profiles["mac/ps3"];
            }
         }
         else if(deviceName == "Wireless Controller")
         {
            if(_platform == "WIN")
            {
               profile = profiles["windows/ps4"];
            }
         }
         return profile;
      }
   }
}
