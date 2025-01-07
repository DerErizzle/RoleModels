package jackboxgames.thewheel.actionpackages.triviatypes
{
   import flash.display.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.model.*;
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
   
   public class Matching extends TriviaTypeActionPackage implements IMatchingBehaviorDelegate
   {
      private var _interaction:EntityInteractionHandler;
      
      private var _promptShower:MovieClipShower;
      
      private var _promptTf:ExtendableTextField;
      
      private var _preview:MatchingPreviewWidget;
      
      private var _answerWidgets:Array;
      
      private var _content:MatchingData;
      
      private var _chosenAnswers:Array;
      
      private var _itemsA:Array;
      
      private var _itemsB:Array;
      
      private var _answerWidgetsInPlay:Array;
      
      private var _playerIsFrozen:PerPlayerContainer;
      
      private var _freezeCancellers:PerPlayerContainer;
      
      private var _answersMatched:PerPlayerContainer;
      
      public function Matching(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _linkage() : String
      {
         return "Matching";
      }
      
      override protected function get _triviaType() : TriviaType
      {
         return GameConstants.TRIVIA_TYPE_MATCHING;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._interaction = new EntityInteractionHandler(new MatchingBehavior(this),GameState.instance,false,false);
         this._promptShower = new MovieClipShower(_mc.prompt);
         this._promptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.prompt.text);
         this._preview = new MatchingPreviewWidget(_mc.preview);
         this._answerWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc.answers,"answer").map(function(answerMc:MovieClip, ... args):MatchingAnswerWidget
         {
            return new MatchingAnswerWidget(answerMc);
         });
      }
      
      private function _playerHasMatchedItem(p:Player, item:MatchingItem) : Boolean
      {
         return ArrayUtil.arrayContainsElement(this._answersMatched.getDataForPlayer(p),item.source);
      }
      
      public function get content() : MatchingData
      {
         return this._content;
      }
      
      override public function setup() : void
      {
         var a:MatchingAnswerData = null;
         this._content = MatchingData(GameState.instance.currentTriviaData.content);
         this._promptTf.text = this._content.prompt;
         this._chosenAnswers = ArrayUtil.getRandomElements(this._content.answers,Math.min(GameState.instance.jsonData.gameConfig.matchingNumAnswers,this._content.answers.length));
         this._itemsA = [];
         this._itemsB = [];
         for each(a in this._chosenAnswers)
         {
            this._itemsA.push(new MatchingItem(a.text,a));
            this._itemsB.push(new MatchingItem(a.match,a));
         }
         this._itemsA = ArrayUtil.shuffled(this._itemsA);
         this._itemsB = ArrayUtil.shuffled(this._itemsB);
         this._freezeCancellers = new PerPlayerContainer();
         this._playerIsFrozen = new PerPlayerContainer();
         this._answersMatched = PerPlayerContainerUtil.MAP(GameState.instance.players,function(p:Player, ... args):Array
         {
            return [];
         });
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            p.widget.setBestPerformanceLabel("HIGH_SCORE");
            p.widget.setResultViewMode(PlayerWidget.RESULT_VIEW_MODE_STANDARD);
            p.widget.updateResult(0);
         });
         this._preview.setup(this._content);
      }
      
      override protected function _doReset() : void
      {
         JBGUtil.reset([this._interaction]);
         JBGUtil.reset([this._promptShower,this._preview]);
         JBGUtil.gotoFrame(_mc.answers,"Park");
         JBGUtil.reset(this._answerWidgets);
         this._disposeOfFreezeCancellers();
         this._answerWidgetsInPlay = [];
      }
      
      override public function getPerformanceForPlayer(p:Player) : int
      {
         return this._answersMatched.getDataForPlayer(p).length;
      }
      
      override public function getPlayersEligibleForBonusSlice() : Array
      {
         var max:int = 0;
         max = MapFold.process(GameState.instance.players,function(p:Player, ... args):int
         {
            return _answersMatched.getDataForPlayer(p).length;
         },MapFold.FOLD_MAX);
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return _answersMatched.getDataForPlayer(p).length == max;
         });
      }
      
      override public function doBehavior(behavior:String, doneFn:Function) : void
      {
         if(behavior == "Answering")
         {
            doneFn();
         }
         else if(behavior == "Reveal")
         {
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_MATCHING_REVEAL",this._chosenAnswers.map(function(ans:MatchingAnswerData, ... args):String
            {
               return ans.text + " + " + ans.match;
            }).join(","));
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_MATCHING_PLAYER_RESULT",TheWheelTextUtil.formattedPlayerName(p),_answersMatched.getDataForPlayer(p).length);
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
      
      public function handleActionSetInteractionActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         else
         {
            this._disposeOfFreezeCancellers();
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               if(_playerIsFrozen.getDataForPlayer(p))
               {
                  p.widget.setFrozen(false);
               }
            });
         }
         this._preview.setActive(params.isActive);
         this._interaction.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPreviewShown(ref:IActionRef, params:Object) : void
      {
         this._preview.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupReveal(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrame(_mc.answers,"Layout" + this._chosenAnswers.length);
         this._answerWidgetsInPlay = this._answerWidgets.slice(0,this._chosenAnswers.length);
         ArrayUtil.parallelForEach(function(answerWidget:MatchingAnswerWidget, answerData:MatchingAnswerData):void
         {
            answerWidget.setup(answerData);
         },this._answerWidgetsInPlay,this._chosenAnswers);
         ref.end();
      }
      
      public function handleActionSetAnswersShown(ref:IActionRef, params:Object) : void
      {
         MovieClipShower.setMultiple(this._answerWidgetsInPlay,params.isShown,Duration.fromSec(0.1),TSUtil.createRefEndFn(ref));
      }
      
      public function getControllerItemsForPlayer(p:Player) : Array
      {
         var mapper:Function = null;
         mapper = function(item:MatchingItem, ... args):Object
         {
            return {
               "text":item.text,
               "isAccepted":_playerHasMatchedItem(p,item)
            };
         };
         return [this._itemsA.map(mapper),this._itemsB.map(mapper)];
      }
      
      public function playerTriedToMatch(p:Player, itemIndexA:int, itemIndexB:int) : Boolean
      {
         var itemA:MatchingItem;
         var itemB:MatchingItem;
         if(!NumberUtil.isValidIndexForArray(itemIndexA,this._itemsA) || !NumberUtil.isValidIndexForArray(itemIndexB,this._itemsB))
         {
            return false;
         }
         itemA = this._itemsA[itemIndexA];
         itemB = this._itemsB[itemIndexB];
         if(ArrayUtil.arrayContainsElement(this._answersMatched.getDataForPlayer(p),itemA.source))
         {
            return false;
         }
         if(itemA.source == itemB.source)
         {
            this._answersMatched.getDataForPlayer(p).push(itemA.source);
            p.widget.updateResult(this._answersMatched.getDataForPlayer(p).length);
            if(this.playerHasMatchedAll(p))
            {
               p.widget.setAnswering(false);
            }
            return true;
         }
         this._playerIsFrozen.setDataForPlayer(p,true);
         p.widget.setFrozen(true);
         this._freezeCancellers.setDataForPlayer(p,JBGUtil.runFunctionAfter(function():void
         {
            _playerIsFrozen.setDataForPlayer(p,false);
            p.widget.setFrozen(false);
            _freezeCancellers.setDataForPlayer(p,Nullable.NULL_FUNCTION);
            _interaction.forceUpdateEntities(new EntityUpdateRequest().withPlayerMainEntity(p));
         },GameState.instance.jsonData.gameConfig.matchingFreezeTime));
         return false;
      }
      
      public function playerIsFrozen(p:JBGPlayer) : Boolean
      {
         return this._playerIsFrozen.getDataForPlayer(p);
      }
      
      private function _disposeOfFreezeCancellers() : void
      {
         if(Boolean(this._freezeCancellers))
         {
            this._freezeCancellers.forEach(function(f:Function, ... args):void
            {
               f();
            });
         }
         this._freezeCancellers = null;
      }
      
      public function playerHasMatchedAll(p:Player) : Boolean
      {
         return this._answersMatched.getDataForPlayer(p).length == this._chosenAnswers.length;
      }
   }
}

