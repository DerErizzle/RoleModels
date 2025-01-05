package jackboxgames.rolemodels
{
   import jackboxgames.rolemodels.data.*;
   
   public class GameConstants
   {
      
      public static const GAME_VERSION:String = "1.0.0";
      
      public static const UA_APPNAME:String = "Role Models";
      
      public static const UA_APPID:String = "rolemodels";
      
      public static const UA_VERSIONID:String = "1.0.0";
      
      public static const CATEGORY_TYPES:Array = ["RMPopCulturePrompt","RMSituationalPrompt"];
      
      public static const MIN_PLAYERS:int = 3;
      
      public static const MAX_PLAYERS:int = 6;
      
      public static const MAX_NUMBER_OF_ROUNDS:int = 3;
      
      public static const MINIMUM_ALLOWED_FUN_POINTS:int = 40;
      
      public static const MINIMUM_TIEBREAKER_REVEALS_PER_ROUND:int = 1;
      
      public static const MAX_MINIGAMES_PER_ROUND:int = 3;
      
      public static const NUMBER_OF_CATEGORY_OPTIONS:int = 5;
      
      public static const NUMBER_OF_TAGS_FOR_FINAL_ROLE:int = 3;
      
      public static const MAJORITY_CALLOUT_THRESHOLD:Number = 0.75;
      
      public static const TIEBREAKER_RESULTS:Object = {
         "QUIPLASH":"Quiplash",
         "MAJORITY":"Majority",
         "TIE":"Tie",
         "DOUBLE_DOWN_BROKE_TIE":"DoubleDownBrokeTie"
      };
      
      public static const SETTING_PREVENT_PICTURES:String = "PreventPictures";
      
      public static const AVATAR_DRAWING_SIZE_X:int = 300;
      
      public static const AVATAR_DRAWING_SIZE_Y:int = 408;
      
      public static const NUMBER_OF_CHARACTERS_IN_TEXT_ENTRY:int = 60;
      
      public static const AUDIENCE_VOTE_EXTRA_PELLET:int = 1;
      
      public static const PLAYER_COLORS:Array = ["#0001fe","#ff9b99","#fcfc08","#00ccfe","#ff0000","#ff9900"];
      
      public static const AUTO_VOTE_TYPES:Array = ["MajoritySV","MajorityNSV","AllTiesSV","AllTiesNSV","NoMajoritiesOrTiesSV","NoMajoritiesOrTiesNSV","HalfAndHalfSV","HalfAndHalfNSV","Random"];
      
      public static const MAJORITY_VALUE_PER_PLAYER_COUNT:Object = {
         3:2,
         4:2,
         5:3,
         6:3
      };
      
      public static const TROPHY_SIX_MAJORITIES_ONE_ROUND:String = "ROLEMODELS_SIX_MAJORITIES_ONE_ROUND";
      
      public static const TROPHY_SELF_DOUBLE_DOWN:String = "ROLEMODELS_SELF_DOUBLE_DOWN";
      
      public static const TROPHY_OBLIVIOUS_MAJORITY:String = "ROLEMODELS_OBLIVIOUS_MAJORITY";
      
      public static const TROPHY_GET_CONSOLATION:String = "ROLEMODELS_GET_CONSOLATION";
      
      public static const REVEAL_CONSTANTS:Object = {
         "majority":new RevealConstants({
            "name":"Majority",
            "felocity":1,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.majority,
            "pointsNotSelf":2,
            "pointsSelf":4,
            "requiresContent":false,
            "minPlayers":1,
            "maxPlayers":1
         }),
         "recount":new RevealConstants({
            "name":"Recount",
            "felocity":6,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":false,
            "maximumPerRound":1
         }),
         "judgement":new RevealConstants({
            "name":"Judgement",
            "felocity":7,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":false,
            "maximumPerRound":1
         }),
         "getInCharacter":new RevealConstants({
            "name":"GetInCharacter",
            "felocity":13,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":true
         }),
         "freebie":new RevealConstants({
            "name":"Freebie",
            "felocity":7,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.majority,
            "points":1,
            "requiresContent":false,
            "maximumPerRound":1,
            "minPlayers":1
         }),
         "abundance":new RevealConstants({
            "name":"Abundance",
            "felocity":10,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "points":1,
            "requiresContent":true,
            "maximumPerRound":1,
            "minPlayers":1
         }),
         "split":new RevealConstants({
            "name":"Split",
            "felocity":10,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":true,
            "maxPlayers":2
         }),
         "methodAct":new RevealConstants({
            "name":"MethodAct",
            "felocity":12,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":true
         }),
         "trivia":new RevealConstants({
            "name":"Trivia",
            "felocity":11,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":true
         }),
         "tagChoice":new RevealConstants({
            "name":"TagChoice",
            "felocity":9,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":false,
            "maximumPerRound":1,
            "minPlayers":1,
            "maxPlayers":2
         }),
         "fightTiebreaker":new RevealConstants({
            "name":"FightTiebreaker",
            "felocity":10,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.tie,
            "requiresContent":true
         }),
         "fightJustPlaying":new RevealConstants({
            "name":"FightJustPlaying",
            "felocity":12,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.justPlaying,
            "pointsForWinning":3,
            "requiresContent":false
         }),
         "tagResolution":new RevealConstants({
            "name":"TagResolution",
            "felocity":11,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.justPlaying,
            "pointsForWinning":3,
            "requiresContent":false
         }),
         "tagContradiction":new RevealConstants({
            "name":"TagContradiction",
            "felocity":13,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.justPlaying,
            "pointsForWinning":3,
            "pointsForVotingCorrectly":1,
            "requiresContent":false
         }),
         "powers":new RevealConstants({
            "name":"Powers",
            "felocity":10,
            "choosable":true,
            "type":RevealConstants.REVEAL_DATA_TYPES.justPlaying,
            "points":3,
            "requiresContent":false
         })
      };
       
      
      public function GameConstants()
      {
         super();
      }
   }
}
