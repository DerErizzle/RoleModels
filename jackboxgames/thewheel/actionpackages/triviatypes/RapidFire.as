package jackboxgames.thewheel.actionpackages.triviatypes
{
   import jackboxgames.algorithm.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.model.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public class RapidFire extends TriviaTypeActionPackage implements IRapidFireBehaviorDelegate
   {
      private var _promptShower:MovieClipShower;
      
      private var _promptTf:ExtendableTextField;
      
      private var _preview:RapidFirePreviewWidget;
      
      private var _interaction:EntityInteractionHandler;
      
      private var _content:RapidFireData;
      
      private var _numCorrectPerPlayer:PerPlayerContainer;
      
      private var _numAnsweredPerPlayer:PerPlayerContainer;
      
      private var _choiceSelectorPerPlayer:PerPlayerContainer;
      
      private var _currentChoicesPerPlayer:PerPlayerContainer;
      
      private var _currentCorrectChoiceForPlayer:PerPlayerContainer;
      
      private var _playerIsFrozen:PerPlayerContainer;
      
      private var _freezeCancellers:PerPlayerContainer;
      
      public function RapidFire(apRef:IActionPackageRef)
      {
         super(apRef);
      }
      
      override protected function get _linkage() : String
      {
         return "RapidFire";
      }
      
      override protected function get _triviaType() : TriviaType
      {
         return GameConstants.TRIVIA_TYPE_RAPID_FIRE;
      }
      
      public function get content() : RapidFireData
      {
         return this._content;
      }
      
      override protected function _onLoaded() : void
      {
         super._onLoaded();
         this._promptShower = new MovieClipShower(_mc.prompt);
         this._promptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.prompt.text);
         this._preview = new RapidFirePreviewWidget(_mc.preview);
         this._interaction = new EntityInteractionHandler(new RapidFireBehavior(this),GameState.instance,false,false);
      }
      
      override public function setup() : void
      {
         this._content = RapidFireData(GameState.instance.currentTriviaData.content);
         this._choiceSelectorPerPlayer = new PerPlayerContainer();
         this._currentChoicesPerPlayer = new PerPlayerContainer();
         this._currentCorrectChoiceForPlayer = new PerPlayerContainer();
         this._numAnsweredPerPlayer = new PerPlayerContainer();
         this._numCorrectPerPlayer = new PerPlayerContainer();
         this._freezeCancellers = new PerPlayerContainer();
         this._playerIsFrozen = new PerPlayerContainer();
         GameState.instance.players.forEach(function(p:Player, i:int, a:Array):void
         {
            _choiceSelectorPerPlayer.setDataForPlayer(p,_content.generateSelector());
            _numCorrectPerPlayer.setDataForPlayer(p,0);
            _numAnsweredPerPlayer.setDataForPlayer(p,0);
            _updateChoicesForPlayer(p);
            p.widget.setBestPerformanceLabel("HIGH_SCORE");
            p.widget.setResultViewMode(PlayerWidget.RESULT_VIEW_MODE_STANDARD);
            p.widget.updateResult(0);
         });
         this._promptTf.text = this._content.prompt;
         this._preview.setup(this._content);
      }
      
      override protected function _doReset() : void
      {
         JBGUtil.reset([this._interaction,this._promptShower,this._preview]);
         this._disposeOfFreezeCancellers();
      }
      
      override public function getPerformanceForPlayer(p:Player) : int
      {
         return this._numCorrectPerPlayer.getDataForPlayer(p);
      }
      
      override public function getPlayersEligibleForBonusSlice() : Array
      {
         var maxCorrect:int = 0;
         maxCorrect = MapFold.process(GameState.instance.players,function(p:Player, ... args):int
         {
            return _numCorrectPerPlayer.getDataForPlayer(p);
         },MapFold.FOLD_MAX);
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return _numCorrectPerPlayer.getDataForPlayer(p) == maxCorrect;
         });
      }
      
      override public function doBehavior(behavior:String, doneFn:Function) : void
      {
         if(behavior == "Reveal")
         {
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_RAPID_FIRE_PLAYER_RESULT",TheWheelTextUtil.formattedPlayerName(p),_numCorrectPerPlayer.getDataForPlayer(p));
            });
            GameState.instance.textDescriptions.updateEntity();
         }
         doneFn();
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
         ref.end();
      }
      
      public function onPlayerAnswered(p:Player, chosen:int) : Boolean
      {
         this._numAnsweredPerPlayer.incrementDataForPlayer(p);
         if(chosen == this._currentCorrectChoiceForPlayer.getDataForPlayer(p))
         {
            this._numCorrectPerPlayer.incrementDataForPlayer(p);
            p.widget.updateResult(this._numCorrectPerPlayer.getDataForPlayer(p));
            this._updateChoicesForPlayer(p);
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
         },GameState.instance.jsonData.gameConfig.rapidFireFreezeTime));
         this._updateChoicesForPlayer(p);
         return false;
      }
      
      private function _updateChoicesForPlayer(p:Player) : void
      {
         var choicesTexts:Array;
         var choices:Array = this._content.selectChoices(GameState.instance.jsonData.gameConfig.rapidFireNumChoices,this._choiceSelectorPerPlayer.getDataForPlayer(p));
         this._currentCorrectChoiceForPlayer.setDataForPlayer(p,this._content.getCorrectIndex(choices));
         choicesTexts = choices.map(function(c:RapidFireChoiceData, i:int, a:Array):Object
         {
            return {"text":c.text};
         });
         this._currentChoicesPerPlayer.setDataForPlayer(p,choicesTexts);
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
      
      public function getChoicesForPlayer(p:Player) : Array
      {
         return this._currentChoicesPerPlayer.getDataForPlayer(p);
      }
   }
}

