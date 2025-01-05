package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class ArtifactData
   {
       
      
      private var _data:Object;
      
      public function ArtifactData(numRounds:int, players:Array)
      {
         var j:int = 0;
         super();
         this._data = {"rounds":[]};
         for(var i:int = 0; i < numRounds; i++)
         {
            this._data.rounds.push({
               "roundIndex":i,
               "initialVotes":[],
               "reveals":[]
            });
            for(j = 0; j < players.length; j++)
            {
               this._data.rounds[i].initialVotes.push({
                  "playerName":players[j].name.val,
                  "roles":[]
               });
            }
         }
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function setVotes(round:int, votes:PerPlayerContainer) : void
      {
         votes.forEach(function(voteObject:Object, playerId:String, ... args):void
         {
            var roleName:String = null;
            var namesOfVotingPlayers:Array = null;
            var p:Player = Player(GameState.instance.getPlayerByUserId(playerId));
            for(roleName in voteObject)
            {
               namesOfVotingPlayers = [];
               voteObject[roleName].forEach(function(votingPlayer:Player, ... args):void
               {
                  namesOfVotingPlayers.push(votingPlayer.name.val);
               });
               _data.rounds[round].initialVotes[p.index.val].roles.push({
                  "roleName":roleName,
                  "votes":namesOfVotingPlayers
               });
            }
         });
      }
      
      public function addReveal(round:int, reveal:IRevealData) : void
      {
         var p:Player = null;
         var namesOfRoles:String = null;
         var i:int = 0;
         var playerNames:Array = [];
         for each(p in reveal.primaryPlayers)
         {
            playerNames.push({"name":p.name.val});
         }
         namesOfRoles = "";
         for(i = 0; i < reveal.rolesInvolved.length; i++)
         {
            namesOfRoles += reveal.rolesInvolved[i].name;
            if(i < reveal.rolesInvolved.length - 1)
            {
               namesOfRoles += ", ";
            }
         }
         this._data.rounds[round].reveals.push({
            "name":reveal.revealConstants.name,
            "playersInvolved":playerNames,
            "rolesInvolved":namesOfRoles
         });
      }
      
      public function addVoteResult(round:int, primaryPlayers:Array, votes:PerPlayerContainer) : void
      {
         var playerObject:Object = null;
         var p:Player = null;
         var namesOfVotingPlayers:Array = null;
         for each(playerObject in ArrayUtil.last(this._data.rounds[round].reveals).playersInvolved)
         {
            for each(p in primaryPlayers)
            {
               if(playerObject.name == p.name.val)
               {
                  namesOfVotingPlayers = [];
                  votes.getDataForPlayer(p).forEach(function(votingPlayer:Player, ... args):void
                  {
                     namesOfVotingPlayers.push(votingPlayer.name.val);
                  });
                  playerObject.votes = namesOfVotingPlayers;
               }
            }
         }
      }
      
      public function addAbundanceResult(round:int, roles:Array, votes:Object) : void
      {
         var role:RoleData = null;
         var namesOfVotingPlayers:Array = null;
         var votingUserId:String = null;
         ArrayUtil.last(this._data.rounds[round].reveals).abundanceRoles = [];
         for each(role in roles)
         {
            namesOfVotingPlayers = [];
            for each(votingUserId in votes[role.name])
            {
               if(votingUserId == Player.AUDIENCE_PLAYER.userId.val)
               {
                  namesOfVotingPlayers.push(Player.AUDIENCE_PLAYER.name.val);
               }
               else
               {
                  namesOfVotingPlayers.push(GameState.instance.getPlayerByUserId(votingUserId).name.val);
               }
            }
            ArrayUtil.last(this._data.rounds[round].reveals).abundanceRoles.push({
               "roleName":role.name,
               "votes":namesOfVotingPlayers
            });
         }
      }
      
      public function addSplitResult(round:int, primaryPlayers:Array, votes:PerPlayerContainer) : void
      {
         var playerObject:Object = null;
         for each(playerObject in ArrayUtil.last(this._data.rounds[round].reveals).playersInvolved)
         {
            playerObject.splitRoles = [];
            votes.forEach(function(voteObject:Object, playerId:String, ... args):void
            {
               var roleName:String = null;
               var namesOfVotingPlayers:Array = null;
               var p:Player = Player(GameState.instance.getPlayerByUserId(playerId));
               if(playerObject.name == p.name.val)
               {
                  for(roleName in voteObject)
                  {
                     namesOfVotingPlayers = [];
                     voteObject[roleName].forEach(function(votingPlayer:Player, ... args):void
                     {
                        namesOfVotingPlayers.push(votingPlayer.name.val);
                     });
                     playerObject.splitRoles.push({
                        "roleName":roleName,
                        "votes":namesOfVotingPlayers
                     });
                  }
               }
            });
         }
      }
      
      public function addTriviaResult(round:int, correctPlayer:Player) : void
      {
         ArrayUtil.last(this._data.rounds[round].reveals).correctPlayer = correctPlayer.name.val;
      }
      
      public function addPlayerChoiceResult(round:int, chosenPlayer:Player) : void
      {
         ArrayUtil.last(this._data.rounds[round].reveals).chosenPlayer = chosenPlayer.name.val;
      }
      
      public function addFinalPlayerInfo() : void
      {
         var p:Player = null;
         var playerInfo:Object = null;
         var uberRoleString:String = null;
         var role:RoleData = null;
         var roleInfo:Object = null;
         var tag:TagData = null;
         this._data.finalPlayerInfo = [];
         for each(p in GameState.instance.players)
         {
            playerInfo = {
               "playerName":p.name.val,
               "userId":p.userId.val,
               "color":GameConstants.PLAYER_COLORS[p.index.val],
               "score":p.score.val,
               "placeIndex":p.placeIndex,
               "tookPicture":p.tookPicture,
               "drewAvatar":p.drewAvatar,
               "uberRole":GameState.instance.getPlayerFinalRole(p),
               "uberRoleArray":[],
               "roles":[]
            };
            for each(uberRoleString in GameState.instance.getPlayerFinalRoleTags(p))
            {
               playerInfo.uberRoleArray.push(uberRoleString);
            }
            for each(role in GameState.instance.playerAssignedRoles(p))
            {
               roleInfo = {
                  "roleName":role.name,
                  "shortRoleName":role.shortName,
                  "roleSource":role.source,
                  "isRequired":role.required,
                  "categoryName":role.categoryName,
                  "categoryId":role.idOfCategory,
                  "usedInDataAnalysis":role.usedInDataAnalysis,
                  "tags":[]
               };
               for each(tag in role.tags)
               {
                  roleInfo.tags.push({
                     "rawString":tag.rawString,
                     "wasModified":tag.wasModified,
                     "usedPower":tag.usedPower,
                     "partOfSpeech":tag.type,
                     "protoTag":tag.protoTag,
                     "protoTagPartOfSpeech":tag.protoTagType
                  });
               }
               playerInfo.roles.push(roleInfo);
            }
            this._data.finalPlayerInfo.push(playerInfo);
         }
      }
   }
}
