package jackboxgames.userinput
{
   import flash.events.EventDispatcher;
   import flash.utils.*;
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class UserInputDirector extends EventDispatcher
   {
      private static var _instance:UserInputDirector;
      
      private static var _platformGamepadMap:Object;
      
      public static const EVENT_INPUT:String = "UserInput.ReceivedInput";
      
      public static const INPUT_SELECT:String = "SELECT";
      
      public static const INPUT_BACK:String = "BACK";
      
      public static const INPUT_PAUSE:String = "PAUSE";
      
      public static const INPUT_ALT1:String = "ALT1";
      
      public static const INPUT_ALT2:String = "ALT2";
      
      public static const INPUT_UP:String = "UP";
      
      public static const INPUT_DOWN:String = "DOWN";
      
      public static const INPUT_LEFT:String = "LEFT";
      
      public static const INPUT_RIGHT:String = "RIGHT";
      
      public static const DIRECTIONAL_INPUTS:Array = ["UP","DOWN","LEFT","RIGHT"];
      
      private static const GAMEPAD_MAP:Object = {
         "SELECT":["A"],
         "BACK":["B"],
         "PAUSE":["START"],
         "ALT1":["X"],
         "ALT2":["Y"],
         "UP":["DPAD_UP","LEFT_STICK_UP"],
         "DOWN":["DPAD_DOWN","LEFT_STICK_DOWN"],
         "LEFT":["DPAD_LEFT","LEFT_STICK_LEFT"],
         "RIGHT":["DPAD_RIGHT","LEFT_STICK_RIGHT"],
         "CANCEL":["B"],
         "QUIT":["A","ENTER"],
         "SKIP":["B","START"]
      };
      
      private static const ALL_INPUTS:Array = ["SELECT","BACK","PAUSE","ALT1","ALT2","UP","DOWN","LEFT","RIGHT","CANCEL","QUIT","SKIP"];
      
      public function UserInputDirector()
      {
         super();
         var platformInputConfig:Object = BuildConfig.instance.configVal("gamepad-inputs-mapping") ? JSON.deserialize(BuildConfig.instance.configVal("gamepad-inputs-mapping")) : {};
         _platformGamepadMap = ObjectUtil.concat(GAMEPAD_MAP,platformInputConfig);
         Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._onGamepadInput);
      }
      
      public static function get instance() : UserInputDirector
      {
         return Boolean(_instance) ? _instance : (_instance = new UserInputDirector());
      }
      
      public static function getGamepadArrayFromInput(inputKey:String) : Array
      {
         var _key:String = inputKey.toUpperCase();
         if(ArrayUtil.arrayContainsElement(UserInputDirector.ALL_INPUTS,_key))
         {
            return UserInputDirector._platformGamepadMap[_key];
         }
         return null;
      }
      
      private function _onGamepadInput(evt:EventWithData) : void
      {
         var inputId:String = null;
         var inputs:Array = new Array();
         for each(inputId in ALL_INPUTS)
         {
            if(ArrayUtil.intersection(_platformGamepadMap[inputId],evt.data.inputs).length > 0)
            {
               inputs.push(inputId);
               dispatchEvent(new EventWithData(inputId,inputId));
            }
         }
         dispatchEvent(new EventWithData(EVENT_INPUT,{"inputs":inputs}));
      }
      
      public function forceInputs(inputs:Array) : void
      {
         var inputId:String = null;
         for each(inputId in inputs)
         {
            dispatchEvent(new EventWithData(inputId,inputId));
         }
         dispatchEvent(new EventWithData(EVENT_INPUT,{"inputs":inputs}));
      }
   }
}

