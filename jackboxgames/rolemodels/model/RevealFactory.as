package jackboxgames.rolemodels.model
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.actionpackages.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.data.analysis.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.utils.*;
   
   public class RevealFactory
   {
       
      
      public function RevealFactory()
      {
         super();
      }
      
      public function getNextMajorityReveal(role:RoleData, roundData:RoundData) : IRevealData
      {
         var eligibleMajorityReveals:Array = this._eligibleMajorityReveals(role,roundData);
         if(eligibleMajorityReveals.length > 0)
         {
            eligibleMajorityReveals.sortOn("felocity",Array.NUMERIC | Array.DESCENDING);
            return this._revealFactory(eligibleMajorityReveals[0],role,roundData);
         }
         return null;
      }
      
      public function getNextPluralityReveal(roles:Array, roundData:RoundData) : IRevealData
      {
         var eligiblePluralityReveals:Array = this._eligiblePluralityReveals(roles,roundData);
         if(eligiblePluralityReveals.length > 0)
         {
            eligiblePluralityReveals.sortOn("numVotes",Array.NUMERIC | Array.DESCENDING);
            if(eligiblePluralityReveals[0].numVotes > 0)
            {
               return this._revealFactory(eligiblePluralityReveals[0].constants,eligiblePluralityReveals[0].role,roundData);
            }
         }
         return null;
      }
      
      public function getNextTiebreakerReveal(role:RoleData, roundData:RoundData) : IRevealData
      {
         var eligibleTiebreakerReveals:Array = this._eligibleTiebreakerReveals(role,roundData);
         if(eligibleTiebreakerReveals.length > 0)
         {
            eligibleTiebreakerReveals.sortOn("felocity",Array.NUMERIC | Array.DESCENDING);
            return this._revealFactory(eligibleTiebreakerReveals[0],role,roundData);
         }
         return null;
      }
      
      public function getNextRelaxedTiebreakerReveal(role:RoleData, roundData:RoundData) : IRevealData
      {
         var eligibleTiebreakerReveals:Array = this._eligibleRelaxedTiebreakerReveal(role,roundData);
         if(eligibleTiebreakerReveals.length > 0)
         {
            eligibleTiebreakerReveals.sortOn("felocity",Array.NUMERIC | Array.DESCENDING);
            return this._revealFactory(eligibleTiebreakerReveals[0],role,roundData);
         }
         return null;
      }
      
      public function getNextDesperateTiebreakerReveal(role:RoleData, roundData:RoundData) : IRevealData
      {
         var eligibleTiebreakerReveals:Array = this._eligibleDesperateTiebreakerReveal(role,roundData);
         if(eligibleTiebreakerReveals.length > 0)
         {
            eligibleTiebreakerReveals.sortOn("felocity",Array.NUMERIC | Array.DESCENDING);
            return this._revealFactory(eligibleTiebreakerReveals[0],role,roundData);
         }
         return null;
      }
      
      public function getNextSinglePlayerReveal(role:RoleData, roundData:RoundData) : IRevealData
      {
         var eligibleSinglePlayerReveals:Array = this._eligibleSinglePlayerReveals(role,roundData);
         if(eligibleSinglePlayerReveals.length > 0)
         {
            eligibleSinglePlayerReveals.sortOn("felocity",Array.NUMERIC | Array.DESCENDING);
            return this._revealFactory(eligibleSinglePlayerReveals[0],role,roundData);
         }
         return null;
      }
      
      public function getNextJustPlayingReveal(roundData:RoundData) : IRevealData
      {
         var eligibleJustPlayingReveals:Array = this._eligibleJustPlayingReveals(roundData);
         if(eligibleJustPlayingReveals.length > 0)
         {
            return this._revealFactory(eligibleJustPlayingReveals[0],null,roundData);
         }
         return null;
      }
      
      public function getAbundanceReveal(role:RoleData, roundData:RoundData) : IRevealData
      {
         if(roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.CONSOLATION).length > 0)
         {
            return this._revealFactory(GameConstants.REVEAL_CONSTANTS.abundance,role,roundData);
         }
         return null;
      }
      
      private function _eligibleMajorityReveals(role:RoleData, roundData:RoundData) : Array
      {
         var reveals:Array = [];
         if(roundData.getMajorityVotesFiltered(role).length == 1)
         {
            if(roundData.getVotesForPlayer(roundData.getMajorityVotesFiltered(role)[0],role).length >= GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length])
            {
               reveals.push(GameConstants.REVEAL_CONSTANTS.majority);
            }
         }
         return this._filterChoosable(reveals);
      }
      
      private function _eligiblePluralityReveals(roles:Array, roundData:RoundData) : Array
      {
         var role:RoleData = null;
         var playerWithPlurality:Player = null;
         var reveals:Array = [];
         for each(role in roles)
         {
            if(roundData.isFilteredPlurality(role))
            {
               playerWithPlurality = ArrayUtil.first(ArrayUtil.difference(roundData.getSortedPlayers(role),roundData.getAllPlayersAssignedRoles()));
               reveals.push({
                  "constants":GameConstants.REVEAL_CONSTANTS.majority,
                  "role":role,
                  "numVotes":roundData.getVotesForPlayer(playerWithPlurality,role).length
               });
            }
         }
         return reveals;
      }
      
      private function _eligibleTiebreakerReveals(role:RoleData, roundData:RoundData) : Array
      {
         var reveals:Array = [];
         if(roundData.getMajorityVotesFiltered(role).length == GameConstants.REVEAL_CONSTANTS.judgement.minPlayers && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            if(ArrayUtil.difference(GameState.instance.players,roundData.playersInvolvedInResult(role)).length > 0 && roundData.playersVotedForSelf(roundData.getMajorityVotesFiltered(role),role))
            {
               reveals.push(GameConstants.REVEAL_CONSTANTS.judgement);
            }
         }
         if(roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.getInCharacter,role) && roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.getInCharacter.minPlayers && GameState.instance.players.length - roundData.getMajorityVotesFiltered(role).length >= 2 && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.getInCharacter);
         }
         if(roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.split.minPlayers && roundData.getMajorityVotesFiltered(role).length < GameState.instance.players.length && roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.split,role) && roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.split,role).roles.length >= roundData.getMajorityVotesFiltered(role).length && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.split);
         }
         if(roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.fightTiebreaker,role) && roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.fightTiebreaker.minPlayers && GameState.instance.players.length - roundData.getMajorityVotesFiltered(role).length >= 1 && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.fightTiebreaker);
         }
         if(roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.methodAct,role) && roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.methodAct.minPlayers && GameState.instance.players.length - roundData.getMajorityVotesFiltered(role).length >= 1 && roundData.playersVotedForSelf(roundData.getMajorityVotesFiltered(role),role) && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.methodAct);
         }
         if(roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.trivia.minPlayers && roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.trivia,role) && roundData.playersVotedForSelf(roundData.getMajorityVotesFiltered(role),role) && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.trivia);
         }
         return this._filterChoosable(reveals).filter(function(revealConstants:RevealConstants, ... args):Boolean
         {
            var previousReveal:* = undefined;
            var previousRole:* = undefined;
            for each(previousReveal in roundData.reveals)
            {
               if(roundData.getPreviousRevealsOfName(revealConstants.name).length >= revealConstants.maximumPerRound)
               {
                  return false;
               }
               for each(previousRole in previousReveal.rolesInvolved)
               {
                  if(previousRole.name == role.name)
                  {
                     return false;
                  }
               }
            }
            return true;
         });
      }
      
      private function _eligibleRelaxedTiebreakerReveal(role:RoleData, roundData:RoundData) : Array
      {
         var reveals:Array = [];
         if(roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.methodAct,role) && roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.methodAct.minPlayers && GameState.instance.players.length - roundData.getMajorityVotesFiltered(role).length > 0 && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.methodAct);
         }
         if(roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.trivia.minPlayers && roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.trivia,role) && roundData.highestVotedPlayerHasAtLeastOneVote(role))
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.trivia);
         }
         return this._filterChoosable(reveals).filter(function(revealConstants:RevealConstants, ... args):Boolean
         {
            var previousReveal:* = undefined;
            var previousRole:* = undefined;
            for each(previousReveal in roundData.reveals)
            {
               if(roundData.getPreviousRevealsOfName(revealConstants.name).length >= revealConstants.maximumPerRound)
               {
                  return false;
               }
               for each(previousRole in previousReveal.rolesInvolved)
               {
                  if(previousRole.name == role.name)
                  {
                     return false;
                  }
               }
            }
            return true;
         });
      }
      
      private function _eligibleDesperateTiebreakerReveal(role:RoleData, roundData:RoundData) : Array
      {
         var otherRoles:Array = null;
         var reveals:Array = [];
         if(roundData.getMajorityVotesFiltered(role).length >= GameConstants.REVEAL_CONSTANTS.recount.minPlayers)
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.recount);
         }
         if(Boolean(roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.getInCharacter,role)) && roundData.unassignedPlayers.length >= GameConstants.REVEAL_CONSTANTS.getInCharacter.minPlayers)
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.getInCharacter);
         }
         if(Boolean(roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.fightTiebreaker,role)) && roundData.unassignedPlayers.length >= GameConstants.REVEAL_CONSTANTS.fightTiebreaker.minPlayers)
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.fightTiebreaker);
         }
         if(Boolean(roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.methodAct,role)) && roundData.unassignedPlayers.length >= GameConstants.REVEAL_CONSTANTS.methodAct.minPlayers)
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.methodAct);
         }
         if(roundData.unassignedPlayers.length > GameConstants.REVEAL_CONSTANTS.tagChoice.minPlayers && roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).length > 1)
         {
            otherRoles = roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).filter(function(otherRole:RoleData, ... args):Boolean
            {
               return role.name != otherRole.name && TagData.differentTags(role.tags,otherRole.tags).length > 0;
            });
            if(otherRoles.length > 0)
            {
               reveals.push(GameConstants.REVEAL_CONSTANTS.tagChoice);
            }
         }
         return this._filterChoosable(reveals).filter(function(revealConstants:RevealConstants, ... args):Boolean
         {
            var previousReveal:* = undefined;
            var previousRole:* = undefined;
            for each(previousReveal in roundData.reveals)
            {
               if(roundData.getPreviousRevealsOfName(revealConstants.name).length >= revealConstants.maximumPerRound)
               {
                  return false;
               }
               for each(previousRole in previousReveal.rolesInvolved)
               {
                  if(previousRole.name == role.name)
                  {
                     return false;
                  }
               }
            }
            return true;
         });
      }
      
      private function _eligibleSinglePlayerReveals(role:RoleData, roundData:RoundData) : Array
      {
         var otherRoles:Array = null;
         var reveals:Array = [];
         if(roundData.unassignedPlayers.length >= GameConstants.REVEAL_CONSTANTS.freebie.minPlayers && roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).length > 0)
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.freebie);
         }
         if(roundData.unassignedPlayers.length == GameConstants.REVEAL_CONSTANTS.abundance.minPlayers && roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).length > 0 && roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.CONSOLATION).length > 0)
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.abundance);
         }
         if(roundData.unassignedPlayers.length == GameConstants.REVEAL_CONSTANTS.tagChoice.minPlayers && roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).length > 1)
         {
            otherRoles = roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).filter(function(otherRole:RoleData, ... args):Boolean
            {
               return role.name != otherRole.name && TagData.differentTags(role.tags,otherRole.tags).length > 0;
            });
            if(otherRoles.length > 0)
            {
               reveals.push(GameConstants.REVEAL_CONSTANTS.tagChoice);
            }
         }
         return this._filterChoosable(reveals).filter(function(revealConstants:RevealConstants, ... args):Boolean
         {
            var previousReveal:* = undefined;
            var previousRole:* = undefined;
            for each(previousReveal in roundData.reveals)
            {
               if(roundData.getPreviousRevealsOfName(revealConstants.name).length >= revealConstants.maximumPerRound)
               {
                  return false;
               }
               for each(previousRole in previousReveal.rolesInvolved)
               {
                  if(previousReveal.revealConstants.name == revealConstants.name && previousRole.name == role.name)
                  {
                     return false;
                  }
               }
            }
            return true;
         });
      }
      
      private function _eligibleJustPlayingReveals(roundData:RoundData) : Array
      {
         var reveals:Array = [];
         var resolutionMatchupData:DataAnalysisMatchupMetadata = DataAnalysisUtil.getBestMatchupsWithContent(DataAnalysisUtil.MATCHUP_TYPE_RESOLUTION);
         var contradictionMatchupData:DataAnalysisMatchupMetadata = DataAnalysisUtil.getBestMatchupsWithContent(DataAnalysisUtil.MATCHUP_TYPE_CONTRADICTION);
         var fightMatchupData:DataAnalysisMatchupMetadata = DataAnalysisUtil.getBestMatchupsWithContent(DataAnalysisUtil.MATCHUP_TYPE_FIGHT);
         var dataAnalysisMatchups:Array = [resolutionMatchupData,contradictionMatchupData,fightMatchupData];
         dataAnalysisMatchups = dataAnalysisMatchups.filter(function(matchup:DataAnalysisMatchupMetadata, ... args):Boolean
         {
            return matchup.matchups.length > 0;
         });
         if(dataAnalysisMatchups.length > 0)
         {
            dataAnalysisMatchups.sort(function(matchupA:DataAnalysisMatchupMetadata, matchupB:DataAnalysisMatchupMetadata):int
            {
               if(matchupA.weight != matchupB.weight)
               {
                  return matchupB.weight - matchupA.weight;
               }
               return matchupB.revealConstants.felocity - matchupA.revealConstants.felocity;
            });
            reveals.push(ArrayUtil.first(dataAnalysisMatchups).revealConstants);
         }
         else if(GameState.instance.getPlayersWithPowers().length > 0)
         {
            reveals.push(GameConstants.REVEAL_CONSTANTS.powers);
         }
         return this._filterChoosable(reveals);
      }
      
      private function _filterChoosable(reveals:Array) : Array
      {
         return reveals.filter(function(revealConstants:RevealConstants, ... args):Boolean
         {
            return revealConstants.choosable;
         });
      }
      
      private function _revealFactory(revealConstants:RevealConstants, role:RoleData, roundData:RoundData) : IRevealData
      {
         var judgePlayer:Array = null;
         var freebieHighestVotedPlayerRole:Object = null;
         switch(revealConstants.name)
         {
            case GameConstants.REVEAL_CONSTANTS.majority.name:
               return this._constructMajorityReveal(revealConstants,role,roundData);
            case GameConstants.REVEAL_CONSTANTS.recount.name:
               return new RecountData(revealConstants,role,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers),GameState.instance.players);
            case GameConstants.REVEAL_CONSTANTS.judgement.name:
               judgePlayer = ArrayUtil.getRandomElements(ArrayUtil.difference(GameState.instance.players,roundData.playersInvolvedInResult(role)));
               return new JudgementData(revealConstants,role,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers),judgePlayer);
            case GameConstants.REVEAL_CONSTANTS.getInCharacter.name:
               return new GetInCharacterData(revealConstants,role,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers),ArrayUtil.difference(GameState.instance.players,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers)),roundData.getRolePromptFromRevealContent(revealConstants,role).question,roundData.getRolePromptFromRevealContent(revealConstants,role).idx);
            case GameConstants.REVEAL_CONSTANTS.powers.name:
               return this._constructPowersReveal(revealConstants);
            case GameConstants.REVEAL_CONSTANTS.split.name:
               return new SplitData(revealConstants,role,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers),ArrayUtil.difference(GameState.instance.players,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers)),roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.split,role).question,roundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.split,role).roles.slice(0,revealConstants.maxPlayers).map(function(roleContent:Object, index:int, ... args):RoleData
               {
                  var role:* = new RoleData(roleContent.name,roleContent.hasOwnProperty("short") ? String(roleContent.short) : String(roleContent.name),RoleData.ROLE_SOURCE.SPLIT,roleContent.tags,index,roundData.contentId,roundData.category);
                  GameState.instance.currentRound.addRole(role);
                  return role;
               }),roundData.getRolePromptFromRevealContent(revealConstants,role).idx);
            case GameConstants.REVEAL_CONSTANTS.methodAct.name:
               return new MethodActData(revealConstants,role,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers),ArrayUtil.difference(GameState.instance.players,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers)),roundData.getRolePromptFromRevealContent(revealConstants,role).question,roundData.getRolePromptFromRevealContent(revealConstants,role).idx);
            case GameConstants.REVEAL_CONSTANTS.trivia.name:
               return new TriviaData(revealConstants,role,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers),roundData.getRolePromptFromRevealContent(revealConstants,role).question,[roundData.getRolePromptFromRevealContent(revealConstants,role).correct].concat(roundData.getRolePromptFromRevealContent(revealConstants,role).altSpellings),roundData.getRolePromptFromRevealContent(revealConstants,role).idx);
            case GameConstants.REVEAL_CONSTANTS.fightTiebreaker.name:
               return new FightTiebreakerData(revealConstants,role,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers),ArrayUtil.difference(GameState.instance.players,roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers)),roundData.getRolePromptFromRevealContent(revealConstants,role).question,roundData.getRolePromptFromRevealContent(revealConstants,role).idx);
            case GameConstants.REVEAL_CONSTANTS.abundance.name:
               return this._constructAbundanceReveal(revealConstants,roundData);
            case GameConstants.REVEAL_CONSTANTS.freebie.name:
               freebieHighestVotedPlayerRole = roundData.getHighestVotedUnassignedRoleAndPlayer();
               return new FreebieData(revealConstants,freebieHighestVotedPlayerRole.role,freebieHighestVotedPlayerRole.player);
            case GameConstants.REVEAL_CONSTANTS.tagChoice.name:
               return this._constructTagChoiceReveal(role,revealConstants,roundData);
            case GameConstants.REVEAL_CONSTANTS.fightJustPlaying.name:
               return this._constructFightJustPlayingReveal(revealConstants);
            case GameConstants.REVEAL_CONSTANTS.tagResolution.name:
               return this._constructTagResolutionReveal(revealConstants);
            case GameConstants.REVEAL_CONSTANTS.tagContradiction.name:
               return this._constructTagContradictionReveal(revealConstants);
            default:
               return null;
         }
      }
      
      private function _constructTagResolutionReveal(revealConstants:RevealConstants) : IRevealData
      {
         var matchups:Array = DataAnalysisUtil.getBestMatchupsWithContent(DataAnalysisUtil.MATCHUP_TYPE_RESOLUTION).matchups;
         var matchup:DataAnalysisMatchup = ArrayUtil.getRandomElement(matchups);
         var rolesAndTags:RolePairAndTags = ArrayUtil.getRandomElement(matchup.rolesAndTags);
         var tags:TagPair = ArrayUtil.getRandomElement(rolesAndTags.tags);
         var printfTag:String = tags.tag1.protoTagType == TagData.TYPE_NOUN ? "OF A " + tags.tag1.protoTag : tags.tag1.protoTag;
         GameState.instance.currentRound.addProtoTagToUsed(tags.tag1.protoTag);
         var content:Object = DataAnalysisUtil.getTagResolutionContent(tags.tag1.protoTag,true)[0];
         GameState.instance.dataAnalysisContent = content;
         return new TagResolutionData(revealConstants,[rolesAndTags.role1,rolesAndTags.role2],[matchup.p1,matchup.p2],ArrayUtil.difference(GameState.instance.players,[matchup.p1,matchup.p2]),printfTag,[tags.tag1,tags.tag2],content.prompt);
      }
      
      private function _constructTagContradictionReveal(revealConstants:RevealConstants) : IRevealData
      {
         var matchups:Array = DataAnalysisUtil.getBestMatchupsWithContent(DataAnalysisUtil.MATCHUP_TYPE_CONTRADICTION).matchups;
         var matchup:DataAnalysisMatchup = ArrayUtil.getRandomElement(matchups);
         var primaryPlayer:Player = matchup.p1;
         var rolesAndTags:RolePairAndTags = ArrayUtil.getRandomElement(matchup.rolesAndTags);
         var tags:TagPair = ArrayUtil.getRandomElement(rolesAndTags.tags);
         GameState.instance.currentRound.addProtoTagToUsed(tags.tag1.protoTag);
         GameState.instance.currentRound.addProtoTagToUsed(tags.tag2.protoTag);
         var content:Object = DataAnalysisUtil.getTagContradictionContent(tags.tag1.protoTag,tags.tag2.protoTag,true)[0];
         GameState.instance.dataAnalysisContent = content;
         return new TagContradictionData(revealConstants,[rolesAndTags.role1,rolesAndTags.role2],[tags.tag1,tags.tag2],primaryPlayer,ArrayUtil.difference(GameState.instance.players,[primaryPlayer]),content.prompt);
      }
      
      private function _constructFightJustPlayingReveal(revealConstants:RevealConstants) : IRevealData
      {
         var content:Object;
         var tagsInvolved:Array = null;
         var tagsPerPlayer:PerPlayerContainer = null;
         var matchups:Array = DataAnalysisUtil.getBestMatchupsWithContent(DataAnalysisUtil.MATCHUP_TYPE_FIGHT).matchups;
         var matchup:DataAnalysisMatchup = ArrayUtil.getRandomElement(matchups);
         var primaryPlayers:Array = [matchup.p1,matchup.p2];
         var rolesAndTags:RolePairAndTags = ArrayUtil.getRandomElement(matchup.rolesAndTags);
         var rolesInvolved:Array = [rolesAndTags.role1,rolesAndTags.role2];
         var tags:TagPair = ArrayUtil.getRandomElement(rolesAndTags.tags);
         tagsInvolved = [tags.tag1,tags.tag2];
         tagsPerPlayer = new PerPlayerContainer();
         primaryPlayers.forEach(function(player:Player, i:int, ... args):void
         {
            tagsPerPlayer.setDataForPlayer(player,LocalizationUtil.getPrintfText("FIGHT_JUST_PLAYING_VOTE_CHOICE",player.name.val,tagsInvolved[i].protoTag));
         });
         GameState.instance.currentRound.addProtoTagToUsed(tags.tag1.protoTag);
         GameState.instance.currentRound.addProtoTagToUsed(tags.tag2.protoTag);
         content = DataAnalysisUtil.getTagFightContent(tags.tag1.protoTag,tags.tag2.protoTag,true)[0];
         GameState.instance.dataAnalysisContent = content;
         return new FightJustPlayingData(revealConstants,primaryPlayers,ArrayUtil.difference(GameState.instance.players,primaryPlayers),tagsPerPlayer,rolesInvolved,tagsInvolved,content.prompt);
      }
      
      private function _constructPowersReveal(revealConstants:RevealConstants) : IRevealData
      {
         var playerAndPowerfulRoles:PlayerWithPowerfulRoles = ArrayUtil.getRandomElement(GameState.instance.getPlayersWithPowers());
         var power:RoleWithPower = ArrayUtil.getRandomElement(playerAndPowerfulRoles.powerfulRoles);
         var sortedPlayers:Array = GameState.instance.getPlayersSorted(Player.PROPERTY_FUNCTION_SCORE,power.power == Powers.STEAL ? GameState.SORT_TYPE_ASCENDING : GameState.SORT_TYPE_DESCENDING);
         GameState.instance.currentRound.addProtoTagToUsed(power.tag.protoTag);
         return new PowersData(revealConstants,power.role,power.tag,playerAndPowerfulRoles.p,ArrayUtil.difference(GameState.instance.players,[playerAndPowerfulRoles.p]).slice(0,revealConstants.maxPlayers),power.power);
      }
      
      private function _constructMajorityReveal(revealConstants:RevealConstants, role:RoleData, roundData:RoundData) : IRevealData
      {
         var round:RoundData = null;
         var reveal:IRevealData = null;
         var pastMajorityData:MajorityData = null;
         var majorityPlayer:Player = ArrayUtil.first(roundData.getPlayersForReveal(role,revealConstants.minPlayers,revealConstants.maxPlayers));
         var playerVotedForSelf:Boolean = GameState.instance.currentRound.playerVotedForSelf(majorityPlayer,role);
         var votes:PerPlayerContainer = roundData.getRoleVotes(role);
         var wasSuperVote:Boolean = votes.getDataForPlayer(majorityPlayer).length / GameState.instance.players.length > GameConstants.MAJORITY_CALLOUT_THRESHOLD;
         var numSelfVotes:int = 0;
         var numWrongVotes:int = 0;
         if(wasSuperVote)
         {
            if(playerVotedForSelf)
            {
               numSelfVotes++;
            }
            else
            {
               numWrongVotes++;
            }
         }
         for each(round in GameState.instance.rounds)
         {
            for each(reveal in round.reveals)
            {
               if(reveal.revealConstants.name == GameConstants.REVEAL_CONSTANTS.majority.name)
               {
                  pastMajorityData = MajorityData(reveal);
                  if(pastMajorityData.winningPlayer == majorityPlayer && pastMajorityData.wasSuperVote)
                  {
                     if(pastMajorityData.playerVotedForSelf)
                     {
                        numSelfVotes++;
                     }
                     else
                     {
                        numWrongVotes++;
                     }
                  }
               }
            }
         }
         return new MajorityData(revealConstants,role,majorityPlayer,votes,playerVotedForSelf,wasSuperVote,numSelfVotes,numWrongVotes);
      }
      
      private function _constructAbundanceReveal(revealConstants:RevealConstants, roundData:RoundData) : IRevealData
      {
         var highestVotedPlayerRole:Object = roundData.getHighestVotedUnassignedRoleAndPlayer();
         return new AbundanceData(revealConstants,[highestVotedPlayerRole.role,ArrayUtil.getRandomElement(roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.CONSOLATION))],highestVotedPlayerRole.player,ArrayUtil.difference(GameState.instance.players,[highestVotedPlayerRole.player]));
      }
      
      private function _constructTagChoiceReveal(firstRole:RoleData, revealConstants:RevealConstants, roundData:RoundData) : IRevealData
      {
         var firstTag:TagData = null;
         var secondTag:TagData = null;
         var firstPotentialTag:TagData = null;
         var firstPlayer:Player = null;
         var secondPlayer:Player = null;
         var otherRoles:Array = roundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).filter(function(otherRole:RoleData, ... args):Boolean
         {
            return firstRole.name != otherRole.name && TagData.differentTags(otherRole.tags,firstRole.tags).length > 0;
         });
         var secondRole:RoleData = ArrayUtil.getRandomElement(otherRoles);
         for each(firstPotentialTag in firstRole.tags)
         {
            if(TagData.differentTags(secondRole.tags,[firstPotentialTag]).length > 0)
            {
               firstTag = firstPotentialTag;
               secondTag = ArrayUtil.getRandomElement(TagData.differentTags(secondRole.tags,[firstPotentialTag]));
               break;
            }
         }
         if(roundData.unassignedPlayers.length == 1)
         {
            return new TagChoiceData(revealConstants,[firstRole,secondRole],[firstTag,secondTag],roundData.unassignedPlayers,ArrayUtil.difference(GameState.instance.players,roundData.unassignedPlayers));
         }
         firstPlayer = ArrayUtil.first(roundData.getPlayersForReveal(firstRole,revealConstants.minPlayers,revealConstants.minPlayers));
         secondPlayer = ArrayUtil.first(ArrayUtil.difference(roundData.getPlayersForReveal(secondRole,revealConstants.maxPlayers,revealConstants.maxPlayers),[firstPlayer]));
         return new TagChoiceData(revealConstants,[firstRole,secondRole],[firstTag,secondTag],[firstPlayer,secondPlayer],ArrayUtil.difference(GameState.instance.players,[firstPlayer,secondPlayer]));
      }
   }
}
