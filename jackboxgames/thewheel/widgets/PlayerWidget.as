package jackboxgames.thewheel.widgets
{
   import com.greensock.easing.*;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import jackboxgames.algorithm.*;
   import jackboxgames.animation.tween.*;
   import jackboxgames.animation.tweenable.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.utils.*;
   
   public class PlayerWidget implements IPlayerWidgetBehaviors
   {
      private static const STATE_DEFAULT:String = "default";
      
      private static const STATE_ANSWERING:String = "answering";
      
      private static const STATE_HIGHLIGHTED:String = "highlighted";
      
      private static const STATE_DIMMED:String = "dimmed";
      
      private static const STATE_SELECTABLE:String = "selectable";
      
      private static const STATE_SELECTED:String = "selected";
      
      private static const STATE_FROZEN:String = "frozen";
      
      public static const RESULT_VIEW_MODE_STANDARD:String = "standard";
      
      public static const RESULT_VIEW_MODE_WIDE:String = "wide";
      
      private var _mc:MovieClip;
      
      private var _mcStateMachine:FrameStateMachine;
      
      private var _shower:MovieClipShower;
      
      private var _scoreShower:MovieClipShower;
      
      private var _scoreMultiplierShower:MovieClipShower;
      
      private var _playerCorrectShower:MovieClipShower;
      
      private var _nameTf:ExtendableTextField;
      
      private var _scoreTf:ExtendableTextField;
      
      private var _scoreMultiplierTf:ExtendableTextField;
      
      private var _numCorrectTf:ExtendableTextField;
      
      private var _uniqueShower:MovieClipShower;
      
      private var _uniqueCorrectTf:ExtendableTextField;
      
      private var _slicesShower:MovieClipShower;
      
      private var _sliceMcs:Array;
      
      private var _bonusSliceShower:MovieClipShower;
      
      private var _numberAnswerShower:MovieClipShower;
      
      private var _numberAnswerTf:ExtendableTextField;
      
      private var _highScoreShower:MovieClipShower;
      
      private var _highScoreLabelTf:ExtendableTextField;
      
      private var _closestAnswerShower:MovieClipShower;
      
      private var _answerMc:MovieClip;
      
      private var _answerTf:ExtendableTextField;
      
      private var _maxSlicesWeCanShow:int;
      
      private var _player:Player;
      
      private var _numSlicesRevealed:int;
      
      private var _isAnswering:Boolean;
      
      private var _isHighlighted:Boolean;
      
      private var _lastWinnerMode:Boolean;
      
      private var _basePointsEarned:int;
      
      private var _totalPointsEarned:int;
      
      private var _totalMultipliers:Number;
      
      private var _scoreTweenText:TweenableTextFieldWrapper;
      
      private var _playerResultViewMode:String;
      
      public function PlayerWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._mcStateMachine = new FrameStateMachine().withNode(STATE_DEFAULT).withNode(STATE_ANSWERING).withNode(STATE_HIGHLIGHTED).withNode(STATE_DIMMED).withNode(STATE_SELECTABLE).withNode(STATE_SELECTED).withNode(STATE_FROZEN).withTransition(STATE_DEFAULT,STATE_ANSWERING,"Answering").withTransition(STATE_ANSWERING,STATE_DEFAULT,"Answered").withTransition(STATE_DEFAULT,STATE_HIGHLIGHTED,"Highlight").withTransition(STATE_HIGHLIGHTED,STATE_DEFAULT,"Unhighlight").withTransition(STATE_DEFAULT,STATE_DIMMED,"Dim").withTransition(STATE_DIMMED,STATE_DEFAULT,"Undim").withTransition(STATE_DEFAULT,STATE_SELECTABLE,"Selectable").withTransition(STATE_SELECTABLE,STATE_DEFAULT,"Default").withTransition(STATE_SELECTABLE,STATE_SELECTED,"Highlight").withTransition(STATE_SELECTED,STATE_SELECTABLE,"Selectable").withTransition(STATE_SELECTED,STATE_DEFAULT,"Default").withTransition(STATE_ANSWERING,STATE_FROZEN,"Frozen").withTransition(STATE_FROZEN,STATE_ANSWERING,"Unfrozen");
         this._shower = new MovieClipShower(this._mc);
         this._scoreShower = new MovieClipShower(this._mc.playerScore);
         this._scoreMultiplierShower = new MovieClipShower(this._mc.playerScore.multiplier);
         this._playerCorrectShower = new MovieClipShower(this._mc.playerCorrect);
         this._nameTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerName);
         this._scoreTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerScore.amount);
         this._scoreMultiplierTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerScore.multiplier.amount);
         this._numCorrectTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerCorrect.container.total);
         this._uniqueShower = new MovieClipShower(this._mc.playerCorrect.container.unique);
         this._uniqueCorrectTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerCorrect.container.unique.amount);
         this._slicesShower = new MovieClipShower(this._mc.playerSlices);
         this._sliceMcs = JBGUtil.getPropertiesOfNameInOrder(this._mc.playerSlices.container,"slice");
         this._bonusSliceShower = new MovieClipShower(this._mc.bonusSlice);
         this._scoreTweenText = new TweenableTextFieldWrapper(this._scoreTf,function(num:Number):String
         {
            return TheWheelTextUtil.formattedScore(Math.floor(num));
         });
         this._numberAnswerShower = new MovieClipShower(this._mc.numberAnswer);
         this._numberAnswerTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.numberAnswer.container.total);
         this._highScoreShower = new MovieClipShower(this._mc.playerCorrect.highScore);
         this._highScoreLabelTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerCorrect.highScore.mc);
         this._closestAnswerShower = new MovieClipShower(this._mc.numberAnswer.closest);
         this._answerMc = this._mc.answer;
         this._answerTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.answer.container.tf);
         this._maxSlicesWeCanShow = MapFold.process(this._mc.playerSlices.container.currentLabels,function(l:FrameLabel, ... args):int
         {
            if(l.name.indexOf("Layout") == 0)
            {
               return int(l.name.substring("Layout".length));
            }
            return 0;
         },MapFold.FOLD_MAX);
      }
      
      public function get shower() : MovieClipShower
      {
         return this._shower;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower,this._mcStateMachine,this._scoreShower,this._scoreMultiplierShower,this._playerCorrectShower,this._uniqueShower,this._slicesShower,this._bonusSliceShower,this._numberAnswerShower,this._highScoreShower,this._closestAnswerShower]);
         JBGUtil.arrayGotoFrame(this._sliceMcs,"Park");
         JBGUtil.gotoFrame(this._mc.playerAvatar,"Default");
         JBGUtil.gotoFrame(this._mc.playerAvatar.color,"Default");
         JBGUtil.gotoFrame(this._mc.playerCorrect.container,"Default");
         JBGUtil.arrayGotoFrame([this._answerMc],"Park");
         if(Boolean(this._player))
         {
            this._player.unlinkFromWidget();
            this._player = null;
         }
         this._numSlicesRevealed = 0;
         this._isAnswering = false;
         this._isHighlighted = false;
         this._basePointsEarned = 0;
         this._totalPointsEarned = 0;
         this._totalMultipliers = 1;
         this._playerResultViewMode = RESULT_VIEW_MODE_STANDARD;
      }
      
      public function setup(p:Player) : void
      {
         this._player = p;
         this._player.linkWithWidget(this);
         JBGUtil.gotoFrame(this._mc.playerAvatar,p.avatar.frame);
         this._lastWinnerMode = p.isInWinnerMode;
         JBGUtil.gotoFrame(this._mc.playerAvatar.color,p.isInWinnerMode ? "Winnable" : "Default");
         this._nameTf.text = TheWheelTextUtil.formattedPlayerName(p);
         this._setScoreVisuals(this._player.score.val,false);
         this._setNumSlices(this._player.numPlaceableSlices,false);
         JBGUtil.reset([this._playerCorrectShower,this._numberAnswerShower]);
         this._basePointsEarned = 0;
         this._totalPointsEarned = 0;
         this._totalMultipliers = 1;
         this._playerResultViewMode = RESULT_VIEW_MODE_STANDARD;
      }
      
      public function setScoreShown(val:Boolean) : void
      {
         this._scoreShower.setShown(val,Nullable.NULL_FUNCTION);
      }
      
      private function _setScoreVisuals(score:int, ignoreZero:Boolean) : void
      {
         this._scoreTf.text = score != 0 || ignoreZero ? TheWheelTextUtil.formattedScore(score) : "0000";
      }
      
      public function setupScoreReveal() : void
      {
         this._basePointsEarned = MapFold.process(this._player.pendingScoreChanges,function(sc:ScoreChange, ... args):int
         {
            return sc.getAmount(false);
         },function(a:Number, b:Number):Number
         {
            return a + b;
         });
         this._totalPointsEarned = MapFold.process(this._player.pendingScoreChanges,function(sc:ScoreChange, ... args):int
         {
            return sc.getAmount(true);
         },function(a:Number, b:Number):Number
         {
            return a + b;
         });
         this._totalMultipliers = MapFold.process(this._player.pendingScoreChanges,function(sc:ScoreChange, ... args):Number
         {
            return sc.totalMultiplier;
         },function(a:Number, b:Number):Number
         {
            return a * b;
         });
      }
      
      public function updateScore(rackUpTime:Duration) : void
      {
         var newScore:int = 0;
         var scoreTween:JBGTween = null;
         if(this._player.pendingScoreChanges.length > 0)
         {
            newScore = this._player.score.val + this._totalPointsEarned;
            this._scoreShower.doAnimation("Popup",Nullable.NULL_FUNCTION);
            this._scoreTweenText.num = this._player.score.val;
            scoreTween = new JBGTween(this._scoreTweenText,rackUpTime,{"num":this._player.score.val + this._totalPointsEarned},Linear.ease,true);
            TrackedTweens.track(scoreTween);
            JBGUtil.eventOnce(scoreTween,JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
            {
               _scoreShower.doAnimation(_totalPointsEarned >= 0 ? "Update" : "UpdateBad",Nullable.NULL_FUNCTION);
            });
            this._setScoreVisuals(newScore,false);
         }
      }
      
      public function setResultViewMode(mode:String) : void
      {
         this._playerResultViewMode = mode;
      }
      
      public function setResultsShown(val:Boolean) : void
      {
         var shower:MovieClipShower = this._playerResultViewMode == RESULT_VIEW_MODE_WIDE ? this._numberAnswerShower : this._playerCorrectShower;
         shower.setShown(val,Nullable.NULL_FUNCTION);
      }
      
      public function setResultsHighlighted(val:Boolean) : void
      {
         var clip:MovieClip = this._playerResultViewMode == RESULT_VIEW_MODE_WIDE ? this._mc.numberAnswer.container : this._mc.playerCorrect.container;
         JBGUtil.gotoFrame(clip,val ? "Highlight" : "Default");
      }
      
      public function setBestPerformanceLabel(key:String) : void
      {
         this._highScoreLabelTf.text = LocalizationManager.instance.getValueForKey(key);
      }
      
      public function setBestPerformanceShown(val:Boolean) : void
      {
         var shower:MovieClipShower = this._playerResultViewMode == RESULT_VIEW_MODE_WIDE ? this._closestAnswerShower : this._highScoreShower;
         shower.setShown(val,Nullable.NULL_FUNCTION);
      }
      
      public function setUniqueResultsShown(val:Boolean) : void
      {
         this._uniqueShower.setShown(val,Nullable.NULL_FUNCTION);
      }
      
      public function updateResult(numCorrect:int) : void
      {
         if(this._playerResultViewMode == RESULT_VIEW_MODE_WIDE)
         {
            this._numberAnswerTf.text = TheWheelTextUtil.formattedPlayerResult(numCorrect,this._playerResultViewMode);
            this._numberAnswerShower.doAnimation("Update",Nullable.NULL_FUNCTION);
         }
         else
         {
            this._numCorrectTf.text = TheWheelTextUtil.formattedPlayerResult(numCorrect,this._playerResultViewMode);
            this._playerCorrectShower.doAnimation("Update",Nullable.NULL_FUNCTION);
         }
      }
      
      public function updateUniqueResult(numUnique:int) : void
      {
         this._uniqueCorrectTf.text = String(numUnique);
      }
      
      public function updateResultWithDuration(d:Duration) : void
      {
         if(this._playerResultViewMode == RESULT_VIEW_MODE_WIDE)
         {
            this._numberAnswerTf.text = NumberUtil.format(d.inSec,6);
         }
         else
         {
            this._numCorrectTf.text = NumberUtil.format(d.inSec,2);
         }
      }
      
      private function _setVisualState(state:String) : void
      {
         var frame:String = this._mcStateMachine.transition(state);
         if(!frame)
         {
            return;
         }
         this._shower.doAnimation(frame,Nullable.NULL_FUNCTION);
      }
      
      public function setAnswering(val:Boolean) : void
      {
         this._setVisualState(val ? STATE_ANSWERING : STATE_DEFAULT);
      }
      
      public function setHighlighted(val:Boolean) : void
      {
         this._setVisualState(val ? STATE_HIGHLIGHTED : STATE_DEFAULT);
      }
      
      public function setDimmed(val:Boolean) : void
      {
         this._setVisualState(val ? STATE_DIMMED : STATE_DEFAULT);
      }
      
      public function setSelectable(val:Boolean) : void
      {
         this._setVisualState(val ? STATE_SELECTABLE : STATE_DEFAULT);
      }
      
      public function setSelected(val:Boolean) : void
      {
         this._setVisualState(val ? STATE_SELECTED : STATE_SELECTABLE);
      }
      
      public function setFrozen(val:Boolean) : void
      {
         this._setVisualState(val ? STATE_FROZEN : STATE_ANSWERING);
      }
      
      public function setSlicesShown(val:Boolean) : void
      {
         this._slicesShower.setShown(val,Nullable.NULL_FUNCTION);
      }
      
      private function _setNumSlices(num:int, animated:Boolean) : void
      {
         var newNumSlicesRevealed:int = this._numSlicesRevealed + num;
         var slicesToShow:int = Math.min(this._maxSlicesWeCanShow,newNumSlicesRevealed);
         JBGUtil.gotoFrame(this._mc.playerSlices.container,"Layout" + slicesToShow);
         for(var i:int = this._numSlicesRevealed; i < slicesToShow; i++)
         {
            JBGUtil.gotoFrame(this._sliceMcs[i],animated ? "Earn" : "Appear");
         }
         this._numSlicesRevealed = newNumSlicesRevealed;
      }
      
      public function addSlices(num:int) : void
      {
         this._setNumSlices(num,true);
      }
      
      public function setBonusSliceShown(val:Boolean) : void
      {
         this._bonusSliceShower.setShown(val,Nullable.NULL_FUNCTION);
      }
      
      public function setMultipliersShown(val:Boolean) : void
      {
         this._scoreMultiplierShower.setShown(val && this._totalMultipliers > 1,Nullable.NULL_FUNCTION);
         this._scoreMultiplierTf.text = TheWheelTextUtil.formattedMultiplier(this._totalMultipliers);
      }
      
      public function showPendingPoints(includeMultipliers:Boolean, skipIfNoMultipliers:Boolean) : void
      {
         if(this._basePointsEarned == 0 || skipIfNoMultipliers && this._totalMultipliers == 1)
         {
            return;
         }
         this._scoreShower.setShown(true,Nullable.NULL_FUNCTION);
         this._scoreShower.doAnimation("Popup",Nullable.NULL_FUNCTION);
         this._scoreTf.text = (this._totalPointsEarned > 0 ? "+" : "") + TheWheelTextUtil.formattedScore(includeMultipliers ? this._totalPointsEarned : this._basePointsEarned);
      }
      
      public function showCurrentScore() : void
      {
         this._setScoreVisuals(this._player.score.val,true);
         this._scoreShower.doAnimation("Popup",Nullable.NULL_FUNCTION);
      }
      
      public function get hasMultiplier() : Boolean
      {
         return this._totalMultipliers != 1;
      }
      
      public function updateWinnerMode() : void
      {
         if(this._lastWinnerMode == this._player.isInWinnerMode)
         {
            return;
         }
         this._lastWinnerMode = this._player.isInWinnerMode;
         JBGUtil.gotoFrame(this._mc.playerAvatar.color,this._lastWinnerMode ? "EnterWinnable" : "ExitWinnable");
      }
      
      public function showTemporaryAnswer(answer:String) : void
      {
         if(!SettingsManager.instance.getValue(GameConstants.SETTING_ALLOW_PLAYER_CONTENT_ON_SCREEN).val)
         {
            return;
         }
         this._answerTf.text = answer;
         JBGUtil.gotoFrame(this._answerMc,"AppearAnswer");
      }
   }
}

