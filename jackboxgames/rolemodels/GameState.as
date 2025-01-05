package jackboxgames.rolemodels
{
   import flash.display.*;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.blobcast.modules.*;
   import jackboxgames.events.*;
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.rolemodels.actionpackages.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.data.analysis.*;
   import jackboxgames.rolemodels.model.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   
   public class GameState extends BlobCastGameState
   {
      
      private static var _instance:GameState;
      
      public static const SORT_TYPE_ASCENDING:String = "Ascending";
      
      public static const SORT_TYPE_DESCENDING:String = "Descending";
       
      
      private var _screenOrganizer:DisplayObjectOrganizer;
      
      private var _roundIndex:int;
      
      private var _rounds:Array;
      
      private var _currentReveal:IRevealData;
      
      private var _revealFactory:RevealFactory;
      
      private var _debugRound:RoundData;
      
      private var _finalRoleTagsPerPlayer:PerPlayerContainer;
      
      private var _audioRegistrationStack:AudioEventRegistrationStack;
      
      private var _dataAnalysisContent:Object;
      
      private var _voting:Voting;
      
      private var _gameAudience:RMAudience;
      
      private var _artifactState:ArtifactData;
      
      public function GameState(ts:IEngineAPI, options:Object = null)
      {
         super(ts,options);
         this._revealFactory = new RevealFactory();
         this._finalRoleTagsPerPlayer = new PerPlayerContainer();
         this._voting = _sessions.registerModule(new Voting(BuildConfig.instance.configVal("gameName") + " Vote")) as Voting;
         this._gameAudience = new RMAudience(this.audience,this._voting);
         this._audioRegistrationStack = new AudioEventRegistrationStack();
      }
      
      public static function get instance() : GameState
      {
         return _instance;
      }
      
      public static function initialize(ts:IEngineAPI) : void
      {
         _instance = new GameState(ts,{
            "audience":true,
            "vote":true,
            "comments":false
         });
         _instance.minPlayers = GameConstants.MIN_PLAYERS;
      }
      
      public function get audioRegistrationStack() : AudioEventRegistrationStack
      {
         return this._audioRegistrationStack;
      }
      
      public function get dataAnalysisContentId() : String
      {
         return this._dataAnalysisContent.id;
      }
      
      public function get dataAnalysisContentType() : String
      {
         return this._dataAnalysisContent.contentType;
      }
      
      public function set dataAnalysisContent(val:Object) : void
      {
         this._dataAnalysisContent = val;
         _ts.g.templateRootPath = JBGLoader.instance.getUrl(this._dataAnalysisContent.path);
         DebugTextWidget.sharedInstance.text = this._dataAnalysisContent.contentType + " " + this._dataAnalysisContent.id;
      }
      
      public function get artifactState() : ArtifactData
      {
         return this._artifactState;
      }
      
      public function get screenOrganizer() : DisplayObjectOrganizer
      {
         return this._screenOrganizer;
      }
      
      public function get roundIndex() : int
      {
         return this._roundIndex;
      }
      
      public function get rounds() : Array
      {
         return this.isDebugRevealMode || this._isDebugFinalRole ? [this._debugRound] : this._rounds;
      }
      
      public function set debugRound(round:RoundData) : void
      {
         this._debugRound = round;
      }
      
      public function get currentRound() : RoundData
      {
         return this.isDebugRevealMode || this._isDebugFinalRole ? this._debugRound : this._rounds[this._roundIndex];
      }
      
      public function get currentReveal() : IRevealData
      {
         return this._currentReveal;
      }
      
      public function set currentReveal(reveal:IRevealData) : void
      {
         if(this.isDebugRevealMode)
         {
            this._currentReveal = reveal;
         }
      }
      
      public function get isDebugRevealMode() : Boolean
      {
         return Boolean(_ts.g.hasOwnProperty("debugReveal")) && Boolean(_ts.g["debugReveal"]);
      }
      
      private function get _isDebugFinalRole() : Boolean
      {
         return Boolean(_ts.g.hasOwnProperty("debugFinalRole")) && Boolean(_ts.g["debugFinalRole"]);
      }
      
      public function get isRevealAvailable() : Boolean
      {
         return this._currentReveal != null;
      }
      
      public function get isAutoVoteOn() : Boolean
      {
         return TuneableValues.instance.getValue("AutoVote").val;
      }
      
      public function get finalRoleTagsInUse() : Array
      {
         return this._finalRoleTagsPerPlayer.getAllData();
      }
      
      public function get isGameOver() : Boolean
      {
         return this._roundIndex >= GameConstants.MAX_NUMBER_OF_ROUNDS;
      }
      
      public function get gameAudience() : RMAudience
      {
         return this._gameAudience;
      }
      
      public function get playerToAwardAudienceBonus() : Player
      {
         var role:RoleData = null;
         for each(role in this.currentReveal.rolesInvolved)
         {
            if(this.currentRound.playerWonAudienceVotedBonusRole(role))
            {
               return role.playerAssignedRole;
            }
         }
         return null;
      }
      
      public function get playersWhoVotedIncorrectly() : Array
      {
         var incorrectPlayers:Array = null;
         incorrectPlayers = [];
         players.forEach(function(player:Player, ... args):void
         {
            var role:RoleData = null;
            for each(role in currentReveal.rolesInvolved)
            {
               if(!ArrayUtil.arrayContainsElement(GameState.instance.currentReveal.primaryPlayers,currentRound.getPlayerVotedForRole(player,role)) && currentRound.getPlayerVotedForRole(player,role) != null)
               {
                  incorrectPlayers.push(player);
               }
            }
         });
         return incorrectPlayers;
      }
      
      public function get playersWhoVotedForAssignedPlayers() : Array
      {
         var playersWhoVoted:Array = null;
         var otherAssignedPlayers:Array = null;
         playersWhoVoted = [];
         otherAssignedPlayers = ArrayUtil.intersection(ArrayUtil.difference(players,this.currentRound.unassignedPlayers),ArrayUtil.difference(players,this.currentReveal.primaryPlayers));
         players.forEach(function(player:Player, ... args):void
         {
            var role:RoleData = null;
            for each(role in currentReveal.rolesInvolved)
            {
               if(ArrayUtil.arrayContainsElement(otherAssignedPlayers,currentRound.getPlayerVotedForRole(player,role)))
               {
                  playersWhoVoted.push(player);
               }
            }
         });
         return playersWhoVoted;
      }
      
      public function get playersWhoVotedForLosingUnassignedPlayers() : Array
      {
         return ArrayUtil.difference(this.playersWhoVotedIncorrectly,this.playersWhoVotedForAssignedPlayers);
      }
      
      public function get playersWithPendingPoints() : Array
      {
         return players.filter(function(p:Player, ... args):Boolean
         {
            return p.pendingPoints.val != 0;
         });
      }
      
      public function get firstTimeSeeingReveal() : Boolean
      {
         var rd:RoundData = null;
         var reveal:IRevealData = null;
         for each(rd in this.rounds)
         {
            for each(reveal in rd.reveals)
            {
               if(reveal.revealConstants.name == this.currentReveal.revealConstants.name)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function get primaryPlayersAreTied() : Boolean
      {
         var p:Player = null;
         var tieAmount:int = 0;
         var voteAmount:int = 0;
         if(!this._currentReveal.roleData || this._currentReveal.primaryPlayers.length == 0)
         {
            return false;
         }
         var voteAmounts:Array = [];
         for each(p in this._currentReveal.primaryPlayers)
         {
            voteAmounts.push(this.currentRound.getVotesForPlayer(p,this._currentReveal.roleData).length);
         }
         tieAmount = ArrayUtil.first(voteAmounts);
         for each(voteAmount in voteAmounts)
         {
            if(voteAmount != tieAmount)
            {
               return false;
            }
         }
         return true;
      }
      
      public function isTagUsedThisRound(tag:TagData) : Boolean
      {
         var protoTag:String = null;
         for each(protoTag in this.currentRound.protoTagsUsed)
         {
            if(tag.protoTag == protoTag)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isTagUsedThisGame(tag:TagData) : Boolean
      {
         var round:RoundData = null;
         var protoTag:String = null;
         for each(round in this.rounds)
         {
            for each(protoTag in round.protoTagsUsed)
            {
               if(tag.protoTag == protoTag)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      override public function destroy() : void
      {
         this._audioRegistrationStack.reset();
         super.destroy();
      }
      
      public function reset() : void
      {
         this._audioRegistrationStack.reset();
      }
      
      public function disposePlayerPictures() : void
      {
         var p:Player = null;
         for each(p in players)
         {
            p.reset();
         }
      }
      
      public function goBackToMenu() : void
      {
         this.disposePlayerPictures();
         _cancelAllAndGoBack("Main","goBackToMenu");
      }
      
      public function goBackToLobby() : void
      {
         this.disposePlayerPictures();
         _cancelAllAndGoBack("Main","goBackToLobby");
      }
      
      public function startGame() : void
      {
         ++this.numGamesPlayedEver;
         ++this.numGamesPlayedWithSamePlayers;
         ++this.numGamesPlayedSession;
         this._roundIndex = 0;
         this._rounds = [];
         this._finalRoleTagsPerPlayer.reset();
         players.forEach(function(p:Player, ... args):void
         {
            p.score.reset();
         });
         this._gameAudience.reset(true);
         this._artifactState = new ArtifactData(GameConstants.MAX_NUMBER_OF_ROUNDS,GameState.instance.players);
         if(this.isDebugRevealMode)
         {
            this._artifactState.addReveal(this._roundIndex,this._currentReveal);
         }
      }
      
      public function endGame() : void
      {
      }
      
      override protected function createPlayer(index:int, userId:String, name:String, options:Object, p:* = null) : *
      {
         if(p == null)
         {
            p = new Player();
         }
         p.initialize(index,userId,name,{"persistent":false});
         return p;
      }
      
      override protected function _onDisconnect(evt:EventWithData) : void
      {
         this.goBackToMenu();
         super._onDisconnect(evt);
      }
      
      public function getPlayerListFromString(s:String) : Array
      {
         var p:Player = null;
         if(s == null || s == "")
         {
            return players;
         }
         var potentialArray:* = VariableUtil.getVariableValue(s);
         if(potentialArray && potentialArray is Array)
         {
            return potentialArray;
         }
         for each(p in GameState.instance.players)
         {
            if(p.userId.val == s)
            {
               return [p];
            }
            if(p.index.val == s)
            {
               return [p];
            }
         }
         Assert.assert(false);
         return null;
      }
      
      public function setupScreenOrganizer(d:DisplayObjectContainer) : void
      {
         this._screenOrganizer = new DisplayObjectOrganizer(d);
      }
      
      public function advanceRoundNumber() : void
      {
         ++this._roundIndex;
      }
      
      public function addRoundData(roundData:RoundData) : void
      {
         this.rounds.push(roundData);
      }
      
      public function cacheCurrentReveal() : void
      {
         var roundData:RoundData = this.rounds[GameState.instance.roundIndex];
         if(Boolean(this._currentReveal))
         {
            roundData.addReveal(this._currentReveal);
            if(!this.isDebugRevealMode)
            {
               this._currentReveal = null;
            }
         }
      }
      
      public function generateNextReveal() : void
      {
         var unassignedInitialRoles:Array = null;
         var nonMajorityRole:RoleData = null;
         var nonSelfVotedRole:RoleData = null;
         var desperateRole:RoleData = null;
         var nonTiedRole:RoleData = null;
         var role:RoleData = null;
         var roundData:RoundData = this.currentRound;
         if(!roundData.allPlayersAssignedRoles)
         {
            unassignedInitialRoles = roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL);
            if(TuneableValues.instance.getValue("PluralityMode").val)
            {
               this._currentReveal = this._revealFactory.getNextPluralityReveal(unassignedInitialRoles,roundData);
               if(this._currentReveal != null)
               {
                  return;
               }
            }
            else
            {
               for each(role in unassignedInitialRoles)
               {
                  this._currentReveal = this._revealFactory.getNextMajorityReveal(role,roundData);
                  if(this._currentReveal != null)
                  {
                     return;
                  }
               }
            }
            for each(nonMajorityRole in unassignedInitialRoles)
            {
               this._currentReveal = this._revealFactory.getNextTiebreakerReveal(nonMajorityRole,roundData);
               if(this._currentReveal != null)
               {
                  return;
               }
            }
            for each(nonSelfVotedRole in unassignedInitialRoles)
            {
               this._currentReveal = this._revealFactory.getNextRelaxedTiebreakerReveal(nonSelfVotedRole,roundData);
               if(this._currentReveal != null)
               {
                  return;
               }
            }
            if(roundData.unassignedPlayers.length == 1 && unassignedInitialRoles.length > 0 && this.currentRound.getPreviousRevealsOfType(RevealConstants.REVEAL_DATA_TYPES.tie).length < GameConstants.MINIMUM_TIEBREAKER_REVEALS_PER_ROUND)
            {
               this._currentReveal = this._revealFactory.getAbundanceReveal(ArrayUtil.getRandomElement(unassignedInitialRoles),roundData);
               if(this._currentReveal != null)
               {
                  return;
               }
            }
            this._currentReveal = this._revealFactory.getNextPluralityReveal(unassignedInitialRoles,roundData);
            if(this._currentReveal != null)
            {
               return;
            }
            for each(desperateRole in unassignedInitialRoles)
            {
               this._currentReveal = this._revealFactory.getNextDesperateTiebreakerReveal(desperateRole,roundData);
               if(this._currentReveal != null)
               {
                  return;
               }
            }
            for each(nonTiedRole in unassignedInitialRoles)
            {
               this._currentReveal = this._revealFactory.getNextSinglePlayerReveal(nonTiedRole,roundData);
               if(this._currentReveal != null)
               {
                  return;
               }
            }
         }
      }
      
      public function generateNextAnalysis() : void
      {
         if(this.currentRound.getPreviousRevealsOfType(RevealConstants.REVEAL_DATA_TYPES.justPlaying).length + this.currentRound.getPreviousRevealsOfType(RevealConstants.REVEAL_DATA_TYPES.tie).length < GameConstants.MAX_MINIGAMES_PER_ROUND)
         {
            this._currentReveal = this._revealFactory.getNextJustPlayingReveal(this.currentRound);
         }
      }
      
      public function getPlayersSorted(propFn:Function, sortType:String) : Array
      {
         var sorted:Array = ArrayUtil.copy(players);
         sorted.sort(function(a:Player, b:Player):int
         {
            var aProp:* = propFn(a);
            var bProp:* = propFn(b);
            if(aProp == bProp)
            {
               return a.index.val - b.index.val;
            }
            if(sortType == SORT_TYPE_ASCENDING)
            {
               return aProp - bProp;
            }
            if(sortType == SORT_TYPE_DESCENDING)
            {
               return bProp - aProp;
            }
            return bProp - aProp;
         });
         return sorted;
      }
      
      public function playerAssignedRoles(player:Player) : Array
      {
         var roles:Array = null;
         roles = [];
         this.rounds.forEach(function(round:RoundData, ... args):void
         {
            roles = roles.concat(round.allRoles.filter(function(role:RoleData, ... args):Boolean
            {
               return role.playerAssignedRole == player;
            }));
         });
         return roles;
      }
      
      public function unusedRolesForPlayer(player:Player) : Array
      {
         return this.playerAssignedRoles(player).filter(function(role:RoleData, ... args):Boolean
         {
            return !role.usedInDataAnalysis;
         });
      }
      
      public function playerAssignedTags(player:Player) : Array
      {
         var tags:Array = null;
         tags = [];
         this.playerAssignedRoles(player).forEach(function(role:RoleData, ... args):void
         {
            tags = ArrayUtil.union(tags,role.tags);
         });
         return tags;
      }
      
      public function getTagResolutionMatchups() : Array
      {
         var p1:Player = null;
         var p2:Player = null;
         var rolesWithSharedTags:Array = null;
         var matchups:Array = [];
         for each(p1 in _players)
         {
            for each(p2 in ArrayUtil.difference(_players,[p1]))
            {
               rolesWithSharedTags = [];
               this.unusedRolesForPlayer(p1).forEach(function(role1:RoleData, ... args):void
               {
                  unusedRolesForPlayer(p2).forEach(function(role2:RoleData, ... args):void
                  {
                     var tag1:TagData = null;
                     var tag2:TagData = null;
                     var sharedTags:Array = [];
                     for each(tag1 in role1.tags)
                     {
                        for each(tag2 in role2.tags)
                        {
                           if(tag1.protoTag == tag2.protoTag)
                           {
                              sharedTags.push(new TagPair(tag1,tag2));
                           }
                        }
                     }
                     if(sharedTags.length > 0)
                     {
                        rolesWithSharedTags.push(new RolePairAndTags(role1,role2,sharedTags));
                     }
                  });
               });
               if(rolesWithSharedTags.length > 0)
               {
                  matchups.push(new DataAnalysisMatchup(p1,p2,rolesWithSharedTags));
               }
            }
         }
         return matchups;
      }
      
      public function getTagContradictionMatchups() : Array
      {
         var p:Player = null;
         var rolesWithFightingTags:Array = null;
         var role1:RoleData = null;
         var role2:RoleData = null;
         var fightingTags:Array = null;
         var tag1:TagData = null;
         var tag2:TagData = null;
         var matchups:Array = [];
         for each(p in _players)
         {
            rolesWithFightingTags = [];
            for each(role1 in this.unusedRolesForPlayer(p))
            {
               for each(role2 in ArrayUtil.difference(this.unusedRolesForPlayer(p),[role1]))
               {
                  fightingTags = [];
                  for each(tag1 in role1.tags)
                  {
                     for each(tag2 in role2.tags)
                     {
                        if(TagData.tagsAreOpposites(tag1,tag2))
                        {
                           fightingTags.push(new TagPair(tag1,tag2));
                        }
                     }
                  }
                  if(fightingTags.length > 0)
                  {
                     rolesWithFightingTags.push(new RolePairAndTags(role1,role2,fightingTags));
                  }
               }
            }
            if(rolesWithFightingTags.length > 0)
            {
               matchups.push(new DataAnalysisMatchup(p,null,rolesWithFightingTags));
            }
         }
         return matchups;
      }
      
      public function getTagFightMatchups() : Array
      {
         var p1:Player = null;
         var p2:Player = null;
         var rolesWithFightingTags:Array = null;
         var matchups:Array = [];
         for each(p1 in _players)
         {
            for each(p2 in ArrayUtil.difference(_players,[p1]))
            {
               rolesWithFightingTags = [];
               this.unusedRolesForPlayer(p1).forEach(function(role1:RoleData, ... args):void
               {
                  unusedRolesForPlayer(p2).forEach(function(role2:RoleData, ... args):void
                  {
                     var p1Tag:TagData = null;
                     var p2Tag:TagData = null;
                     var fightingTags:Array = [];
                     for each(p1Tag in role1.tags)
                     {
                        for each(p2Tag in role2.tags)
                        {
                           if(TagData.tagsAreOpposites(p1Tag,p2Tag))
                           {
                              fightingTags.push(new TagPair(p1Tag,p2Tag));
                           }
                        }
                     }
                     if(fightingTags.length > 0)
                     {
                        rolesWithFightingTags.push(new RolePairAndTags(role1,role2,fightingTags));
                     }
                  });
               });
               if(rolesWithFightingTags.length > 0)
               {
                  matchups.push(new DataAnalysisMatchup(p1,p2,rolesWithFightingTags));
               }
            }
         }
         return matchups;
      }
      
      public function getPlayersWithPowers() : Array
      {
         var p:Player = null;
         var rolesWithPowers:Array = null;
         var role:RoleData = null;
         var tag:TagData = null;
         var playersWithPowers:Array = [];
         for each(p in _players)
         {
            rolesWithPowers = [];
            for each(role in this.unusedRolesForPlayer(p))
            {
               for each(tag in role.tags)
               {
                  if(ArrayUtil.arrayContainsElement(TagCorpusManager.STEAL_POWER_TAGS,tag.protoTag) && !this.isTagUsedThisRound(tag))
                  {
                     rolesWithPowers.push(new RoleWithPower(role,tag,Powers.STEAL));
                  }
                  else if(ArrayUtil.arrayContainsElement(TagCorpusManager.DONATE_POWER_TAGS,tag.protoTag) && !this.isTagUsedThisRound(tag))
                  {
                     rolesWithPowers.push(new RoleWithPower(role,tag,Powers.DONATE));
                  }
                  else if(ArrayUtil.arrayContainsElement(TagCorpusManager.GIVE_POWER_TAGS,tag.rawString) && !this.isTagUsedThisRound(tag))
                  {
                     rolesWithPowers.push(new RoleWithPower(role,tag,Powers.GIVE));
                  }
               }
            }
            if(rolesWithPowers.length > 0)
            {
               playersWithPowers.push(new PlayerWithPowerfulRoles(p,rolesWithPowers));
            }
         }
         return playersWithPowers;
      }
      
      public function updatePlayerPlaces() : void
      {
         var sortedPlayers:Array = GameState.instance.getPlayersSorted(Player.PROPERTY_FUNCTION_SCORE,GameState.SORT_TYPE_DESCENDING);
         sortedPlayers.forEach(function(player:Player, place:int, ... args):void
         {
            player.placeIndex = place;
         });
      }
      
      public function generatePlayerFinalRoles() : void
      {
         var sortedPlayers:Array = GameState.instance.getPlayersSorted(Player.PROPERTY_FUNCTION_SCORE,GameState.SORT_TYPE_DESCENDING);
         sortedPlayers.forEach(function(player:Player, ... args):void
         {
            if(!_finalRoleTagsPerPlayer.hasDataForPlayer(player))
            {
               _finalRoleTagsPerPlayer.setDataForPlayer(player,RMUtil.getFinalRoleArray(player,GameConstants.NUMBER_OF_TAGS_FOR_FINAL_ROLE));
            }
         });
      }
      
      public function getPlayerFinalRoleTags(player:Player) : Array
      {
         Assert.assert(this._finalRoleTagsPerPlayer.getDataForPlayer(player) != null);
         return this._finalRoleTagsPerPlayer.getDataForPlayer(player);
      }
      
      public function getPlayerFinalRole(player:Player) : String
      {
         var finalRole:String = null;
         finalRole = "";
         this.getPlayerFinalRoleTags(player).forEach(function(tag:String, index:int, array:Array):void
         {
            finalRole += tag;
            if(index != array.length - 1)
            {
               finalRole += " ";
            }
         });
         return finalRole;
      }
      
      override protected function get _artifactType() : String
      {
         return BuildConfig.instance.configVal("gameName") + "Game";
      }
      
      override protected function get _artifact() : Object
      {
         return this._artifactState.data;
      }
      
      public function awardDoubleDownPointsForRole(role:RoleData, points:int, pointsSelf:int) : void
      {
         players.forEach(function(player:Player, ... args):void
         {
            if(currentRound.playerWonDoubleDown(player,role))
            {
               currentRound.addDoubleDownWinner(player);
               if(player == role.playerAssignedRole)
               {
                  player.pendingPoints.val += pointsSelf;
                  Trophy.instance.unlock(GameConstants.TROPHY_SELF_DOUBLE_DOWN);
               }
               else
               {
                  player.pendingPoints.val += points;
               }
            }
         });
      }
      
      public function awardDoubleDownPointsForCurrentReveal() : void
      {
         var role:RoleData = null;
         for each(role in this.currentReveal.rolesInvolved)
         {
            this.awardDoubleDownPointsForRole(role,this.currentReveal.revealConstants.pointsForDoublingDown,this.currentReveal.revealConstants.pointsForDoublingDownSelf);
         }
      }
   }
}
