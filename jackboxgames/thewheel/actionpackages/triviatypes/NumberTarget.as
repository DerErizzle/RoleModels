package jackboxgames.thewheel.actionpackages.triviatypes
{
   import flash.display.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.entityinteraction.*;
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
   
   public class NumberTarget extends TriviaTypeActionPackage implements INumberTargetBehaviorDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _promptShower:MovieClipShower;
      
      private var _promptTf:ExtendableTextField;
      
      private var _unitShower:MovieClipShower;
      
      private var _unitTf:ExtendableTextField;
      
      private var _answerWidget:NumberTargetAnswerWidget;
      
      private var _content:NumberTargetData;
      
      private var _playerGuesses:PerPlayerContainer;
      
      private var _distance:PerPlayerContainer;
      
      public function NumberTarget(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _linkage() : String
      {
         return "NumberTarget";
      }
      
      override protected function get _triviaType() : TriviaType
      {
         return GameConstants.TRIVIA_TYPE_NUMBER_TARGET;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._interaction = new EntityInteractionHandler(new NumberTargetBehavior(this),GameState.instance,false,false);
         this._promptShower = new MovieClipShower(_mc.prompt);
         this._promptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.prompt.text);
         this._unitShower = new MovieClipShower(_mc.unit);
         this._unitTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.unit.text);
         this._answerWidget = new NumberTargetAnswerWidget(_mc.answer);
      }
      
      public function get content() : NumberTargetData
      {
         return this._content;
      }
      
      override public function setup() : void
      {
         this._content = NumberTargetData(GameState.instance.currentTriviaData.content);
         this._promptTf.text = this._content.prompt;
         this._playerGuesses = PerPlayerContainerUtil.MAP(GameState.instance.players,function(p:Player, ... args):int
         {
            return 0;
         });
         this._distance = new PerPlayerContainer();
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            p.widget.setBestPerformanceLabel("HIGH_SCORE");
         });
      }
      
      override protected function _doReset() : void
      {
         JBGUtil.reset([this._interaction,this._promptShower,this._unitShower,this._answerWidget]);
      }
      
      override public function getPerformanceForPlayer(p:Player) : int
      {
         return int.MAX_VALUE - this._distance.getDataForPlayer(p);
      }
      
      override public function getPlayersEligibleForBonusSlice() : Array
      {
         var bestDistance:int = 0;
         bestDistance = MapFold.process(GameState.instance.players,function(p:Player, ... args):int
         {
            return _distance.getDataForPlayer(p);
         },MapFold.FOLD_MIN);
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return _distance.getDataForPlayer(p) == bestDistance;
         });
      }
      
      override public function doBehavior(behavior:String, doneFn:Function) : void
      {
         if(behavior == "Reveal")
         {
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_NUMBER_TARGET_REVEAL",this._content.answer);
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_NUMBER_TARGET_PLAYER_RESULT",TheWheelTextUtil.formattedPlayerName(p),_playerGuesses.getDataForPlayer(p));
            });
            GameState.instance.textDescriptions.updateEntity();
         }
         doneFn();
      }
      
      public function handleActionSetPromptShown(ref:IActionRef, params:Object) : void
      {
         this._promptShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetUnitShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._unitTf.text = this._content.unit;
         }
         this._unitShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         this._interaction.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         var correctAnswer:int = 0;
         correctAnswer = this.content.answer;
         GameState.instance.players.forEach(function(p:Player, i:int, a:Array):void
         {
            var answer:int = _playerGuesses.getDataForPlayer(p);
            var distance:int = Math.abs(answer - correctAnswer);
            p.widget.setResultViewMode(PlayerWidget.RESULT_VIEW_MODE_WIDE);
            p.widget.updateResult(answer);
            _distance.setDataForPlayer(p,distance);
         });
         this._answerWidget.setup(this._content.answer);
         ref.end();
      }
      
      public function onPlayerGuessChanged(p:Player, guess:int) : void
      {
         this._playerGuesses.setDataForPlayer(p,guess);
      }
      
      public function onPlayerSubmittedGuess(p:Player) : void
      {
         p.widget.setAnswering(false);
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.utils.*;

class NumberTargetAnswerWidget
{
   private var _mc:MovieClip;
   
   private var _tf:ExtendableTextField;
   
   public function NumberTargetAnswerWidget(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.container.text);
   }
   
   public function reset() : void
   {
   }
   
   public function setup(answer:int) : void
   {
      this._tf.text = answer.toString();
   }
}