import jackboxgames.thewheel.data.MatchingAnswerData;

class MatchingItem
{
   private var _text:String;
   
   private var _source:MatchingAnswerData;
   
   public function MatchingItem(text:String, source:MatchingAnswerData)
   {
      super();
      this._text = text;
      this._source = source;
   }
   
   public function get text() : String
   {
      return this._text;
   }
   
   public function get source() : MatchingAnswerData
   {
      return this._source;
   }
}

import flash.display.MovieClip;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.utils.*;

class MatchingAnswerWidget
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _leftTf:ExtendableTextField;
   
   private var _rightTf:ExtendableTextField;
   
   public function MatchingAnswerWidget(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
      this._leftTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.left);
      this._rightTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.right);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function reset() : void
   {
      this._shower.reset();
   }
   
   public function setup(data:MatchingAnswerData) : void
   {
      this._leftTf.text = data.text;
      this._rightTf.text = data.match;
   }
}

import flash.display.MovieClip;
import flash.events.TimerEvent;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.utils.*;

class MatchingPreviewWidget
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _leftTitle:ExtendableTextField;
   
   private var _rightTitle:ExtendableTextField;
   
   private var _leftItemWidgets:Array;
   
   private var _rightItemWidgets:Array;
   
   private var _isActive:Boolean;
   
   private var _data:MatchingData;
   
   private var _randomizedLeftItems:Array;
   
   private var _randomizedRightItems:Array;
   
   private var _leftIndex:int;
   
   private var _rightIndex:int;
   
   private var _leftActive:Array;
   
   private var _rightActive:Array;
   
   private var _timer:PausableTimer;
   
   public function MatchingPreviewWidget(mc:MovieClip)
   {
      var itemMapper:Function = null;
      super();
      itemMapper = function(itemMc:MovieClip, ... args):MatchingPreviewItemWidget
      {
         return new MatchingPreviewItemWidget(itemMc);
      };
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
      this._leftTitle = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.leftTitle);
      this._rightTitle = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.rightTitle);
      this._leftItemWidgets = JBGUtil.getPropertiesOfNameInOrder(this._mc,"left").map(itemMapper);
      this._rightItemWidgets = JBGUtil.getPropertiesOfNameInOrder(this._mc,"right").map(itemMapper);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function reset() : void
   {
      this.setActive(false);
      this._shower.reset();
      this._data = null;
   }
   
   public function setup(data:MatchingData) : void
   {
      var i:int = 0;
      this._data = data;
      this._leftTitle.text = this._data.header.text;
      this._rightTitle.text = this._data.header.match;
      this._randomizedLeftItems = ArrayUtil.shuffled(this._data.answers.map(function(ans:MatchingAnswerData, ... args):String
      {
         return ans.text;
      }));
      this._randomizedRightItems = ArrayUtil.shuffled(this._data.answers.map(function(ans:MatchingAnswerData, ... args):String
      {
         return ans.match;
      }));
      this._leftIndex = this._rightIndex = 0;
      this._leftActive = [];
      this._rightActive = [];
      for(i = 0; i < this._leftItemWidgets.length; i++)
      {
         this._leftActive.push(this._pullNextLeftText());
      }
      for(i = 0; i < this._rightItemWidgets.length; i++)
      {
         this._rightActive.push(this._pullNextRightText());
      }
      this._setText();
   }
   
   private function _pullNextLeftText() : String
   {
      var index:int = int(this._leftIndex);
      ++this._leftIndex;
      if(this._leftIndex >= this._randomizedLeftItems.length)
      {
         this._leftIndex = 0;
      }
      return this._randomizedLeftItems[index];
   }
   
   private function _pullNextRightText() : String
   {
      var index:int = int(this._rightIndex);
      ++this._rightIndex;
      if(this._rightIndex >= this._randomizedRightItems.length)
      {
         this._rightIndex = 0;
      }
      return this._randomizedRightItems[index];
   }
   
   private function _setText() : void
   {
      var i:int = 0;
      for(i = 0; i < this._leftItemWidgets.length; i++)
      {
         this._leftItemWidgets[i].setText(this._leftActive[i]);
      }
      for(i = 0; i < this._rightItemWidgets.length; i++)
      {
         this._rightItemWidgets[i].setText(this._rightActive[i]);
      }
   }
   
   public function setActive(val:Boolean) : void
   {
      if(this._isActive == val)
      {
         return;
      }
      this._isActive = val;
      if(this._isActive)
      {
         this._timer = new PausableTimer(GameState.instance.jsonData.gameConfig.matchingCycleTime.inMs);
         this._timer.addEventListener(TimerEvent.TIMER,this._onTimer);
         this._timer.start();
      }
      else
      {
         this._timer.stop();
         this._timer = null;
      }
   }
   
   private function _onTimer(evt:TimerEvent) : void
   {
      this._cycle();
   }
   
   private function _cycle() : void
   {
      this._leftActive.splice(this._leftActive.length - 1,1);
      this._leftActive.unshift(this._pullNextLeftText());
      this._rightActive.splice(this._rightActive.length - 1,1);
      this._rightActive.unshift(this._pullNextRightText());
      this._setText();
      this._shower.doAnimation("Cycle",Nullable.NULL_FUNCTION);
   }
}

import flash.display.MovieClip;
import jackboxgames.text.ETFHelperUtil;
import jackboxgames.text.ExtendableTextField;

class MatchingPreviewItemWidget
{
   private var _mc:MovieClip;
   
   private var _tf:ExtendableTextField;
   
   public function MatchingPreviewItemWidget(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc);
   }
   
   public function setText(text:String) : void
   {
      this._tf.text = text;
   }
}

