package jackboxgames.thewheel.actionpackages.triviatypes
{
   import flash.display.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class Guessing extends TriviaTypeActionPackage implements IGuessingBehaviorDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _promptShower:MovieClipShower;
      
      private var _promptTf:ExtendableTextField;
      
      private var _clueShower:MovieClipShower;
      
      private var _clueTf:ExtendableTextField;
      
      private var _answerShower:MovieClipShower;
      
      private var _answerTf:ExtendableTextField;
      
      private var _content:GuessingData;
      
      private var _guessDurations:PerPlayerContainer;
      
      private var _cluesGiven:Array;
      
      private var _timerAtStartOfInteraction:uint;
      
      private var _currentlyShowingClueIndex:int;
      
      public function Guessing(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _linkage() : String
      {
         return "Guessing";
      }
      
      override protected function get _triviaType() : TriviaType
      {
         return GameConstants.TRIVIA_TYPE_GUESSING;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._interaction = new EntityInteractionHandler(new GuessingBehavior(this),GameState.instance,false,false,false);
         this._promptShower = new MovieClipShower(_mc.prompt);
         this._promptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.prompt.text);
         this._clueShower = new MovieClipShower(_mc.clue);
         this._clueTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.clue.text);
         this._answerShower = new MovieClipShower(_mc.answer);
         this._answerTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.answer.container.text);
      }
      
      public function get content() : GuessingData
      {
         return this._content;
      }
      
      public function get currentlyShowingClueIndex() : int
      {
         return this._currentlyShowingClueIndex;
      }
      
      override public function setup() : void
      {
         this._content = GuessingData(GameState.instance.currentTriviaData.content);
         this._guessDurations = new PerPlayerContainer();
         this._cluesGiven = [];
         this._currentlyShowingClueIndex = 0;
         this._promptTf.text = this._content.prompt;
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            p.widget.setBestPerformanceLabel("FASTEST_ANSWER");
         });
      }
      
      override protected function _doReset() : void
      {
         JBGUtil.reset([this._interaction,this._promptShower,this._clueShower,this._answerShower]);
      }
      
      private function _getGuessDurationForPlayer(p:Player) : Duration
      {
         return this._guessDurations.hasDataForPlayer(p) ? this._guessDurations.getDataForPlayer(p) : Duration.fromMs(int.MAX_VALUE);
      }
      
      override public function getPerformanceForPlayer(p:Player) : int
      {
         return int.MAX_VALUE - this._getGuessDurationForPlayer(p).inMs;
      }
      
      override public function getPlayersEligibleForBonusSlice() : Array
      {
         var minDuration:Duration = null;
         minDuration = MapFold.process(GameState.instance.players,function(p:Player, ... args):Duration
         {
            return _getGuessDurationForPlayer(p);
         },function(a:Duration, b:Duration):Duration
         {
            return a.isLessThan(b) ? a : b;
         });
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            var gd:* = _getGuessDurationForPlayer(p);
            return gd.isEqualTo(minDuration);
         });
      }
      
      override public function doBehavior(behavior:String, doneFn:Function) : void
      {
         var correctPlayers:Array = null;
         if(behavior == "Reveal")
         {
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_GUESSING_REVEAL",this._content.answer);
            correctPlayers = GameState.instance.players.filter(function(p:Player, ... args):Boolean
            {
               return _guessDurations.hasDataForPlayer(p);
            });
            if(correctPlayers.length > 0)
            {
               correctPlayers.forEach(function(p:Player, ... args):void
               {
                  GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_GUESSING_PLAYER_RESULT",TheWheelTextUtil.formattedPlayerName(p),NumberUtil.format(_guessDurations.getDataForPlayer(p).inSec,2));
               });
            }
            else
            {
               GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_GUESSING_PLAYER_NO_ONE");
            }
            GameState.instance.textDescriptions.updateEntity();
         }
         doneFn();
      }
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
            this._timerAtStartOfInteraction = Platform.instance.getTimer();
         }
         this._interaction.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      private function _setClueTextToCurrent() : void
      {
         this._clueTf.text = GuessingClueData(this._content.clues[this._currentlyShowingClueIndex]).text;
         this._cluesGiven = [];
         for(var i:int = 0; i < this._currentlyShowingClueIndex + 1; i++)
         {
            this._cluesGiven.push(this._content.clues[i].text);
         }
         this._interaction.forceUpdateEntities(new EntityUpdateRequest().withPlayerMainEntity(GameState.instance.players));
      }
      
      public function handleActionSetPromptShown(ref:IActionRef, params:Object) : void
      {
         this._promptShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetClueShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._setClueTextToCurrent();
         }
         this._clueShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionUpdateToNextClue(ref:IActionRef, params:Object) : void
      {
         ++this._currentlyShowingClueIndex;
         this._setClueTextToCurrent();
         this._clueShower.doAnimation("Update",Nullable.NULL_FUNCTION);
         ref.end();
      }
      
      public function handleActionSetAnswerShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._answerTf.text = this._content.answer;
         }
         this._answerShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function get revealedClues() : Array
      {
         return this._cluesGiven;
      }
      
      public function onPlayerGuessed(p:Player, guess:String) : void
      {
         var durationInMs:uint = 0;
         var d:Duration = null;
         if(this._content.isCorrectGuess(guess))
         {
            durationInMs = uint(Platform.instance.getTimer() - this._timerAtStartOfInteraction);
            d = Duration.fromMs(durationInMs);
            this._guessDurations.setDataForPlayer(p,d);
            p.widget.setResultViewMode(PlayerWidget.RESULT_VIEW_MODE_STANDARD);
            p.widget.updateResultWithDuration(d);
            p.widget.setResultsShown(true);
            p.widget.setAnswering(false);
         }
         else
         {
            p.widget.showTemporaryAnswer(guess);
         }
      }
      
      public function hasPlayerGuessed(p:Player) : Boolean
      {
         return this._guessDurations.hasDataForPlayer(p);
      }
   }
}

