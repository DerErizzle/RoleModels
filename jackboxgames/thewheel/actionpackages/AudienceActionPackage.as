package jackboxgames.thewheel.actionpackages
{
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import jackboxgames.algorithm.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.entityinteraction.commonbehaviors.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.model.*;
   import jackboxgames.modules.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.audience.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.utils.*;
   
   public dynamic class AudienceActionPackage extends JBGActionPackage implements IAudienceDataProvider, IChooseDataDelegate, IChooseEventDelegate
   {
      private static const COUNT_MODE_AUDIENCE_COUNT:String = "audienceCount";
      
      private static const COUNT_MODE_VOTE_COUNT:String = "votes";
      
      private static const COUNT_MODE_PERCENT_WHO_CHOSE:String = "percentWhoChose";
      
      private static const COUNT_UPDATE_INTERVAL:Duration = Duration.fromSec(1);
      
      private var _containerMc:MovieClip;
      
      private var _cloudMc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _containerStateMachine:FrameStateMachine;
      
      private var _countTf:ExtendableTextField;
      
      private var _countLabelTf:ExtendableTextField;
      
      private var _promptTf:ExtendableTextField;
      
      private var _chosenTriviaWinnerShower:MovieClipShower;
      
      private var _sliceMcs:Array;
      
      private var _voteForTriviaWinnerInteraction:AudienceInteractionHandler;
      
      private var _audienceBinaryChoiceSliceEffectInteraction:AudienceInteractionHandler;
      
      private var _playerBinaryChoiceSliceEffectInteraction:EntityInteractionHandler;
      
      private var _delayedDoneInputter:DelayedInputter;
      
      private var _chooseWinnerPromptKeys:Array;
      
      private var _isActive:Boolean;
      
      private var _countMode:String;
      
      private var _isUpdatingCount:Boolean;
      
      private var _lastCount:int;
      
      private var _countTimer:Timer;
      
      private var _numSlices:int;
      
      private var _lastNumVotesFromAudience:int;
      
      private var _lastNumVotesFromPlayers:int;
      
      private var _chosenTriviaWinner:Player;
      
      private var _chosenTriviaWinnerRatio:Number;
      
      private var _votesForA:int;
      
      private var _votesForB:int;
      
      public function AudienceActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _sourceURL() : String
      {
         return null;
      }
      
      override protected function _createReferences() : void
      {
         _mc = Gameplay(g.gameplay).mc.audience;
      }
      
      override protected function _disposeOfReferences() : void
      {
         _mc = null;
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
         var triviaWinnerDelegate:AudienceChooseFnDelegate;
         var binaryChoiceDelegate:AudienceChooseFnDelegate;
         var i:int;
         g.audience = this;
         GameState.instance.setAudienceDataProvider(this);
         this._containerMc = _mc.container;
         this._cloudMc = this._containerMc.cloud;
         this._shower = new MovieClipShower(_mc);
         this._containerStateMachine = new FrameStateMachine().withNode("Default").withNode("Prompt").withNode("Slices").withTransition("Default","Prompt","ShowPrompt").withTransition("Prompt","Default","HidePrompt").withTransition("Default","Slices","ShowSlices").withTransition("Slices","Default","HideSlices");
         this._chosenTriviaWinnerShower = new MovieClipShower(this._cloudMc.player);
         this._countTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._cloudMc.audienceCount.amount);
         this._countLabelTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._cloudMc.audience);
         this._promptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._containerMc.prompt);
         this._sliceMcs = JBGUtil.getPropertiesOfNameInOrder(this._containerMc.audienceSlices.container,"slice");
         triviaWinnerDelegate = new AudienceChooseFnDelegate().withCategoryFn(function():String
         {
            return "ChooseTriviaWinner";
         }).withPromptFn(function():String
         {
            return LocalizationUtil.getPrintfText(ArrayUtil.getRandomElement(_chooseWinnerPromptKeys));
         }).withChoicesFn(function():Array
         {
            return GameState.instance.players.map(function(p:Player, ... args):Object
            {
               return {
                  "text":TheWheelTextUtil.formattedPlayerName(p),
                  "id":p.sessionId.val
               };
            });
         }).withVotesUpdated(function(counts:Object):void
         {
            _lastNumVotesFromAudience = ObjectUtil.getTotal(counts);
         }).withDoneFn(function(counts:Object):void
         {
            var mostVotes:* = undefined;
            var totalVotes:* = ObjectUtil.getTotal(counts);
            if(totalVotes == 0)
            {
               return;
            }
            mostVotes = MapFold.process(GameState.instance.players,function(p:Player, i:int, a:Array):int
            {
               return counts[String(i)];
            },MapFold.FOLD_MAX);
            _chosenTriviaWinner = ArrayUtil.getRandomElement(GameState.instance.players.filter(function(p:Player, i:int, a:Array):Boolean
            {
               return counts[String(i)] == mostVotes;
            }));
            _chosenTriviaWinnerRatio = Number(mostVotes) / totalVotes;
         });
         this._voteForTriviaWinnerInteraction = new AudienceInteractionHandler(new AudienceChoose(triviaWinnerDelegate,triviaWinnerDelegate),GameState.instance);
         binaryChoiceDelegate = new AudienceChooseFnDelegate().withCategoryFn(function():String
         {
            return "BinaryChoiceFor" + _currentLastSpinResult.chosenPotentialEffect.id;
         }).withPromptFn(function():String
         {
            return _currentBinarySliceEffect.controllerPrompt;
         }).withChoicesFn(function():Array
         {
            return [_currentBinarySliceEffect.optionA,_currentBinarySliceEffect.optionB];
         }).withVotesUpdated(function(counts:Object):void
         {
            var numVotes:* = ObjectUtil.getTotal(counts);
            if(numVotes == _lastNumVotesFromAudience)
            {
               return;
            }
            _lastNumVotesFromAudience = ObjectUtil.getTotal(counts);
            if(_lastNumVotesFromAudience > 0 && !_delayedDoneInputter.isActive)
            {
               _delayedDoneInputter.isActive = true;
            }
            else
            {
               _delayedDoneInputter.poke();
            }
         }).withDoneFn(function(counts:Object):void
         {
            _votesForA += counts["0"];
            _votesForB += counts["1"];
         });
         this._audienceBinaryChoiceSliceEffectInteraction = new AudienceInteractionHandler(new AudienceChoose(binaryChoiceDelegate,binaryChoiceDelegate),GameState.instance);
         this._playerBinaryChoiceSliceEffectInteraction = new EntityInteractionHandler(new Choose(this,this,new MakeSingleChoiceCompiler()),GameState.instance,false,false,false);
         this._delayedDoneInputter = new DelayedInputter("Done",Duration.fromSec(5));
         i = 0;
         this._chooseWinnerPromptKeys = [];
         while(LocalizationManager.instance.hasValueForKey("AUDIENCE_CHOOSE_TRIVIA_WINNER_PROMPT_" + i))
         {
            this._chooseWinnerPromptKeys.push("AUDIENCE_CHOOSE_TRIVIA_WINNER_PROMPT_" + i);
            i++;
         }
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         this._isActive = false;
         JBGUtil.reset([this._shower,this._chosenTriviaWinnerShower,this._containerStateMachine]);
         JBGUtil.reset([this._voteForTriviaWinnerInteraction,this._audienceBinaryChoiceSliceEffectInteraction,this._playerBinaryChoiceSliceEffectInteraction,this._delayedDoneInputter]);
         JBGUtil.gotoFrame(this._containerMc,"Default");
         JBGUtil.arrayGotoFrame(this._sliceMcs,"Park");
         this._setIsUpdatingCount(false);
         this._countMode = COUNT_MODE_AUDIENCE_COUNT;
         this._lastCount = -1;
         ref.end();
      }
      
      private function _setIsUpdatingCount(val:Boolean) : void
      {
         if(this._isUpdatingCount == val)
         {
            return;
         }
         this._isUpdatingCount = val;
         if(this._isUpdatingCount)
         {
            this._countTimer = new Timer(COUNT_UPDATE_INTERVAL.inMs);
            this._countTimer.addEventListener(TimerEvent.TIMER,function(evt:TimerEvent):void
            {
               _updateCount();
            });
            this._countTimer.start();
            this._updateCount();
         }
         else
         {
            this._countTimer.stop();
            this._countTimer = null;
         }
      }
      
      private function _updateCountLabel() : void
      {
         var key:String = null;
         if(this._countMode == COUNT_MODE_PERCENT_WHO_CHOSE)
         {
            key = "AUDIENCE_LABEL_PERCENTWHOCHOSE_" + (this.earnedSlice ? "CORRECT" : "INCORRECT");
         }
         else
         {
            key = "AUDIENCE_LABEL_" + this._countMode.toUpperCase();
         }
         this._countLabelTf.text = LocalizationManager.instance.getValueForKey(key);
      }
      
      private function _updateCount() : void
      {
         var newCount:int = 0;
         var prefix:String = "";
         var suffix:String = "";
         var canPlayUpdate:Boolean = false;
         if(this._countMode == COUNT_MODE_AUDIENCE_COUNT)
         {
            newCount = GameState.instance.audience.audienceCount;
            canPlayUpdate = true;
         }
         else if(this._countMode == COUNT_MODE_VOTE_COUNT)
         {
            newCount = this._lastNumVotesFromAudience + this._lastNumVotesFromPlayers;
         }
         else if(this._countMode == COUNT_MODE_PERCENT_WHO_CHOSE)
         {
            newCount = Math.round(this._chosenTriviaWinnerRatio * 100);
            suffix = "%";
         }
         this._countTf.text = prefix + TheWheelTextUtil.formattedAudienceNum(newCount) + suffix;
         if(canPlayUpdate && newCount != this._lastCount)
         {
            JBGUtil.gotoFrame(this._cloudMc.audienceCount,"UpdateNum");
         }
         this._lastCount = newCount;
      }
      
      private function _updateNumSlices(newNumSlices:int) : void
      {
         var i:int = 0;
         var previousNumSlices:int = this._numSlices;
         this._numSlices = newNumSlices;
         JBGUtil.gotoFrame(this._containerMc.audienceSlices.container,"Layout" + this._numSlices);
         if(this._numSlices > previousNumSlices)
         {
            for(i = previousNumSlices; i < this._numSlices; i++)
            {
               JBGUtil.gotoFrame(this._sliceMcs[i],"Earn");
            }
         }
         else
         {
            for(i = this._numSlices; i < previousNumSlices; i++)
            {
               JBGUtil.gotoFrame(this._sliceMcs[i],"Park");
            }
         }
      }
      
      public function handleActionSetupForNewGame(ref:IActionRef, params:Object) : void
      {
         this._updateNumSlices(0);
         ref.end();
      }
      
      public function handleActionSetShown(ref:IActionRef, params:Object) : void
      {
         if(!SettingsManager.instance.getValue(SettingsConstants.SETTING_AUDIENCE_ON).val)
         {
            ref.end();
            return;
         }
         this._isActive = params.isShown;
         this._setIsUpdatingCount(params.isShown);
         this._updateCountLabel();
         this._shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupForNewRound(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         this._updateNumSlices(0);
         ref.end();
      }
      
      public function handleActionSetupForNewTrivia(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         this._lastNumVotesFromAudience = 0;
         this._lastNumVotesFromPlayers = 0;
         this._chosenTriviaWinner = null;
         ref.end();
      }
      
      public function handleActionSetPromptShown(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         var frame:String = this._containerStateMachine.transition(Boolean(params.isShown) ? "Prompt" : "Default");
         if(!frame)
         {
            ref.end();
            return;
         }
         if(Boolean(params.isShown))
         {
            this._promptTf.text = LocalizationManager.instance.getValueForKey(params.text);
         }
         JBGUtil.gotoFrameWithFn(this._containerMc,frame,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetSlicesShown(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         var frame:String = this._containerStateMachine.transition(Boolean(params.isShown) ? "Slices" : "Default");
         if(!frame)
         {
            ref.end();
            return;
         }
         JBGUtil.gotoFrameWithFn(this._containerMc,frame,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSwitchCountMode(ref:IActionRef, params:Object) : void
      {
         var frame:String;
         var lastCountMode:String = null;
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         if(this._countMode == params.mode)
         {
            ref.end();
            return;
         }
         this._setIsUpdatingCount(false);
         lastCountMode = this._countMode;
         this._countMode = params.mode;
         JBGUtil.eventOnce(this._cloudMc,MovieClipEvent.EVENT_TRIGGER,function(... args):void
         {
            _updateCount();
            _updateCountLabel();
         });
         frame = (function():String
         {
            if(_countMode == COUNT_MODE_PERCENT_WHO_CHOSE)
            {
               return earnedSlice ? "CorrectOn" : "WrongOn";
            }
            if(lastCountMode == COUNT_MODE_PERCENT_WHO_CHOSE)
            {
               return earnedSlice ? "CorrectOff" : "WrongOff";
            }
            return "Flip";
         })();
         JBGUtil.gotoFrameWithFn(this._cloudMc,frame,MovieClipEvent.EVENT_ANIMATION_DONE,function():void
         {
            _setIsUpdatingCount(true);
            ref.end();
         });
      }
      
      public function handleActionSetTriviaWinnerInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         this._voteForTriviaWinnerInteraction.setIsActive(params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetChosenTriviaWinnerShown(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         if(Boolean(params.isShown))
         {
            JBGUtil.gotoFrame(this._cloudMc.player.playerAvatar,this._chosenTriviaWinner.avatar.frame);
         }
         this._chosenTriviaWinnerShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetChosenTriviaWinnerResultShown(ref:IActionRef, params:Object) : void
      {
         var frame:String;
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         frame = (function():String
         {
            if(Boolean(params.isShown))
            {
               return earnedSlice ? "CorrectOn" : "WrongOn";
            }
            return earnedSlice ? "CorrectOff" : "WrongOff";
         })();
         JBGUtil.gotoFrameWithFn(this._cloudMc,frame,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionGiveAudienceSlice(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         this._updateNumSlices(this._numSlices + 1);
         ref.end();
      }
      
      private function get _currentLastSpinResult() : SpinResult
      {
         return SpinTheWheel(g.spinTheWheel).lastSpinResult;
      }
      
      private function get _currentBinarySliceEffect() : AudienceBinaryChoiceEffect
      {
         return AudienceBinaryChoiceEffect(this._currentLastSpinResult.effect);
      }
      
      public function handleActionSetupForBinaryChoiceSliceEffect(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         TSInputHandler.instance.setupForSingleInput();
         this._lastNumVotesFromAudience = 0;
         this._lastNumVotesFromPlayers = 0;
         this._votesForA = 0;
         this._votesForB = 0;
         ref.end();
      }
      
      public function handleActionSetBinaryChoiceSliceEffectInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         PromiseUtil.ALL([this._audienceBinaryChoiceSliceEffectInteraction.setIsActive(params.isActive),this._playerBinaryChoiceSliceEffectInteraction.setIsActive(GameState.instance.players,params.isActive)]).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
         if(!params.isActive)
         {
            this._delayedDoneInputter.isActive = false;
         }
      }
      
      public function handleActionPrepareBinaryChoiceSliceEffectForEvaluation(ref:IActionRef, params:Object) : void
      {
         if(!this._isActive)
         {
            ref.end();
            return;
         }
         this._currentBinarySliceEffect.prepareForEvaluation(this._votesForA,this._votesForB);
         ref.end();
      }
      
      public function get numSlices() : int
      {
         return this._numSlices;
      }
      
      public function get chosenTriviaWinner() : Player
      {
         return this._chosenTriviaWinner;
      }
      
      public function get earnedSlice() : Boolean
      {
         if(!this._chosenTriviaWinner)
         {
            return false;
         }
         return ArrayUtil.arrayContainsElement(GameState.instance.currentTriviaData.result.playersWithTopScore,this._chosenTriviaWinner);
      }
      
      public function getChooseCategory(p:JBGPlayer) : String
      {
         return "BinaryChoiceFor" + this._currentLastSpinResult.chosenPotentialEffect.id;
      }
      
      public function getChoosePrompt(p:JBGPlayer) : String
      {
         return this._currentBinarySliceEffect.controllerPrompt;
      }
      
      public function getChooseChoices(p:JBGPlayer) : Array
      {
         return [this._currentBinarySliceEffect.optionA,this._currentBinarySliceEffect.optionB];
      }
      
      public function setupChoose() : void
      {
      }
      
      public function onPlayerChose(p:JBGPlayer, index:int) : void
      {
         if(this._delayedDoneInputter.isActive)
         {
            this._delayedDoneInputter.poke();
         }
         else
         {
            this._delayedDoneInputter.isActive = true;
         }
         Player(p).widget.setAnswering(false);
         ++this._lastNumVotesFromPlayers;
      }
      
      public function onChooseDone(payload:*, finishedOnPlayerInput:Boolean) : void
      {
         var choices:PerPlayerContainer = null;
         choices = payload;
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            if(!choices.hasDataForPlayer(p))
            {
               return;
            }
            if(choices.getDataForPlayer(p) == 0)
            {
               ++_votesForA;
            }
            else if(choices.getDataForPlayer(p) == 1)
            {
               ++_votesForB;
            }
         });
      }
   }
}

