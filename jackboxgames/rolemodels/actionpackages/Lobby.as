package jackboxgames.rolemodels.actionpackages
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.actionpackages.delegates.*;
   import jackboxgames.rolemodels.widgets.lobby.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public class Lobby extends JBGActionPackage
   {
      
      private static const LOW_FIDELITY_SOURCE:String = "lo/rm_lobby_lo.swf";
       
      
      private var _connecting:Connecting;
      
      private var _lobby:RoleModelsLobby;
      
      private var _handWidget:LobbyHandWidget;
      
      private var _eyesWidget:LobbyEyesWidget;
      
      private var _gridMC:MovieClip;
      
      private var _bg:MovieClip;
      
      private var _preloader:PreloaderDelegate;
      
      public function Lobby(sourceURL:String)
      {
         if(Platform.instance.PlatformFidelity == Platform.PLATFORM_FIDELITY_LOW)
         {
            sourceURL = LOW_FIDELITY_SOURCE;
         }
         super(sourceURL);
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         GameState.instance.screenOrganizer.addChild(_mc,0);
         this._connecting = new Connecting(_mc,GameState.instance.goBackToMenu);
         this._lobby = new RoleModelsLobby(_mc,GameState.instance,GameState.instance.minPlayers);
         this._handWidget = new LobbyHandWidget(_mc.hand.hand);
         this._eyesWidget = new LobbyEyesWidget(_mc.hand.eyes);
         this._gridMC = _mc.grid;
         this._bg = _mc.bg;
         this._preloader = new PreloaderDelegate(_mc.preloader);
         addDelegate(this._preloader);
         addDelegate(this._connecting);
         addDelegate(this._lobby);
      }
      
      private function parkEverything() : void
      {
         resetDelegates();
         JBGUtil.arrayGotoFrameWithFn([this._gridMC,this._gridMC.grid],"Park",null,null);
      }
      
      private function _transitionBackground(evt:MovieClipEvent) : void
      {
         if(evt.data == "TransitionToLobby")
         {
            JBGUtil.gotoFrame(this._bg,"Lobby");
         }
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         this.parkEverything();
         this._handWidget.reset();
         this._eyesWidget.reset();
         _mc.connecting.addEventListener(MovieClipEvent.EVENT_TRIGGER,this._transitionBackground);
         JBGUtil.gotoFrame(this._bg,"Menu");
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         _mc.connecting.addEventListener(MovieClipEvent.EVENT_TRIGGER,this._transitionBackground);
         this._lobby.start();
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         this.parkEverything();
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         ref.end();
      }
      
      public function handleActionShowGrid(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrame(this._gridMC.grid,"Appear");
         JBGUtil.gotoFrameWithFn(this._gridMC,"Appear",MovieClipEvent.EVENT_APPEAR_DONE,TSUtil.createRefEndFn(ref));
         ref.end();
      }
      
      public function handleActionShowHandAndEyes(ref:IActionRef, params:Object) : void
      {
         this._handWidget.showHand();
         this._eyesWidget.showEyes();
         ref.end();
      }
      
      public function handleActionStartLobbyAnimations(ref:IActionRef, params:Object) : void
      {
         var timeBetween:Number = NaN;
         this._handWidget.goIdle();
         if(params.minTimeBetweenAnimations > params.minTimeBetweenAnimations)
         {
            timeBetween = Math.min(params.minTimeBetweenAnimations,params.maxTimeBetweenAnimations);
            this._handWidget.loopAnimations(Duration.fromSec(timeBetween),Duration.fromSec(timeBetween));
            this._eyesWidget.loopAnimations(Duration.fromSec(timeBetween),Duration.fromSec(timeBetween));
         }
         else
         {
            this._handWidget.loopAnimations(Duration.fromSec(params.minTimeBetweenAnimations),Duration.fromSec(params.maxTimeBetweenAnimations));
            this._eyesWidget.loopAnimations(Duration.fromSec(params.minTimeBetweenAnimations),Duration.fromSec(params.maxTimeBetweenAnimations));
         }
         JBGUtil.gotoFrame(this._gridMC.grid,"Loop");
         ref.end();
      }
      
      public function handleActionStopLobbyAnimations(ref:IActionRef, params:Object) : void
      {
         this._handWidget.goIdle();
         this._eyesWidget.goIdle();
         JBGUtil.gotoFrame(this._gridMC.grid,"Park");
         ref.end();
      }
      
      public function handleActionWaitForSpinnerToEnd(ref:IActionRef, params:Object) : void
      {
         var _stopSpinner:Function = null;
         _stopSpinner = function(evt:MovieClipEvent):void
         {
            if(evt.data == "LoopEnd")
            {
               _mc.connecting.spinner.stop();
               _mc.connecting.spinner.removeEventListener(MovieClipEvent.EVENT_TRIGGER,_stopSpinner);
               ref.end();
            }
         };
         _mc.connecting.spinner.addEventListener(MovieClipEvent.EVENT_TRIGGER,_stopSpinner);
      }
      
      public function handleActionSetVisible(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,Boolean(params.isVisible) ? DisplayObjectOrganizer.STATE_ON : DisplayObjectOrganizer.STATE_OFF);
         ref.end();
      }
   }
}
