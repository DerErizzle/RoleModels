package jackboxgames.thewheel.actionpackages
{
   import flash.display.MovieClip;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.commonbehaviors.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class Intro extends LibraryActionPackage implements IChooseDataDelegate, IChooseEventDelegate, IEnterTextDataDelegate, IEnterTextEventDelegate, IEnterTextCompiler
   {
      private var _textShower:MovieClipShower;
      
      private var _textTf:ExtendableTextField;
      
      private var _playerWidgets:Array;
      
      private var _timer:TFTimer;
      
      private var _loopingMcs:Array;
      
      private var _skipInteraction:EntityInteractionHandler;
      
      private var _askTheWheelInteraction:EntityInteractionHandler;
      
      private var _playersThatDidntAsk:Array;
      
      public function Intro(apRef:IActionPackageRef)
      {
         super(apRef,GameState.instance);
      }
      
      override protected function get _linkage() : String
      {
         return "Intro";
      }
      
      override protected function get _displayIndex() : int
      {
         return 2;
      }
      
      override protected function get _propertyName() : String
      {
         return "intro";
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._textShower = new MovieClipShower(_mc.title);
         this._textTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.title.text);
         this._playerWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc.players,"player").map(function(playerMc:MovieClip, ... args):IntroPlayer
         {
            return new IntroPlayer(playerMc);
         });
         this._loopingMcs = [_mc.clouds1,_mc.clouds2,_mc.clouds3,_mc.rays];
         this._timer = new TFTimer(_mc.timerContainer);
         this._skipInteraction = new EntityInteractionHandler(new Choose(this,this,new MakeSingleChoiceCompiler()),GameState.instance,false,false);
         this._askTheWheelInteraction = new EntityInteractionHandler(new EnterText(this,this,this),GameState.instance,false,false,false);
      }
      
      override protected function _onReset() : void
      {
         super._onReset();
         JBGUtil.reset([this._textShower,this._timer]);
         JBGUtil.reset([this._skipInteraction,this._askTheWheelInteraction]);
         JBGUtil.reset(this._playerWidgets);
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Park");
         JBGUtil.gotoFrame(_mc.mountain,"Default");
      }
      
      override protected function _onActiveChanged(isActive:Boolean) : void
      {
         JBGUtil.arrayGotoFrame(this._loopingMcs,isActive ? "Loop" : "Park");
         if(isActive)
         {
            JBGUtil.gotoFrame(_mc.players,"Layout" + GameState.instance.players.length);
            GameState.instance.players.forEach(function(p:Player, i:int, a:Array):void
            {
               _playerWidgets[i].setup(p);
            });
         }
      }
      
      public function get playersThatDidntAsk() : Array
      {
         return this._playersThatDidntAsk;
      }
      
      public function handleActionSetTextShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._textTf.text = LocalizationManager.instance.getText(params.key);
         }
         this._textShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionUpdateText(ref:IActionRef, params:Object) : void
      {
         JBGUtil.eventOnce(mc,MovieClipEvent.EVENT_TRIGGER,function(evt:MovieClipEvent):void
         {
            _textTf.text = LocalizationManager.instance.getText(params.key);
         });
         this._textShower.doAnimation("Update",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPlayersShown(ref:IActionRef, params:Object) : void
      {
         MovieClipShower.setMultiple(this._playerWidgets.slice(0,GameState.instance.players.length),params.isShown,Duration.fromSec(0.1),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupTimer(ref:IActionRef, params:Object) : void
      {
         if(GameState.instance.debug.fastTimersMode)
         {
            params.id = "fast";
         }
         this._timer.setup(GameState.instance.jsonData.getTimerConfig(params.id));
         ref.end();
      }
      
      public function handleActionSetTimerShown(ref:IActionRef, params:Object) : void
      {
         this._timer.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetTimerActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            this._timer.start(function(timeLeft:Duration):void
            {
               if(timeLeft.isLessThanOrEqualTo(GameState.instance.jsonData.gameConfig.playTimerAudioWhenLessThan))
               {
                  GameState.instance.audioRegistrationStack.play("timerTick");
               }
            },function():void
            {
               TSInputHandler.instance.input("TimeUp");
            });
         }
         else
         {
            this._timer.stop();
         }
      }
      
      public function handleActionSetSkipInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         if(EnvUtil.isDebug())
         {
            if(Boolean(params.isActive))
            {
               GameState.instance.debug.addEventListener(TheWheelDebug.EVENT_SKIP,this._onDebugSkip);
            }
            else
            {
               GameState.instance.debug.removeEventListener(TheWheelDebug.EVENT_SKIP,this._onDebugSkip);
            }
         }
         this._skipInteraction.setIsActive([GameState.instance.VIP],params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetAskTheWheelInteractionActive(ref:IActionRef, params:Object) : void
      {
         this._askTheWheelInteraction.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowWheel(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(_mc.mountain,"Wheel",MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      private function _onDebugSkip(... args) : void
      {
         TSInputHandler.instance.input("Skip");
      }
      
      public function getChooseCategory(p:JBGPlayer) : String
      {
         return "skip-intro";
      }
      
      public function getChoosePrompt(p:JBGPlayer) : String
      {
         return LocalizationManager.instance.getText("SKIP_PROMPT");
      }
      
      public function getChooseChoices(p:JBGPlayer) : Array
      {
         return [LocalizationManager.instance.getText("SKIP_CHOICE")];
      }
      
      public function setupChoose() : void
      {
      }
      
      public function onPlayerChose(p:JBGPlayer, index:int) : void
      {
      }
      
      public function onChooseDone(payload:*, finishedOnPlayerInput:Boolean) : void
      {
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Skip");
         }
      }
      
      public function get maxLength() : int
      {
         return 120;
      }
      
      public function get filterContent() : Boolean
      {
         return true;
      }
      
      public function getEnterTextCategory(p:JBGPlayer) : String
      {
         return "askTheWheel";
      }
      
      public function getEnterTextPrompt(p:JBGPlayer) : String
      {
         return LocalizationUtil.getPrintfText("ASK_THE_WHEEL_PROMPT");
      }
      
      public function getEnterTextPlaceholder(p:JBGPlayer) : String
      {
         return LocalizationUtil.getPrintfText("ASK_THE_WHEEL_PLACEHOLDER");
      }
      
      public function getEnterTextSubmitText(p:JBGPlayer) : String
      {
         return LocalizationUtil.getPrintfText("SUBMIT");
      }
      
      public function getEnterTextDoneText(p:JBGPlayer) : String
      {
         return LocalizationUtil.getPrintfText("ASK_THE_WHEEL_DONE_TEXT");
      }
      
      public function getEnterTextInputType() : String
      {
         return "text";
      }
      
      public function setupEnterText() : void
      {
         TSInputHandler.instance.setupForSingleInput();
      }
      
      public function onPlayerEnteredText(p:JBGPlayer, entry:String) : void
      {
         this._playerWidgets[p.index.val].shower.setShown(false,Nullable.NULL_FUNCTION);
      }
      
      public function onEnterTextDone(payload:*, finishedOnPlayerInput:Boolean) : void
      {
         this._playersThatDidntAsk = GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return p.question == null;
         });
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
      
      public function setup(players:Array) : void
      {
      }
      
      public function canAdd(p:JBGPlayer, entry:String) : Boolean
      {
         return Player(p).question == null;
      }
      
      public function add(p:JBGPlayer, entry:String) : void
      {
         Player(p).question = entry;
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return Player(p).question != null;
      }
      
      public function get payload() : *
      {
         return null;
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.utils.*;

class IntroPlayer
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _nameTf:ExtendableTextField;
   
   public function IntroPlayer(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
      this._nameTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerName);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function reset() : void
   {
      JBGUtil.reset([this._shower]);
      JBGUtil.gotoFrame(this._mc.playerAvatar,"Default");
   }
   
   public function setup(p:Player) : void
   {
      JBGUtil.gotoFrame(this._mc.playerAvatar,p.avatar.frame);
      this._nameTf.text = TheWheelTextUtil.formattedPlayerName(p);
   }
}

