package jackboxgames.rolemodels.actionpackages
{
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.actionpackages.delegates.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.rolemodels.widgets.gameplay.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.utils.*;
   
   public class Gameplay extends JBGActionPackage
   {
      
      private static const LOW_FIDELITY_SOURCE:String = "lo/rm_gameplay_lo.swf";
       
      
      private var _timer:SubmissionTimer;
      
      private var _winnerScreen:WinnerScreenWidget;
      
      private var _blinkTransitionWidget:BlinkTransitionWidget;
      
      private var _delegateAudienceVote:AudienceVote;
      
      public function Gameplay(sourceURL:String)
      {
         if(Platform.instance.PlatformFidelity == Platform.PLATFORM_FIDELITY_LOW)
         {
            sourceURL = LOW_FIDELITY_SOURCE;
         }
         super(sourceURL);
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         var c:Counter = null;
         c = new Counter(2,TSUtil.createRefEndFn(ref));
         _setLoaded(true,function():void
         {
            _onLoaded();
            c.tick();
         });
         JBGUtil.eventOnce(ContentManager.instance,ContentManager.EVENT_LOAD_RESULT,function(evt:EventWithData):void
         {
            if(evt.data)
            {
               c.tick();
            }
         });
         ContentManager.instance.load();
         TagCorpusManager.initialize();
      }
      
      private function _onLoaded() : void
      {
         GameState.instance.screenOrganizer.addChild(_mc,10);
         _ts.g.gameplay = this;
         this._winnerScreen = new WinnerScreenWidget(_mc.winnerScreen);
         this._blinkTransitionWidget = new BlinkTransitionWidget(_mc.transition);
         this._timer = new SubmissionTimer(_mc.timer);
         this._delegateAudienceVote = new AudienceVote();
         addDelegate(this._delegateAudienceVote);
      }
      
      public function handleActionDisposePlayerPictures(ref:IActionRef, params:Object) : void
      {
         GameState.instance.disposePlayerPictures();
         ref.end();
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         GameState.instance.reset();
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         resetDelegates();
         JBGUtil.reset([this._timer,this._winnerScreen,this._blinkTransitionWidget]);
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         BlobCast.instance.uaEvent(BuildConfig.instance.configVal("gameName"),"start",null,GameState.instance.players.length);
         ref.end();
      }
      
      public function handleActionSetupNewGame(ref:IActionRef, params:Object) : void
      {
         GameState.instance.startGame();
         GameState.instance.setRoomBlob({"state":"Logo"});
         GameState.instance.players.forEach(function(p:Player, i:int, arr:Array):void
         {
            GameState.instance.setCustomerBlobWithMetadata(p,{"state":"Logo"});
            p.setup();
         });
         ref.end();
      }
      
      public function handleActionDoGameplayBlinkTransition(ref:IActionRef, params:Object) : void
      {
         this._blinkTransitionWidget.doTransition(Nullable.NULL_FUNCTION,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionAdvanceRound(ref:IActionRef, params:Object) : void
      {
         GameState.instance.advanceRoundNumber();
         ref.end();
      }
      
      public function handleActionGenerateNextReveal(ref:IActionRef, params:Object) : void
      {
         GameState.instance.generateNextReveal();
         if(GameState.instance.isRevealAvailable)
         {
            GameState.instance.artifactState.addReveal(GameState.instance.roundIndex,GameState.instance.currentReveal);
         }
         ref.end();
      }
      
      public function handleActionGenerateNextAnalysis(ref:IActionRef, params:Object) : void
      {
         GameState.instance.generateNextAnalysis();
         if(GameState.instance.isRevealAvailable)
         {
            GameState.instance.artifactState.addReveal(GameState.instance.roundIndex,GameState.instance.currentReveal);
         }
         ref.end();
      }
      
      public function handleActionCacheCurrentReveal(ref:IActionRef, params:Object) : void
      {
         GameState.instance.cacheCurrentReveal();
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         resetDelegates();
         BlobCast.instance.uaEvent(BuildConfig.instance.configVal("gameName"),"end",null,GameState.instance.players.length);
         ref.end();
      }
      
      public function handleActionSendArtifact(ref:IActionRef, params:Object) : void
      {
         GameState.instance.sendGameArtifacts(function(result:Boolean):void
         {
            ref.end();
         });
      }
      
      public function handleActionSetupTimer(ref:IActionRef, params:Object) : void
      {
         this._timer.setup(Duration.fromSec(SettingsManager.instance.getValue(SettingsConstants.SETTING_EXTENDED_TIMERS).val ? Number(params.extendedTime) : Number(params.time)));
         ref.end();
      }
      
      public function handleActionSetTimerActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            this._timer.start(function():void
            {
               TSInputHandler.instance.input("TimeUp");
            });
         }
         else
         {
            this._timer.stop();
            ref.end();
         }
      }
      
      public function handleActionSetTimerShown(ref:IActionRef, params:Object) : void
      {
         GameState.instance.audioRegistrationStack.play(Boolean(params.isShown) ? "TimerOn" : "TimerOff",Nullable.NULL_FUNCTION);
         this._timer.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionStartRound(ref:IActionRef, params:Object) : void
      {
         GameState.instance.addRoundData(new RoundData());
         ref.end();
      }
      
      public function handleActionSetupWinnerScreen(ref:IActionRef, params:Object) : void
      {
         GameState.instance.updatePlayerPlaces();
         this._winnerScreen.setup();
         ref.end();
      }
      
      public function handleActionGeneratePlayerFinalRoles(ref:IActionRef, params:Object) : void
      {
         GameState.instance.generatePlayerFinalRoles();
         ref.end();
      }
      
      public function handleActionAddFinalPlayerInfoToArtifact(ref:IActionRef, params:Object) : void
      {
         GameState.instance.artifactState.addFinalPlayerInfo();
         ref.end();
      }
      
      public function handleActionShowWinnerScreenBackground(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.showBackground(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHideWinnerAndFinalRoleTexts(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.hideWinnerAndFinalRole(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowHandsWinnerScreen(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.showHands(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRevealFinalRole(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.revealFinalRole(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRevealWinner(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.revealWinner(Nullable.NULL_FUNCTION);
         ref.end();
      }
      
      public function handleActionHideHands(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.hideHands();
         ref.end();
      }
      
      public function handleActionSetNonWinnersShown(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.setNonWinnersShown(params.isShown,Duration.fromSec(params.timeBetweenAppears),Duration.fromSec(params.timeAfterAppearUntilShrink),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoLeadupAnimation(ref:IActionRef, params:Object) : void
      {
         this._winnerScreen.doLeadupAnimation(TSUtil.createRefEndFn(ref));
      }
   }
}
