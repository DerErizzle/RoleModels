package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.engine.*;
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.text.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class Connecting
   {
      private var _mc:MovieClip;
      
      private var _automaticallyGoBackCanceller:Function;
      
      private var _troubleCanceller:Function;
      
      private var _exitFunction:Function;
      
      private var _connectingTf:ExtendableTextField;
      
      private var _troubleTf:ExtendableTextField;
      
      private var _cancelTf:ExtendableTextField;
      
      public function Connecting(mc:MovieClip, exitFunction:Function)
      {
         super();
         this._mc = mc;
         this._exitFunction = exitFunction;
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc.connectInfoActions,this._mc.connectInfoActions.troubleContainer,this._mc.connectInfoActions.cancelActions,this._mc.connectInfoActions.spinner],"Park");
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handleInput);
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
         JBGUtil.gotoFrameWithFn(this._mc.connectInfoActions,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,TSUtil.createRefEndFn(ref));
         JBGUtil.gotoFrame(this._mc.connectInfoActions.spinner,"Appear");
         this._troubleCanceller = JBGUtil.runFunctionAfter(function():void
         {
            _automaticallyGoBackCanceller = JBGUtil.runFunctionAfter(function():void
            {
               UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,_handleInput);
               GameEngine.instance.error.handleError("INTERNET_DISCONNECTED");
               _exitFunction();
            },Duration.fromMs(BuildConfig.instance.configVal("connectingDurationAbort")));
            UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,_handleInput);
            JBGUtil.arrayGotoFrame([_mc.connectInfoActions.troubleContainer,_mc.connectInfoActions.cancelActions],"Appear");
         },Duration.fromMs(BuildConfig.instance.configVal("connectingDurationTrouble")));
      }
      
      public function handleActionDismissConnecting(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(this._mc.connectInfoActions,"Disappear",MovieClipEvent.EVENT_DISAPPEAR_DONE,function():void
         {
            JBGUtil.gotoFrame(_mc.connectInfoActions.spinner,"Park");
            ref.end();
         });
         UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handleInput);
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
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_BACK))
         {
            if(this._automaticallyGoBackCanceller != null)
            {
               this._automaticallyGoBackCanceller();
               this._automaticallyGoBackCanceller = null;
            }
            UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._handleInput);
            this._exitFunction();
         }
      }
   }
}

