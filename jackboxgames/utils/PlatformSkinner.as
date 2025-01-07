package jackboxgames.utils
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.events.*;
   import jackboxgames.logger.*;
   import jackboxgames.mobile.*;
   import jackboxgames.nativeoverride.*;
   
   public class PlatformSkinner extends PausableEventDispatcher
   {
      public static var EVENT_STATE_CHANGED:String = "PlatformSkinner.StateChanged";
      
      private var _mc:MovieClip;
      
      private var _platform:String;
      
      private var _inputType:String;
      
      public function PlatformSkinner(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._platform = Platform.instance.PlatformIdUpperCase;
         this._inputType = Platform.instance.lastInputType;
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
         ExternalDisplayManager.instance.addEventListener(ExternalDisplayManager.EVENT_SCREEN_STATE_CHANGED,this._onScreenStateChanged);
         this._determineState();
      }
      
      public function dispose() : void
      {
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
      }
      
      private function _onNativeMessage(evt:EventWithData) : void
      {
         if(evt.data.message == "InputTypeChanged" && evt.data.parameter is String)
         {
            this._onInputTypeChanged(evt.data.parameter);
         }
      }
      
      private function _onInputTypeChanged(newInputType:String) : void
      {
         this._inputType = newInputType.toUpperCase();
         this._determineState();
      }
      
      private function _onJoystickConnected() : void
      {
         this._determineState();
      }
      
      private function _onScreenStateChanged(evt:Event) : void
      {
         this._determineState();
      }
      
      private function _tryToGoToFrame(frame:String) : Boolean
      {
         if(this._mc.currentFrameLabel == frame)
         {
            return true;
         }
         var hasFrame:Boolean = MovieClipUtil.gotoFrameIfExists(this._mc,frame);
         if(hasFrame)
         {
            dispatchEvent(new EventWithData(EVENT_STATE_CHANGED,{}));
         }
         return hasFrame;
      }
      
      private function _determineState() : void
      {
         if(!this._mc)
         {
            return;
         }
         if(Boolean(this._inputType) && this._tryToGoToFrame(this._inputType))
         {
            return;
         }
         if(this._tryToGoToFrame(this._platform))
         {
            return;
         }
         if(Gamepad.instance.getNumberOfJoysticks() > 0 && this._tryToGoToFrame("GAMEPAD"))
         {
            return;
         }
         if(BuildConfig.instance.configVal("supportsKeyboard") == true && this._tryToGoToFrame("KEYBOARD"))
         {
            return;
         }
         if(this._tryToGoToFrame(this._platform + "_" + (ExternalDisplayManager.instance.isOnExternalDisplay ? "ED" : "ID")))
         {
            return;
         }
         if(Platform.instance.isConsole && this._tryToGoToFrame("CONSOLE"))
         {
            return;
         }
         if(Platform.instance.isSetTopBox && this._tryToGoToFrame("SET_TOP_BOX"))
         {
            return;
         }
         if(this._platform == "AFTM" && this._tryToGoToFrame("AFT"))
         {
            return;
         }
         if(Platform.instance.isHandheld && this._tryToGoToFrame("HANDHELD"))
         {
            return;
         }
         if(BuildConfig.instance.configVal("isBundle") && this._tryToGoToFrame("BUNDLE"))
         {
            return;
         }
         if(EnvUtil.isDebug() && this._tryToGoToFrame("DEBUG"))
         {
            return;
         }
         if(!EnvUtil.isDebug() && this._tryToGoToFrame("RELEASE"))
         {
            return;
         }
         if(this._tryToGoToFrame("DEFAULT"))
         {
            return;
         }
         this._tryToGoToFrame("PARK");
      }
   }
}

