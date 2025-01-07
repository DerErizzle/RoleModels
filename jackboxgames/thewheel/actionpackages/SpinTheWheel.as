package jackboxgames.thewheel.actionpackages
{
   import com.greensock.easing.*;
   import flash.display.MovieClip;
   import jackboxgames.algorithm.*;
   import jackboxgames.animation.tween.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.events.*;
   import jackboxgames.expressionparser.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.input.*;
   import jackboxgames.text.*;
   import jackboxgames.thewheel.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.entitybehaviors.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.effects.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.thewheel.widgets.*;
   import jackboxgames.utils.*;
   
   public dynamic class SpinTheWheel extends LibraryActionPackage implements ISpinDelegate, IWheelDataDelegate, ISpinWheelBehaviorDelegate, IChooseSliceDelegate, IPlayerControllerStateProvider
   {
      private static const CURRENT_SLICE_MODE_SLICE_DATA:String = "sliceData";
      
      private static const CURRENT_SLICE_MODE_SLICE_EFFECT:String = "sliceEffect";
      
      private static const DO_SPIN_ON_END_INPUT:String = "input";
      
      private static const DO_SPIN_ON_END_REF:String = "ref";
      
      private var _loopingMcs:Array;
      
      private var _wheelContainerMc:MovieClip;
      
      private var _timer:TFTimer;
      
      private var _playersShower:MovieClipShower;
      
      private var _playerWidgets:Array;
      
      private var _wheelShower:MovieClipShower;
      
      private var _stageLightsShower:MovieClipShower;
      
      private var _ringLightMcs:Array;
      
      private var _flameMcs:Array;
      
      private var _stageObjectShower:MovieClipShower;
      
      private var _selectedStageObject:String;
      
      private var _pedastalPlayerWidget:PlayerWidget;
      
      private var _pot:Pot;
      
      private var _currentSlice:CurrentSlice;
      
      private var _spinMeter:SpinMeter;
      
      private var _decisionShower:MovieClipShower;
      
      private var _decisionPromptTf:ExtendableTextField;
      
      private var _decisionOptionATf:ExtendableTextField;
      
      private var _decisionOptionBTf:ExtendableTextField;
      
      private var _decisionOptionAPercentTf:ExtendableTextField;
      
      private var _decisionOptionBPercentTf:ExtendableTextField;
      
      private var _placeSlices:EntityInteractionHandler;
      
      private var _spinWheel:EntityInteractionHandler;
      
      private var _selectSpinTarget:EntityInteractionHandler;
      
      private var _mainWheelAudio:WheelAudio;
      
      private var _winWheelAudio:WheelAudio;
      
      private var _hostAudioBehavior:AudioMeterPropertyChanger;
      
      private var _scoreboardGoalAmountText:ExtendableTextField;
      
      private var _scoreboardPlayerWidgets:Array;
      
      private var _miniWheelContainerMc:MovieClip;
      
      private var _miniWheelTitleShower:MovieClipShower;
      
      private var _miniWheelTitleTf:ExtendableTextField;
      
      private var _playerWidgetsInPlay:Array;
      
      private var _playerOnPedastal:Player;
      
      private var _numSpinsThisRound:int;
      
      private var _totalSpinsThisRound:int;
      
      private var _currentPot:Number;
      
      private var _finalSpinPotIncrease:Number;
      
      private var _mainWheel:Wheel;
      
      private var _isInIntro:Boolean;
      
      private var _currentWheel:Wheel;
      
      private var _currentWheelAudio:WheelAudio;
      
      private var _isFinalSpin:Boolean;
      
      private var _currentSpinner:Player;
      
      private var _currentSpinTypeCategory:String;
      
      private var _spinType:SpinType;
      
      private var _spunSlice:Slice;
      
      private var _playerScoresBeforeSpin:PerPlayerContainer;
      
      private var _lastSpinResult:SpinResult;
      
      private var _spinToPositionTween:JBGTween;
      
      private var _currentSliceMode:String;
      
      private var _isZoomedIn:Boolean;
      
      private var _isZoomedInForScoreboard:Boolean;
      
      private var _subWheel:Wheel;
      
      private var _spunSliceBeforeSubWheel:Slice;
      
      private var _lastSpinResultBeforeSubWheel:SpinResult;
      
      private var _winWheelPlayers:Array;
      
      public function SpinTheWheel(apRef:IActionPackageRef)
      {
         super(apRef,GameState.instance);
      }
      
      override protected function get _linkage() : String
      {
         return "SpinTheWheel";
      }
      
      override protected function get _displayIndex() : int
      {
         return 2;
      }
      
      override protected function get _propertyName() : String
      {
         return "spinTheWheel";
      }
      
      public function get timer() : TFTimer
      {
         return this._timer;
      }
      
      public function get playerOnPedastal() : Player
      {
         return this._playerOnPedastal;
      }
      
      public function get isWheelFull() : Boolean
      {
         var pos:int = 0;
         for each(pos in this._mainWheel.slicePositions)
         {
            if(!this._mainWheel.getSliceAt(pos,false))
            {
               return false;
            }
         }
         return true;
      }
      
      public function get slicesOnMainWheel() : Array
      {
         return this._mainWheel.getAllSlices();
      }
      
      public function get spunSlice() : Slice
      {
         return this._spunSlice;
      }
      
      public function get nonSpunSlices() : Array
      {
         return this._currentWheel.getAllSlices().filter(function(s:Slice, ... args):Boolean
         {
            return s != _spunSlice;
         });
      }
      
      public function get playersInWinnerModeThatHaveEarnedPointsFromSpin() : Array
      {
         Assert.assert(this._playerScoresBeforeSpin != null);
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return p.isInWinnerMode && p.score.val > _playerScoresBeforeSpin.getDataForPlayer(p);
         });
      }
      
      public function get numSpinsThisRound() : int
      {
         return this._numSpinsThisRound;
      }
      
      public function get totalSpinsThisRound() : int
      {
         return this._totalSpinsThisRound;
      }
      
      public function get spinMeterRatio() : Number
      {
         return this._spinMeter.ratio;
      }
      
      public function get currentSpinner() : Player
      {
         return this._currentSpinner;
      }
      
      public function isFinalSpin() : Boolean
      {
         return this._isFinalSpin;
      }
      
      public function get lastSpinResult() : SpinResult
      {
         return this._lastSpinResult;
      }
      
      public function get lastSpinWasMainWheel() : Boolean
      {
         return this._currentWheel == this._mainWheel;
      }
      
      public function get spinType() : SpinType
      {
         return this._spinType;
      }
      
      public function get winWheelPlayers() : Array
      {
         return this._winWheelPlayers;
      }
      
      override protected function _onLoaded() : void
      {
         var _this:SpinTheWheel = null;
         super._onLoaded();
         _this = this;
         _shower.behaviorTranslator = function(s:String):String
         {
            if(s == "Appear")
            {
               return _isInIntro ? "AppearFast" : "Appear";
            }
            if(s == "Disappear")
            {
               if(Boolean(GameState.instance.winner))
               {
                  return "WinDisappear";
               }
               if(_isZoomedInForScoreboard)
               {
                  return "ScoreDisappear";
               }
               return s;
            }
            return s;
         };
         this._loopingMcs = JBGUtil.getPropertiesOfNameInOrder(_mc.bg,"bg");
         this._wheelContainerMc = _mc.wheelBehaviors.wheelContainer;
         this._timer = new TFTimer(_mc.timerContainer);
         this._playersShower = new MovieClipShower(_mc.players);
         this._playersShower.behaviorTranslator = function(s:String):String
         {
            return s + _playerWidgetsInPlay.length;
         };
         this._playerWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc.players,"player").map(function(playerMc:MovieClip, ... args):PlayerWidget
         {
            return new PlayerWidget(playerMc);
         });
         this._wheelShower = new MovieClipShower(_mc.wheelBehaviors);
         this._stageLightsShower = new MovieClipShower(_mc.foreground.lights);
         this._stageObjectShower = new MovieClipShower(_mc.foreground.object);
         this._ringLightMcs = [_mc.wheelBehaviors.armLeft,_mc.wheelBehaviors.armRight];
         this._flameMcs = [_mc.foreground.flame0,_mc.foreground.flame1];
         this._pedastalPlayerWidget = new PlayerWidget(_mc.spinner);
         this._pot = new Pot(_mc.wheelBehaviors.prizeAmount);
         this._currentSlice = new CurrentSlice(_mc.info);
         this._placeSlices = new EntityInteractionHandler(new PlaceSlicesBehavior(new DefaultPlaceSlicesDelegate(this),new WheelControllerProvider(this,GameConstants.WHEEL_CONTROLLER_MODE_SECRETIVE)),GameState.instance,false,false,false);
         this._spinWheel = new EntityInteractionHandler(new SpinWheelBehavior(this,new WheelControllerProvider(this,GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT)),GameState.instance,false,false,false);
         this._selectSpinTarget = new EntityInteractionHandler(new ChooseSliceBehavior(this,new WheelControllerProvider(this,GameConstants.WHEEL_CONTROLLER_MODE_DEFAULT)),GameState.instance,false,false,false);
         this._spinMeter = new SpinMeter(_mc.spinMeter);
         this._decisionShower = new MovieClipShower(_mc.decision);
         this._decisionPromptTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.decision.prompt.text);
         this._decisionOptionATf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.decision.optionA.text);
         this._decisionOptionBTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.decision.optionB.text);
         this._decisionOptionAPercentTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.decision.optionA.percent);
         this._decisionOptionBPercentTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.decision.optionB.percent);
         this._scoreboardPlayerWidgets = JBGUtil.getPropertiesOfNameInOrder(_mc.wheelBehaviors.scoreboard,"player").map(function(playerMc:MovieClip, i:int, a:Array):ScoreboardPlayerWidget
         {
            return new ScoreboardPlayerWidget(playerMc);
         });
         this._scoreboardGoalAmountText = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.wheelBehaviors.scoreboard.goalAmount);
         this._miniWheelContainerMc = _mc.wheelBehaviors.miniWheelContainer;
         this._miniWheelTitleShower = new MovieClipShower(_mc.wheelBehaviors.miniTitle);
         this._miniWheelTitleShower.behaviorTranslator = function(s:String):String
         {
            var potentialBehavior:String = s + TextUtils.capitalizeFirstCharacter(_subWheel.id);
            return MovieClipUtil.frameExists(_mc.wheelBehaviors.miniTitle,potentialBehavior) ? potentialBehavior : s;
         };
         this._miniWheelTitleTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.wheelBehaviors.miniTitle.text0);
         this._mainWheelAudio = new WheelAudio("SFX/Wheel/sfx_wheel_spin","SFX/Wheel/sfx_wheel_ticks",true);
         this._winWheelAudio = new WheelAudio("SFX/WinnerWheel/sfx_winnerWheel_spin","SFX/WinnerWheel/sfx_winnerWheel_ticks",true);
         this._hostAudioBehavior = new AudioMeterPropertyChanger(_mc.wheelBehaviors.prizeAmount.glowContainer.glow,"alpha","Host",GameState.instance.jsonData.gameConfig.hostAudioMeterData);
         GameState.instance.expressionParserDataDelegate.add(new PropertyDataDelegate(this));
         GameConstants.SLICE_TYPES_ALL.forEach(function(st:SliceType, ... args):void
         {
            _this[st.id + "SlicesOnMainWheel"] = function():Array
            {
               return _mainWheel.getSlicesWithType(st);
            };
            _this[st.id + "ReservedSlicesOnMainWheel"] = function():Array
            {
               return _mainWheel.getSlicesWithType(GameConstants.SLICE_TYPE_RESERVED).filter(function(s:Slice, ... args):Boolean
               {
                  return ReservedSliceData(s.params.data).reservedFor == st.id;
               });
            };
            _this[st.id + "SliceNeighbors"] = function():Array
            {
               return _mainWheel.getSlicesAdjacentToSlicesWithType(st);
            };
         });
      }
      
      private function _disposeOfWheels() : void
      {
         if(Boolean(this._mainWheel))
         {
            if(Boolean(this._wheelContainerMc))
            {
               JBGUtil.safeRemoveChild(this._wheelContainerMc,this._mainWheel);
            }
            this._mainWheel.dispose();
            this._mainWheel = null;
         }
         if(Boolean(this._subWheel))
         {
            if(Boolean(this._wheelContainerMc))
            {
               JBGUtil.safeRemoveChild(this._wheelContainerMc,this._subWheel);
            }
            if(Boolean(this._miniWheelContainerMc))
            {
               JBGUtil.safeRemoveChild(this._miniWheelContainerMc,this._subWheel);
            }
            this._subWheel.dispose();
            this._subWheel = null;
         }
      }
      
      override protected function _onReset() : void
      {
         super._onReset();
         JBGUtil.reset(this._playerWidgets);
         JBGUtil.reset([this._playersShower,this._wheelShower,this._decisionShower,this._stageObjectShower,this._stageLightsShower,this._miniWheelTitleShower]);
         JBGUtil.reset([this._pedastalPlayerWidget,this._pot,this._currentSlice,this._timer,this._spinMeter]);
         JBGUtil.reset([this._placeSlices,this._spinWheel,this._selectSpinTarget]);
         JBGUtil.reset([this._mainWheelAudio,this._winWheelAudio,this._hostAudioBehavior]);
         JBGUtil.reset(this._scoreboardPlayerWidgets);
         JBGUtil.arrayGotoFrame(this._loopingMcs,"Default");
         JBGUtil.arrayGotoFrame(this._ringLightMcs,"Default");
         this._setRingLightMode("Default");
         JBGUtil.arrayGotoFrame(this._flameMcs,"Park");
         JBGUtil.arrayGotoFrame([_mc.wheelBehaviors.scoreboard],"Default");
         JBGUtil.gotoFrame(_mc.floor,"Park");
         this._disposeOfWheels();
         if(Boolean(this._spinToPositionTween))
         {
            this._spinToPositionTween.dispose();
            this._spinToPositionTween = null;
         }
         this._playerOnPedastal = null;
         this._currentWheel = null;
         this._currentWheelAudio = null;
         this._currentSpinTypeCategory = null;
         this._spinType = null;
         this._lastSpinResult = null;
         this._currentSliceMode = null;
         this._isZoomedIn = false;
         this._isZoomedInForScoreboard = false;
         this._spunSlice = null;
         this._winWheelPlayers = null;
      }
      
      override protected function _onActiveChanged(isActive:Boolean) : void
      {
         this._wheelShower.setShown(isActive,Nullable.NULL_FUNCTION);
         this._hostAudioBehavior.setActive(isActive);
         JBGUtil.arrayGotoFrame(this._loopingMcs,isActive ? "Loop" : "Default");
         JBGUtil.arrayGotoFrame(this._flameMcs,isActive ? "Appear" : "Park");
      }
      
      private function _updateCurrentSlice() : void
      {
         if(this._currentSliceMode == CURRENT_SLICE_MODE_SLICE_DATA)
         {
            this._currentSlice.updateWithSlice(this._currentWheel.getSliceAtFlapper(),this._currentWheel,this._currentSpinner);
         }
         else if(this._currentSliceMode == CURRENT_SLICE_MODE_SLICE_EFFECT)
         {
            this._currentSlice.updateWithSliceEffect(this._lastSpinResult.chosenPotentialEffect,this._lastSpinResult.effect,this._currentWheel);
         }
      }
      
      private function _createSubWheel(id:String, containerMc:MovieClip, bgClassName:String, flapperClassName:String, audio:WheelAudio) : void
      {
         Assert.assert(this._subWheel == null);
         this._spunSliceBeforeSubWheel = this._spunSlice;
         this._lastSpinResultBeforeSubWheel = this._lastSpinResult;
         this._subWheel = new Wheel(id,90,GameState.instance.jsonData.gameConfig.sliceSizeMiniWheel,GameState.instance.jsonData.gameConfig.sliceSizeMiniWheel,bgClassName,flapperClassName);
         containerMc.addChild(this._subWheel);
         this._currentWheel = this._subWheel;
         this._currentWheelAudio = audio;
      }
      
      private function _addStartingSlices(config:StartingSliceConfig, toWheel:Wheel) : void
      {
         var currentWinnerSliceIndex:int = 0;
         currentWinnerSliceIndex = 0;
         config.slices.filter(function(starting:StartingSlice, ... args):Boolean
         {
            return starting.getIsValid(GameState.instance.expressionParserDataDelegate);
         }).forEach(function(starting:StartingSlice, ... args):void
         {
            var params:SliceParameters = null;
            var requestedType:SliceType = GameConstants.GET_SLICE_TYPE_BY_ID(starting.type);
            if(requestedType == GameConstants.SLICE_TYPE_BONUS)
            {
               params = GameState.instance.currentRoundData.bonusSlice;
            }
            else
            {
               params = SliceParameters.CREATE(requestedType);
               switch(params.type)
               {
                  case GameConstants.SLICE_TYPE_RESERVED:
                     ReservedSliceData(params.data).reservedFor = starting.data.reservedFor;
                     break;
                  case GameConstants.SLICE_TYPE_MULTIPLIER:
                     MultiplierSliceData(params.data).multiplier = starting.data.multiplier;
                     break;
                  case GameConstants.SLICE_TYPE_PLAYER:
                     if(starting.data.hasOwnProperty("playerIndex"))
                     {
                        PlayerSliceData(params.data).addStakeForPlayer(GameState.instance.players[starting.data.playerIndex]);
                     }
                     if(starting.data.hasOwnProperty("multiplier"))
                     {
                        PlayerSliceData(params.data).multiplier = starting.data.multiplier;
                     }
                     break;
                  case GameConstants.SLICE_TYPE_WINNER:
                     WinnerSliceData(params.data).playerThatWins = _winWheelPlayers[currentWinnerSliceIndex];
                     ++currentWinnerSliceIndex;
                     if(currentWinnerSliceIndex >= _winWheelPlayers.length)
                     {
                        currentWinnerSliceIndex = 0;
                     }
               }
            }
            var newSlice:Slice = toWheel.addSlice(params,starting.pos);
            newSlice.instantOn();
         });
      }
      
      public function handleActionSetup(ref:IActionRef, params:Object) : void
      {
         var validStartingSliceConfigs:Array;
         var chosenStartingSliceConfig:StartingSliceConfig;
         var c:Counter;
         var randomPlayer:Player = null;
         if(GameState.instance.debug.skipTrivia)
         {
            GameState.instance.players.forEach(function(p:Player, ... args):void
            {
               p.changePlaceableSlices(Random.instance.roll(6,3));
            });
            randomPlayer = ArrayUtil.getRandomElement(GameState.instance.players);
            GameState.instance.currentRoundData.setBonusSlice(randomPlayer,GameState.instance.generateBonusSliceForPlayer(randomPlayer));
         }
         this._playerWidgetsInPlay = this._playerWidgets.slice(0,GameState.instance.players.length);
         this._playerWidgetsInPlay.forEach(function(widget:PlayerWidget, i:int, a:Array):void
         {
            widget.setup(GameState.instance.players[i]);
         });
         JBGUtil.gotoFrame(_mc.floor,"Layout" + this._playerWidgetsInPlay.length);
         this.currentPot = GameState.instance.jsonData.gameConfig.baseStartingPot + GameState.instance.roundIndex * GameState.instance.jsonData.gameConfig.startingPotIncreasePerRound;
         this._isFinalSpin = false;
         this._spinMeter.setup();
         this._mainWheel = new Wheel("main",90,GameState.instance.jsonData.gameConfig.sliceSize,GameState.instance.jsonData.gameConfig.sliceSize,"wheelBg","flapper");
         this._isInIntro = false;
         this._mainWheel.setSpinInstant(-(GameState.instance.jsonData.gameConfig.sliceSize / 2));
         this._currentWheel = this._mainWheel;
         this._currentWheelAudio = this._mainWheelAudio;
         this._wheelContainerMc.addChild(this._mainWheel);
         validStartingSliceConfigs = GameState.instance.jsonData.startingSliceConfigs.filter(function(config:StartingSliceConfig, ... args):Boolean
         {
            if(Boolean(GameState.instance.debug.forcedStartingSliceConfigId))
            {
               return config.id == GameState.instance.debug.forcedStartingSliceConfigId;
            }
            return config.getIsValid(GameState.instance.expressionParserDataDelegate);
         });
         Assert.assert(validStartingSliceConfigs.length > 0);
         chosenStartingSliceConfig = ArrayUtil.getRandomElement(validStartingSliceConfigs);
         trace("Chose Starting Slice Config: " + chosenStartingSliceConfig.id);
         this._addStartingSlices(chosenStartingSliceConfig,this._mainWheel);
         this._selectedStageObject = ArrayUtil.getRandomElement(MovieClipUtil.getFramesWithNameInOrder(_mc.foreground.object,"Object"));
         MovieClipUtil.gotoFrameIfExists(_mc.foreground.object,this._selectedStageObject,false);
         c = new Counter(2,TSUtil.createRefEndFn(ref));
         this._mainWheelAudio.setLoaded(true,c.generateDoneFn());
         this._winWheelAudio.setLoaded(true,c.generateDoneFn());
      }
      
      public function handleActionSetupForIntro(ref:IActionRef, params:Object) : void
      {
         var validStartingSliceConfigs:Array;
         this._playerWidgetsInPlay = this._playerWidgets.slice(0,GameState.instance.players.length);
         this._playerWidgetsInPlay.forEach(function(widget:PlayerWidget, i:int, a:Array):void
         {
            widget.setup(GameState.instance.players[i]);
         });
         JBGUtil.gotoFrame(_mc.floor,"Layout" + this._playerWidgetsInPlay.length);
         this._mainWheel = new Wheel("main",90,GameState.instance.jsonData.gameConfig.sliceSize,GameState.instance.jsonData.gameConfig.sliceSize,"wheelBg","flapper");
         this._isInIntro = true;
         this._currentWheel = this._mainWheel;
         this._currentWheelAudio = this._mainWheelAudio;
         this._wheelContainerMc.addChild(this._mainWheel);
         validStartingSliceConfigs = GameState.instance.jsonData.startingSliceConfigs.filter(function(config:StartingSliceConfig, ... args):Boolean
         {
            return config.id == "intro" + GameState.instance.players.length + "Players";
         });
         Assert.assert(validStartingSliceConfigs.length > 0);
         this._addStartingSlices(ArrayUtil.getRandomElement(validStartingSliceConfigs),this._mainWheel);
         this._mainWheelAudio.setLoaded(true,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPlayersShown(ref:IActionRef, params:Object) : void
      {
         MovieClipShower.setMultiple(this._playerWidgetsInPlay,params.isShown,Duration.ZERO,Nullable.NULL_FUNCTION);
         this._playersShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionShowWheel(ref:IActionRef, params:Object) : void
      {
         this._wheelShower.doAnimation(this._isInIntro ? "AppearFast" : "AppearWheel",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetStageLightsShown(ref:IActionRef, params:Object) : void
      {
         this._stageLightsShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoStageLightsBehavior(ref:IActionRef, params:Object) : void
      {
         this._stageLightsShower.doAnimation(params.behavior,Nullable.NULL_FUNCTION);
         ref.end();
      }
      
      private function _setRingLightMode(mode:String) : void
      {
         this._ringLightMcs.forEach(function(lightMc:MovieClip, ... args):void
         {
            JBGUtil.gotoFrame(lightMc.lightColor,mode);
         });
      }
      
      public function handleActionSetRingLightMode(ref:IActionRef, params:Object) : void
      {
         this._setRingLightMode(params.mode);
         ref.end();
      }
      
      public function handleActionDoRingLightBehavior(ref:IActionRef, params:Object) : void
      {
         var behavior:String = params.behavior;
         var hasEndingEvent:Boolean = behavior != "Park" && behavior != "Default" && behavior.indexOf("Loop") < 0;
         if(hasEndingEvent)
         {
            JBGUtil.arrayGotoFrameWithFn(this._ringLightMcs,behavior,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
         }
         else
         {
            JBGUtil.arrayGotoFrame(this._ringLightMcs,behavior);
            ref.end();
         }
      }
      
      public function handleActionDoFlameBehavior(ref:IActionRef, params:Object) : void
      {
         JBGUtil.arrayGotoFrameWithFn(this._flameMcs,params.behavior,MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetCurrentSliceInfoShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._currentSliceMode = params.mode;
            this._updateCurrentSlice();
         }
         else
         {
            this._currentSliceMode = null;
         }
         this._currentSlice.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetCurrentSliceInfoSelected(ref:IActionRef, params:Object) : void
      {
         this._currentSlice.setSelected(params.isSelected,TSUtil.createRefEndFn(ref));
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
      
      public function handleActionSetPlaceSlicesActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         this._placeSlices.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoPostPlacementLogic(ref:IActionRef, params:Object) : void
      {
         ref.end();
      }
      
      public function handleActionRevealBonusSlice(ref:IActionRef, params:Object) : void
      {
         var reservedForBonus:Slice = ArrayUtil.find(this._mainWheel.getAllSlices(),function(s:Slice, ... args):Boolean
         {
            return s.params.type == GameConstants.SLICE_TYPE_RESERVED && ReservedSliceData(s.params.data).reservedFor == "bonus";
         });
         var bonusSlice:SliceParameters = GameState.instance.currentRoundData.bonusSlice;
         this._mainWheel.replaceSliceWithNewSlice(reservedForBonus,bonusSlice,Wheel.REPLACE_TYPE_OVERWRITE,TSUtil.createRefEndFn(ref));
      }
      
      private function _fillAtPosition(w:Wheel, pos:int) : void
      {
         var reservedSlices:Array = null;
         var multiplierSlices:Array = null;
         var reserved:Slice = null;
         var reservedData:ReservedSliceData = null;
         var type:SliceType = null;
         var slices:Array = w.getSlicesAt(pos,false);
         if(slices.length == 0)
         {
            w.addSlice(GameState.instance.generateFillerSlice(),pos);
         }
         else if(slices.length == 1)
         {
            reservedSlices = slices.filter(Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_RESERVED));
            if(reservedSlices.length > 0)
            {
               reserved = ArrayUtil.first(reservedSlices);
               reservedData = ReservedSliceData(reserved.params.data);
               type = GameConstants.GET_SLICE_TYPE_BY_ID(reservedData.reservedFor);
               if(type != GameConstants.SLICE_TYPE_BONUS)
               {
                  w.addSlice(SliceParameters.CREATE(type),pos);
               }
            }
            multiplierSlices = slices.filter(Slice.GENERATE_FIND_FN_FOR_TYPE(GameConstants.SLICE_TYPE_MULTIPLIER));
            if(multiplierSlices.length > 0)
            {
               w.addSlice(GameState.instance.generateFillerSlice(),pos);
            }
         }
      }
      
      private function _revealAtPosition(w:Wheel, pos:int, doneFn:Function) : void
      {
         var slices:Array = w.getSlicesAt(pos,false);
         var slicesOnScreen:Array = slices.filter(function(s:Slice, ... args):Boolean
         {
            return s.isOnScreen;
         });
         var slicesOffScreen:Array = slices.filter(function(s:Slice, ... args):Boolean
         {
            return !s.isOnScreen;
         });
         if(slices.length == 0)
         {
            doneFn();
         }
         else if(slices.length == 1)
         {
            if(slicesOffScreen.length == 1)
            {
               ArrayUtil.first(slicesOffScreen).slideIn(doneFn);
            }
            else
            {
               doneFn();
            }
         }
         else if(slices.length == 2)
         {
            Assert.assert(slicesOnScreen.length == 1 && slicesOffScreen.length == 1);
            w.replaceSliceWithExistingSlice(ArrayUtil.first(slicesOnScreen),ArrayUtil.first(slicesOffScreen),Wheel.REPLACE_TYPE_OVERWRITE,doneFn);
         }
         else
         {
            Assert.assert(false);
         }
      }
      
      public function handleActionFillWheel(ref:IActionRef, params:Object) : void
      {
         var d:Duration = null;
         var c:Counter = null;
         d = Duration.fromSec(0.07);
         c = new Counter(this._mainWheel.slicePositions.length,TSUtil.createRefEndFn(ref));
         this._mainWheel.slicePositions.forEach(function(pos:int, ... args):void
         {
            _fillAtPosition(_mainWheel,pos);
         });
         this._mainWheel.slicePositions.forEach(function(pos:int, i:int, a:Array):void
         {
            JBGUtil.runFunctionAfter(function():void
            {
               _revealAtPosition(_mainWheel,pos,c.generateDoneFn());
            },Duration.scale(d,i));
         });
      }
      
      public function handleActionSetupForSpinning(ref:IActionRef, params:Object) : void
      {
         this._numSpinsThisRound = 0;
         this._totalSpinsThisRound = 0;
         this._updateCurrentSlice();
         GameState.instance.addPlayerControllerStateProvider(this);
         ref.end();
      }
      
      public function handleActionFinishSpinning(ref:IActionRef, params:Object) : void
      {
         GameState.instance.removePlayerControllerStateProvider(this);
         ref.end();
      }
      
      public function handleActionSetSpinMeterShown(ref:IActionRef, params:Object) : void
      {
         this._spinMeter.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetCurrentPotShown(ref:IActionRef, params:Object) : void
      {
         this._pot.shower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionDoCurrentPotBehavior(ref:IActionRef, params:Object) : void
      {
         this._pot.doBehavior(params.behavior,params.icon,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupNextMainWheelSpin(ref:IActionRef, params:Object) : void
      {
         var newFinalSpin:Boolean;
         this._mainWheel.getAllSlices().forEach(function(s:Slice, ... args):void
         {
            s.updateVisuals();
         });
         this._playerScoresBeforeSpin = PerPlayerContainerUtil.MAP(GameState.instance.players,function(p:Player, ... args):int
         {
            return p.score.val;
         });
         newFinalSpin = this._numSpinsThisRound >= GameState.instance.currentRoundData.setup.numSpinsBeforeFinal;
         if(newFinalSpin != this._isFinalSpin)
         {
            this._spinMeter.setFinalSpin();
         }
         this._isFinalSpin = newFinalSpin;
         ++this._numSpinsThisRound;
         ++this._totalSpinsThisRound;
         GameState.instance.playerWithMainWheelControl.recordSpin();
         ref.end();
      }
      
      public function handleActionSetSpinWheelActive(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isActive))
         {
            TSInputHandler.instance.setupForSingleInput();
            this._currentSpinner = TSUtil.resolveFromVariablePath(params.player,Player);
            this._currentSpinTypeCategory = params.category;
         }
         if(GameState.instance.debug.spinTargetMode)
         {
            this._selectSpinTarget.setIsActive([this._currentSpinner],params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
         }
         else
         {
            this._spinWheel.setIsActive(GameState.instance.players,params.isActive).then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
         }
      }
      
      public function handleActionDoSpin(ref:IActionRef, params:Object) : void
      {
         var spinAmount:int;
         var duration:Duration;
         var spinTween:JBGTween;
         var power:Number = NaN;
         var potIncreasePerRevolution:int = 0;
         var potIncrease:int = 0;
         if(params.onEnd == DO_SPIN_ON_END_INPUT)
         {
            TSInputHandler.instance.setupForSingleInput();
         }
         if(this._currentWheel == this._mainWheel && GameState.instance.playersInWinnerMode.length == GameState.instance.players.length)
         {
            Trophy.instance.unlock(GameConstants.TROPHY_SPIN_WHEN_EVERYONE_CAN_WIN);
         }
         if(!this._spinType)
         {
            Assert.assert(this._currentSpinTypeCategory != null);
            power = Random.instance.nextRandomNumber();
            this._spinType = GameState.instance.jsonData.getSpinType(this._currentSpinTypeCategory,power);
         }
         spinAmount = this._spinType.minSpin + Math.floor(Number(this._spinType.maxSpin - this._spinType.minSpin) * Math.random());
         if(GameState.instance.debug.fixedSpinAmount > 0)
         {
            spinAmount = GameState.instance.debug.fixedSpinAmount;
         }
         duration = GameState.instance.debug.fastTimersMode ? GameState.instance.debug.fastSpinDuration : this._spinType.duration;
         spinTween = new JBGTween(this._currentWheel,duration,{"spin":this._currentWheel.spin + spinAmount},this._spinType.ease,true);
         TrackedTweens.track(spinTween);
         spinTween.addEventListener(JBGTween.EVENT_TWEEN_UPDATE,function(evt:EventWithData):void
         {
            _updateCurrentSlice();
         });
         if(this._currentWheel == this._mainWheel)
         {
            potIncreasePerRevolution = GameState.instance.jsonData.gameConfig.basePotIncreasePerRevolution + GameState.instance.roundIndex * GameState.instance.jsonData.gameConfig.potIncreasePerRevolutionIncreasePerRound;
            potIncrease = Math.floor(Number(spinAmount) / 360 * potIncreasePerRevolution);
            TrackedTweens.track(new JBGTween(this,duration,{"currentPot":this.currentPot + potIncrease},this._spinType.ease));
            TrackedTweens.track(new JBGTween(this._spinMeter,duration,{"ratio":Number(this._numSpinsThisRound) / GameState.instance.currentRoundData.setup.numSpinsBeforeFinal},Linear.ease));
         }
         JBGUtil.eventOnce(spinTween,JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
         {
            _spunSlice = _currentWheel.getSliceAtFlapper();
            _currentWheel.setSpinInstant(_currentWheel.spin % 360);
            _currentWheelAudio.setActive(false);
            _updateCurrentSlice();
            if(params.onEnd == DO_SPIN_ON_END_INPUT)
            {
               TSInputHandler.instance.input("Done");
            }
            else if(params.onEnd == DO_SPIN_ON_END_REF)
            {
               ref.end();
            }
         });
         this._currentWheelAudio.setup(this._currentWheel);
         this._currentWheelAudio.setActive(true);
         if(params.onEnd == DO_SPIN_ON_END_INPUT)
         {
            ref.end();
         }
      }
      
      public function handleActionSpinToPosition(ref:IActionRef, params:Object) : void
      {
         var spinTarget:Number = params.numTimesAround * 360 + params.targetPosition - this._currentWheel.flapperPosition;
         var duration:Duration = Duration.fromSec(params.durationInSec);
         var ease:CustomEase2 = new CustomEase2("debug",params.easeData,null);
         this._spinToPositionTween = new JBGTween(this._currentWheel,duration,{"spin":spinTarget},ease,true);
         JBGUtil.eventOnce(this._spinToPositionTween,JBGTween.EVENT_TWEEN_COMPLETE,function(evt:EventWithData):void
         {
            _spunSlice = _currentWheel.getSliceAtFlapper();
            _currentWheelAudio.setActive(false);
            _spinToPositionTween.dispose();
            _spinToPositionTween = null;
            ref.end();
         });
         this._currentWheelAudio.setup(this._currentWheel);
         this._currentWheelAudio.setActive(true);
      }
      
      public function handleActionStopSpinToPosition(ref:IActionRef, params:Object) : void
      {
         this._currentWheelAudio.setActive(false);
         if(Boolean(this._spinToPositionTween))
         {
            this._spinToPositionTween.dispose();
            this._spinToPositionTween = null;
         }
         ref.end();
      }
      
      public function handleActionGivePot(ref:IActionRef, params:Object) : void
      {
         var multiplier:Number = NaN;
         var multiplierPerPlayer:PerPlayerContainer = null;
         var pointsPerPlayer:int = 0;
         var players:Array = TSUtil.resolveArrayFromVariablePath(params.players,Player);
         var split:Boolean = Boolean(params.split);
         multiplier = Number(params.multiplier);
         multiplierPerPlayer = TSUtil.resolveFromVariablePath(params.multiplierPerPlayer,PerPlayerContainer);
         var pot:int = this._currentPot;
         pointsPerPlayer = Boolean(params.split) ? int(Math.round(Number(pot) / players.length)) : pot;
         players.forEach(function(p:Player, ... args):void
         {
            var sc:ScoreChange = new ScoreChange().withAmount(pointsPerPlayer);
            sc.withMultiplier(new ScoreChangeMultiplier(multiplier));
            if(Boolean(multiplierPerPlayer) && multiplierPerPlayer.hasDataForPlayer(p))
            {
               sc.withMultiplier(new ScoreChangeMultiplier(multiplierPerPlayer.getDataForPlayer(p)));
            }
            p.addScoreChange(sc);
         });
         ref.end();
      }
      
      public function handleActionMultiplyPotForFinalSpin(ref:IActionRef, params:Object) : void
      {
         this._currentPot *= GameState.instance.jsonData.gameConfig.finalSpinPotIncreaseFactor;
         this._pot.updateAmount(this._currentPot);
         ref.end();
      }
      
      public function handleActionSetZoomedIn(ref:IActionRef, params:Object) : void
      {
         this._isZoomedIn = params.isZoomedIn;
         _shower.doAnimation(this._isZoomedIn ? "SpinZoomIn" : "SpinZoomOut",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetZoomedInForScoreboard(ref:IActionRef, params:Object) : void
      {
         this._isZoomedInForScoreboard = params.isZoomedIn;
         _shower.doAnimation(this._isZoomedInForScoreboard ? "ScoreZoomIn" : "ScoreZoomOut",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetSlicesHighlighted(ref:IActionRef, params:Object) : void
      {
         var slices:Array = TSUtil.resolveArrayFromVariablePath(params.slices,Slice);
         if(slices.length == 0)
         {
            ref.end();
            return;
         }
         slices.forEach(function(s:Slice, ... args):void
         {
            s.setVisualState(Boolean(params.isHighlighted) ? Slice.STATE_HIGHLIGHTED : Slice.STATE_DEFAULT);
         });
         ref.end();
      }
      
      public function handleActionSetSlicesDimmed(ref:IActionRef, params:Object) : void
      {
         var slices:Array = TSUtil.resolveArrayFromVariablePath(params.slices,Slice);
         if(slices.length == 0)
         {
            ref.end();
            return;
         }
         slices.forEach(function(s:Slice, ... args):void
         {
            s.setVisualState(Boolean(params.isDimmed) ? Slice.STATE_DIMMED : Slice.STATE_DEFAULT);
         });
         ref.end();
      }
      
      public function handleActionSetWheelIconsShown(ref:IActionRef, params:Object) : void
      {
         this._mainWheel.iconRingShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetupSpinResult(ref:IActionRef, params:Object) : void
      {
         var param:DoSpinResultParam = new DoSpinResultParam(this._currentSpinner,this._spunSlice,this._currentWheel,this);
         this._lastSpinResult = GameState.instance.setupSpinResult(param);
         ref.end();
      }
      
      public function handleActionEvaluateSpinResult(ref:IActionRef, params:Object) : void
      {
         var p:Promise = this._lastSpinResult.effect.evaluate();
         if(this._lastSpinResult.potChange > 0)
         {
            this.currentPot += this._lastSpinResult.potChange;
         }
         p.then(TSUtil.createRefEndFn(ref),TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSwitchSlices(ref:IActionRef, params:Object) : void
      {
         var bonusSliceParams:SliceParameters = null;
         var slicesToReplace:Array = null;
         var paramsGenerator:Function = null;
         var c:Counter = null;
         bonusSliceParams = GameState.instance.currentRoundData.bonusSlice;
         var bonusSlices:Array = this._mainWheel.getSlicesWithParams(bonusSliceParams);
         if(this._spunSlice.params == bonusSliceParams)
         {
            slicesToReplace = bonusSlices;
            paramsGenerator = function():SliceParameters
            {
               return GameState.instance.generateBadSlice();
            };
         }
         else
         {
            slicesToReplace = [this._spunSlice];
            if(bonusSlices.length > 0)
            {
               paramsGenerator = function():SliceParameters
               {
                  return bonusSliceParams;
               };
            }
            else
            {
               paramsGenerator = function():SliceParameters
               {
                  return GameState.instance.generateBadSlice();
               };
            }
         }
         if(slicesToReplace.length == 0)
         {
            ref.end();
            return;
         }
         c = new Counter(slicesToReplace.length,TSUtil.createRefEndFn(ref));
         slicesToReplace.forEach(function(s:Slice, i:int, a:Array):void
         {
            _mainWheel.replaceSliceWithNewSlice(s,paramsGenerator(),Wheel.REPLACE_TYPE_FLIP,c.generateDoneFn());
         });
         this._updateCurrentSlice();
      }
      
      public function handleActionSwitchPlayerSlicesForIntro(ref:IActionRef, params:Object) : void
      {
         var c:Counter = null;
         var playerSlices:Array = this._mainWheel.getSlicesWithType(GameConstants.SLICE_TYPE_PLAYER);
         c = new Counter(playerSlices.length,TSUtil.createRefEndFn(ref));
         playerSlices.forEach(function(s:Slice, i:int, a:Array):void
         {
            _mainWheel.replaceSliceWithNewSlice(s,SliceParameters.CREATE(GameConstants.SLICE_TYPE_BAD),Wheel.REPLACE_TYPE_FLIP,c.generateDoneFn());
         });
      }
      
      public function handleActionMovePlayerOntoPedastal(ref:IActionRef, params:Object) : void
      {
         var slotWidget:PlayerWidget = null;
         Assert.assert(this._playerOnPedastal == null);
         this._playerOnPedastal = TSUtil.resolveFromVariablePath(params.player,Player);
         Assert.assert(this._playerOnPedastal != null);
         slotWidget = this._playerWidgetsInPlay[this._playerOnPedastal.index.val];
         slotWidget.shower.setShown(false,function():void
         {
            slotWidget.reset();
            _pedastalPlayerWidget.setup(_playerOnPedastal);
            _pedastalPlayerWidget.shower.setShown(true,TSUtil.createRefEndFn(ref));
         });
      }
      
      public function handleActionRemovePlayerFromPedastal(ref:IActionRef, params:Object) : void
      {
         var playerThatWasOnPedastal:Player = null;
         Assert.assert(this._playerOnPedastal != null);
         playerThatWasOnPedastal = this._playerOnPedastal;
         this._playerOnPedastal = null;
         this._pedastalPlayerWidget.shower.setShown(false,function():void
         {
            _pedastalPlayerWidget.reset();
            var slotWidget:PlayerWidget = _playerWidgetsInPlay[playerThatWasOnPedastal.index.val];
            slotWidget.setup(playerThatWasOnPedastal);
            slotWidget.shower.setShown(true,TSUtil.createRefEndFn(ref));
         });
      }
      
      public function handleActionSwapPedastalPlayer(ref:IActionRef, params:Object) : void
      {
         var playerMovingIntoSlot:Player = null;
         var playerMovingOntoPedastal:Player = null;
         Assert.assert(this._playerOnPedastal != null);
         playerMovingIntoSlot = this._playerOnPedastal;
         playerMovingOntoPedastal = TSUtil.resolveFromVariablePath(params.player,Player);
         this._playerOnPedastal = playerMovingOntoPedastal;
         MovieClipShower.setMultiple([this._pedastalPlayerWidget.shower,PlayerWidget(this._playerWidgetsInPlay[playerMovingOntoPedastal.index.val]).shower],false,Duration.ZERO,function():void
         {
            _pedastalPlayerWidget.reset();
            PlayerWidget(_playerWidgetsInPlay[playerMovingOntoPedastal.index.val]).reset();
            PlayerWidget(_playerWidgetsInPlay[playerMovingIntoSlot.index.val]).setup(playerMovingIntoSlot);
            _pedastalPlayerWidget.setup(playerMovingOntoPedastal);
            MovieClipShower.setMultiple([_pedastalPlayerWidget.shower,PlayerWidget(_playerWidgetsInPlay[playerMovingIntoSlot.index.val]).shower],true,Duration.ZERO,TSUtil.createRefEndFn(ref));
         });
      }
      
      public function handleActionSetupWinSubWheel(ref:IActionRef, params:Object) : void
      {
         var validStartingSliceConfigs:Array;
         var configName:String = null;
         var numPlayerSlices:int = 0;
         this._createSubWheel("winner",this._miniWheelContainerMc,"miniWheelBg","miniFlapper",this._winWheelAudio);
         this._winWheelPlayers = TSUtil.resolveArrayFromVariablePath(params.players,Player);
         this._winWheelPlayers.sort(function(a:Player, b:Player):int
         {
            if(a.score.val == b.score.val)
            {
               return 0;
            }
            return a.score.val > b.score.val ? -1 : 1;
         });
         if(!params.isForIntro)
         {
            GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_WIN_WHEEL_STATUS",this._winWheelPlayers.map(function(p:Player, ... args):String
            {
               return TheWheelTextUtil.formattedPlayerName(p);
            }).join(", "));
            GameState.instance.textDescriptions.updateEntity();
         }
         if(this._winWheelPlayers.length == GameState.instance.players.length)
         {
            configName = "winWheelAllPlayerSlots";
         }
         else
         {
            numPlayerSlices = Math.max(this._subWheel.slicePositions.length - GameState.instance.jsonData.gameConfig.numBadSlicesOnWinWheel,this._winWheelPlayers.length);
            configName = "winWheel" + numPlayerSlices + "PlayerSlots";
         }
         validStartingSliceConfigs = GameState.instance.jsonData.startingSliceConfigs.filter(function(config:StartingSliceConfig, ... args):Boolean
         {
            return config.id == configName;
         });
         Assert.assert(validStartingSliceConfigs.length > 0);
         this._addStartingSlices(ArrayUtil.getRandomElement(validStartingSliceConfigs),this._subWheel);
         if(!params.isForIntro)
         {
            GameState.instance.recordWinWheelSpin();
         }
         ref.end();
      }
      
      public function handleActionSetupSliceEffectSubWheel(ref:IActionRef, params:Object) : void
      {
         Assert.assert(this._lastSpinResult.effect is ISliceEffectWithSubWheel);
         var effectWithSubWheel:ISliceEffectWithSubWheel = ISliceEffectWithSubWheel(this._lastSpinResult.effect);
         this._createSubWheel(this._lastSpinResult.chosenPotentialEffect.id,this._miniWheelContainerMc,effectWithSubWheel.bgClassName,effectWithSubWheel.flapperClassName,this._mainWheelAudio);
         effectWithSubWheel.fillWheel(this._subWheel);
         ref.end();
      }
      
      public function handleActionSetSubWheelShown(ref:IActionRef, params:Object) : void
      {
         var c:Counter = null;
         if(Boolean(params.isShown))
         {
            c = new Counter(this._subWheel.getAllSlices().length,TSUtil.createRefEndFn(ref));
            this._subWheel.getAllSlices().forEach(function(s:Slice, ... args):void
            {
               s.slideIn(c.generateDoneFn());
            });
            this._updateCurrentSlice();
         }
         else
         {
            ref.end();
         }
      }
      
      public function handleActionDisposeOfSubWheel(ref:IActionRef, params:Object) : void
      {
         Assert.assert(this._subWheel != null);
         DisplayObjectUtil.removeFromParent(this._subWheel);
         this._subWheel.dispose();
         this._subWheel = null;
         this._currentWheel = this._mainWheel;
         this._currentWheelAudio = this._mainWheelAudio;
         this._spunSlice = this._spunSliceBeforeSubWheel;
         this._lastSpinResult = this._lastSpinResultBeforeSubWheel;
         this._updateCurrentSlice();
         ref.end();
      }
      
      public function handleActionAdvancePlayerWithMainWheelControl(ref:IActionRef, params:Object) : void
      {
         GameState.instance.advancePlayerWithMainWheelControl();
         ref.end();
      }
      
      public function handleActionFlipToScoreboard(ref:IActionRef, params:Object) : void
      {
         var playersRanked:Array = null;
         playersRanked = GameState.instance.playersRanked;
         var widgetsInPlay:Array = this._scoreboardPlayerWidgets.slice(0,playersRanked.length);
         widgetsInPlay.forEach(function(s:ScoreboardPlayerWidget, i:int, a:Array):void
         {
            s.setup(playersRanked[i]);
            s.appear(s.player.isInWinnerMode && !GameState.instance.currentRoundData.playerIsNewToWinnerMode(s.player));
         });
         this._scoreboardGoalAmountText.text = TheWheelTextUtil.formattedScore(GameState.instance.jsonData.gameConfig.pointsRequiredToWinGame);
         GameState.instance.textDescriptions.addTextDescription("TEXT_DESCRIPTION_SCOREBOARD",playersRanked.map(function(p:Player, ... args):String
         {
            return TheWheelTextUtil.formattedPlayerName(p) + " " + p.score.val;
         }).join(", "));
         GameState.instance.textDescriptions.updateEntity();
         this._wheelShower.doAnimation("FlipToScores",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetPointGoalHighlighted(ref:IActionRef, params:Object) : void
      {
         JBGUtil.gotoFrameWithFn(_mc.wheelBehaviors.scoreboard,Boolean(params.isHighlighted) ? "HighlightGoal" : "UnhighlightGoal",MovieClipEvent.EVENT_ANIMATION_DONE,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionHighlightNewToWinnerMode(ref:IActionRef, params:Object) : void
      {
         var highlightQueue:Array = null;
         highlightQueue = this._scoreboardPlayerWidgets.filter(function(s:ScoreboardPlayerWidget, ... args):Boolean
         {
            return GameState.instance.currentRoundData.playerIsNewToWinnerMode(s.player);
         }).map(function(s:ScoreboardPlayerWidget, i:int, a:Array):Function
         {
            return function():void
            {
               s.shower.doAnimation("Highlight",i < highlightQueue.length - 1 ? highlightQueue[i + 1] : TSUtil.createRefEndFn(ref));
            };
         });
         if(highlightQueue.length > 0)
         {
            highlightQueue[0]();
         }
         else
         {
            ref.end();
         }
      }
      
      public function handleActionFlipMiniWheel(ref:IActionRef, params:Object) : void
      {
         this._wheelShower.doAnimation(Boolean(params.isShown) ? "FlipToMini" : "FlipFromMini",TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetMiniWheelTitleShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this._miniWheelTitleTf.text = this._subWheel.id.toUpperCase();
         }
         this._miniWheelTitleShower.setShown(params.isShown,TSUtil.createRefEndFn(ref));
      }
      
      public function handleActionSetBinaryDecisionShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            JBGUtil.arrayGotoFrame([_mc.decision.optionA,_mc.decision.optionB],"Default");
         }
         if(Boolean(params.prompt) && params.prompt.length > 0)
         {
            this._decisionPromptTf.text = params.prompt;
         }
         if(Boolean(params.optionA) && params.optionA.length > 0)
         {
            this._decisionOptionATf.text = params.optionA;
         }
         if(Boolean(params.optionB) && params.optionB.length > 0)
         {
            this._decisionOptionBTf.text = params.optionB;
         }
         var c:Counter = new Counter(2,TSUtil.createRefEndFn(ref));
         _shower.doAnimation(Boolean(params.isShown) ? "DecisionShow" : "DecisionUnshow",c.generateDoneFn());
         this._decisionShower.setShown(params.isShown,c.generateDoneFn());
      }
      
      public function handleActionRevealBinaryDecision(ref:IActionRef, params:Object) : void
      {
         this._decisionOptionAPercentTf.text = Math.round(params.ratioForA * 100) + "%";
         this._decisionOptionBPercentTf.text = Math.round(params.ratioForB * 100) + "%";
         JBGUtil.gotoFrame(_mc.decision.optionA,params.decision == GameConstants.OPTION_A ? "Highlight" : "Dim");
         JBGUtil.gotoFrame(_mc.decision.optionB,params.decision == GameConstants.OPTION_B ? "Highlight" : "Dim");
         ref.end();
      }
      
      public function get currentPot() : Number
      {
         return this._currentPot;
      }
      
      public function set currentPot(val:Number) : void
      {
         this._currentPot = val;
         this._pot.updateAmount(this._currentPot);
      }
      
      public function setNumSpinsAndAnimateSpinMeter(newNumSpins:int, d:Duration) : void
      {
         this._numSpinsThisRound = newNumSpins;
         TrackedTweens.track(new JBGTween(this._spinMeter,d,{"ratio":Number(this._numSpinsThisRound) / GameState.instance.currentRoundData.setup.numSpinsBeforeFinal},Linear.ease));
      }
      
      public function getWheel() : Wheel
      {
         return this._currentWheel;
      }
      
      public function get spinWheelSpinner() : Player
      {
         return this._currentSpinner;
      }
      
      public function get spinWheelSpinTypeCategory() : String
      {
         return this._currentSpinTypeCategory;
      }
      
      public function onWheelSpun(p:Player, type:SpinType) : void
      {
         this._spinType = type;
      }
      
      public function getChooseSlicePrompt(p:Player) : String
      {
         return "DEBUG: Where do you want to spin to?";
      }
      
      public function get showSelectedSlices() : Boolean
      {
         return true;
      }
      
      public function canChooseSlice(p:Player, pos:int) : Boolean
      {
         return true;
      }
      
      public function onChooseSliceSubmitted(p:Player, chosenPosition:int) : void
      {
      }
      
      public function onChooseSliceDone(chosenSlices:PerPlayerContainer, finishedOnPlayerInput:Boolean) : void
      {
         var s:Slice = null;
         var distance:Object = null;
         var spin:SpinType = null;
         if(chosenSlices.hasDataForPlayer(this._currentSpinner))
         {
            s = this._mainWheel.getSliceAt(chosenSlices.getDataForPlayer(this._currentSpinner),false);
            distance = this._mainWheel.distanceToSlice(s);
            spin = new SpinType();
            spin.load({
               "id":"toSlice",
               "category":"debug",
               "durationInSec":2,
               "minPower":0,
               "maxPower":0.4,
               "customEaseData":"M0,0,C0,0,0.198,0,0.208,0.17,0.212,0.241,0.22,0.631,0.266,0.752,0.32,0.896,0.458,1,1,1",
               "minSpin":distance.min,
               "maxSpin":distance.max
            });
            this._spinType = spin;
         }
         if(finishedOnPlayerInput)
         {
            TSInputHandler.instance.input("Done");
         }
      }
      
      public function mutateState(p:Player, state:Object) : void
      {
         state.isSpinner = p == this._currentSpinner;
      }
   }
}

import jackboxgames.thewheel.data.StartingSlice;
import jackboxgames.thewheel.wheel.Slice;
import jackboxgames.thewheel.wheel.Wheel;

class PlacedStartingSlice
{
   private var _startingSlice:StartingSlice;
   
   private var _placedSlice:Slice;
   
   private var _onWheel:Wheel;
   
   public function PlacedStartingSlice(startingSlice:StartingSlice, placedSlice:Slice)
   {
      super();
      this._startingSlice = startingSlice;
      this._placedSlice = placedSlice;
   }
   
   public function get startingSlice() : StartingSlice
   {
      return this._startingSlice;
   }
   
   public function get placedSlice() : Slice
   {
      return this._placedSlice;
   }
}

import flash.display.MovieClip;
import jackboxgames.algorithm.*;
import jackboxgames.events.*;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.thewheel.wheel.*;
import jackboxgames.thewheel.wheel.slicedata.*;
import jackboxgames.thewheel.widgets.*;
import jackboxgames.utils.*;

class SpinMeter
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _ratio:Number;
   
   public function SpinMeter(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function get ratio() : Number
   {
      return this._ratio;
   }
   
   public function set ratio(val:Number) : void
   {
      this._ratio = val;
      this._mc.meterFill.meter.scaleX = this._ratio;
   }
   
   public function reset() : void
   {
      JBGUtil.reset([this._shower]);
      this.ratio = 0;
   }
   
   public function setup() : void
   {
      this.ratio = 0;
   }
   
   public function setFinalSpin() : void
   {
      this._shower.doAnimation("LastSpin",Nullable.NULL_FUNCTION);
   }
}

import flash.display.MovieClip;
import jackboxgames.algorithm.*;
import jackboxgames.events.*;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.thewheel.wheel.*;
import jackboxgames.thewheel.wheel.slicedata.*;
import jackboxgames.thewheel.widgets.*;
import jackboxgames.utils.*;

class Pot
{
   private var _mc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _amountTf:ExtendableTextField;
   
   public function Pot(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
      this._amountTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.amount);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function reset() : void
   {
      JBGUtil.reset([this._shower]);
      JBGUtil.gotoFrame(this._mc.icon,"Default");
   }
   
   public function updateAmount(newAmount:int) : void
   {
      this._amountTf.text = TheWheelTextUtil.formattedPot(newAmount);
   }
   
   public function doBehavior(behavior:String, icon:String, doneFn:Function) : void
   {
      if(Boolean(icon))
      {
         JBGUtil.gotoFrame(this._mc.icon,icon);
      }
      this._shower.doAnimation(behavior,doneFn);
   }
}

import flash.display.MovieClip;
import jackboxgames.algorithm.*;
import jackboxgames.events.*;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.thewheel.wheel.*;
import jackboxgames.thewheel.wheel.slicedata.*;
import jackboxgames.thewheel.widgets.*;
import jackboxgames.utils.*;

class CurrentSlice
{
   private var _mc:MovieClip;
   
   private var _containerMc:MovieClip;
   
   private var _titleMc:MovieClip;
   
   private var _descriptionMc:MovieClip;
   
   private var _shower:MovieClipShower;
   
   private var _titleTf:ExtendableTextField;
   
   private var _descriptionTf:ExtendableTextField;
   
   private var _playerNamesTf:ExtendableTextField;
   
   public function CurrentSlice(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._containerMc = this._mc.container;
      this._shower = new MovieClipShower(this._mc);
      this._titleMc = this._mc.container.sliceName;
      this._descriptionMc = this._mc.container.description;
      this._titleTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._titleMc);
      this._descriptionTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._descriptionMc.description);
      this._playerNamesTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._descriptionMc.playerNames);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function reset() : void
   {
      JBGUtil.reset([this._shower]);
      JBGUtil.gotoFrame(this._containerMc,"Default");
      JBGUtil.gotoFrame(this._descriptionMc,"Default");
   }
   
   public function updateWithSlice(s:Slice, w:Wheel, currentSpinner:Player) : void
   {
      var playersNeighboring:Array = null;
      this._titleTf.text = s.params.data.name;
      if(s.params.type == GameConstants.SLICE_TYPE_RESERVED)
      {
         this._descriptionTf.text = "";
         JBGUtil.gotoFrame(this._descriptionMc,"Default");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_MULTIPLIER)
      {
         this._descriptionTf.text = "";
         JBGUtil.gotoFrame(this._descriptionMc,"Default");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_PLAYER)
      {
         this._playerNamesTf.text = TheWheelTextUtil.formattedPlayerList(PlayerSliceData(s.params.data).playersWithStake);
         JBGUtil.gotoFrame(this._descriptionMc,"PlayerSlice");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_WINNER)
      {
         this._descriptionTf.text = s.params.data.description;
         JBGUtil.gotoFrame(this._descriptionMc,"Default");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_POINTS)
      {
         this._playerNamesTf.text = TheWheelTextUtil.formattedPlayerList([currentSpinner]);
         JBGUtil.gotoFrame(this._descriptionMc,"PlayerSlice");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_POINTS_FOR_PLAYER)
      {
         this._playerNamesTf.text = TheWheelTextUtil.formattedPlayerList([PointsForPlayerSliceData(s.params.data).player]);
         JBGUtil.gotoFrame(this._descriptionMc,"PlayerSlice");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_NEIGHBOR)
      {
         playersNeighboring = MapFold.process(w.getSlicesAdjacentTo(s),function(neighboring:Slice, ... args):Array
         {
            if(neighboring.params.type == GameConstants.SLICE_TYPE_PLAYER)
            {
               return PlayerSliceData(neighboring.params.data).playersWithStake;
            }
            if(neighboring.params.type == GameConstants.SLICE_TYPE_BONUS)
            {
               return [BonusSliceData(neighboring.params.data).owner];
            }
            return [];
         },ArrayUtil.FOLD_CONCAT);
         playersNeighboring.push(currentSpinner);
         playersNeighboring = ArrayUtil.deduplicated(playersNeighboring);
         this._playerNamesTf.text = TheWheelTextUtil.formattedPlayerList(playersNeighboring);
         JBGUtil.gotoFrame(this._descriptionMc,"PlayerSlice");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_ANSWER)
      {
         this._descriptionTf.text = "";
         JBGUtil.gotoFrame(this._descriptionMc,"Default");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_BAD)
      {
         this._playerNamesTf.text = TheWheelTextUtil.formattedPlayerList(GameState.instance.players.filter(ArrayUtil.GENERATE_FILTER_EXCEPT(currentSpinner)));
         JBGUtil.gotoFrame(this._descriptionMc,"PlayerSlice");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_BONUS)
      {
         this._playerNamesTf.text = TheWheelTextUtil.formattedPlayerList([BonusSliceData(s.params.data).owner]);
         JBGUtil.gotoFrame(this._descriptionMc,"PlayerSlice");
      }
      else if(s.params.type == GameConstants.SLICE_TYPE_AUDIENCE)
      {
         this._playerNamesTf.text = TheWheelTextUtil.formattedPlayerList([currentSpinner]);
         JBGUtil.gotoFrame(this._descriptionMc,"PlayerSlice");
      }
      else
      {
         Assert.assert(false,"What slice type are we even looking at???");
      }
   }
   
   public function updateWithSliceEffect(potentialEffect:SliceTypePotentialEffect, effect:ISliceEffect, w:Wheel) : void
   {
      this._titleTf.text = potentialEffect.name;
      this._descriptionTf.text = potentialEffect.description;
      JBGUtil.gotoFrame(this._descriptionMc,"Default");
   }
   
   public function setSelected(isSelected:Boolean, doneFn:Function) : void
   {
      JBGUtil.gotoFrameWithFn(this._containerMc,isSelected ? "Selected" : "Unselected",MovieClipEvent.EVENT_ANIMATION_DONE,doneFn);
   }
}

import flash.display.MovieClip;
import jackboxgames.algorithm.*;
import jackboxgames.events.*;
import jackboxgames.text.*;
import jackboxgames.thewheel.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.utils.*;
import jackboxgames.thewheel.wheel.*;
import jackboxgames.thewheel.wheel.slicedata.*;
import jackboxgames.thewheel.widgets.*;
import jackboxgames.utils.*;

class ScoreboardPlayerWidget
{
   private var _mc:MovieClip;
   
   private var _player:Player;
   
   private var _shower:MovieClipShower;
   
   private var _avatarMc:MovieClip;
   
   private var _nameText:ExtendableTextField;
   
   private var _scoreText:ExtendableTextField;
   
   public function ScoreboardPlayerWidget(mc:MovieClip)
   {
      super();
      this._mc = mc;
      this._shower = new MovieClipShower(this._mc);
      this._avatarMc = this._mc.avatar;
      this._nameText = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.playerName);
      this._scoreText = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.score);
   }
   
   public function get shower() : MovieClipShower
   {
      return this._shower;
   }
   
   public function get player() : Player
   {
      return this._player;
   }
   
   public function reset() : void
   {
      JBGUtil.reset([this._shower]);
      JBGUtil.gotoFrame(this._avatarMc,"Default");
      this._player = null;
   }
   
   public function setup(p:Player) : void
   {
      this._player = p;
      this._nameText.text = TheWheelTextUtil.formattedPlayerName(this._player);
      JBGUtil.gotoFrame(this._avatarMc,this._player.avatar.frame);
   }
   
   public function appear(oldWinner:Boolean) : void
   {
      if(!this._player)
      {
         return;
      }
      this._scoreText.text = TheWheelTextUtil.formattedPlayerScore(this._player);
      this._shower.setShown(true,function():void
      {
         if(oldWinner)
         {
            _shower.doAnimation("AppearHighlighted",Nullable.NULL_FUNCTION);
         }
      });
   }
   
   public function highlightPlayer() : void
   {
      this._shower.doAnimation("Highlight",Nullable.NULL_FUNCTION);
   }
}

