package jackboxgames.rolemodels
{
   import jackboxgames.loader.*;
   import jackboxgames.logger.*;
   import jackboxgames.rolemodels.actionpackages.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class DeveloperConsoleAPI
   {
       
      
      private var _ts:IEngineAPI;
      
      private var _tests:Object;
      
      public function DeveloperConsoleAPI(ts:IEngineAPI)
      {
         super();
         this._ts = ts;
         JBGLoader.instance.loadFile("tests.jet",function(result:Object):void
         {
            _tests = Boolean(result.success) ? result.contentAsJSON : {};
         });
      }
      
      public function help() : void
      {
         Logger.debug("go to the wiki for (hopefully) up-to-date documentation on developer functions");
      }
      
      public function runReveal(revealName:String, numPrimaryPlayers:int = 1) : void
      {
         if(GameState.instance.players.length < GameConstants.MIN_PLAYERS)
         {
            Logger.error("Minimum number of players not connected. Please connect the minimum number of players before running the test.");
            return;
         }
         var availableListOfReveals:Array = this._tests["Reveals"]["availableList"];
         if(!ArrayUtil.arrayContainsElement(availableListOfReveals,revealName))
         {
            Logger.error("Reveal name provided not found in list of testable reveals!");
            return;
         }
         if(this._isValidTestParameters(revealName,numPrimaryPlayers))
         {
            this._ts.g.runningTestMc.tf.text = revealName;
            this._ts.g.runningTestMc.visible = true;
            this._ts.g["debugReveal"] = true;
            GameState.instance.currentReveal = this._testRevealFactory(revealName,numPrimaryPlayers);
            if(GameState.instance.currentReveal.revealConstants.type == RevealConstants.REVEAL_DATA_TYPES.tie)
            {
               this.autoVote("HalfAndHalfSV");
            }
            else if(GameState.instance.currentReveal.revealConstants.type == RevealConstants.REVEAL_DATA_TYPES.majority)
            {
               this.autoVote("MajoritySV");
            }
            GameState.instance.currentRound.setRoundVotes(AutoVoter.formatAutoVotes(GameState.instance.players,GameState.instance.currentRound.allRoles));
         }
         else
         {
            this._ts.g.runningTestMc.tf.text = "";
            this._ts.g.runningTestMc.visible = false;
         }
      }
      
      private function _isValidTestParameters(revealName:String, numPrimaryPlayers:int) : Boolean
      {
         switch(revealName)
         {
            case GameConstants.REVEAL_CONSTANTS.powers.name:
            case GameConstants.REVEAL_CONSTANTS.majority.name:
            case GameConstants.REVEAL_CONSTANTS.recount.name:
            case GameConstants.REVEAL_CONSTANTS.trivia.name:
            case GameConstants.REVEAL_CONSTANTS.getInCharacter.name:
            case GameConstants.REVEAL_CONSTANTS.methodAct.name:
               if(numPrimaryPlayers < 1)
               {
                  Logger.error("Number of primary players specified is less than 1");
                  return false;
               }
               break;
            case GameConstants.REVEAL_CONSTANTS.abundance:
            case GameConstants.REVEAL_CONSTANTS.tagContradiction.name:
               if(numPrimaryPlayers != 1)
               {
                  Logger.error("For this reveal the player count can only be 1");
                  return false;
               }
               break;
            case GameConstants.REVEAL_CONSTANTS.judgement.name:
            case GameConstants.REVEAL_CONSTANTS.fightTiebreaker.name:
               if(numPrimaryPlayers < 2)
               {
                  Logger.error("Number of primary players specified is less than 2");
                  return false;
               }
               break;
            case GameConstants.REVEAL_CONSTANTS.fightJustPlaying.name:
            case GameConstants.REVEAL_CONSTANTS.split.name:
            case GameConstants.REVEAL_CONSTANTS.tagResolution.name:
               if(numPrimaryPlayers != 2)
               {
                  Logger.error("For this reveal the player count can only be 2");
                  return false;
               }
               break;
            case GameConstants.REVEAL_CONSTANTS.tagChoice.name:
               if(numPrimaryPlayers != 1 && numPrimaryPlayers != 2)
               {
                  Logger.error("For Tag Choice the player count can only be either 1 or 2");
                  return false;
               }
               break;
         }
         return true;
      }
      
      private function _testRevealFactory(revealName:String, numPrimaryPlayers:int) : IRevealData
      {
         var role:RoleData;
         var testContent:Object = null;
         var testRoundData:RoundData = null;
         var primaryPlayers:Array = null;
         var votes:PerPlayerContainer = null;
         var judgePlayer:Array = null;
         var powerfulPlayer:Player = null;
         var splitPlayers:Array = null;
         var splitPromptContent:Object = null;
         var splitRole:RoleData = null;
         var methodActPromptContent:Object = null;
         var methodActRole:RoleData = null;
         var methodActPrimaryPlayers:Array = null;
         var triviaPromptContent:Object = null;
         var triviaRole:RoleData = null;
         var fightTiebreakerContent:Object = null;
         var fightTiebreakerRole:RoleData = null;
         var fightTiebreakerPrimaryPlayers:Array = null;
         var abundancePrimaryPlayer:Player = null;
         var abundanceRoles:Array = null;
         var tagChoicePrimaryPlayers:Array = null;
         var tagChoiceRoles:Array = null;
         var firstTagChoiceTag:TagData = null;
         var secondTagChoiceTag:TagData = null;
         var tagResolutionPrimaryPlayers:Array = null;
         var tagResolutionRoles:Array = null;
         var tagResolutionTag1:TagData = null;
         var tagResolutionTag2:TagData = null;
         var printfTag:String = null;
         var tagContradictionPrimaryPlayer:Player = null;
         var tagContradictionRoles:Array = null;
         var tagContradictionTag1:TagData = null;
         var tagContradictionTag2:TagData = null;
         var fightJustPlayingPrimaryPlayers:Array = null;
         var fightJustPlayingRoles:Array = null;
         var fightJustPlayingTag1:TagData = null;
         var fightJustPlayingTag2:TagData = null;
         var fightJustPlayingTags:Array = null;
         var fightJustPlayingTagsPerPlayer:PerPlayerContainer = null;
         var r:RoleData = null;
         var firstPotentialTag:TagData = null;
         testContent = this._findUsableContent(revealName);
         testRoundData = new RoundData();
         testRoundData.setContent(testContent);
         this._ts.g.templateRootPath = JBGLoader.instance.getUrl(testContent.path);
         GameState.instance.debugRound = testRoundData;
         role = ArrayUtil.getRandomElement(GameState.instance.currentRound.getRolesOfSource(RoleData.ROLE_SOURCE.INITIAL));
         primaryPlayers = [];
         switch(revealName)
         {
            case GameConstants.REVEAL_CONSTANTS.majority.name:
               primaryPlayers = ArrayUtil.shuffled(GameState.instance.players.concat());
               votes = new PerPlayerContainer();
               primaryPlayers.forEach(function(player:Player, i:int, ... args):void
               {
                  if(i == 0)
                  {
                     votes.setDataForPlayer(player,GameState.instance.players);
                  }
                  else
                  {
                     votes.setDataForPlayer(player,[]);
                  }
               });
               return new MajorityData(GameConstants.REVEAL_CONSTANTS.majority,role,ArrayUtil.first(primaryPlayers),votes,true,true,1,0);
            case GameConstants.REVEAL_CONSTANTS.recount.name:
               primaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers);
               return new RecountData(GameConstants.REVEAL_CONSTANTS.recount,role,primaryPlayers,GameState.instance.players);
            case GameConstants.REVEAL_CONSTANTS.judgement.name:
               primaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,2);
               judgePlayer = ArrayUtil.getRandomElements(ArrayUtil.difference(GameState.instance.players,primaryPlayers));
               return new JudgementData(GameConstants.REVEAL_CONSTANTS.judgement,role,primaryPlayers,judgePlayer);
            case GameConstants.REVEAL_CONSTANTS.getInCharacter.name:
               for each(r in GameState.instance.currentRound.getRolesOfSource(RoleData.ROLE_SOURCE.INITIAL))
               {
                  if(Boolean(testRoundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.getInCharacter,r)))
                  {
                     role = r;
                     break;
                  }
               }
               primaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers);
               return new GetInCharacterData(GameConstants.REVEAL_CONSTANTS.getInCharacter,role,primaryPlayers,ArrayUtil.difference(GameState.instance.players,primaryPlayers),testRoundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.getInCharacter,role).question,testRoundData.getRolePromptFromRevealContent(GameConstants.REVEAL_CONSTANTS.getInCharacter,role).idx);
            case GameConstants.REVEAL_CONSTANTS.freebie.name:
               return new FreebieData(GameConstants.REVEAL_CONSTANTS.freebie,role,ArrayUtil.getRandomElement(GameState.instance.players));
            case GameConstants.REVEAL_CONSTANTS.powers.name:
               powerfulPlayer = ArrayUtil.getRandomElement(GameState.instance.players);
               return new PowersData(GameConstants.REVEAL_CONSTANTS.powers,role,ArrayUtil.getRandomElement(role.tags),powerfulPlayer,ArrayUtil.getRandomElements(ArrayUtil.difference(GameState.instance.players,[powerfulPlayer]),GameConstants.REVEAL_CONSTANTS.powers.maxPlayers),ArrayUtil.getRandomElement([Powers.STEAL,Powers.GIVE,Powers.DONATE]));
            case GameConstants.REVEAL_CONSTANTS.split.name:
               splitPlayers = ArrayUtil.getRandomElements(GameState.instance.players,2);
               splitPromptContent = ArrayUtil.getRandomElement(testRoundData.getRevealContent(GameConstants.REVEAL_CONSTANTS.split.name).prompts);
               splitRole = this._findRoleInformation(testRoundData,testContent,splitPromptContent.name);
               return new SplitData(GameConstants.REVEAL_CONSTANTS.split,splitRole,splitPlayers,ArrayUtil.difference(GameState.instance.players,splitPlayers),splitPromptContent.question,splitPromptContent.roles.slice(0,2).map(function(roleContent:Object, index:int, ... args):RoleData
               {
                  var newRole:* = new RoleData(roleContent.name,roleContent.hasOwnProperty("short") ? String(roleContent.short) : String(roleContent.name),RoleData.ROLE_SOURCE.SPLIT,roleContent.tags,index,testRoundData.contentId,testRoundData.category);
                  testRoundData.addRole(newRole);
                  return newRole;
               }),splitPromptContent.idx);
            case GameConstants.REVEAL_CONSTANTS.methodAct.name:
               methodActPromptContent = ArrayUtil.getRandomElement(testRoundData.getRevealContent(GameConstants.REVEAL_CONSTANTS.methodAct.name).prompts);
               methodActRole = this._findRoleInformation(testRoundData,testContent,methodActPromptContent.name);
               methodActPrimaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers);
               return new MethodActData(GameConstants.REVEAL_CONSTANTS.methodAct,methodActRole,methodActPrimaryPlayers,ArrayUtil.difference(GameState.instance.players,methodActPrimaryPlayers),methodActPromptContent.question,methodActPromptContent.idx);
            case GameConstants.REVEAL_CONSTANTS.trivia.name:
               triviaPromptContent = ArrayUtil.getRandomElement(testRoundData.getRevealContent(GameConstants.REVEAL_CONSTANTS.trivia.name).prompts);
               triviaRole = this._findRoleInformation(testRoundData,testContent,triviaPromptContent.name);
               return new TriviaData(GameConstants.REVEAL_CONSTANTS.trivia,triviaRole,ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers),triviaPromptContent.question,[triviaPromptContent.correct].concat(triviaPromptContent.altSpellings),triviaPromptContent.idx);
            case GameConstants.REVEAL_CONSTANTS.fightTiebreaker.name:
               fightTiebreakerContent = ArrayUtil.getRandomElement(testRoundData.getRevealContent(GameConstants.REVEAL_CONSTANTS.fightTiebreaker.name).prompts);
               fightTiebreakerRole = this._findRoleInformation(testRoundData,testContent,fightTiebreakerContent.name);
               fightTiebreakerPrimaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers);
               return new FightTiebreakerData(GameConstants.REVEAL_CONSTANTS.fightTiebreaker,fightTiebreakerRole,fightTiebreakerPrimaryPlayers,ArrayUtil.difference(GameState.instance.players,fightTiebreakerPrimaryPlayers),fightTiebreakerContent.question,fightTiebreakerContent.idx);
            case GameConstants.REVEAL_CONSTANTS.abundance.name:
               abundancePrimaryPlayer = ArrayUtil.getRandomElement(GameState.instance.players);
               abundanceRoles = ArrayUtil.getRandomElements(testRoundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL),1);
               abundanceRoles.push(ArrayUtil.getRandomElement(testRoundData.getRolesOfSource(RoleData.ROLE_SOURCE.CONSOLATION)));
               return new AbundanceData(GameConstants.REVEAL_CONSTANTS.abundance,abundanceRoles,abundancePrimaryPlayer,ArrayUtil.difference(GameState.instance.players,[abundancePrimaryPlayer]));
            case GameConstants.REVEAL_CONSTANTS.tagChoice.name:
               tagChoicePrimaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers);
               tagChoiceRoles = ArrayUtil.getRandomElements(testRoundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL),2);
               for each(firstPotentialTag in tagChoiceRoles[0].tags)
               {
                  if(TagData.differentTags(tagChoiceRoles[1].tags,[firstPotentialTag]).length > 0)
                  {
                     firstTagChoiceTag = firstPotentialTag;
                     secondTagChoiceTag = ArrayUtil.getRandomElement(TagData.differentTags(tagChoiceRoles[1].tags,[firstPotentialTag]));
                     break;
                  }
               }
               if(firstTagChoiceTag == null)
               {
                  firstTagChoiceTag = ArrayUtil.getRandomElement(tagChoiceRoles[0].tags);
                  secondTagChoiceTag = ArrayUtil.getRandomElement(tagChoiceRoles[1].tags);
               }
               return new TagChoiceData(GameConstants.REVEAL_CONSTANTS.tagChoice,tagChoiceRoles,[firstTagChoiceTag,secondTagChoiceTag],tagChoicePrimaryPlayers,ArrayUtil.difference(GameState.instance.players,tagChoicePrimaryPlayers));
            case GameConstants.REVEAL_CONSTANTS.tagResolution.name:
               tagResolutionPrimaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers);
               tagResolutionRoles = ArrayUtil.getRandomElements(testRoundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL),2);
               tagResolutionRoles[0].playerAssignedRole = tagResolutionPrimaryPlayers[0];
               tagResolutionRoles[1].playerAssignedRole = tagResolutionPrimaryPlayers[1];
               tagResolutionTag1 = ArrayUtil.getRandomElement(tagResolutionRoles[0].tags);
               tagResolutionTag2 = ArrayUtil.getRandomElement(tagResolutionRoles[1].tags);
               printfTag = tagResolutionTag1.protoTagType == TagData.TYPE_NOUN ? "OF A " + tagResolutionTag1.protoTag : tagResolutionTag1.protoTag;
               return new TagResolutionData(GameConstants.REVEAL_CONSTANTS.tagResolution,tagResolutionRoles,tagResolutionPrimaryPlayers,ArrayUtil.difference(GameState.instance.players,tagResolutionPrimaryPlayers),printfTag,[tagResolutionTag1,tagResolutionTag2],LocalizationUtil.getPrintfText("TAG_RESOLUTION_TEMP_PROMPT",printfTag));
            case GameConstants.REVEAL_CONSTANTS.tagContradiction.name:
               tagContradictionPrimaryPlayer = ArrayUtil.getRandomElement(GameState.instance.players);
               tagContradictionRoles = ArrayUtil.getRandomElements(testRoundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL),2);
               tagContradictionRoles[0].playerAssignedRole = tagContradictionPrimaryPlayer;
               tagContradictionRoles[1].playerAssignedRole = tagContradictionPrimaryPlayer;
               tagContradictionTag1 = ArrayUtil.getRandomElement(tagContradictionRoles[0].tags);
               tagContradictionTag2 = ArrayUtil.getRandomElement(tagContradictionRoles[1].tags);
               return new TagContradictionData(GameConstants.REVEAL_CONSTANTS.tagContradiction,tagContradictionRoles,[tagContradictionTag1,tagContradictionTag2],tagContradictionPrimaryPlayer,ArrayUtil.difference(GameState.instance.players,[tagContradictionPrimaryPlayer]),LocalizationUtil.getPrintfText("TAG_CONTRADICTION_TEMP_PROMPT",ArrayUtil.getRandomElement(TagContradiction.FILLER_TOPICS)));
            case GameConstants.REVEAL_CONSTANTS.fightJustPlaying.name:
               fightJustPlayingPrimaryPlayers = ArrayUtil.getRandomElements(GameState.instance.players,numPrimaryPlayers);
               fightJustPlayingRoles = ArrayUtil.getRandomElements(testRoundData.getUnassignedRolesOfSource(RoleData.ROLE_SOURCE.INITIAL),2);
               fightJustPlayingRoles[0].playerAssignedRole = fightJustPlayingPrimaryPlayers[0];
               fightJustPlayingRoles[1].playerAssignedRole = fightJustPlayingPrimaryPlayers[1];
               fightJustPlayingTag1 = ArrayUtil.getRandomElement(fightJustPlayingRoles[0].tags);
               fightJustPlayingTag2 = ArrayUtil.getRandomElement(fightJustPlayingRoles[1].tags);
               fightJustPlayingTags = [fightJustPlayingTag1,fightJustPlayingTag2];
               fightJustPlayingTagsPerPlayer = new PerPlayerContainer();
               fightJustPlayingPrimaryPlayers.forEach(function(player:Player, i:int, ... args):void
               {
                  fightJustPlayingTagsPerPlayer.setDataForPlayer(player,LocalizationUtil.getPrintfText("FIGHT_JUST_PLAYING_VOTE_CHOICE",player.name.val,fightJustPlayingTags[i].protoTag));
               });
               return new FightJustPlayingData(GameConstants.REVEAL_CONSTANTS.fightJustPlaying,fightJustPlayingPrimaryPlayers,ArrayUtil.difference(GameState.instance.players,fightJustPlayingPrimaryPlayers),fightJustPlayingTagsPerPlayer,fightJustPlayingRoles,fightJustPlayingTags,LocalizationUtil.getPrintfText("FIGHT_JUST_PLAYING_TEMP_PROMPT"));
            default:
               return null;
         }
      }
      
      private function _findUsableContent(revealName:String) : Object
      {
         var contentType:String = null;
         var testContent:Object = null;
         var testRoundData:RoundData = new RoundData();
         var requiresContent:Boolean = this._getRevealConstantsFromString(revealName).requiresContent;
         if(revealName == GameConstants.REVEAL_CONSTANTS.abundance.name)
         {
            revealName = "Consolation";
         }
         for each(contentType in GameConstants.CATEGORY_TYPES)
         {
            for each(testContent in ContentManager.instance.getAllContent(contentType))
            {
               if(!requiresContent)
               {
                  return testContent;
               }
               testRoundData.setContent(testContent);
               if(Boolean(testRoundData.getRevealContent(revealName)))
               {
                  return testContent;
               }
            }
         }
         return null;
      }
      
      private function _findRoleInformation(testRoundData:RoundData, content:Object, roleName:String) : RoleData
      {
         var role:Object;
         var existingRole:RoleData = null;
         if(Boolean(GameState.instance.currentRound))
         {
            existingRole = GameState.instance.currentRound.getRole(roleName);
            if(Boolean(existingRole))
            {
               return existingRole;
            }
         }
         role = ArrayUtil.find(content.roles,function(role:Object, i:int, a:Array):Boolean
         {
            return role.name == roleName;
         });
         if(Boolean(role))
         {
            return new RoleData(role.name,role.hasOwnProperty("short") ? String(role.short) : String(role.name),RoleData.ROLE_SOURCE.INITIAL,role.tags,content.roles.indexOf(role),testRoundData.contentId,testRoundData.category);
         }
         return null;
      }
      
      private function _getRevealConstantsFromString(revealName:String) : RevealConstants
      {
         var revealConstantsProperty:String = null;
         for(revealConstantsProperty in GameConstants.REVEAL_CONSTANTS)
         {
            if(GameConstants.REVEAL_CONSTANTS[revealConstantsProperty].name == revealName)
            {
               return GameConstants.REVEAL_CONSTANTS[revealConstantsProperty];
            }
         }
         return null;
      }
      
      private function _populateRoleInformation() : Boolean
      {
         var testRoundData:RoundData;
         var content:Array;
         var testContent:Object = null;
         if(GameState.instance.players.length < GameConstants.MIN_PLAYERS)
         {
            Logger.error("Minimum number of players not connected. Please connect the minimum number of players before running the test.");
            return false;
         }
         testRoundData = new RoundData();
         content = ContentManager.instance.getRandomUnusedContent(ArrayUtil.getRandomElement(GameConstants.CATEGORY_TYPES),3);
         for each(testContent in content)
         {
            testRoundData.setContent(testContent);
         }
         GameState.instance.debugRound = testRoundData;
         GameState.instance.players.forEach(function(p:Player, i:int, ... args):void
         {
            p.setup();
            p.score.val = NumberUtil.getRandomInt(20);
         });
         GameState.instance.currentRound.allRoles.forEach(function(role:RoleData, i:int, ... args):void
         {
            role.playerAssignedRole = GameState.instance.players[i % GameState.instance.players.length];
         });
         return true;
      }
      
      public function forceCategory(id:int) : void
      {
         var contentType:String = null;
         var possibleContent:Array = null;
         var contentFound:Boolean = false;
         for each(contentType in GameConstants.CATEGORY_TYPES)
         {
            possibleContent = ContentManager.instance.getContentByProperty(contentType,"id",id);
            if(possibleContent.length > 0)
            {
               CategoryManager.instance.addCategory(possibleContent);
               contentFound = true;
               break;
            }
         }
         if(!contentFound)
         {
            Logger.error("No Category with id = " + id + " found!");
         }
      }
      
      public function skipToWinnerScreen(isSkippingToWinnerScreen:Boolean) : void
      {
         this._ts.g.runningTestMc.tf.text = "WinnerScreen";
         this._ts.g.runningTestMc.visible = isSkippingToWinnerScreen;
         this._ts.g["debugFinalRole"] = isSkippingToWinnerScreen;
         this._ts.g["debugWinnerScreen"] = isSkippingToWinnerScreen;
         if(isSkippingToWinnerScreen)
         {
            this._populateRoleInformation();
         }
      }
      
      public function skipToCredits(isSkippingToCredits:Boolean) : void
      {
         this._ts.g.runningTestMc.tf.text = "Credits";
         this._ts.g.runningTestMc.visible = isSkippingToCredits;
         this._ts.g["debugFinalRole"] = isSkippingToCredits;
         this._ts.g["debugCredits"] = isSkippingToCredits;
         if(isSkippingToCredits)
         {
            this._populateRoleInformation();
         }
      }
      
      public function autoVote(type:String) : void
      {
         if(ArrayUtil.arrayContainsElement(GameConstants.AUTO_VOTE_TYPES,type))
         {
            TuneableValues.instance.getValue("AutoVote").val = true;
            TuneableValues.instance.getValue("VoteType").val = type;
         }
         else if(type.toLowerCase() == "off")
         {
            TuneableValues.instance.getValue("AutoVote").val = false;
            TuneableValues.instance.clearValue("VoteType");
         }
         else
         {
            Logger.error("No auto vote type called " + type + " found!");
         }
      }
      
      public function pluralityMode(isOn:Boolean) : void
      {
         TuneableValues.instance.getValue("PluralityMode").val = isOn;
      }
   }
}
