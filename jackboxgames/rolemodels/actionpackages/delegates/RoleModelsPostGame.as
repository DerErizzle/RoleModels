package jackboxgames.rolemodels.actionpackages.delegates
{
   import flash.display.*;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.userinteraction.*;
   import jackboxgames.rolemodels.widgets.lobby.*;
   import jackboxgames.rolemodels.widgets.postgame.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public class RoleModelsPostGame extends PostGame implements IFeedInteractionAdapter
   {
       
      
      private var _handWidget:LobbyHandWidget;
      
      private var _eyesWidget:LobbyEyesWidget;
      
      private var _postGameMouthWidget:EatingMouthWidget;
      
      private var _feedBehavior:FeedInteraction;
      
      private var _feedInteraction:InteractionHandler;
      
      public function RoleModelsPostGame(mc:MovieClip, gameState:BlobCastGameState)
      {
         super(mc,gameState);
         setAudioHandler(new AudioEventPostGameAudioHandler());
         onCountdownStartedFn = this._startMouthAnimation;
         onCountdownStoppedFn = this._stopMouthAnimation;
         this._handWidget = new LobbyHandWidget(mc.hand);
         this._eyesWidget = new LobbyEyesWidget(mc.tank.eyes);
         this._postGameMouthWidget = new EatingMouthWidget(mc.tank.lips);
         this._feedBehavior = new FeedInteraction(this);
         this._feedInteraction = new InteractionHandler(this._feedBehavior,GameState.instance,false,false);
      }
      
      override public function reset() : void
      {
         super.reset();
         JBGUtil.reset([this._handWidget,this._eyesWidget,this._postGameMouthWidget]);
         this._feedInteraction.reset();
      }
      
      public function handleActionSetupFeeding(ref:IActionRef, params:Object) : void
      {
         this._postGameMouthWidget.setup();
         ref.end();
      }
      
      public function handleActionShowMouth(ref:IActionRef, params:Object) : void
      {
         this._postGameMouthWidget.shower.setShown(true,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetFeedingActive(ref:IActionRef, params:Object) : void
      {
         this._feedInteraction.setIsActive(GameState.instance.players,params.isActive);
         ref.end();
      }
      
      public function handleActionSetAssistantAnimationsActive(ref:IActionRef, params:Object) : void
      {
         var timeBetween:Number = NaN;
         this._handWidget.goIdle();
         this._eyesWidget.goIdle();
         if(Boolean(params.isActive))
         {
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
         }
         ref.end();
      }
      
      private function _startMouthAnimation() : void
      {
         this._postGameMouthWidget.countdown(Nullable.NULL_FUNCTION);
      }
      
      private function _stopMouthAnimation() : void
      {
         this._postGameMouthWidget.stopCountdown(Nullable.NULL_FUNCTION);
      }
      
      public function onFeed() : void
      {
         this._postGameMouthWidget.chew(this._feedBehavior.totalBiscuits,this._feedBehavior.allBiscuitsFed,Nullable.NULL_FUNCTION);
      }
   }
}
