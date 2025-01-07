package jackboxgames.thewheel
{
   import jackboxgames.algorithm.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.logger.*;
   import jackboxgames.model.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.services.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.thewheel.audience.*;
   import jackboxgames.thewheel.data.*;
   import jackboxgames.thewheel.gameplay.*;
   import jackboxgames.thewheel.utils.*;
   import jackboxgames.thewheel.wheel.*;
   import jackboxgames.thewheel.wheel.slicedata.*;
   import jackboxgames.utils.*;
   
   public class GameState extends JBGGameState
   {
      private static var _instance:GameState;
      
      private var _jsonData:TheWheelJsonData;
      
      private var _debug:TheWheelDebug;
      
      private var _audienceDataProvider:IAudienceDataProvider;
      
      private var _playerControllerStateProviders:Array;
      
      private var _textDescriptions:TextDescriptions;
      
      private var _mainWheelControlPlayers:Array;
      
      private var _playerIndexWithMainWheelControl:int;
      
      private var _numWinWheelSpins:int;
      
      private var _roundData:Array;
      
      private var _currentRoundIndex:int;
      
      private var _currentTriviaIndex:int;
      
      private var _previousWinner:Player;
      
      private var _winner:Player;
      
      public function GameState(ts:IEngineAPI, options:Object = null)
      {
         super(ts,options);
         this._jsonData = new TheWheelJsonData();
         this._debug = new TheWheelDebug();
         this._playerControllerStateProviders = [];
         this._textDescriptions = new TextDescriptions(this);
      }
      
      public static function initialize(ts:IEngineAPI) : void
      {
         _instance = new GameState(ts,{"audience":true});
         _instance.minPlayers = GameConstants.MIN_PLAYERS;
      }
      
      public static function get instance() : GameState
      {
         return _instance;
      }
      
      public function get jsonData() : TheWheelJsonData
      {
         return this._jsonData;
      }
      
      public function get debug() : TheWheelDebug
      {
         return this._debug;
      }
      
      public function get audienceData() : IAudienceDataProvider
      {
         return this._audienceDataProvider;
      }
      
      public function get textDescriptions() : TextDescriptions
      {
         return this._textDescriptions;
      }
      
      public function addPlayerControllerStateProvider(p:IPlayerControllerStateProvider) : void
      {
         this._playerControllerStateProviders.push(p);
      }
      
      public function removePlayerControllerStateProvider(p:IPlayerControllerStateProvider) : void
      {
         ArrayUtil.removeElementFromArray(this._playerControllerStateProviders,p);
      }
      
      public function get playerWithMainWheelControl() : Player
      {
         return this._mainWheelControlPlayers[this._playerIndexWithMainWheelControl];
      }
      
      public function get numWinWheelSpins() : int
      {
         return this._numWinWheelSpins;
      }
      
      public function get currentRoundData() : RoundData
      {
         return Boolean(this._roundData) ? this._roundData[this._currentRoundIndex] : null;
      }
      
      public function get currentTriviaIndex() : int
      {
         return this._currentTriviaIndex;
      }
      
      public function get currentTriviaNum() : int
      {
         return this._currentTriviaIndex + 1;
      }
      
      public function get currentTriviaType() : TriviaType
      {
         return this.currentRoundData.triviaList.types[this._currentTriviaIndex];
      }
      
      public function get currentTriviaData() : RoundTriviaData
      {
         return this.currentRoundData.triviaData[this._currentTriviaIndex];
      }
      
      public function get isFinalTriviaForRound() : Boolean
      {
         return this._currentTriviaIndex == this.currentRoundData.triviaList.types.length - 1;
      }
      
      public function get playersInWinnerMode() : Array
      {
         return players.filter(function(p:Player, ... args):Boolean
         {
            return p.isInWinnerMode;
         });
      }
      
      public function get roundIndex() : int
      {
         return this._currentRoundIndex;
      }
      
      public function get roundNum() : int
      {
         return this._currentRoundIndex + 1;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this.screenOrganizer,this.audioRegistrationStack]);
         this._playerControllerStateProviders = [];
         this._textDescriptions.reset();
         this._resetContentActionPackages();
      }
      
      public function setAudienceDataProvider(p:IAudienceDataProvider) : void
      {
         this._audienceDataProvider = p;
      }
      
      public function setupForNewLobby() : void
      {
         this._roundData = null;
         this._previousWinner = null;
      }
      
      override protected function createPlayer(index:int, sessionId:int, userId:String, name:String) : JBGPlayer
      {
         var p:Player = new Player();
         var unusedAvatars:Array = this.jsonData.avatars.filter(function(a:Avatar, ... args):Boolean
         {
            var otherP:* = undefined;
            for each(otherP in _players)
            {
               if(otherP.avatar == a)
               {
                  return false;
               }
            }
            return true;
         });
         p.initialize(index,sessionId,userId,name,new ObjectEntity(_wsClient,"player:" + sessionId,{},["r id:" + sessionId]));
         p.setupForNewLobby(ArrayUtil.getRandomElement(unusedAvatars));
         p.addEventListener(Player.EVENT_CONTROLLER_STATE_UPDATE_REQUEST,function(e:EventWithData):void
         {
            _updatePlayerControllerState(Player(e.target));
         });
         this._updatePlayerControllerState(p);
         return p;
      }
      
      override protected function _generateInfoForPlayer(p:JBGPlayer) : Object
      {
         var wheelPlayer:Player = Player(p);
         return {
            "name":wheelPlayer.name.val,
            "avatarId":wheelPlayer.avatar.id
         };
      }
      
      override protected function _getACLsForInfo(p:JBGPlayer) : Array
      {
         return ["r *"];
      }
      
      private function _updatePlayerControllerState(p:Player) : void
      {
         var provider:IPlayerControllerStateProvider = null;
         var state:Object = p.generatePlayerControllerState();
         state.isWinner = p == this._winner;
         for each(provider in this._playerControllerStateProviders)
         {
            provider.mutateState(p,state);
         }
         _wsClient.setObject("playerstate:" + p.sessionId.val,state,["r id:" + p.sessionId.val]);
      }
      
      override public function goBackToMenu() : void
      {
         _cancelAllAndGoBack("Main","goBackToMenu");
      }
      
      override public function goBackToLobby() : void
      {
         _cancelAllAndGoBack("Main","goBackToLobby");
      }
      
      public function registerContentActionPackages() : void
      {
         GameConstants.TRIVIA_TYPES_ALL.forEach(function(tt:TriviaType, ... args):void
         {
            if(Boolean(tt.actionPackageClass))
            {
               ActionPackageClassManager.instance.registerClass(tt.actionPackageName,tt.actionPackageClass,null);
            }
         });
         GameConstants.SLICE_TYPES_ALL.forEach(function(st:SliceType, ... args):void
         {
            st.potentialEffects.forEach(function(e:SliceTypePotentialEffect, ... args):void
            {
               if(Boolean(e.actionPackageClass))
               {
                  ActionPackageClassManager.instance.registerClass(e.actionPackageName,e.actionPackageClass,null);
               }
            });
         });
      }
      
      public function loadContentActionPackages() : void
      {
         GameConstants.TRIVIA_TYPES_ALL.forEach(function(tt:TriviaType, ... args):void
         {
            if(Boolean(tt.actionPackageClass))
            {
               _getActionPackageRefForTriviaType(tt).load();
               _getTriviaTypeActionPackage(tt).load();
            }
         });
         GameConstants.SLICE_TYPES_ALL.forEach(function(st:SliceType, ... args):void
         {
            st.potentialEffects.forEach(function(e:SliceTypePotentialEffect, ... args):void
            {
               if(Boolean(e.actionPackageClass))
               {
                  _getActionPackageRefForPotentialEffect(e).load();
               }
            });
         });
      }
      
      private function _getActionPackageRefForPotentialEffect(e:SliceTypePotentialEffect) : IActionPackageRef
      {
         return IActionPackageRef(_ts.getActionPackage(_ts.activeExport.projectName + ":" + e.actionPackageName));
      }
      
      private function _getEffectActionPackageForPotentialEffect(e:SliceTypePotentialEffect) : EffectActionPackage
      {
         var apRef:IActionPackageRef = this._getActionPackageRefForPotentialEffect(e);
         if(!apRef)
         {
            return null;
         }
         if(!(apRef.actionPackage is EffectActionPackage))
         {
            return null;
         }
         return EffectActionPackage(apRef.actionPackage);
      }
      
      private function _getActionPackageRefForTriviaType(tt:TriviaType) : IActionPackageRef
      {
         return IActionPackageRef(_ts.getActionPackage(_ts.activeExport.projectName + ":" + tt.actionPackageName));
      }
      
      private function _getTriviaTypeActionPackage(tt:TriviaType) : TriviaTypeActionPackage
      {
         var apRef:IActionPackageRef = this._getActionPackageRefForTriviaType(tt);
         if(!apRef)
         {
            return null;
         }
         return TriviaTypeActionPackage(apRef.actionPackage);
      }
      
      private function _resetContentActionPackages() : void
      {
         GameConstants.TRIVIA_TYPES_ALL.forEach(function(tt:TriviaType, ... args):void
         {
            var ap:TriviaTypeActionPackage = _getTriviaTypeActionPackage(tt);
            if(Boolean(ap))
            {
               ap.reset();
            }
         });
         GameConstants.SLICE_TYPES_ALL.forEach(function(st:SliceType, ... args):void
         {
            st.potentialEffects.forEach(function(e:SliceTypePotentialEffect, ... args):void
            {
               var ap:EffectActionPackage = _getEffectActionPackageForPotentialEffect(e);
               if(Boolean(ap))
               {
                  ap.reset();
               }
            });
         });
      }
      
      private function _reshuffleMainWheelControlPlayers() : void
      {
         this._mainWheelControlPlayers = ArrayUtil.shuffled(players);
      }
      
      public function setupNewGame() : void
      {
         var p:Player = null;
         ++this.numGamesPlayedEver;
         ++this.numGamesPlayedWithSamePlayers;
         ++this.numGamesPlayedSession;
         for each(p in players)
         {
            p.reset();
         }
         setRoomBlob(_prepareSharedObject());
         this._reshuffleMainWheelControlPlayers();
         this._playerIndexWithMainWheelControl = 0;
         this._numWinWheelSpins = 0;
         this._currentRoundIndex = 0;
         this._roundData = [];
         this._winner = null;
         for each(p in players)
         {
            this._updatePlayerControllerState(p);
         }
      }
      
      public function setupNewRound() : void
      {
         var roundSetup:RoundSetup = null;
         var types:Array = null;
         var i:int = 0;
         var validRoundSetups:Array = null;
         Logger.debug("Setting up new round: " + this._currentRoundIndex + "(num = " + this.roundNum + ")");
         if(Boolean(this.debug.forcedTriviaTypeId))
         {
            types = [];
            for(i = 0; i < this.debug.forcedTriviaTypeNumTimes; i++)
            {
               types.push(this.debug.forcedTriviaTypeId);
            }
            roundSetup = new RoundSetup();
            roundSetup.load({
               "id":"DEBUG",
               "skeleton":{"types":types}
            });
            Logger.debug("Using debug skeleton with type: " + this.debug.forcedTriviaTypeId);
         }
         else
         {
            validRoundSetups = this.jsonData.roundSetups.filter(function(r:RoundSetup, ... args):Boolean
            {
               return r.getIsValid(expressionParserDataDelegate);
            });
            Logger.debug("Valid round setups: " + validRoundSetups.map(function(r:RoundSetup, ... args):String
            {
               return r.id;
            }).join(", "));
            Assert.assert(validRoundSetups.length > 0);
            roundSetup = ArrayUtil.getRandomElement(validRoundSetups);
            Logger.debug("Chose: " + roundSetup.id);
         }
         this._roundData[this._currentRoundIndex] = new RoundData(this._currentRoundIndex,roundSetup,this._currentRoundIndex > 0 ? this._roundData[this._currentRoundIndex - 1] : null);
         this._currentTriviaIndex = 0;
      }
      
      public function finishRound() : void
      {
         var bonusSliceWinners:Array = null;
         this.currentRoundData.finishRound();
         if(Boolean(this._winner))
         {
            bonusSliceWinners = this._roundData.map(function(rd:RoundData, ... args):Player
            {
               return rd.bonusPlayer;
            });
            if(ArrayUtil.deduplicated(bonusSliceWinners).length == 1)
            {
               Trophy.instance.unlock(GameConstants.TROPHY_EARN_EVERY_POWER_SLICE);
            }
         }
      }
      
      public function recordWinWheelSpin() : void
      {
         ++this._numWinWheelSpins;
      }
      
      public function advanceToNextRound() : void
      {
         ++this._currentRoundIndex;
      }
      
      public function setupNewTrivia() : void
      {
         var contentData:Object;
         var previousContent:ITriviaContent = null;
         var filters:Array = [SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER,SettingsUtil.US_CENTRIC_CONTENT_FILTER];
         previousContent = (function():ITriviaContent
         {
            if(_currentTriviaIndex == 0)
            {
               if(_currentRoundIndex > 0)
               {
                  return RoundTriviaData(ArrayUtil.last(RoundData(_roundData[_currentRoundIndex - 1]).triviaData)).content;
               }
               return null;
            }
            return RoundTriviaData(currentRoundData.triviaData[_currentTriviaIndex - 1]).content;
         })();
         if(Boolean(previousContent))
         {
            filters.push(function(o:Object, ... args):Boolean
            {
               if(previousContent.subtype && o.subtype && previousContent.subtype == o.subtype)
               {
                  return false;
               }
               if(previousContent.category && o.category && previousContent.category == o.category)
               {
                  return false;
               }
               return true;
            });
         }
         if(Boolean(this.debug.forcedTriviaContentId))
         {
            filters = [function(c:Object, ... args):Boolean
            {
               return c.id == debug.forcedTriviaContentId;
            }];
         }
         contentData = ArrayUtil.first(ContentManager.instance.getRandomUnusedContent(this.currentTriviaType.contentType,1,filters));
         Assert.assert(contentData);
         TSUtil.setTemplateRootPath(JBGLoader.instance.getUrl(contentData.path));
         this.currentRoundData.setupTrivia(this._currentTriviaIndex,new this.currentTriviaType.contentClass(contentData));
      }
      
      public function advanceToNextTrivia() : void
      {
         ++this._currentTriviaIndex;
      }
      
      public function generatePlayerSlice() : SliceParameters
      {
         return SliceParameters.CREATE(GameConstants.SLICE_TYPE_PLAYER);
      }
      
      public function generateBonusSliceForPlayer(p:Player) : SliceParameters
      {
         return SliceParameters.CREATE_WITH_OWNER(GameConstants.SLICE_TYPE_BONUS,p);
      }
      
      public function generateFillerSlice() : SliceParameters
      {
         var type:SliceType = ArrayUtil.getRandomElement(GameConstants.SLICE_TYPES_FILLER);
         return SliceParameters.CREATE(type);
      }
      
      public function generateBadSlice() : SliceParameters
      {
         return SliceParameters.CREATE(GameConstants.SLICE_TYPE_BAD);
      }
      
      public function runTriviaResultTest(scores:Array) : void
      {
         var roundDataBefore:Array;
         var roundIndexBefore:int;
         var triviaIndexBefore:int;
         var res:TriviaResult = null;
         var playerListToStringList:Function = function(playerList:Array):Array
         {
            return playerList.map(function(p:Player, i:int, a:Array):String
            {
               return scores[p.index.val];
            });
         };
         var playersBefore:Array = _players;
         _players = scores.map(function(score:int, i:int, a:Array):Player
         {
            var p:* = new Player();
            p.index.val = i;
            return p;
         });
         roundDataBefore = this._roundData;
         roundIndexBefore = this._currentRoundIndex;
         triviaIndexBefore = this._currentTriviaIndex;
         this._currentRoundIndex = 0;
         this._currentTriviaIndex = 0;
         this._roundData = [new RoundData(0,ArrayUtil.getRandomElement(this.jsonData.roundSetups),roundDataBefore[0])];
         this._roundData[0].setupTrivia(0,null);
         res = this.generateTriviaResult(new TestTriviaType(_players,scores),true);
         Logger.debug("Players: " + playerListToStringList(_players).join(", "));
         Logger.debug("Top Half Players: " + playerListToStringList(res.topHalfPlayers).join(", "));
         Logger.debug("Bottom Half Players: " + playerListToStringList(res.bottomHalfPlayers).join(", "));
         Logger.debug("Standout Players: " + playerListToStringList(res.standoutPlayers).join(", "));
         Logger.debug("Places: " + _players.map(function(p:Player, ... args):String
         {
            return String(res.placeIndices.getDataForPlayer(p));
         }).join(", "));
         Logger.debug("topScore: " + res.topScore);
         Logger.debug("average: " + ArrayUtil.average(scores));
         Logger.debug("everyoneTied: " + res.everyoneTied);
         Logger.debug("bonusPlayer: " + res.bonusPlayer.index.val);
         Logger.debug("bonusSliceWasFromBrokenTie: " + res.bonusSliceWasFromBrokenTie);
         _players = playersBefore;
         this._roundData = roundDataBefore;
         this._currentRoundIndex = roundIndexBefore;
         this._currentTriviaIndex = triviaIndexBefore;
      }
      
      public function generateTriviaResult(forTrivia:TriviaTypeActionPackage, giveBonusSlice:Boolean) : TriviaResult
      {
         var pivotFnPerPlayerCount:Object;
         var pivotFn:Function;
         var pivot:int;
         var average:Number;
         var bonusPlayer:Player;
         var bonusSlice:SliceParameters;
         var bonusSliceWasFromBrokenTie:Boolean;
         var bonusSliceTiedPlayers:Array;
         var standOutPlayers:Array;
         var topHalfPlayersWithBestPerformance:Array;
         var playersWithTopScore:Array;
         var everyoneTied:Boolean;
         var result:TriviaResult;
         var placeIndices:PerPlayerContainer = null;
         var topHalfPlayers:Array = null;
         var bottomHalfPlayers:Array = null;
         var lowestTopHalfPerformance:int = 0;
         var highestBottomHalfPerformance:int = 0;
         var bestPerformanceInTopHalf:int = 0;
         var topScore:int = 0;
         var graduate:Array = null;
         var demote:Array = null;
         var eligiblePlayers:Array = null;
         var minTiesBroken:int = 0;
         var playersWithMinTies:Array = null;
         var sortedPlayers:Array = ArrayUtil.copy(this.players).sort(function(a:Player, b:Player):int
         {
            return forTrivia.getPerformanceForPlayer(b) - forTrivia.getPerformanceForPlayer(a);
         });
         placeIndices = new PerPlayerContainer();
         sortedPlayers.forEach(function(p:Player, i:int, a:Array):void
         {
            var placeIndex:int = 0;
            var previous:Player = null;
            if(i == 0)
            {
               placeIndex = forTrivia.getPerformanceForPlayer(p) > 0 ? 0 : -1;
            }
            else
            {
               previous = a[i - 1];
               if(forTrivia.getPerformanceForPlayer(p) == 0)
               {
                  placeIndex = -1;
               }
               else if(forTrivia.getPerformanceForPlayer(p) == forTrivia.getPerformanceForPlayer(previous))
               {
                  placeIndex = placeIndices.getDataForPlayer(previous);
               }
               else
               {
                  placeIndex = i;
               }
            }
            placeIndices.setDataForPlayer(p,placeIndex);
         });
         pivotFnPerPlayerCount = {
            2:Math.floor,
            3:Math.ceil,
            4:Math.floor,
            5:Math.floor,
            6:Math.floor,
            7:Math.floor,
            8:Math.floor
         };
         pivotFn = pivotFnPerPlayerCount[GameState.instance.players.length];
         Assert.assert(pivotFn != null);
         pivot = pivotFn(Number(sortedPlayers.length) / 2);
         topHalfPlayers = sortedPlayers.slice(0,pivot);
         bottomHalfPlayers = sortedPlayers.slice(pivot);
         lowestTopHalfPerformance = forTrivia.getPerformanceForPlayer(ArrayUtil.last(topHalfPlayers));
         highestBottomHalfPerformance = forTrivia.getPerformanceForPlayer(ArrayUtil.first(bottomHalfPlayers));
         average = ArrayUtil.average(sortedPlayers.map(function(p:Player, ... args):Number
         {
            return forTrivia.getPerformanceForPlayer(p);
         }));
         if(lowestTopHalfPerformance >= average)
         {
            graduate = bottomHalfPlayers.filter(function(p:Player, ... args):Boolean
            {
               return forTrivia.getPerformanceForPlayer(p) == lowestTopHalfPerformance;
            });
            graduate.forEach(function(p:Player, ... args):void
            {
               topHalfPlayers.push(p);
               ArrayUtil.removeElementFromArray(bottomHalfPlayers,p);
            });
         }
         else
         {
            demote = topHalfPlayers.filter(function(p:Player, ... args):Boolean
            {
               return forTrivia.getPerformanceForPlayer(p) == highestBottomHalfPerformance;
            });
            demote.forEach(function(p:Player, ... args):void
            {
               bottomHalfPlayers.push(p);
               ArrayUtil.removeElementFromArray(topHalfPlayers,p);
            });
         }
         bonusPlayer = null;
         bonusSlice = null;
         bonusSliceWasFromBrokenTie = false;
         bonusSliceTiedPlayers = [];
         if(giveBonusSlice)
         {
            eligiblePlayers = forTrivia.getPlayersEligibleForBonusSlice();
            if(eligiblePlayers.length > 0)
            {
               if(eligiblePlayers.length == 1)
               {
                  bonusPlayer = ArrayUtil.first(eligiblePlayers);
               }
               else
               {
                  bonusSliceTiedPlayers = eligiblePlayers;
                  minTiesBroken = MapFold.process(bonusSliceTiedPlayers,function(p:Player, ... args):int
                  {
                     return p.tiesBroken;
                  },MapFold.FOLD_MIN);
                  playersWithMinTies = bonusSliceTiedPlayers.filter(function(p:Player, ... args):Boolean
                  {
                     return p.tiesBroken == minTiesBroken;
                  });
                  bonusPlayer = ArrayUtil.getRandomElement(playersWithMinTies);
                  bonusPlayer.recordBrokenTie();
               }
               bonusSlice = this.generateBonusSliceForPlayer(bonusPlayer);
               this.currentRoundData.setBonusSlice(bonusPlayer,bonusSlice);
            }
         }
         standOutPlayers = [];
         bestPerformanceInTopHalf = MapFold.process(topHalfPlayers,function(p:Player, ... args):int
         {
            return forTrivia.getPerformanceForPlayer(p);
         },MapFold.FOLD_MAX);
         topHalfPlayersWithBestPerformance = topHalfPlayers.filter(function(p:Player, ... args):Boolean
         {
            return forTrivia.getPerformanceForPlayer(p) == bestPerformanceInTopHalf;
         });
         if(topHalfPlayers.length == 1 || topHalfPlayersWithBestPerformance.length <= topHalfPlayers.length / 2)
         {
            standOutPlayers = topHalfPlayersWithBestPerformance;
         }
         topScore = forTrivia.getPerformanceForPlayer(ArrayUtil.first(sortedPlayers));
         playersWithTopScore = sortedPlayers.filter(function(p:Player, ... args):Boolean
         {
            return forTrivia.getPerformanceForPlayer(p) == topScore;
         });
         everyoneTied = playersWithTopScore.length == sortedPlayers.length;
         result = new TriviaResult(topHalfPlayers,bottomHalfPlayers,standOutPlayers,placeIndices,topScore,playersWithTopScore,everyoneTied,bonusPlayer,bonusSlice,bonusSliceWasFromBrokenTie,bonusSliceTiedPlayers);
         this.currentTriviaData.recordResult(result);
         return result;
      }
      
      public function setupSpinResult(param:DoSpinResultParam) : SpinResult
      {
         var chosenEffect:SliceTypePotentialEffect;
         var ap:EffectActionPackage;
         var validEffects:Array = null;
         var spinResult:SpinResult = new SpinResult();
         if(Boolean(this.debug.forcedBonusEffectId) && param.spunSlice.params.type == GameConstants.SLICE_TYPE_BONUS)
         {
            validEffects = param.spunSlice.params.type.potentialEffects.filter(function(e:SliceTypePotentialEffect, ... args):Boolean
            {
               return e.id == debug.forcedBonusEffectId;
            });
         }
         else if(Boolean(this.debug.forcedAudienceEffectId) && param.spunSlice.params.type == GameConstants.SLICE_TYPE_AUDIENCE)
         {
            validEffects = param.spunSlice.params.type.potentialEffects.filter(function(e:SliceTypePotentialEffect, ... args):Boolean
            {
               return e.id == debug.forcedAudienceEffectId;
            });
         }
         else
         {
            Logger.info("Getting slice effect for slice type: " + param.spunSlice.params.type.id);
            validEffects = param.spunSlice.params.type.potentialEffects.filter(function(e:SliceTypePotentialEffect, ... args):Boolean
            {
               var isValid:* = e.getIsValid(expressionParserDataDelegate);
               var desc:* = Boolean(e.isValid) ? e.isValid.description : "null";
               Logger.info(e.id + "(" + isValid + "), ->" + desc);
               return isValid;
            });
            Logger.info("spinMeterRatio = " + expressionParserDataDelegate.getKeywordValue("spinMeterRatio"));
         }
         Assert.assert(validEffects.length > 0);
         chosenEffect = ArrayUtil.getRandomElement(validEffects);
         spinResult.chosenPotentialEffect = chosenEffect;
         spinResult.effect = new chosenEffect.effectClass();
         spinResult.effect.setup(param,spinResult);
         ap = this._getEffectActionPackageForPotentialEffect(chosenEffect);
         if(Boolean(ap))
         {
            ap.setup(param,spinResult);
         }
         return spinResult;
      }
      
      public function advancePlayerWithMainWheelControl() : void
      {
         ++this._playerIndexWithMainWheelControl;
         if(this._playerIndexWithMainWheelControl >= this._mainWheelControlPlayers.length)
         {
            this._playerIndexWithMainWheelControl = 0;
         }
      }
      
      public function get playersThatSpunTheLeast() : Array
      {
         var minSpins:int = 0;
         minSpins = MapFold.process(players,function(p:Player, ... args):int
         {
            return p.numSpins;
         },MapFold.FOLD_MIN);
         return players.filter(function(p:Player, ... args):Boolean
         {
            return p.numSpins == minSpins;
         });
      }
      
      public function setPlayerAsWinner(p:Player) : void
      {
         this._winner = p;
         this._winner.requestToUpdateControllerState();
         this.textDescriptions.addTextDescription("TEXT_DESCRIPTION_WINNER",TheWheelTextUtil.formattedPlayerName(this._winner));
         this.textDescriptions.updateEntity();
         if(this._previousWinner == this._winner)
         {
            Trophy.instance.unlock(GameConstants.TROPHY_BACK_TO_BACK_WINNER);
         }
         this._previousWinner = this.winner;
      }
      
      public function get winner() : Player
      {
         return this._winner;
      }
      
      public function get lowestScore() : int
      {
         return MapFold.process(players,function(p:Player, ... args):int
         {
            return p.score.val;
         },MapFold.FOLD_MIN);
      }
      
      public function get playersRanked() : Array
      {
         return ArrayUtil.copy(players).sort(function(a:Player, b:Player):int
         {
            if(a.score.val == b.score.val)
            {
               return 0;
            }
            return a.score.val > b.score.val ? -1 : 1;
         });
      }
      
      public function getRankOfPlayer(rankee:Player) : int
      {
         return players.filter(function(p:Player, ... args):Boolean
         {
            return p == rankee || p.score.val > rankee.score.val;
         }).length;
      }
      
      public function get scoreDifferenceBetweenFirstAndLast() : int
      {
         return this.playersRanked[0].score.val - this.playersRanked[this.playersRanked.length - 1].score.val;
      }
      
      public function get playersWithPositivePointsPending() : Array
      {
         return players.filter(function(p:Player, ... args):Boolean
         {
            return p.totalPendingScoreChanges > 0;
         });
      }
      
      public function get playersWithNegativePointsPending() : Array
      {
         return players.filter(function(p:Player, ... args):Boolean
         {
            return p.totalPendingScoreChanges < 0;
         });
      }
      
      override protected function get _artifactType() : String
      {
         return BuildConfig.instance.configVal("gameName") + "Game";
      }
      
      override protected function get _artifact() : Object
      {
         var simplePlayers:Array = _players.map(function(p:Player, ... args):Object
         {
            var simplePlayer:* = p.toSimpleObject();
            simplePlayer.isWinner = _winner == p;
            return simplePlayer;
         });
         return {
            "locale":locale,
            "players":simplePlayers
         };
      }
   }
}

