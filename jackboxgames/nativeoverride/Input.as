package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.Assert;
   import jackboxgames.utils.EnvUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class Input extends PausableEventDispatcher
   {
      private static var _instance:Input;
      
      public static const EVENT_ALERT_DONE:String = "Input.AlertDone";
      
      public static const KEYBOARD_TYPE_DEFAULT:String = "default";
      
      public static const KEYBOARD_TYPE_EMAIL:String = "email";
      
      public static const KEYBOARD_TYPE_URL:String = "url";
      
      public var ctorNative:Function = null;
      
      private var _keyboardCompleteCallback:Function = null;
      
      private var _keyboardCancelledCallback:Function = null;
      
      public var getKeyboardInputNative:Function = null;
      
      public var popupAlertNative:Function = null;
      
      public var setBackButtonHandlerNative:Function = null;
      
      public var setConsoleModeNative:Function = null;
      
      public function Input()
      {
         super();
         if(!EnvUtil.isAIR())
         {
            ExternalInterface.call("InitializeNativeOverride","Input",this);
         }
         if(this.ctorNative != null)
         {
            this.ctorNative();
         }
      }
      
      public static function Initialize() : void
      {
      }
      
      public static function get instance() : Input
      {
         if(!_instance)
         {
            _instance = new Input();
         }
         return _instance;
      }
      
      public function getKeyboardInput(inputText:String, title:String, message:String, hidden:Boolean, keyboardType:String, complete:Function, cancelled:Function) : void
      {
         Assert.assert(this.getKeyboardInputNative != null);
         Assert.assert(complete != null && cancelled != null);
         Assert.assert(this._keyboardCompleteCallback == null && this._keyboardCancelledCallback == null);
         this._keyboardCompleteCallback = complete;
         this._keyboardCancelledCallback = cancelled;
         this.getKeyboardInputNative(inputText,title,message,hidden,keyboardType);
      }
      
      public function onKeyboardInputReceived(input:String) : void
      {
         var tempCallback:Function = this._keyboardCompleteCallback;
         this._keyboardCompleteCallback = null;
         this._keyboardCancelledCallback = null;
         tempCallback(input);
      }
      
      public function onKeyboardInputCancelled() : void
      {
         var tempCallback:Function = this._keyboardCancelledCallback;
         this._keyboardCompleteCallback = null;
         this._keyboardCancelledCallback = null;
         tempCallback();
      }
      
      public function popupAlert(title:String, message:String, buttons:Array) : void
      {
         this.popupAlertNative(title,message,buttons);
      }
      
      public function showError(error:String, message:String) : void
      {
         this.popupAlert("Uh oh!",message + (Boolean(error) ? "(" + error + ")" : ""),["OK"]);
      }
      
      public function onAlertDone(index:int) : void
      {
         dispatchEvent(new EventWithData(EVENT_ALERT_DONE,index));
      }
      
      public function setBackButtonHandler(handled:Boolean) : void
      {
         if(this.setBackButtonHandlerNative == null)
         {
            return;
         }
         this.setBackButtonHandlerNative(handled);
      }
      
      public function setConsoleMode(visible:Boolean) : void
      {
         if(this.setConsoleModeNative == null)
         {
            return;
         }
         this.setConsoleModeNative(visible);
      }
   }
}

