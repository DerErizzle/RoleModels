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
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class TappingList extends TriviaTypeActionPackage implements ITappingListBehaviorDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _promptShower:MovieClipShower;
      
      private var _promptTf:ExtendableTextField;
      
      private var _answerWidgets:Array;
      
      private var _content:TappingListData;
      
      private var _availableChoices:Array;
      
      private var _numCorrectSelectedPerPlayer:PerPlayerContainer;
      
      private var _playerChoices:PerPlayerContainer;
      
      private var _answerWidgetsInPlay:Array;
      
      public function TappingList(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _linkage() : String
      {
         return "TappingList";
      }
      
      override protected function get _triviaType() : TriviaType
      {
         return GameConstants.TRIVIA_TYPE_TAPPING_LIST;
      }
      
      public function get content() : TappingListData
      {
         return this._content;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._promptShower = new MovieClipShower(_mc.prompt);
         this._promptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.prompt.text);
         this._interaction = new EntityInteractionHandler(new TappingListBehavior(this),GameState.instance,false,false);
         this._answerWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc,"answer").map(function(answerMc:MovieClip, ... args):TappingListAnswerWidget
         {
            return new TappingListAnswerWidget(answerMc);
         });
      }
      
      override public function setup() : void
      {
         this._content = TappingListData(GameState.instance.currentTriviaData.content);
         this._availableChoices = ArrayUtil.getRandomElements(this._content.decoys,Math.min(this._content.decoys.length,6)).concat(ArrayUtil.getRandomElements(this._content.answers,GameState.instance.jsonData.gameConfig.tappingListChoicesCount - this._content.decoys.length));
         this._availableChoices = ArrayUtil.shuffled(this._availableChoices);
         this._promptTf.text = this._content.prompt;
         this._playerChoices = new PerPlayerContainer();
         this._numCorrectSelectedPerPlayer = new PerPlayerContainer();
         GameState.instance.players.forEach(function(p:Player, i:int, a:Array):void
         {
            _playerChoices.setDataForPlayer(p,ArrayUtil.makeArray(_availableChoices.length,ETappingListValue.FALSE));
            _numCorrectSelectedPerPlayer.setDataForPlayer(p,0);
         });
         this._answerWidgetsInPlay = this._answerWidgets.slice(0,this._availableChoices.length);
         this._answerWidgetsInPlay.forEach(function(widget:TappingListAnswerWidget, i:int, a:Array):void
         {
            widget.setup(_availableChoices[i]);
         });
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            p.widget.setBestPerformanceLabel("HIGH_SCORE");
         });
      }
      
      override protected function _doReset() : void
      {
         JBGUtil.reset([this._interaction,this._promptShower]);
         JBGUtil.reset(this._answerWidgets);
      }
      
      override public function getPerformanceForPlayer(p:Player) : int
      {
         return this._numCorrectSelectedPerPlayer.getDataForPlayer(p);
      }
      
      override public function getPlayersEligibleForBonusSlice() : Array
      {
         var maxCorrect:int = 0;
         maxCorrect = MapFold.process(GameState.instance.players,function(p:Player, ... args):int
         {
            return _numCorrectSelectedPerPlayer.getDataForPlayer(p);
         },MapFold.FOLD_MAX);
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return _numCorrectSelectedPerPlayer.getDataForPlayer(p) == maxCorrect;
         });
      }
      
      override public function doBehavior(behavior:String, doneFn:Function) : void
      {
         if(behavior == "Reveal")
         {
            this._answerWidgetsInPlay.forEach(function(widget:TappingListAnswerWidget, i:int, a:Array):void
            {
               widget.reveal();
            });
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_TAPPING_LIST_REVEAL",this._availableChoices.filter(function(choice:TappingListChoiceData, ... args):Boolean
            {
               return choice.val == ETappingListValue.TRUE;
            }).map(function(choice:TappingListChoiceData, ... args):String
            {
               return choice.text;
            }).join(", "));
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_TAPPING_LIST_PLAYER_RESULT",TheWheelTextUtil.formattedPlayerName(p),_numCorrectSelectedPerPlayer.getDataForPlayer(p));
            });
            GameState.instance.textDescriptions.updateEntity();
            doneFn();
         }
         else
         {
            doneFn();
         }
      }
      
      public function handleActionSetPromptShown(ref:IActionRef, params:Object) : void
      {
         this._promptShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetChoicesShown(ref:IActionRef, params:Object) : void
      {
         MovieClipShower.setMultiple(this._answerWidgetsInPlay,params.isShown,Duration.fromSec(0.1),TSUtil.createRefEndFn(ref));
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
         var highestScore:int;
         this._availableChoices.forEach(function(choice:TappingListChoiceData, i:int, a:Array):void
         {
            GameState.instance.players.forEach(function(p:Player, j:int, b:Array):void
            {
               if(choice.val == _playerChoices.getDataForPlayer(p)[i])
               {
                  _numCorrectSelectedPerPlayer.incrementDataForPlayer(p);
               }
            });
         });
         highestScore = 0;
         GameState.instance.players.forEach(function(p:Player, i:int, a:Array):void
         {
            p.widget.setResultViewMode(PlayerWidget.RESULT_VIEW_MODE_STANDARD);
            p.widget.updateResult(_numCorrectSelectedPerPlayer.getDataForPlayer(p));
         });
         ref.end();
      }
      
      public function getAnswers(p:Player) : Array
      {
         var playerChoices:Array = [];
         for(var i:int = 0; i < this._availableChoices.length; i++)
         {
            playerChoices.push({
               "text":this._availableChoices[i].text,
               "isSelected":this._playerChoices.getDataForPlayer(p)[i] == ETappingListValue.TRUE
            });
         }
         return playerChoices;
      }
      
      public function setAnswer(p:Player, index:int, value:Boolean) : void
      {
         var pChoices:Array = this._playerChoices.getDataForPlayer(p);
         pChoices[index] = value ? ETappingListValue.TRUE : ETappingListValue.FALSE;
      }
      
      public function onPlayerIsDone(p:Player) : void
      {
         p.widget.setAnswering(false);
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.gameplay.ETappingListValue;
import jackboxgames.thewheel.utils.*;
import jackboxgames.utils.*;

class TappingListAnswerWidget
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _tf:ExtendableTextField;
   
   private var _choice:TappingListChoiceData;
   
   public function TappingListAnswerWidget(mc:MovieClip)
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
   
   public function reset() : void
   {
      JBGUtil.reset([this._shower]);
      JBGUtil.gotoFrame(this._mc.container,"Default");
      this._choice = null;
   }
   
   public function setup(choice:TappingListChoiceData) : void
   {
      this._choice = choice;
      this._tf.text = this._choice.text;
      JBGUtil.gotoFrame(this._mc.container,"Default");
   }
   
   public function reveal() : void
   {
      JBGUtil.gotoFrame(this._mc.container,this._choice.val == ETappingListValue.TRUE ? "Reveal" : "RevealDecoy");
   }
}

