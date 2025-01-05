package jackboxgames.rolemodels.utils
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.utils.*;
   
   public class AutoVoter
   {
       
      
      public function AutoVoter()
      {
         super();
      }
      
      private static function _playersVotedForRole(votes:PerPlayerContainer, players:Array, role:RoleData) : Array
      {
         return players.filter(function(p:Player, ... args):Boolean
         {
            return votes.getDataForPlayer(p)[role.name].length > 0;
         });
      }
      
      private static function _playersVotedForRoles(votes:PerPlayerContainer, players:Array, roles:Array) : Array
      {
         var votedPlayers:Array = null;
         votedPlayers = [];
         roles.forEach(function(role:RoleData, ... args):void
         {
            votedPlayers = votedPlayers.concat(_playersVotedForRole(votes,players,role));
         });
         return votedPlayers;
      }
      
      private static function _randomUnvotedPlayer(votes:PerPlayerContainer, roles:Array) : Player
      {
         return ArrayUtil.getRandomElement(ArrayUtil.difference(GameState.instance.players,_playersVotedForRoles(votes,GameState.instance.players,roles)));
      }
      
      private static function _randomVoter(playerVotingFor:Player, votes:PerPlayerContainer, role:RoleData) : Player
      {
         var alreadyVoted:Array = null;
         alreadyVoted = [];
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            votes.getDataForPlayer(p)[role.name].forEach(function(alreadyVotedPlayer:Player, ... args):void
            {
               if(!ArrayUtil.arrayContainsElement(alreadyVoted,alreadyVotedPlayer))
               {
                  alreadyVoted.push(alreadyVotedPlayer);
               }
            });
         });
         if(!ArrayUtil.arrayContainsElement(alreadyVoted,playerVotingFor))
         {
            alreadyVoted.push(playerVotingFor);
         }
         return ArrayUtil.getRandomElement(ArrayUtil.difference(GameState.instance.players,alreadyVoted));
      }
      
      private static function _randomUnvotedRole(playerVoting:Player, votes:PerPlayerContainer, roles:Array) : RoleData
      {
         var alreadyVotedRoles:Array = null;
         alreadyVotedRoles = [];
         GameState.instance.players.forEach(function(p:Player, ... args):void
         {
            roles.forEach(function(role:RoleData, ... args):void
            {
               votes.getDataForPlayer(p)[role.name].forEach(function(alreadyVotedPlayer:Player, ... args):void
               {
                  if(alreadyVotedPlayer == playerVoting && !ArrayUtil.arrayContainsElement(alreadyVotedRoles,role))
                  {
                     alreadyVotedRoles.push(role);
                  }
               });
            });
         });
         return ArrayUtil.getRandomElement(ArrayUtil.difference(roles,alreadyVotedRoles));
      }
      
      private static function _numReceivedVotes(votes:PerPlayerContainer, p:Player, roles:Array) : int
      {
         var voteTotal:int = 0;
         voteTotal = 0;
         roles.forEach(function(role:RoleData, ... args):void
         {
            voteTotal += votes.getDataForPlayer(p)[role.name].length;
         });
         return voteTotal;
      }
      
      private static function _votablePlayers(votes:PerPlayerContainer, roles:Array) : Array
      {
         var votesNeeded:int = 0;
         var maxPossibleVotes:int = 0;
         votesNeeded = GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] - 1;
         maxPossibleVotes = int(GameState.instance.players.length);
         return GameState.instance.players.filter(function(p:Player, ... args):Boolean
         {
            return maxPossibleVotes - _numReceivedVotes(votes,p,roles) >= votesNeeded;
         });
      }
      
      private static function _playerToTieWith(votes:PerPlayerContainer, roles:Array, originalPlayer:Player) : Player
      {
         return ArrayUtil.getRandomElement(ArrayUtil.difference(_votablePlayers(votes,roles),[originalPlayer]));
      }
      
      private static function _playerToStartTie(votes:PerPlayerContainer, roles:Array) : Player
      {
         return ArrayUtil.getRandomElement(_votablePlayers(votes,roles));
      }
      
      public static function formatAutoVotes(playersVotedOn:Array, roles:Array) : PerPlayerContainer
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
         switch(TuneableValues.instance.getValue("VoteType").val)
         {
            case GameConstants.AUTO_VOTE_TYPES[0]:
               GameState.instance.players.forEach(function(playerVotedFor:Player, i:int, ... args):void
               {
                  GameState.instance.players.forEach(function(playerVoting:Player, ... args):void
                  {
                     formattedVotes.getDataForPlayer(playerVotedFor)[roles[i].name].push(playerVoting);
                  });
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[1]:
               GameState.instance.players.forEach(function(playerVotedFor:Player, i:int, ... args):void
               {
                  GameState.instance.players.forEach(function(playerVoting:Player, ... args):void
                  {
                     if(playerVotedFor != playerVoting)
                     {
                        formattedVotes.getDataForPlayer(playerVotedFor)[roles[i].name].push(playerVoting);
                     }
                  });
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[2]:
               roles.forEach(function(role:RoleData, roleIndex:int, ... args):void
               {
                  var playerVotedFor:Player = null;
                  var tiedPlayer:Player = null;
                  if(_votablePlayers(formattedVotes,roles).length > 1)
                  {
                     playerVotedFor = _playerToStartTie(formattedVotes,roles);
                     formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(playerVotedFor);
                     tiedPlayer = _playerToTieWith(formattedVotes,roles,playerVotedFor);
                     formattedVotes.getDataForPlayer(tiedPlayer)[role.name].push(tiedPlayer);
                     if(GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] > 2)
                     {
                        formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(_randomVoter(playerVotedFor,formattedVotes,role));
                     }
                     if(GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] > 2)
                     {
                        formattedVotes.getDataForPlayer(tiedPlayer)[role.name].push(_randomVoter(tiedPlayer,formattedVotes,role));
                     }
                  }
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[3]:
               roles.forEach(function(role:RoleData, roleIndex:int, ... args):void
               {
                  var playerVotedFor:Player = null;
                  var tiedPlayer:Player = null;
                  if(_votablePlayers(formattedVotes,roles).length > 1)
                  {
                     playerVotedFor = _playerToStartTie(formattedVotes,roles);
                     while(formattedVotes.getDataForPlayer(playerVotedFor)[role.name].length < GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] - 1)
                     {
                        formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(_randomVoter(playerVotedFor,formattedVotes,role));
                     }
                     tiedPlayer = _playerToTieWith(formattedVotes,roles,playerVotedFor);
                     while(formattedVotes.getDataForPlayer(tiedPlayer)[role.name].length < GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] - 1)
                     {
                        formattedVotes.getDataForPlayer(tiedPlayer)[role.name].push(_randomVoter(tiedPlayer,formattedVotes,role));
                     }
                  }
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[4]:
               roles.forEach(function(role:RoleData, roleIndex:int, ... args):void
               {
                  var playerVotedFor:Player = _randomUnvotedPlayer(formattedVotes,roles);
                  formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(playerVotedFor);
                  if(GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] > 2)
                  {
                     formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(_randomVoter(playerVotedFor,formattedVotes,role));
                  }
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[5]:
               roles.forEach(function(role:RoleData, roleIndex:int, ... args):void
               {
                  var playerVotedFor:Player = _randomUnvotedPlayer(formattedVotes,roles);
                  while(formattedVotes.getDataForPlayer(playerVotedFor)[role.name].length < GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] - 1)
                  {
                     formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(_randomVoter(playerVotedFor,formattedVotes,role));
                  }
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[6]:
               roles.forEach(function(role:RoleData, roleIndex:int, ... args):void
               {
                  var majorityPlayer:Player = null;
                  var playersVoting:Array = null;
                  var playerVotedFor:Player = null;
                  var tiedPlayer:Player = null;
                  if(roleIndex + 1 <= roles.length / 2)
                  {
                     majorityPlayer = GameState.instance.players[roleIndex];
                     playersVoting = [];
                     playersVoting.push(majorityPlayer);
                     playersVoting = playersVoting.concat(ArrayUtil.getRandomElements(ArrayUtil.difference(GameState.instance.players,[majorityPlayer]),GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] - 1));
                     playersVoting.forEach(function(playerVoting:Player, ... args):void
                     {
                        formattedVotes.getDataForPlayer(majorityPlayer)[role.name].push(playerVoting);
                     });
                  }
                  else if(_votablePlayers(formattedVotes,roles).length > 1)
                  {
                     playerVotedFor = _playerToStartTie(formattedVotes,roles);
                     formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(playerVotedFor);
                     if(GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] > 2)
                     {
                        formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(_randomVoter(playerVotedFor,formattedVotes,role));
                     }
                     tiedPlayer = _playerToTieWith(formattedVotes,roles,playerVotedFor);
                     formattedVotes.getDataForPlayer(tiedPlayer)[role.name].push(tiedPlayer);
                     if(GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] > 2)
                     {
                        formattedVotes.getDataForPlayer(tiedPlayer)[role.name].push(_randomVoter(tiedPlayer,formattedVotes,role));
                     }
                  }
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[7]:
               roles.forEach(function(role:RoleData, roleIndex:int, ... args):void
               {
                  var majorityPlayer:Player = null;
                  var playersVoting:Array = null;
                  var playerVotedFor:Player = null;
                  var tiedPlayer:Player = null;
                  if(roleIndex + 1 <= roles.length / 2)
                  {
                     majorityPlayer = GameState.instance.players[roleIndex];
                     playersVoting = [];
                     playersVoting = playersVoting.concat(ArrayUtil.getRandomElements(ArrayUtil.difference(GameState.instance.players,[majorityPlayer]),GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length]));
                     playersVoting.forEach(function(playerVoting:Player, ... args):void
                     {
                        formattedVotes.getDataForPlayer(majorityPlayer)[role.name].push(playerVoting);
                     });
                  }
                  else if(_votablePlayers(formattedVotes,roles).length > 1)
                  {
                     playerVotedFor = _playerToStartTie(formattedVotes,roles);
                     while(formattedVotes.getDataForPlayer(playerVotedFor)[role.name].length < GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] - 1)
                     {
                        formattedVotes.getDataForPlayer(playerVotedFor)[role.name].push(_randomVoter(playerVotedFor,formattedVotes,role));
                     }
                     tiedPlayer = _playerToTieWith(formattedVotes,roles,playerVotedFor);
                     while(formattedVotes.getDataForPlayer(tiedPlayer)[role.name].length < GameConstants.MAJORITY_VALUE_PER_PLAYER_COUNT[GameState.instance.players.length] - 1)
                     {
                        formattedVotes.getDataForPlayer(tiedPlayer)[role.name].push(_randomVoter(tiedPlayer,formattedVotes,role));
                     }
                  }
               });
               break;
            case GameConstants.AUTO_VOTE_TYPES[8]:
               GameState.instance.players.forEach(function(playerVotedFor:Player, ... args):void
               {
                  GameState.instance.players.forEach(function(playerVoting:Player, ... args):void
                  {
                     formattedVotes.getDataForPlayer(playerVotedFor)[_randomUnvotedRole(playerVoting,formattedVotes,roles).name].push(playerVoting);
                  });
               });
         }
         return formattedVotes;
      }
   }
}
