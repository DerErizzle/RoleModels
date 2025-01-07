package jackboxgames.thewheel.actionpackages
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.core.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.actionpackages.triviatypes.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class Trivia extends LibraryActionPackage
   {
      private static const TARGET_MAIN:String = "main";
      
      private static const TARGET_TRIVIA_TYPE:String = "triviatype";
      
      private static const TARGET_BOTH:String = "both";
      
      private var _hostShower:MovieClipShower;
      
      private var _hostAudioBehavior:AudioMeterPropertyChanger;
      
      private var _loopingMcs:Array;
      
      private var _titleShower:MovieClipShower;
      
      private var _titleTf:ExtendableTextField;
      
      private var _triviaNumTf:ExtendableTextField;
      
      private var _playersShower:MovieClipShower;
      
      private var _playerWidgets:Array;
      
      private var _timer:TFTimer;
      
      private var _bonusSliceShower:MovieClipShower;
      
      private var _clueAudio:ClueAudio;
      
      private var _currentTrivia:TriviaTypeActionPackage;
      
      private var _currentDivider:Divider;
      
      private var _playerWidgetsInPlay:Array;
      
      private var _triviaTypeHasBeenRevealed:Boolean;
      
      public function Trivia(apRef:IActionPackageRef)
      {
         super(apRef,GameState.instance);
      }
      
      override protected function get _linkage() : String
      {
         return "Trivia";
      }
      
      override protected function get _displayIndex() : int
      {
         return 2;
      }
      
      override protected function get _propertyName() : String
      {
         return "trivia";
      }
      
      override protected function get _setShowerOnActive() : Boolean
      {
         return false;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._loopingMcs = ArrayUtil.concat([_mc.bg.raysContainer.rays],JBGUtil.getPropertiesOfNameInOrder(_mc,"bg"));
         this._hostShower = new MovieClipShower(_mc.host);
         this._hostAudioBehavior = new AudioMeterPropertyChanger(_mc.host.container.glow,"alpha","Host",GameState.instance.jsonData.gameConfig.hostAudioMeterData);
         this._titleShower = new MovieClipShower(_mc.title);
         this._titleShower.behaviorTranslator = function(behavior:String):String
         {
            if(behavior == "Disappear")
            {
               return _triviaTypeHasBeenRevealed ? "Disappear" : "DisappearNoType";
            }
            return behavior;
         };
         this._titleTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.title.text);
         this._triviaNumTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.title.round.num);
         this._playersShower = new MovieClipShower(_mc.players);
         this._playersShower.behaviorTranslator = function(s:String):String
         {
            return s + _playerWidgetsInPlay.length;
         };
         this._playerWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc.players,"player").map(function(playerMc:MovieClip, ... args):PlayerWidget
         {
            return new PlayerWidget(playerMc);
         });
         this._timer = new TFTimer(_mc.host.container.timerBehaviors);
         this._bonusSliceShower = new MovieClipShower(_mc.bonusSliceContainer);
         this._clueAudio = new ClueAudio(_ts);
      }
      
      override protected function _onReset() : void
      {
         super._onReset();
         JBGUtil.reset([this._hostShower,this._titleShower,this._playersShower,this._hostAudioBehavior,this._timer,this._bonusSliceShower,this._clueAudio]);
         JBGUtil.reset(this._playerWidgets);
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Default");
         JBGUtil.gotoFrame(_mc.title.round,"Default");
         JBGUtil.gotoFrame(_mc.bg.raysContainer,"Default");
         JBGUtil.gotoFrame(_mc.floor,"Park");
         this._playerWidgetsInPlay = [];
         if(Boolean(this._currentTrivia))
         {
            JBGUtil.safeRemoveChild(_mc.triviaContainer,this._currentTrivia.mc);
            this._currentTrivia = null;
         }
         if(Boolean(this._currentDivider))
         {
            this._currentDivider.dispose();
            this._currentDivider = null;
         }
      }
      
      override protected function _onActiveChanged(isActive:Boolean) : void
      {
         this._bonusSliceShower.setShown(isActive,Nullable.NULL_FUNCTION);
         this._hostAudioBehavior.setActive(isActive);
         JBGUtil.arrayGotoFrame(this._loopingMcs,isActive ? "Loop" : "Default");
      }
      
      private function _setupNewTrivia() : void
      {
         GameState.instance.setupNewTrivia();
         this._currentTrivia = TriviaTypeActionPackage.GET_ACTION_PACKAGE(GameState.instance.currentTriviaType);
         this._currentTrivia.reset();
         this._currentTrivia.setup();
         if(Boolean(this._currentTrivia.mc.divider))
         {
            this._currentDivider = new Divider(this._currentTrivia.mc.divider);
         }
         _mc.triviaContainer.addChild(this._currentTrivia.mc);
         this._titleTf.text = GameState.instance.currentTriviaType.getName(GameState.instance.currentTriviaData.content);
         this._triviaNumTf.text = String(GameState.instance.currentTriviaNum);
         JBGUtil.gotoFrame(_mc.title.round,"Default");
         this._titleShower.setShown(true,Nullable.NULL_FUNCTION);
         this._triviaTypeHasBeenRevealed = false;
      }
      
      private function _shutdownCurrentTrivia() : void
      {
         JBGUtil.safeRemoveChild(_mc.triviaContainer,this._currentTrivia.mc);
         if(Boolean(this._currentDivider))
         {
            this._currentDivider.dispose();
            this._currentDivider = null;
         }
         this._currentTrivia.reset();
         this._currentTrivia = null;
         this._titleShower.reset();
         this._clueAudio.reset();
      }
      
      private function _doBehavior(target:String, behavior:String, doneFn:Function) : void
      {
         var mcs:Array = (function():Array
         {
            switch(target)
            {
               case TARGET_MAIN:
                  return [_mc];
               case TARGET_TRIVIA_TYPE:
                  return [_currentTrivia.mc];
               case TARGET_BOTH:
                  return [_mc,_currentTrivia.mc];
               default:
                  return [];
            }
         })();
         var endingEvent:String = MovieClipUtil.getEndingEventForBehavior(behavior);
         var c:Counter = new Counter(2,doneFn);
         if(Boolean(this._currentTrivia))
         {
            this._currentTrivia.doBehavior(behavior,c.generateDoneFn());
         }
         else
         {
            c.tick();
         }
         if(Boolean(endingEvent))
         {
            JBGUtil.arrayGotoFrameWithFn(mcs,behavior,endingEvent,c.generateDoneFn());
         }
         else
         {
            JBGUtil.arrayGotoFrame(mcs,behavior);
            c.tick();
         }
      }
      
      public function handleActionSetup(ref:IActionRef, params:Object) : void
      {
         this._playerWidgetsInPlay = this._playerWidgets.slice(0,GameState.instance.players.length);
         this._playerWidgetsInPlay.forEach(function(widget:PlayerWidget, i:int, a:Array):void
         {
            widget.setup(GameState.instance.players[i]);
         });
         JBGUtil.gotoFrame(_mc.floor,"Layout" + this._playerWidgetsInPlay.length);
         this._setupNewTrivia();
         this._hostShower.setShown(true,Nullable.NULL_FUNCTION);
         ref.end();
      }
      
      public function handleActionAdvanceToNextTrivia(ref:IActionRef, params:Object) : void
      {
         this._doBehavior(TARGET_MAIN,"Next",TSUtil.createRefEndFn(ref));
         JBGUtil.eventOnce(_mc,MovieClipEvent.EVENT_TRIGGER,function(... args):void
         {
            _shutdownCurrentTrivia();
            GameState.instance.advanceToNextTrivia();
            _setupNewTrivia();
         });
      }
      
      public function handleActionSetupClueAudio(ref:IActionRef, params:Object) : void
      {
         this._clueAudio.setup();
         ref.end();
      }
      
      public function handleActionPlayClueAudioIndex(ref:IActionRef, params:Object) : void
      {
         var version:IAudioVersion = this._clueAudio.getAudioFor(params.index);
         if(!version)
         {
            ref.end();
            return;
         }
         g.sfxManager.play(version,ref);
      }
      
      public function handleActionDoBehavior(ref:IActionRef, params:Object) : void
      {
         this._doBehavior(params.target,params.behavior,TSUtil.createRefEndFn(ref));
      }
      
      private function _getTextForKeyFromTs(key:String) : String
      {
         var lookup:* = VariableUtil.getVariableValue(key);
         if(lookup && lookup is String)
         {
            return lookup;
         }
         var localized:String = LocalizationManager.instance.getText(key);
         if(Boolean(localized))
         {
            return localized;
         }
         return "";
      }
      
      public function handleActionSetTitleShown(ref:IActionRef, params:Object) : void
      {
         if(!params.isShown)
         {
            JBGUtil.gotoFrame(_mc.bg.raysContainer,"RevealPrompt");
         }
         this._titleShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRevealFinalRound(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(_mc.title.round,"Final",MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRevealTriviaType(ref:IActionRef, params:Object) : void
      {
         this._titleShower.doAnimation("AppearType",TSUtil.createRefEndFn(ref));
         this._triviaTypeHasBeenRevealed = true;
      }
      
      public function handleActionRevealTriviaNumber(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(_mc.title.round,"RevealNumber",MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPlayersShown(ref:IActionRef, params:Object) : void
      {
         MovieClipShower.setMultiple(this._playerWidgetsInPlay,params.isShown,Duration.ZERO,Nullable.NULL_FUNCTION);
         this._playersShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetInstructionsShown(ref:IActionRef, params:Object) : void
      {
         var text:String = null;
         Assert.assert(this._currentDivider != null);
         if(params.text.length > 0)
         {
            text = LocalizationManager.instance.getValueForKey(params.text);
            this._currentDivider.setup(text);
         }
         this._currentDivider.setShown(params.isShown,TSUtil.createRefEndFn(ref));
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
      
      public function handleActionGenerateTriviaResult(ref:IActionRef, params:Object) : void
      {
         GameState.instance.generateTriviaResult(this._currentTrivia,GameState.instance.isFinalTriviaForRound);
         ref.end();
      }
      
      public function handleActionGivePlaceableSlicesToPlayers(ref:IActionRef, params:Object) : void
      {
         var players:Array = TSUtil.resolveArrayFromVariablePath(params.players,Player);
         players.forEach(function(p:Player, ... args):void
         {
            p.changePlaceableSlices(params.numSlices);
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_PLAYER_GOT_SLICES",TheWheelTextUtil.formattedPlayerName(p),params.numSlices);
         });
         GameState.instance.textDescriptions.updateEntity();
         ref.end();
      }
      
      public function handleActionGiveTriviaPoints(ref:IActionRef, params:Object) : Array
      {
         var placeIndices:PerPlayerContainer = null;
         var playersWithScoreChange:Array = null;
         placeIndices = GameState.instance.currentTriviaData.result.placeIndices;
         playersWithScoreChange = [];
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            if(!placeIndices.hasDataForPlayer(p))
            {
               return;
            }
            var placeIndex:int = placeIndices.getDataForPlayer(p);
            if(placeIndex < 0)
            {
               return;
            }
            p.addScoreChange(new ScoreChange().withAmount(GameState.instance.jsonData.gameConfig.getPointsForTriviaPlaceIndex(placeIndex)));
            playersWithScoreChange.push(p);
         });
         ref.end();
         return playersWithScoreChange;
      }
      
      public function handleActionSetBonusSliceShown(ref:IActionRef, params:Object) : void
      {
         this._bonusSliceShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRevealBonusSlice(ref:IActionRef, params:Object) : void
      {
         this._bonusSliceShower.doAnimation("RevealEffect",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoBonusSliceBehavior(ref:IActionRef, params:Object) : void
      {
         this._bonusSliceShower.doAnimation(params.behavior,TSUtil.createRefEndFn(ref));
         if(params.behavior == "AppearBonus")
         {
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_PLAYER_GOT_POWER_SLICE",TheWheelTextUtil.formattedPlayerName(GameState.instance.currentTriviaData.result.bonusPlayer));
            GameState.instance.textDescriptions.updateEntity();
         }
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.events.*;
import jackboxgames.text.*;
import jackboxgames.utils.*;

class Divider
{
   private var _mc:MovieClip;
   
   private var _tf:ExtendableTextField;
   
   private var _isShown:Boolean;
   
   public function Divider(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.text);
   }
   
   public function dispose() : void
   {
      this._tf.dispose();
      this._tf = null;
      this._mc = null;
   }
   
   public function setup(text:String) : void
   {
      this._tf.text = text;
   }
   
   public function setShown(isShown:Boolean, doneFn:Function) : void
   {
      if(this._isShown == isShown)
      {
         doneFn();
         return;
      }
      this._isShown = isShown;
      JBGUtil.gotoFrameWithFn(this._mc,!!this._isShown ? "ShowText" : "HideText",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
   }
}

