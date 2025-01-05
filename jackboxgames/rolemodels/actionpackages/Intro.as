package jackboxgames.rolemodels.actionpackages
{
   import flash.display.MovieClip;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.actionpackages.delegates.*;
   import jackboxgames.rolemodels.widgets.intro.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.talkshow.stub.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.userinteraction.commonbehaviors.*;
   import jackboxgames.utils.*;
   
   public class Intro extends JBGActionPackage
   {
       
      
      private var _players:IntroLineUpWidget;
      
      private var _backgroundMC:MovieClip;
      
      private var _introWidget:IntroWidget;
      
      private var _introFirstPart:MovieClipShower;
      
      private var _skipScreenShower:MovieClipShower;
      
      private var _skipModule:InteractionHandler;
      
      public function Intro(sourceURL:String)
      {
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
         _ts.g.intro = this;
         GameState.instance.screenOrganizer.addChild(_mc,0);
         this._backgroundMC = _mc.bg;
         this._players = new IntroLineUpWidget(_mc.players);
         this._introWidget = new IntroWidget(_mc.intro);
         this._introFirstPart = new MovieClipShower(_mc.introP1);
         this._skipScreenShower = new MovieClipShower(_mc.skip);
         this._skipModule = new InteractionHandler(new MakeSingleChoice(true,function setup(players:Array):void
         {
            TSInputHandler.instance.setupForSingleInput();
         },function getPromptFn(p:Player):Object
         {
            return {"html":LocalizationUtil.getPrintfText("SKIP_INTRODUCTION")};
         },function getChoicesFn(p:Player):Array
         {
            return [{"text":"SKIP"}];
         },function getChoiceTypeFn(p:Player):String
         {
            return "SkipTutorial";
         },function getDoneText(p:Player, choiceIndex:int):String
         {
            return "Thank you!";
         },function getChoiceIdFn(p:Player):String
         {
            return undefined;
         },function getClassesFn(p:Player):Array
         {
            return [];
         },function finalizeBlob(p:Player, blob:Object):void
         {
         },function playerMadeChoiceFn(p:Player, choice:int):Boolean
         {
            return true;
         },function doneFn(finishedOnPlayerInput:Boolean, chosenChoices:PerPlayerContainer):void
         {
            if(finishedOnPlayerInput)
            {
               TSInputHandler.instance.input("skip");
            }
         }),GameState.instance,false,false);
         addDelegate(new VideoPlayerDelegate(_mc.videoContainer,true));
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         resetDelegates();
         JBGUtil.reset([this._players,this._introWidget,this._skipModule,this._introFirstPart]);
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         this._players.setup(GameState.instance.players);
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         JBGUtil.gotoFrame(this._backgroundMC,"Park");
         this._players.reset();
         ref.end();
      }
      
      public function handleActionSetPlayersShown(ref:IActionRef, params:Object) : void
      {
         this._players.setPlayersShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetLogoShown(ref:IActionRef, params:Object) : void
      {
         this._introWidget.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowAssistant(ref:IActionRef, params:Object) : void
      {
         this._introWidget.showAssistant(TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetSkipIntroActive(ref:IActionRef, params:Object) : void
      {
         this._skipModule.setIsActive([GameState.instance.players[0]],params.isActive);
         ref.end();
      }
      
      public function handleActionDoAnimationOnIntro(ref:IActionRef, params:Object) : void
      {
         this._introFirstPart.doAnimation(params.frameLabel,Nullable.NULL_FUNCTION);
         ref.end();
      }
      
      public function handleActionSetIntroFirstPartShown(ref:IActionRef, params:Object) : void
      {
         this._introFirstPart.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetSkipScreenShown(ref:IActionRef, params:Object) : void
      {
         this._skipScreenShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
   }
}