import flash.display.MovieClip;
import jackboxgames.talkshow.utils.*;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.utils.*;

class RapidFirePreviewWidget
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _choiceWidgets:Array;
   
   private var _isActive:Boolean;
   
   private var _content:RapidFireData;
   
   private var _selector:RandomLowRepeat;
   
   private var _currentChoices:Array;
   
   private var _currentCorrectIndex:int;
   
   private var _canceler:Function;
   
   public function RapidFirePreviewWidget(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
      this._choiceWidgets = JBGUtil.getPropertiesOfNameInOrder(this._mc,"choice").map(function(choiceMc:MovieClip, ... args):RapidFirePreviewWidgetChoice
      {
         return new RapidFirePreviewWidgetChoice(choiceMc);
      });
      this._canceler = Nullable.NULL_FUNCTION;
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function reset() : void
   {
      this.setActive(false);
      JBGUtil.reset(this._choiceWidgets);
      this._shower.reset();
      this._canceler();
      this._canceler = Nullable.NULL_FUNCTION;
      this._content = null;
      this._selector = null;
   }
   
   public function setup(data:RapidFireData) : void
   {
      this._content = data;
      this._selector = this._content.generateSelector();
      this._chooseNewContent(false);
   }
   
   private function _chooseNewContent(flip:Boolean) : void
   {
      var i:int = 0;
      this._currentChoices = this._content.selectChoices(this._choiceWidgets.length,this._selector);
      if(this._currentChoices.length < this._choiceWidgets.length)
      {
         for(i = int(this._currentChoices.length); i < this._choiceWidgets.length; i++)
         {
            this._currentChoices.push(ArrayUtil.getRandomElement(this._content.allChoices));
         }
      }
      this._currentCorrectIndex = this._content.getCorrectIndex(this._currentChoices);
      this._choiceWidgets.forEach(function(w:RapidFirePreviewWidgetChoice, i:int, a:Array):void
      {
         w.setup(_currentChoices[i],flip);
      });
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
         this._canceler = JBGUtil.runFunctionAfter(this._reveal,GameState.instance.jsonData.gameConfig.rapidFireTimeBeforePreviewReveal);
      }
      else
      {
         this._canceler();
         this._canceler = Nullable.NULL_FUNCTION;
      }
   }
   
   private function _reveal() : void
   {
      this._choiceWidgets.forEach(function(w:RapidFirePreviewWidgetChoice, i:int, a:Array):void
      {
         w.reveal(i == _currentCorrectIndex);
      });
      this._canceler = JBGUtil.runFunctionAfter(this._flipToNewContent,GameState.instance.jsonData.gameConfig.rapidFireTimeBeforeNextPreview);
   }
   
   private function _flipToNewContent() : void
   {
      this._chooseNewContent(true);
      this._canceler = JBGUtil.runFunctionAfter(this._reveal,GameState.instance.jsonData.gameConfig.rapidFireTimeBeforePreviewReveal);
   }
}

import flash.display.MovieClip;
import jackboxgames.talkshow.utils.*;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.utils.*;

class RapidFirePreviewWidgetChoice
{
   private var _mc:MovieClip;
   
   private var _tf:ExtendableTextField;
   
   public function RapidFirePreviewWidgetChoice(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._tf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.container.text);
   }
   
   public function reset() : void
   {
      JBGUtil.gotoFrame(this._mc,"Default");
      JBGUtil.gotoFrame(this._mc.container,"Default");
   }
   
   public function setup(data:RapidFireChoiceData, flip:Boolean) : void
   {
      this._tf.text = data.text;
      if(flip)
      {
         JBGUtil.gotoFrame(this._mc,"Flip");
      }
      JBGUtil.gotoFrame(this._mc.container,"Default");
   }
   
   public function reveal(isCorrect:Boolean) : void
   {
      JBGUtil.gotoFrame(this._mc.container,isCorrect ? "Correct" : "Incorrect");
   }
}

