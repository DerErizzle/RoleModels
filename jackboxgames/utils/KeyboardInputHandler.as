package jackboxgames.utils
{
   import flash.display.*;
   import flash.events.*;
   import flash.ui.*;
   import flash.utils.*;
   import jackboxgames.userinput.*;
   
   public class KeyboardInputHandler
   {
      private static var _instance:KeyboardInputHandler;
      
      private var _stage:Stage;
      
      private var _keysDown:Dictionary;
      
      private var _isCatchingUp:Boolean;
      
      private var _catchUpFramesLeft:int;
      
      public function KeyboardInputHandler(stage:Stage)
      {
         super();
         this._stage = stage;
         if(BuildConfig.instance.configVal("flashKeyboard"))
         {
            this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this._onKeyDown,false,int.MAX_VALUE - 2);
            this._stage.addEventListener(KeyboardEvent.KEY_UP,this._onKeyUp,false,int.MAX_VALUE - 2);
         }
         this._keysDown = new Dictionary();
      }
      
      public static function initialize(stage:Stage) : void
      {
         if(Boolean(_instance))
         {
            return;
         }
         _instance = new KeyboardInputHandler(stage);
      }
      
      public static function get instance() : KeyboardInputHandler
      {
         return _instance;
      }
      
      public function catchUp() : void
      {
         if(this._isCatchingUp)
         {
            return;
         }
         this._keysDown = new Dictionary();
         this._isCatchingUp = true;
         this._catchUpFramesLeft = 15;
         this._stage.addEventListener(Event.ENTER_FRAME,this._onEnterFrame);
      }
      
      private function _onEnterFrame(... args) : void
      {
         --this._catchUpFramesLeft;
         if(this._catchUpFramesLeft == 0)
         {
            this._stage.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
            this._isCatchingUp = false;
         }
      }
      
      private function _onKeyDown(evt:KeyboardEvent) : void
      {
         var inputs:Array = null;
         var code:uint = evt.keyCode;
         if(!this._keysDown[code])
         {
            this._keysDown[code] = true;
            inputs = this._keyboardCodeToUserInputDirectorInputs(code);
            if(!this._isCatchingUp && inputs.length > 0)
            {
               evt.preventDefault();
               UserInputDirector.instance.forceInputs(inputs);
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
            inputs = this._keyboardCodeToUserInputDirectorInputs(code);
            if(inputs.length > 0)
            {
               evt.preventDefault();
            }
         }
      }
      
      private function _keyboardCodeToUserInputDirectorInputs(keyCode:uint) : Array
      {
         switch(keyCode)
         {
            case Keyboard.ENTER:
            case Keyboard.NUMPAD_ENTER:
               return [UserInputDirector.INPUT_SELECT];
            case Keyboard.ESCAPE:
               return [UserInputDirector.INPUT_BACK,UserInputDirector.INPUT_PAUSE];
            case Keyboard.LEFT:
               return [UserInputDirector.INPUT_LEFT];
            case Keyboard.RIGHT:
               return [UserInputDirector.INPUT_RIGHT];
            case Keyboard.UP:
               return [UserInputDirector.INPUT_UP];
            case Keyboard.DOWN:
               return [UserInputDirector.INPUT_DOWN];
            case Keyboard.SPACE:
               return [UserInputDirector.INPUT_ALT1];
            case Keyboard.TAB:
               return [UserInputDirector.INPUT_ALT2];
            default:
               return [];
         }
      }
   }
}

