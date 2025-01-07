package jackboxgames.thewheel.actionpackages
{
   import flash.display.MovieClip;
   import jackboxgames.animation.tween.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.events.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class AnswerWheel extends LibraryActionPackage implements IWheelDataDelegate, ISpinWheelBehaviorDelegate
   {
      private var _winnerNameTf:ExtendableTextField;
      
      private var _hostShower:MovieClipShower;
      
      private var _answerShower:MovieClipShower;
      
      private var _questionShower:MovieClipShower;
      
      private var _flapperMc:MovieClip;
      
      private var _flapperColorMc:MovieClip;
      
      private var _answerTf:ExtendableTextField;
      
      private var _shadowTf:ExtendableTextField;
      
      private var _questionTf:ExtendableTextField;
      
      private var _wheelContainerMc:MovieClip;
      
      private var _interaction:EntityInteractionHandler;
      
      private var _timer:TFTimer;
      
      private var _wheelAudio:WheelAudio;
      
      private var _hostAudioBehavior:AudioMeterPropertyChanger;
      
      private var _wheel:Wheel;
      
      private var _spinType:SpinType;
      
      private var _oldSpin:Number;
      
      public function AnswerWheel(apRef:IActionPackageRef)
      {
         super(apRef,GameState.instance);
      }
      
      override protected function get _linkage() : String
      {
         return "AnswerWheel";
      }
      
      override protected function get _displayIndex() : int
      {
         return 2;
      }
      
      override protected function get _propertyName() : String
      {
         return "answerWheel";
      }
      
      public function get spinType() : SpinType
      {
         return this._spinType;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._winnerNameTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.playerName);
         this._hostShower = new MovieClipShower(_mc.finalWheel.host);
         this._answerShower = new MovieClipShower(_mc.answerTf);
         this._questionShower = new MovieClipShower(_mc.questionTf);
         this._flapperMc = _mc.flipper;
         this._flapperColorMc = _mc.flipper.color;
         this._answerTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.answerTf.mc.tf);
         this._shadowTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.answerTf.mc.dropShadow);
         this._questionTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.questionTf.tf);
         this._wheelContainerMc = _mc.finalWheel.wheelContainer;
         this._interaction = new EntityInteractionHandler(new SpinWheelBehavior(this,new WheelControllerProvider(this,GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT)),GameState.instance,false,false,false);
         this._timer = new TFTimer(_mc.timer);
         this._wheelAudio = new WheelAudio("SFX/FinalWheel/sfx_finalWheel_spin","SFX/FinalWheel/sfx_finalWheel_ticks",true);
         this._hostAudioBehavior = new AudioMeterPropertyChanger(_mc.finalWheel.host.glowContainer.glow,"alpha","Host",GameState.instance.jsonData.gameConfig.hostAudioMeterData);
      }
      
      override protected function _onReset() : void
      {
         super._onReset();
         JBGUtil.reset([this._hostShower,this._answerShower,this._questionShower]);
         JBGUtil.reset([this._interaction,this._timer,this._wheelAudio,this._hostAudioBehavior]);
         JBGUtil.arrayGotoFrame([this._flapperColorMc,this._flapperMc,_mc.answerTf.mc],"Default");
         this._disposeOfWheel();
      }
      
      override protected function _onActiveChanged(isActive:Boolean) : void
      {
         this._hostShower.setShown(isActive,Nullable.NULL_FUNCTION);
         this._hostAudioBehavior.setActive(isActive);
      }
      
      private function _disposeOfWheel() : void
      {
         if(Boolean(this._wheel))
         {
            if(Boolean(this._wheelContainerMc))
            {
               this._wheelContainerMc.removeChild(this._wheel);
            }
            this._wheel.dispose();
            this._wheel = null;
         }
      }
      
      private function _getBucketForQuestion(question:String) : AnswerBucket
      {
         var word:String = null;
         var b:AnswerBucket = null;
         var key:String = null;
         var keyWords:Array = null;
         var keywordMatch:Boolean = false;
         var index:int = 0;
         var nextWord:String = null;
         var seq:String = null;
         var allBuckets:Array = GameState.instance.jsonData.answerBuckets;
         var questionLower:String = question.replace("&#39;","\'");
         questionLower = questionLower.replace("?","");
         questionLower = questionLower.toLowerCase();
         var questionWordsWithEmpty:Array = questionLower.split(" ");
         var questionWords:Array = [];
         for each(word in questionWordsWithEmpty)
         {
            if(Boolean(word))
            {
               questionWords.push(word);
            }
         }
         for each(b in allBuckets)
         {
            for each(key in b.keywords)
            {
               keyWords = key.split(" ");
               keywordMatch = this._questionHasKeywords(questionWords,keyWords);
               index = int(questionWords.indexOf(key));
               if(keywordMatch)
               {
                  if(b.sequential.length <= 0)
                  {
                     return b;
                  }
                  if(index < questionWords.length - 1)
                  {
                     nextWord = questionWords[index + 1];
                     for each(seq in b.sequential)
                     {
                        if(seq == nextWord)
                        {
                           return b;
                        }
                     }
                  }
               }
            }
         }
         return ArrayUtil.last(allBuckets);
      }
      
      private function _questionHasKeywords(questionWords:Array, keyWords:Array) : Boolean
      {
         var firstKeyIndex:int = int(questionWords.indexOf(keyWords[0]));
         if(firstKeyIndex == -1)
         {
            return false;
         }
         var indexInQuestion:int = firstKeyIndex + 1;
         for(var j:int = 1; j < keyWords.length; j++)
         {
            if(indexInQuestion > questionWords.length - 1)
            {
               return false;
            }
            if(keyWords[j] != questionWords[indexInQuestion])
            {
               return false;
            }
            indexInQuestion++;
         }
         return true;
      }
      
      public function handleActionSetup(ref:IActionRef, params:Object) : void
      {
         var question:String;
         var bucket:AnswerBucket;
         var answerContentData:Array;
         var answers:Array = null;
         var answersWeStillNeed:int = 0;
         var test:int = 0;
         var winner:Player = GameState.instance.winner;
         JBGUtil.gotoFrame(_mc.player,winner.avatar.frame);
         this._winnerNameTf.text = TheWheelTextUtil.formattedPlayerName(winner);
         question = winner.question;
         this._questionTf.text = Boolean(question) ? question : "No Question";
         bucket = this._getBucketForQuestion(question);
         this._questionTf.text = Boolean(GameState.instance.winner.question) ? GameState.instance.winner.question : "No Question";
         this._wheel = new Wheel("answer",0,GameState.instance.jsonData.gameConfig.sliceSize,GameState.instance.jsonData.gameConfig.sliceSize,"wheelBg",this._flapperMc);
         this._wheelContainerMc.addChild(this._wheel);
         answers = [];
         while(answers.length < this._wheel.slicePositions.length)
         {
            answersWeStillNeed = this._wheel.slicePositions.length - answers.length;
            answers = answers.concat(ArrayUtil.getRandomElements(bucket.answers,Math.min(bucket.answers.length,answersWeStillNeed)));
         }
         answers = ArrayUtil.deranged(answers);
         answerContentData = ContentManager.instance.getRandomUnusedContent("TheWheelAnswer",this._wheel.slicePositions.length);
         this._wheel.slicePositions.forEach(function(pos:int, i:int, a:Array):void
         {
            var params:SliceParameters = SliceParameters.CREATE(GameConstants.SLICE_TYPE_ANSWER);
            AnswerSliceData(params.data).index = i;
            AnswerSliceData(params.data).answer = answers[i];
            var s:Slice = _wheel.addSlice(params,pos);
            s.slideIn(Nullable.NULL_FUNCTION);
         });
         JBGUtil.gotoFrame(this._flapperColorMc,GameState.instance.winner.avatar.frame);
         this._wheelAudio.setLoaded(true,TSUtil.createRefEndFn(ref));
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
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         this._interaction.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetAnswerShown(ref:IActionRef, params:Object) : void
      {
         this._answerShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetQuestionShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_ASK_QUESTION",TheWheelTextUtil.formattedPlayerName(GameState.instance.winner),GameState.instance.winner.question);
            GameState.instance.textDescriptions.updateEntity();
         }
         this._questionShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRevealQuestionAndWheel(ref:IActionRef, params:Object) : void
      {
         _shower.doAnimation("Answer",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionPlayPreSpinAnimation(ref:IActionRef, params:Object) : void
      {
         _shower.doAnimation("Spin",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoSpin(ref:IActionRef, params:Object) : void
      {
         var spinAmount:int;
         var duration:Duration;
         var spinTween:JBGTween;
         var power:Number = NaN;
         TSInputHandler.instance.setupForSingleInput();
         if(!this._spinType)
         {
            power = Random.instance.nextRandomNumber();
            this._spinType = GameState.instance.jsonData.getSpinType(this.spinWheelSpinTypeCategory,power);
         }
         spinAmount = this._spinType.minSpin + Math.floor(Number(this._spinType.maxSpin - this._spinType.minSpin) * Math.random());
         duration = GameState.instance.debug.fastTimersMode ? GameState.instance.debug.fastSpinDuration : this._spinType.duration;
         spinTween = new JBGTween(this._wheel,duration,{"spin":this._wheel.spin + spinAmount},this._spinType.ease,true);
         TrackedTweens.track(spinTween);
         spinTween.addEventListener(JBGTween.EVENT_TWEEN_UPDATE,function(evt:EventWithData):void
         {
            _updateCurrentAnswer();
         });
         JBGUtil.eventOnce(spinTween,JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
         {
            GameState.instance.winner.answer = AnswerSliceData(_wheel.getSliceAtFlapper().params.data).answer;
            _updateAnswerText();
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_ANSWER",GameState.instance.winner.answer);
            GameState.instance.textDescriptions.updateEntity();
            _wheel.getSliceAtFlapper().setVisualState(Slice.STATE_HIGHLIGHTED);
            JBGUtil.gotoFrame(_mc.answerTf.mc,"Hilight");
            _wheelAudio.setActive(false);
            TSInputHandler.instance.input("Done");
         });
         this._wheelAudio.setup(this._wheel);
         this._wheelAudio.setActive(true);
         ref.end();
      }
      
      private function _updateAnswerText() : void
      {
         var questionMarked:String = null;
         if(Boolean(GameState.instance.winner.answer))
         {
            this._answerTf.text = GameState.instance.winner.answer;
         }
         else
         {
            questionMarked = AnswerSliceData(this._wheel.getSliceAtFlapper().params.data).answer.replace(/\S/g,"?");
            this._answerTf.text = questionMarked;
         }
         this._shadowTf.text = this._answerTf.text;
      }
      
      private function _updateCurrentAnswer() : void
      {
         if(this._wheel.spin % this._wheel.sliceSize < this._oldSpin % this._wheel.sliceSize)
         {
            this._answerShower.doAnimation("Update",Nullable.NULL_FUNCTION);
            this._updateAnswerText();
         }
         this._oldSpin = this._wheel.spin;
      }
      
      public function get spinWheelSpinner() : Player
      {
         return GameState.instance.winner;
      }
      
      public function get spinWheelSpinTypeCategory() : String
      {
         return "default";
      }
      
      public function onWheelSpun(p:Player, type:SpinType) : void
      {
         this._spinType = type;
      }
      
      public function getWheel() : Wheel
      {
         return this._wheel;
      }
   }
}

