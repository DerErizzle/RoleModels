package jackboxgames.rolemodels.utils
{
   import flash.display.*;
   import flash.geom.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.utils.drawing.*;
   import jackboxgames.utils.*;
   
   public class RMUtil
   {
       
      
      public function RMUtil()
      {
         super();
      }
      
      public static function formatVotes(playersVotedOn:Array, votes:PerPlayerContainer, roles:Array) : PerPlayerContainer
      {
         var formattedVotes:PerPlayerContainer = null;
         formattedVotes = new PerPlayerContainer();
         playersVotedOn.forEach(function(player:Player, ... args):void
         {
            var keys:Object = null;
            keys = {};
            roles.forEach(function(role:RoleData, ... args):void
            {
               keys[role.name] = [];
            });
            formattedVotes.setDataForPlayer(player,keys);
         });
         votes.forEach(function(playerVotes:Array, playerVoting:String, ... args):void
         {
            playerVotes.forEach(function(voteObject:Object, ... args):void
            {
               var playerVotedFor:Player = null;
               var role:RoleData = null;
               if(voteObject.hasOwnProperty("player"))
               {
                  playerVotedFor = GameState.instance.players[voteObject.player];
                  if(voteObject.hasOwnProperty("role"))
                  {
                     role = roles[voteObject.role];
                     formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(GameState.instance.getPlayerByUserId(playerVoting));
                  }
               }
            });
         });
         return formattedVotes;
      }
      
      public static function extractDoubleDownFromVotes(unformattedVotes:PerPlayerContainer, roles:Array) : PerPlayerContainer
      {
         var doubleDowns:PerPlayerContainer = null;
         doubleDowns = new PerPlayerContainer();
         unformattedVotes.forEach(function(playerVotes:Array, playerVoting:String, ... args):void
         {
            playerVotes.forEach(function(voteObject:Object, ... args):void
            {
               var playerVotedFor:Player = null;
               var role:RoleData = null;
               if(voteObject.hasOwnProperty("player") && voteObject.hasOwnProperty("role") && voteObject.hasOwnProperty("doubleDown") && voteObject.doubleDown == true)
               {
                  playerVotedFor = GameState.instance.players[voteObject.player];
                  role = roles[voteObject.role];
                  doubleDowns.setDataForPlayer(GameState.instance.getPlayerByUserId(playerVoting),{
                     "player":playerVotedFor,
                     "role":role
                  });
               }
            });
         });
         return doubleDowns;
      }
      
      private static function _highestNumberOfVotesForRole(votes:PerPlayerContainer, role:RoleData, ignoreAssignedPlayers:Boolean) : int
      {
         var maxVote:int = 0;
         maxVote = 0;
         votes.forEach(function(roleVotes:Object, userId:String, ... args):void
         {
            var numVotes:int = int(roleVotes[role.name].length);
            if(numVotes > maxVote)
            {
               if(ignoreAssignedPlayers)
               {
                  if(!GameState.instance.currentRound.getRoleAssignedToPlayer(Player(GameState.instance.getPlayerByUserId(userId))))
                  {
                     maxVote = numVotes;
                  }
               }
               else
               {
                  maxVote = numVotes;
               }
            }
         });
         return maxVote;
      }
      
      public static function getMostVotedPlayers(votes:PerPlayerContainer, role:RoleData, ignoreAssignedPlayers:Boolean) : Array
      {
         var playersWithMostVotes:Array = null;
         var highestVoteCount:int = 0;
         playersWithMostVotes = [];
         highestVoteCount = _highestNumberOfVotesForRole(votes,role,ignoreAssignedPlayers);
         votes.forEach(function(roleVotes:Object, userId:String, ... args):void
         {
            if(roleVotes[role.name].length == highestVoteCount)
            {
               playersWithMostVotes.push(GameState.instance.getPlayerByUserId(userId));
            }
         });
         return playersWithMostVotes;
      }
      
      public static function getFinalRoleArray(player:Player, numberOfTags:int) : Array
      {
         var modifiedNouns:Array = null;
         var modifiedAdjectives:Array = null;
         var originalNouns:Array = null;
         var originalAdjectives:Array = null;
         var leftOverTags:Array = null;
         var tagsInUse:Array = GameState.instance.finalRoleTagsInUse;
         var playerTags:Array = [];
         var roles:Array = GameState.instance.playerAssignedRoles(player);
         modifiedNouns = [];
         modifiedAdjectives = [];
         originalNouns = [];
         originalAdjectives = [];
         roles.forEach(function(role:RoleData, ... args):void
         {
            var tag:TagData = null;
            for each(tag in role.tags)
            {
               if(tag.wasModified)
               {
                  if(tag.type == TagData.TYPE_NOUN)
                  {
                     modifiedNouns.push(tag.rawString);
                  }
                  else
                  {
                     modifiedAdjectives.push(tag.rawString);
                  }
               }
               else if(tag.type == TagData.TYPE_NOUN)
               {
                  originalNouns.push(tag.rawString);
               }
               else
               {
                  originalAdjectives.push(tag.rawString);
               }
            }
         });
         playerTags = modifiedAdjectives.concat();
         if(playerTags.length < numberOfTags && ArrayUtil.difference(originalAdjectives,tagsInUse).length > 0)
         {
            playerTags = playerTags.concat(ArrayUtil.difference(originalAdjectives,tagsInUse));
         }
         if(playerTags.length < numberOfTags)
         {
            leftOverTags = ArrayUtil.difference(TagData.getRawStrings(GameState.instance.playerAssignedTags(player)),tagsInUse.concat(playerTags));
            playerTags = playerTags.concat(ArrayUtil.getRandomElements(leftOverTags,leftOverTags.length <= numberOfTags - playerTags.length ? int(leftOverTags.length) : numberOfTags - playerTags.length));
         }
         if(playerTags.length > numberOfTags)
         {
            playerTags = playerTags.slice(0,numberOfTags);
         }
         if(ArrayUtil.union(modifiedNouns,originalNouns).length > 0)
         {
            if(playerTags.length == numberOfTags)
            {
               playerTags.pop();
            }
            if(modifiedNouns.length > 0)
            {
               if(ArrayUtil.difference(modifiedNouns,playerTags).length > 0)
               {
                  playerTags.push(ArrayUtil.getRandomElement(ArrayUtil.difference(modifiedNouns,playerTags)));
               }
               else
               {
                  playerTags.push(ArrayUtil.getRandomElement(modifiedNouns));
               }
            }
            else if(ArrayUtil.difference(originalNouns,playerTags).length > 0)
            {
               playerTags.push(ArrayUtil.getRandomElement(ArrayUtil.difference(originalNouns,playerTags)));
            }
            else
            {
               playerTags.push(ArrayUtil.getRandomElement(originalNouns));
            }
         }
         return playerTags;
      }
      
      public static function sortByRevealVotes(players:Array, voteResults:PerPlayerContainer) : Array
      {
         return players.concat().sort(function(a:Player, b:Player):int
         {
            if(voteResults.getDataForPlayer(a).length == voteResults.getDataForPlayer(b).length)
            {
               return a.name.val > b.name.val ? -1 : 1;
            }
            return voteResults.getDataForPlayer(b).length - voteResults.getDataForPlayer(a).length;
         });
      }
      
      public static function calculateTiebreakerResult(revealData:IRevealData, votingPlayers:Array, voteResults:PerPlayerContainer, audienceVotes:PerPlayerContainer) : String
      {
         var sortedPlayers:Array;
         var tiedPlayers:Array;
         var maxVotes:int = 0;
         var winningPlayer:Player = null;
         var playersDoubledDown:Array = null;
         var resultType:String = "";
         var audienceVoted:Boolean = applyAudienceMajorityVote(audienceVotes,voteResults);
         revealData.primaryPlayers.forEach(function(p:Player, ... args):void
         {
            p.broadcast("VotesReceived",{"votingPlayers":voteResults.getDataForPlayer(p)});
         });
         GameState.instance.artifactState.addVoteResult(GameState.instance.roundIndex,revealData.primaryPlayers,voteResults);
         sortedPlayers = sortByRevealVotes(revealData.primaryPlayers,voteResults);
         maxVotes = int(voteResults.getDataForPlayer(sortedPlayers[0]).length);
         tiedPlayers = sortedPlayers.filter(function(p:Player, ... args):Boolean
         {
            return voteResults.getDataForPlayer(p).length == maxVotes;
         });
         if(tiedPlayers.length == 1)
         {
            winningPlayer = ArrayUtil.first(tiedPlayers);
            if(voteWasQuiplash(votingPlayers.length,maxVotes,audienceVoted))
            {
               resultType = String(GameConstants.TIEBREAKER_RESULTS.QUIPLASH);
            }
            else
            {
               resultType = String(GameConstants.TIEBREAKER_RESULTS.MAJORITY);
            }
         }
         else
         {
            playersDoubledDown = tiedPlayers.filter(function(p:Player, ... args):Boolean
            {
               return GameState.instance.currentRound.playerVotedSelfForDoubleDown(p,revealData.roleData);
            });
            if(playersDoubledDown.length == 1)
            {
               winningPlayer = playersDoubledDown[0];
               resultType = String(GameConstants.TIEBREAKER_RESULTS.DOUBLE_DOWN_BROKE_TIE);
            }
            else
            {
               winningPlayer = playersDoubledDown.length > 0 ? ArrayUtil.getRandomElement(playersDoubledDown) : ArrayUtil.getRandomElement(tiedPlayers);
               resultType = String(GameConstants.TIEBREAKER_RESULTS.TIE);
            }
         }
         revealData.roleData.playerAssignedRole = winningPlayer;
         if(GameState.instance.currentRound.playerVotedForSelf(winningPlayer,revealData.roleData))
         {
            winningPlayer.pendingPoints.val += revealData.revealConstants.getProperty("pointsForWinningTieSelf");
         }
         else
         {
            winningPlayer.pendingPoints.val += revealData.revealConstants.getProperty("pointsForWinningTie");
         }
         return resultType;
      }
      
      public static function calculateTwoRoleTiebreakerResult(revealData:IRevealData, roles:Array, votingPlayers:Array, voteResults:PerPlayerContainer, audienceVoted:Boolean) : String
      {
         var numVoters:int = 0;
         var randomPlayer1:Player = null;
         var randomPlayer2:Player = null;
         var randomRole1:RoleData = null;
         var randomRole2:RoleData = null;
         var resultType:String = "";
         var p1:Player = revealData.primaryPlayers[0];
         var p2:Player = revealData.primaryPlayers[1];
         var role1:RoleData = roles[0];
         var role2:RoleData = roles[1];
         var p1VotesForRole1:int = int(voteResults.getDataForPlayer(p1)[role1.name].length);
         var p1VotesForRole2:int = int(voteResults.getDataForPlayer(p1)[role2.name].length);
         var p2VotesForRole1:int = int(voteResults.getDataForPlayer(p2)[role1.name].length);
         var p2VotesForRole2:int = int(voteResults.getDataForPlayer(p2)[role2.name].length);
         if(p1VotesForRole1 > p2VotesForRole1 || p2VotesForRole2 > p1VotesForRole2)
         {
            role1.playerAssignedRole = p1;
            role2.playerAssignedRole = p2;
         }
         else if(p2VotesForRole1 > p1VotesForRole1 || p1VotesForRole2 > p2VotesForRole2)
         {
            role1.playerAssignedRole = p2;
            role2.playerAssignedRole = p1;
         }
         if(role1.playerAssignedRole != null)
         {
            numVoters = audienceVoted ? votingPlayers.length + 1 : int(votingPlayers.length);
            if((p1VotesForRole1 == numVoters && p2VotesForRole2 == numVoters || p1VotesForRole2 == numVoters && p2VotesForRole1 == numVoters) && numVoters > 1)
            {
               resultType = String(GameConstants.TIEBREAKER_RESULTS.QUIPLASH);
            }
            else
            {
               resultType = String(GameConstants.TIEBREAKER_RESULTS.MAJORITY);
            }
         }
         else if(GameState.instance.currentRound.playerVotedSelfForDoubleDown(p1,role1) && !GameState.instance.currentRound.playerVotedSelfForDoubleDown(p2,role1) || GameState.instance.currentRound.playerVotedSelfForDoubleDown(p2,role2) && !GameState.instance.currentRound.playerVotedSelfForDoubleDown(p1,role2))
         {
            resultType = String(GameConstants.TIEBREAKER_RESULTS.DOUBLE_DOWN_BROKE_TIE);
            role1.playerAssignedRole = p1;
            role2.playerAssignedRole = p2;
         }
         else if(GameState.instance.currentRound.playerVotedSelfForDoubleDown(p2,role1) && !GameState.instance.currentRound.playerVotedSelfForDoubleDown(p1,role1) || GameState.instance.currentRound.playerVotedSelfForDoubleDown(p1,role2) && !GameState.instance.currentRound.playerVotedSelfForDoubleDown(p2,role2))
         {
            resultType = String(GameConstants.TIEBREAKER_RESULTS.DOUBLE_DOWN_BROKE_TIE);
            role1.playerAssignedRole = p2;
            role2.playerAssignedRole = p1;
         }
         else
         {
            resultType = String(GameConstants.TIEBREAKER_RESULTS.TIE);
            randomPlayer1 = ArrayUtil.getRandomElement(revealData.primaryPlayers);
            randomPlayer2 = ArrayUtil.first(ArrayUtil.difference(revealData.primaryPlayers,[randomPlayer1]));
            randomRole1 = ArrayUtil.getRandomElement(roles);
            randomRole2 = ArrayUtil.first(ArrayUtil.difference(roles,[randomRole1]));
            randomRole1.playerAssignedRole = randomPlayer1;
            randomRole2.playerAssignedRole = randomPlayer2;
         }
         p1.pendingPoints.val += GameState.instance.currentRound.playerVotedForSelf(p1,GameState.instance.currentRound.getRoleAssignedToPlayer(p1)) ? revealData.revealConstants.getProperty("pointsForWinningTieSelf") : revealData.revealConstants.getProperty("pointsForWinningTie");
         p2.pendingPoints.val += GameState.instance.currentRound.playerVotedForSelf(p2,GameState.instance.currentRound.getRoleAssignedToPlayer(p2)) ? revealData.revealConstants.getProperty("pointsForWinningTieSelf") : revealData.revealConstants.getProperty("pointsForWinningTie");
         return resultType;
      }
      
      public static function applyAudienceMajorityVote(audienceVotes:PerPlayerContainer, voteResults:PerPlayerContainer) : Boolean
      {
         var highestVotePercentage:Number = NaN;
         var highestVotedPlayer:String = null;
         highestVotePercentage = 0;
         audienceVotes.forEach(function(votePercentage:Number, playerId:String, ... args):void
         {
            if(!isNaN(votePercentage) && votePercentage > highestVotePercentage)
            {
               if(voteResults.hasDataForPlayer(GameState.instance.getPlayerByUserId(playerId)))
               {
                  highestVotePercentage = votePercentage;
                  highestVotedPlayer = playerId;
               }
            }
         });
         if(highestVotedPlayer != null)
         {
            voteResults.getDataForPlayer(GameState.instance.getPlayerByUserId(highestVotedPlayer)).push(Player.AUDIENCE_PLAYER);
            return true;
         }
         return false;
      }
      
      public static function constructRoleAndPlayerObject(roleCommaPlayer:String) : Object
      {
         var split:Array = roleCommaPlayer.split(",");
         return {
            "role":GameState.instance.currentRound.getRolesOfSource(RoleData.ROLE_SOURCE.INITIAL)[Number(split[0])],
            "player":GameState.instance.players[Number(split[1])]
         };
      }
      
      public static function voteWasQuiplash(numVotingPlayers:int, numVotes:int, audienceVoted:Boolean) : Boolean
      {
         return (audienceVoted && numVotes == numVotingPlayers + 1 || !audienceVoted && numVotes == numVotingPlayers) && numVotes > 1;
      }
   }
}
