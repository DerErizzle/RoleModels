package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.events.EventWithData;
   import jackboxgames.events.MovieClipEvent;
   import jackboxgames.localizy.LocalizedTextFieldManager;
   import jackboxgames.nativeoverride.Gamepad;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.text.ExtendableTextField;
   import jackboxgames.text.TextFieldUtils;
   import jackboxgames.utils.*;
   
   public class Connecting
   {
       
      
      private var _mc:MovieClip;
      
      private var _automaticallyGoBackCanceller:Function;
      
      private var _troubleCanceller:Function;
      
      private var _cancelButtonSkinner:PlatformSkinner;
      
      private var _cancelButton:PlatformButton;
      
      private var _exitFunction:Function;
      
      private var _connectingTf:ExtendableTextField;
      
      private var _troubleTf:ExtendableTextField;
      
      private var _cancelTf:ExtendableTextField;
      
      public function Connecting(mc:MovieClip, exitFunction:Function)
      {
         super();
         this._mc = mc;
         this._exitFunction = exitFunction;
         this._cancelButtonSkinner = new PlatformSkinner(this._mc.connecting.cancel.container);
         this._cancelButton = new PlatformButton(this._mc.connecting.cancel.container,this._mc.connecting.cancel.container.button,["BACK","B"]);
         this._connectingTf = TextFieldUtils.buildExtendableTextField(this._mc.connecting.connectingText,1,true);
         this._troubleTf = TextFieldUtils.buildExtendableTextField(this._mc.connecting.trouble.container,1,true);
         this._cancelTf = TextFieldUtils.buildExtendableTextField(this._mc.connecting.cancel.container,1,true);
         LocalizedTextFieldManager.instance.add([this._mc.connecting.trouble.container.tf,this._mc.connecting.cancel.container.tf,this._mc.connecting.connectingText.tf]);
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc.connecting,this._mc.connecting.trouble,this._mc.connecting.cancel,this._mc.connecting.spinner],"Park");
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handleInput);
         if(this._troubleCanceller != null)
         {
            this._troubleCanceller();
            this._troubleCanceller = null;
         }
         if(this._automaticallyGoBackCanceller != null)
         {
            this._automaticallyGoBackCanceller();
            this._automaticallyGoBackCanceller = null;
         }
      }
      
      public function handleActionShowConnecting(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc.connecting,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,TSUtil.createRefEndFn(ref));
         JBGUtil.gotoFrame(this._mc.connecting.spinner,"Appear");
         this._troubleCanceller = JBGUtil.runFunctionAfter(function():void
         {
            _automaticallyGoBackCanceller = JBGUtil.runFunctionAfter(function():void
            {
               Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,_handleInput);
               GameEngine.instance.error.handleError("INTERNET_DISCONNECTED");
               _exitFunction();
            },Duration.fromMs(BuildConfig.instance.configVal("connectingDurationAbort")));
            Gamepad.instance.addEventListener(Gamepad.EVENT_RECEIVED_INPUT,_handleInput);
            JBGUtil.arrayGotoFrame([_mc.connecting.trouble,_mc.connecting.cancel],"Appear");
         },Duration.fromMs(BuildConfig.instance.configVal("connectingDurationTrouble")));
      }
      
      public function handleActionDismissConnecting(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc.connecting,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
         {
            JBGUtil.gotoFrame(_mc.connecting.spinner,"Park");
            ref.end();
         });
         Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handleInput);
         if(this._troubleCanceller != null)
         {
            this._troubleCanceller();
            this._troubleCanceller = null;
         }
         if(this._automaticallyGoBackCanceller != null)
         {
            this._automaticallyGoBackCanceller();
            this._automaticallyGoBackCanceller = null;
         }
      }
      
      private function _handleInput(evt:EventWithData) : void
      {
         if(ArrayUtil.arrayContainsOneOf(evt.data.inputs,["B","BACK"]))
         {
            if(this._automaticallyGoBackCanceller != null)
            {
               this._automaticallyGoBackCanceller();
               this._automaticallyGoBackCanceller = null;
            }
            Gamepad.instance.removeEventListener(Gamepad.EVENT_RECEIVED_INPUT,this._handleInput);
            this._exitFunction();
         }
      }
   }
}