import jackboxgames.algorithm.*;
import jackboxgames.thewheel.data.*;
import jackboxgames.thewheel.gameplay.*;

class TestTriviaType extends TriviaTypeActionPackage
{
   private var _players:Array;
   
   private var _scores:Array;
   
   public function TestTriviaType(players:Array, scores:Array)
   {
      super(null);
      this._players = players;
      this._scores = scores;
   }
   
   override protected function get _linkage() : String
   {
      return null;
   }
   
   override protected function get _triviaType() : TriviaType
   {
      return new TriviaType({"id":"Dummy"});
   }
   
   override public function getPerformanceForPlayer(p:Player) : int
   {
      return this._scores[p.index.val];
   }
   
   override public function getPlayersEligibleForBonusSlice() : Array
   {
      var bestScore:int = 0;
      bestScore = MapFold.process(this._players,function(p:Player, ... args):int
      {
         return getPerformanceForPlayer(p);
      },MapFold.FOLD_MIN);
      return GameState.instance.players.filter(function(p:Player, ... args):Boolean
      {
         return getPerformanceForPlayer(p) == bestScore;
      });
   }
}

import jackboxgames.talkshow.actions.JBGActionPackage;
import jackboxgames.talkshow.api.SWFActionPackage;
import jackboxgames.thewheel.gameplay.TriviaTypeActionPackage;

