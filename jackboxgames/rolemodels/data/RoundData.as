package jackboxgames.rolemodels.data
{
   import jackboxgames.algorithm.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.utils.*;
   
   public class RoundData
   {
       
      
      private var _roles:Array;
      
      private var _reveals:Array;
      
      private var _votes:PerPlayerContainer;
      
      private var _doubleDownVotes:PerPlayerContainer;
      
      private var _content:Object;
      
      private var _audienceBonusRole:RoleData;
      
      private var _protoTagsUsed:Array;
      
      private var _doubleDownWinners:Array;
      
      private var _categoryPicker:Player;
      
      public function RoundData()
      {
         super();
         this._roles = [];
         this._votes = new PerPlayerContainer();
         this._doubleDownVotes = new PerPlayerContainer();
         this._reveals = [];
         this._doubleDownWinners = [];
         this._audienceBonusRole = null;
         this._protoTagsUsed = [];
      }
      
      public function get protoTagsUsed() : Array
      {
         return this._protoTagsUsed;
      }
      
      public function addProtoTagToUsed(protoTag:String) : void
      {
         this._protoTagsUsed.push(protoTag);
      }
      
      public function addDoubleDownWinner(player:Player) : void
      {
         Assert.assert(!ArrayUtil.arrayContainsElement(this._doubleDownWinners,player));
         this._doubleDownWinners.push();
      }
      
      public function get doubleDownWinners() : Array
      {
         return this._doubleDownWinners;
      }
      
      public function get categoryPicker() : Player
      {
         return this._categoryPicker;
      }
      
      public function set categoryPicker(categoryPlayer:Player) : void
      {
         this._categoryPicker = categoryPlayer;
      }
      
      public function get contentId() : String
      {
         return this._content.id;
      }
      
      public function get contentType() : String
      {
         return this._content.contentType;
      }
      
      public function get category() : String
      {
         return this._content.category.toUpperCase();
      }
      
      public function get allRoles() : Array
      {
         return this._roles;
      }
      
      public function addRole(role:RoleData) : void
      {
         this._roles.push(role);
      }
      
      public function getRolesOfSource(roleSource:String) : Array
      {
         return this._roles.filter(function(r:RoleData, ... args):Boolean
         {
            return r.source == roleSource;
         });
      }
      
      public function get reveals() : Array
      {
         return this._reveals;
      }
      
      public function addReveal(reveal:IRevealData) : void
      {
         this._reveals.push(reveal);
      }
      
      public function getAssignedRolesOfSource(roleSource:String) : Array
      {
         return this.getRolesOfSource(roleSource).filter(function(r:RoleData, ... args):Boolean
         {
            return r.playerAssignedRole != null;
         });
      }
      
      public function getUnassignedRolesOfSource(roleSource:String) : Array
      {
         return this.getRolesOfSource(roleSource).filter(function(r:RoleData, ... args):Boolean
         {
            return r.playerAssignedRole == null;
         });
      }
      
      public function get allPlayersAssignedRoles() : Boolean
      {
         return this.unassignedPlayers.length == 0;
      }
      
      public function get unassignedPlayers() : Array
      {
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return getRoleAssignedToPlayer(p) == null;
         });
      }
      
      public function get currentRoundFunPoints() : int
      {
         var funPoints:int = 0;
         funPoints = 0;
         this._reveals.forEach(function(reveal:IRevealData, ... args):void
         {
            funPoints += reveal.revealConstants.felocity;
         });
         return funPoints;
      }
      
      public function reset() : void
      {
         this._roles = null;
         this._reveals = null;
         this._votes.reset();
         this._doubleDownVotes.reset();
         this._doubleDownWinners = [];
         this._audienceBonusRole = null;
         this._protoTagsUsed = [];
      }
      
      public function generateAudienceBonusRoleFromVoteData(roles:Array, audienceBonusRoleVotes:Object) : void
      {
         var votePercentage:Number = NaN;
         var highestVotePercentage:Number = 0;
         var rolesAtHighest:Array = [];
         for(var i:int = 0; i < roles.length; i++)
         {
            votePercentage = Number(audienceBonusRoleVotes[roles[i].name]);
            if(votePercentage > highestVotePercentage)
            {
               highestVotePercentage = votePercentage;
               rolesAtHighest = [roles[i]];
            }
            else if(votePercentage == highestVotePercentage && votePercentage > 0)
            {
               rolesAtHighest.push(roles[i]);
            }
         }
         if(rolesAtHighest.length > 0)
         {
            this._audienceBonusRole = ArrayUtil.getRandomElement(rolesAtHighest);
         }
      }
      
      public function setRoundVotes(votes:PerPlayerContainer) : void
      {
         this._votes = votes;
         if(!GameState.instance.isDebugRevealMode)
         {
            GameState.instance.artifactState.setVotes(GameState.instance.roundIndex,this._votes);
         }
      }
      
      public function setDoubleDownVotes(doubleDownVotes:PerPlayerContainer) : void
      {
         this._doubleDownVotes = doubleDownVotes;
      }
      
      public function setContent(content:Object) : void
      {
         var rolesInContent:Array = null;
         var numberOfRequiredRoles:int = 0;
         var consolationRole:Object = null;
         this._content = content;
         rolesInContent = this._content.roles as Array;
         numberOfRequiredRoles = int(rolesInContent.filter(function(roleContent:Object, ... args):Boolean
         {
            return roleContent.hasOwnProperty("required") && Boolean(roleContent.required);
         }).length);
         rolesInContent.forEach(function(roleContent:Object, ... args):void
         {
            Assert.assert(roleContent.tags.length > 0);
            if(roleContent.hasOwnProperty("required") && roleContent.required || _roles.length < GameState.instance.players.length && numberOfRequiredRoles + _roles.length < GameState.instance.players.length)
            {
               numberOfRequiredRoles -= roleContent.hasOwnProperty("required") && Boolean(roleContent.required) ? 1 : 0;
               _roles.push(new RoleData(roleContent.name,roleContent.hasOwnProperty("short") ? String(roleContent.short) : String(roleContent.name),RoleData.ROLE_SOURCE.INITIAL,roleContent.tags,rolesInContent.indexOf(roleContent),contentId,category,roleContent.hasOwnProperty("required") ? Boolean(roleContent.required) : false));
            }
         });
         if(Boolean(this.getRevealContent("Consolation")))
         {
            for each(consolationRole in this.getRevealContent("Consolation").roles)
            {
               this.addRole(new RoleData(consolationRole.name,consolationRole.hasOwnProperty("short") ? String(consolationRole.short) : String(consolationRole.name),RoleData.ROLE_SOURCE.CONSOLATION,consolationRole.tags,this.getRevealContent("Consolation").roles.indexOf(consolationRole),this.contentId,this.category));
            }
         }
      }
      
      public function getRevealContent(revealName:String) : Object
      {
         var reveal:Object = null;
         Assert.assert(this._content != null);
         for each(reveal in this._content.reveals)
         {
            if(reveal.id == revealName)
            {
               return reveal;
            }
         }
         return null;
      }
      
      public function getRolePromptFromRevealContent(revealConstants:RevealConstants, role:RoleData) : Object
      {
         var prompt:Object = null;
         var prompts:Array = [];
         var revealContent:Object = this.getRevealContent(revealConstants.name);
         if(!revealContent)
         {
            return null;
         }
         prompts = revealContent.prompts;
         for each(prompt in prompts)
         {
            if(prompt.name == role.name)
            {
               return prompt;
            }
         }
         return null;
      }
      
      public function highestVotedPlayerHasAtLeastOneVote(role:RoleData) : Boolean
      {
         return this.getVotesForPlayer(ArrayUtil.first(this.getMajorityVotesFiltered(role)),role).length > 0;
      }
      
      public function playersInvolvedInResult(role:RoleData) : Array
      {
         var playersInvolvedInResult:Array = null;
         playersInvolvedInResult = this.getMajorityVotesUnfiltered(role);
         this.getMajorityVotesUnfiltered(role).forEach(function(tiedPlayer:Player, ... args):void
         {
            playersInvolvedInResult = ArrayUtil.union(playersInvolvedInResult,getVotesForPlayer(tiedPlayer,role));
         });
         return playersInvolvedInResult;
      }
      
      public function getMajorityVotesUnfiltered(role:RoleData) : Array
      {
         return RMUtil.getMostVotedPlayers(this._votes,role,true);
      }
      
      public function getMajorityVotesFiltered(role:RoleData) : Array
      {
         return ArrayUtil.intersection(RMUtil.getMostVotedPlayers(this._votes,role,true),this.unassignedPlayers);
      }
      
      public function getPlayersForReveal(role:RoleData, minPlayers:int, maxPlayers:int) : Array
      {
         var eligiblePlayer:Player = null;
         var playersForReveal:Array = [];
         var sortedUnassignedPlayers:Array = ArrayUtil.difference(this.getSortedPlayers(role),this.getAllPlayersAssignedRoles());
         playersForReveal.push(sortedUnassignedPlayers.shift());
         var numVotes:int = int(this.getVotesForPlayer(ArrayUtil.first(playersForReveal),role).length);
         while(numVotes >= 0)
         {
            for each(eligiblePlayer in sortedUnassignedPlayers.concat())
            {
               if(this.getVotesForPlayer(eligiblePlayer,role).length == numVotes)
               {
                  playersForReveal.push(eligiblePlayer);
                  ArrayUtil.removeElementFromArray(sortedUnassignedPlayers,eligiblePlayer);
               }
            }
            if(playersForReveal.length >= minPlayers)
            {
               return playersForReveal.slice(0,Math.min(maxPlayers,GameState.instance.players.length - 1));
            }
            numVotes--;
         }
         return playersForReveal.slice(0,Math.min(maxPlayers,GameState.instance.players.length - 1));
      }
      
      public function getVotesForPlayer(player:Player, role:RoleData) : Array
      {
         return this._votes.getDataForPlayer(player)[role.name];
      }
      
      public function getHighestVotedUnassignedRoleAndPlayer() : Object
      {
         var highestVoteCount:int = 0;
         var highestVoteRole:RoleData = null;
         var primaryPlayer:Player = null;
         highestVoteCount = -1;
         this.unassignedPlayers.forEach(function(player:Player, ... args):void
         {
            getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL).forEach(function(role:RoleData, ... args):void
            {
               var votes:Array = getVotesForPlayer(player,role);
               if(votes.length > highestVoteCount)
               {
                  highestVoteCount = votes.length;
                  highestVoteRole = role;
                  primaryPlayer = player;
               }
            });
         });
         return {
            "role":highestVoteRole,
            "player":primaryPlayer
         };
      }
      
      public function playersVotedForSelf(players:Array, role:RoleData) : Boolean
      {
         return MapFold.process(players,function(p:Player, ... args):Boolean
         {
            return playerVotedForSelf(p,role);
         },MapFold.FOLD_AND);
      }
      
      public function playerVotedForSelf(player:Player, role:RoleData) : Boolean
      {
         var p:Player = null;
         var votes:Array = this.getVotesForPlayer(player,role);
         for each(p in votes)
         {
            if(p == player)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isFilteredPlurality(role:RoleData) : Boolean
      {
         var sortedFilteredPlayers:Array = ArrayUtil.difference(this.getSortedPlayers(role),this.getAllPlayersAssignedRoles());
         if(sortedFilteredPlayers.length == 0)
         {
            return false;
         }
         if(sortedFilteredPlayers.length == 1)
         {
            return true;
         }
         if(this.getVotesForPlayer(sortedFilteredPlayers[0],role).length != this.getVotesForPlayer(sortedFilteredPlayers[1],role).length)
         {
            return true;
         }
         return false;
      }
      
      public function getSortedPlayers(role:RoleData) : Array
      {
         return GameState.instance.players.concat().sort(function(a:Player, b:Player):int
         {
            if(getVotesForPlayer(a,role).length == getVotesForPlayer(b,role).length)
            {
               return a.name.val > b.name.val ? 1 : -1;
            }
            return getVotesForPlayer(b,role).length - getVotesForPlayer(a,role).length;
         });
      }
      
      public function getAllPlayersAssignedRoles() : Array
      {
         return this._roles.filter(function(r:RoleData, ... args):Boolean
         {
            return r.playerAssignedRole != null;
         }).map(function(role:RoleData, ... args):Player
         {
            return role.playerAssignedRole;
         });
      }
      
      public function getRoleAssignedToPlayer(player:Player) : RoleData
      {
         var role:RoleData = null;
         for each(role in this._roles)
         {
            if(role.playerAssignedRole == player)
            {
               return role;
            }
         }
         return null;
      }
      
      public function getRole(roleName:String) : RoleData
      {
         var role:RoleData = null;
         for each(role in this._roles)
         {
            if(role.name == roleName)
            {
               return role;
            }
         }
         return null;
      }
      
      public function getPreviousRevealsOfName(revealName:String) : Array
      {
         return this._reveals.filter(function(reveal:IRevealData, ... args):Boolean
         {
            return reveal.revealConstants.name == revealName;
         });
      }
      
      public function getPreviousRevealsOfType(revealType:String) : Array
      {
         return this._reveals.filter(function(reveal:IRevealData, ... args):Boolean
         {
            return reveal.revealConstants.type == revealType;
         });
      }
      
      public function getRoleVotes(role:RoleData) : PerPlayerContainer
      {
         var roleVotes:PerPlayerContainer = null;
         roleVotes = new PerPlayerContainer();
         GameState.instance.players.forEach(function(player:Player, ... args):void
         {
            roleVotes.setDataForPlayer(player,getVotesForPlayer(player,role));
         });
         return roleVotes;
      }
      
      public function getPlayerVotedForRole(votingPlayer:Player, role:RoleData) : Player
      {
         var roleVotes:PerPlayerContainer = this.getRoleVotes(role);
         var playerVotedFor:Player = null;
         roleVotes.forEach(function(voters:Array, playerVotedForId:String, ... args):void
         {
            if(ArrayUtil.arrayContainsElement(voters,votingPlayer))
            {
               playerVotedFor = Player(GameState.instance.getPlayerByUserId(playerVotedForId));
            }
         });
         return playerVotedFor;
      }
      
      public function playerDoubledDownOnRole(playerDoublingDown:Player, role:RoleData) : Boolean
      {
         if(!this._doubleDownVotes.hasDataForPlayer(playerDoublingDown))
         {
            return false;
         }
         var doubleDownPairing:Object = this._doubleDownVotes.getDataForPlayer(playerDoublingDown);
         return doubleDownPairing.role == role;
      }
      
      public function playerWonDoubleDown(playerDoublingDown:Player, role:RoleData) : Boolean
      {
         if(!this._doubleDownVotes.hasDataForPlayer(playerDoublingDown))
         {
            return false;
         }
         var doubleDownPairing:Object = this._doubleDownVotes.getDataForPlayer(playerDoublingDown);
         return doubleDownPairing.player == role.playerAssignedRole && doubleDownPairing.role == role;
      }
      
      public function playerVotedSelfForDoubleDown(playerDoublingDown:Player, role:RoleData) : Boolean
      {
         if(!this._doubleDownVotes.hasDataForPlayer(playerDoublingDown))
         {
            return false;
         }
         var doubleDownPairing:Object = this._doubleDownVotes.getDataForPlayer(playerDoublingDown);
         return doubleDownPairing.player == playerDoublingDown && doubleDownPairing.role == role;
      }
      
      public function playerWonAudienceVotedBonusRole(role:RoleData) : Boolean
      {
         return Boolean(this._audienceBonusRole) && this._audienceBonusRole == role;
      }
   }
}
