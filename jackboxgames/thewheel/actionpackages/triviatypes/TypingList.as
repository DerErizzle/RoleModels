package jackboxgames.thewheel.actionpackages.triviatypes
{
   import flash.display.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.events.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.actionpackages.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class TypingList extends TriviaTypeActionPackage implements ITypingListBehaviorDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _promptShower:MovieClipShower;
      
      private var _promptTf:ExtendableTextField;
      
      private var _progressShower:MovieClipShower;
      
      private var _progressWidgets:Array;
      
      private var _answerWidgets:Array;
      
      private var _content:TypingListData;
      
      private var _playersThatGuessedAnswerIndex:Array;
      
      private var _numCorrectPerPlayer:PerPlayerContainer;
      
      private var _uniqueCorrectPerPlayer:PerPlayerContainer;
      
      private var _progressWidgetsInPlay:Array;
      
      private var _answerWidgetsInPlay:Array;
      
      private var _answersWithCluesWeHaventHintedAt:Array;
      
      private var _requestedAnswerForClue:TypingListAnswerData;
      
      public function TypingList(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _linkage() : String
      {
         return "TypingList";
      }
      
      override protected function get _triviaType() : TriviaType
      {
         return GameConstants.TRIVIA_TYPE_TYPING_LIST;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._interaction = new EntityInteractionHandler(new TypingListBehavior(this),GameState.instance,false,false);
         this._promptShower = new MovieClipShower(_mc.prompt);
         this._promptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.prompt.text);
         this._progressShower = new MovieClipShower(_mc.progressContainer);
         this._progressWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc.progressContainer.layout,"dot").map(function(progressMc:MovieClip, ... args):TypingListProgressWidget
         {
            return new TypingListProgressWidget(progressMc);
         });
         this._answerWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc.answers,"answer").map(function(answerMc:MovieClip, ... args):TypingListAnswerWidget
         {
            return new TypingListAnswerWidget(answerMc);
         });
      }
      
      public function get content() : TypingListData
      {
         return this._content;
      }
      
      public function get requestedAnswerForClue() : TypingListAnswerData
      {
         return this._requestedAnswerForClue;
      }
      
      public function get playersWithUniqueAnswers() : Array
      {
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return _uniqueCorrectPerPlayer.getDataForPlayer(p) > 0;
         });
      }
      
      override public function setup() : void
      {
         this._content = TypingListData(GameState.instance.currentTriviaData.content);
         this._answersWithCluesWeHaventHintedAt = this._content.answers.filter(function(a:TypingListAnswerData, ... args):Boolean
         {
            return a.hasClue;
         });
         this._promptTf.text = this._content.prompt;
         this._playersThatGuessedAnswerIndex = new Array(this._content.answers.length);
         this._content.answers.forEach(function(ans:TypingListAnswerData, i:int, a:Array):void
         {
            _playersThatGuessedAnswerIndex[i] = [];
         });
         JBGUtil.gotoFrame(_mc.progressContainer.layout,"Layout" + this._content.answers.length);
         this._progressWidgetsInPlay = this._progressWidgets.slice(0,this._content.answers.length);
         this._progressWidgetsInPlay.forEach(function(widget:TypingListProgressWidget, i:int, a:Array):void
         {
            widget.setup(_content.answers[i]);
         });
         this._numCorrectPerPlayer = PerPlayerContainerUtil.MAP(GameState.instance.players,function(... args):int
         {
            return 0;
         });
         this._uniqueCorrectPerPlayer = PerPlayerContainerUtil.MAP(GameState.instance.players,function(... args):int
         {
            return 0;
         });
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            p.widget.setBestPerformanceLabel("HIGH_SCORE");
            p.widget.setResultViewMode(PlayerWidget.RESULT_VIEW_MODE_STANDARD);
            p.widget.updateResult(0);
         });
      }
      
      override protected function _doReset() : void
      {
         JBGUtil.reset([this._interaction,this._promptShower,this._progressShower]);
         JBGUtil.reset(this._answerWidgets);
         JBGUtil.reset(this._progressWidgets);
         JBGUtil.arrayGotoFrame([_mc.progressContainer.layout,_mc.answers],"Park");
      }
      
      override public function doBehavior(behavior:String, doneFn:Function) : void
      {
         if(behavior == "Reveal")
         {
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_TYPING_LIST_REVEAL",this._content.answers.map(function(ans:TypingListAnswerData, ... args):String
            {
               return ans.text;
            }).join(", "));
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_TYPING_LIST_PLAYER_RESULT",TheWheelTextUtil.formattedPlayerName(p),_numCorrectPerPlayer.getDataForPlayer(p));
            });
            GameState.instance.textDescriptions.updateEntity();
         }
         doneFn();
      }
      
      override public function getPerformanceForPlayer(p:Player) : int
      {
         return this._numCorrectPerPlayer.getDataForPlayer(p) + 2 * this._uniqueCorrectPerPlayer.getDataForPlayer(p);
      }
      
      override public function getPlayersEligibleForBonusSlice() : Array
      {
         var maxPerformance:int = 0;
         maxPerformance = MapFold.process(GameState.instance.players,function(p:Player, ... args):int
         {
            return getPerformanceForPlayer(p);
         },MapFold.FOLD_MAX);
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return getPerformanceForPlayer(p) == maxPerformance;
         });
      }
      
      public function handleActionSetPromptShown(ref:IActionRef, params:Object) : void
      {
         this._promptShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetProgressShown(ref:IActionRef, params:Object) : void
      {
         this._progressShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         this._interaction.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionRequestNewAnswerForClue(ref:IActionRef, params:Object) : void
      {
         var unguessedAnswersWithClues:Array = this._answersWithCluesWeHaventHintedAt.filter(function(a:TypingListAnswerData, ... args):Boolean
         {
            return _playersThatGuessedAnswerIndex[a.index].length == 0;
         });
         if(unguessedAnswersWithClues.length == 0)
         {
            this._requestedAnswerForClue = null;
            ref.end();
            return;
         }
         this._requestedAnswerForClue = ArrayUtil.getRandomElement(unguessedAnswersWithClues);
         ArrayUtil.removeElementFromArray(this._answersWithCluesWeHaventHintedAt,this._requestedAnswerForClue);
         ref.end();
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrame(_mc.answers,"Layout" + this._content.answers.length);
         this._answerWidgetsInPlay = this._answerWidgets.slice(0,this._content.answers.length);
         this._answerWidgetsInPlay.forEach(function(widget:TypingListAnswerWidget, i:int, a:Array):void
         {
            widget.setup(_content.answers[i],_playersThatGuessedAnswerIndex[i]);
         });
         ref.end();
      }
      
      private function _getAnswerWidgetsFromString(s:String) : Array
      {
         if(s == "all")
         {
            return this._answerWidgetsInPlay;
         }
         if(s == "guessed")
         {
            return this._answerWidgetsInPlay.filter(function(w:TypingListAnswerWidget, ... args):Boolean
            {
               return w.wasGuessed;
            });
         }
         if(s == "not-guessed")
         {
            return this._answerWidgetsInPlay.filter(function(w:TypingListAnswerWidget, ... args):Boolean
            {
               return !w.wasGuessed;
            });
         }
         if(s == "guessed-uniquely")
         {
            return this._answerWidgetsInPlay.filter(function(w:TypingListAnswerWidget, ... args):Boolean
            {
               return w.wasGuessedUniquely;
            });
         }
         if(s == "guessed-nonuniquely")
         {
            return this._answerWidgetsInPlay.filter(function(w:TypingListAnswerWidget, ... args):Boolean
            {
               return w.wasGuessed && !w.wasGuessedUniquely;
            });
         }
         Assert.assert(false);
         return [];
      }
      
      public function handleActionSetAnswersShown(ref:IActionRef, params:Object) : void
      {
         MovieClipShower.setMultiple(this._getAnswerWidgetsFromString(params.answers),params.isShown,Duration.fromSec(0.1),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetAnswersDimmed(ref:IActionRef, params:Object) : void
      {
         this._getAnswerWidgetsFromString(params.answers).forEach(function(w:TypingListAnswerWidget, ... args):void
         {
            w.setDimmed(params.isDimmed);
         });
         ref.end();
      }
      
      public function handleActionUpdateToFinalScore(ref:IActionRef, params:Object) : void
      {
         this.playersWithUniqueAnswers.forEach(function(p:Player, ... args):void
         {
            p.widget.updateResult(getPerformanceForPlayer(p));
         });
         ref.end();
      }
      
      public function getMappedGuesses(p:Player) : Array
      {
         var booleanArray:Array = null;
         booleanArray = new Array();
         this._content.answers.forEach(function(ans:TypingListAnswerData, i:int, a:Array):void
         {
            booleanArray.push(ArrayUtil.arrayContainsElement(_playersThatGuessedAnswerIndex[i],p));
         });
         return booleanArray;
      }
      
      public function playerHasGuessed(p:Player, answerIndex:int) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._playersThatGuessedAnswerIndex[answerIndex],p);
      }
      
      public function onPlayerGuessedCorrect(p:Player, answerIndex:int) : void
      {
         var formerlyUniquePlayer:Player = null;
         if(ArrayUtil.arrayContainsElement(this._playersThatGuessedAnswerIndex[answerIndex],p))
         {
            return;
         }
         var targetArray:Array = this._playersThatGuessedAnswerIndex[answerIndex];
         this._numCorrectPerPlayer.incrementDataForPlayer(p);
         if(targetArray.length == 0)
         {
            this._uniqueCorrectPerPlayer.incrementDataForPlayer(p);
         }
         else if(targetArray.length == 1)
         {
            formerlyUniquePlayer = ArrayUtil.first(targetArray);
            this._uniqueCorrectPerPlayer.setDataForPlayer(formerlyUniquePlayer,this._uniqueCorrectPerPlayer.getDataForPlayer(formerlyUniquePlayer) - 1);
            formerlyUniquePlayer.widget.updateResult(this._numCorrectPerPlayer.getDataForPlayer(formerlyUniquePlayer));
            formerlyUniquePlayer.widget.updateUniqueResult(this._uniqueCorrectPerPlayer.getDataForPlayer(formerlyUniquePlayer));
         }
         targetArray.push(p);
         this._progressWidgetsInPlay[answerIndex].update(targetArray);
         p.widget.updateResult(this._numCorrectPerPlayer.getDataForPlayer(p));
         p.widget.updateUniqueResult(this._uniqueCorrectPerPlayer.getDataForPlayer(p));
      }
      
      public function onPlayerGuessedIncorrect(p:Player, answer:String) : void
      {
         p.widget.showTemporaryAnswer(answer);
      }
      
      public function onPlayerGuessedCorrectButGuessedAlready(p:Player, correctAnswerIndex:int) : void
      {
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.thewheel.data.TypingListAnswerData;
import jackboxgames.utils.JBGUtil;

class TypingListProgressWidget
{
   private var _mc:MovieClip;
   
   public function TypingListProgressWidget(mc:MovieClip)
   {
      super();
      this._mc = mc;
   }
   
   public function reset() : void
   {
      JBGUtil.gotoFrame(this._mc,"Default");
   }
   
   public function setup(answer:TypingListAnswerData) : void
   {
      JBGUtil.gotoFrame(this._mc,"Default");
   }
   
   public function update(playersWhoGuessed:Array) : void
   {
      JBGUtil.gotoFrame(this._mc,playersWhoGuessed.length > 0 ? "Guessed" : "Default");
   }
}

import flash.display.MovieClip;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.utils.*;

class TypingListAnswerWidget
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _tf:ExtendableTextField;
   
   private var _isDimmed:Boolean;
   
   private var _lastPlayersWhoGuessed:Array;
   
   public function TypingListAnswerWidget(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
      this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.container.text);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function get wasGuessed() : Boolean
   {
      return this._lastPlayersWhoGuessed.length > 0;
   }
   
   public function get wasGuessedUniquely() : Boolean
   {
      return this._lastPlayersWhoGuessed.length == 1;
   }
   
   public function reset() : void
   {
      JBGUtil.reset([this._shower]);
      this._isDimmed = false;
      this._lastPlayersWhoGuessed = [];
      this._updateVisuals();
   }
   
   public function setup(answer:TypingListAnswerData, playersWhoGuessed:Array) : void
   {
      this._tf.text = answer.text;
      this._lastPlayersWhoGuessed = playersWhoGuessed;
      this._updateVisuals();
   }
   
   public function setDimmed(val:Boolean) : void
   {
      if(this._isDimmed == val)
      {
         return;
      }
      this._isDimmed = val;
      this._updateVisuals();
   }
   
   private function _updateVisuals() : void
   {
      var frame:String = !!this.wasGuessed ? "Guessed" : "NotGuessed";
      if(this._isDimmed)
      {
         frame += "Dim";
      }
      JBGUtil.gotoFrame(this._mc.container,frame);
   }
}

