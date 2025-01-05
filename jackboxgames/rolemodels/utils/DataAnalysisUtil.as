package jackboxgames.rolemodels.utils
{
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.data.*;
   import jackboxgames.rolemodels.data.analysis.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class DataAnalysisUtil
   {
      
      public static const MATCHUP_TYPE_RESOLUTION:String = "resolution";
      
      public static const MATCHUP_TYPE_CONTRADICTION:String = "contradiction";
      
      public static const MATCHUP_TYPE_FIGHT:String = "fight";
       
      
      public function DataAnalysisUtil()
      {
         super();
      }
      
      public static function getBestMatchupsWithContent(type:String) : DataAnalysisMatchupMetadata
      {
         var revealConstants:RevealConstants = null;
         var getMatchups:Function = Nullable.NULL_FUNCTION;
         if(type == MATCHUP_TYPE_RESOLUTION)
         {
            getMatchups = GameState.instance.getTagResolutionMatchups;
            revealConstants = GameConstants.REVEAL_CONSTANTS.tagResolution;
         }
         else if(type == MATCHUP_TYPE_CONTRADICTION)
         {
            getMatchups = GameState.instance.getTagContradictionMatchups;
            revealConstants = GameConstants.REVEAL_CONSTANTS.tagContradiction;
         }
         else
         {
            if(type != MATCHUP_TYPE_FIGHT)
            {
               return new DataAnalysisMatchupMetadata(null,false,false,[]);
            }
            getMatchups = GameState.instance.getTagFightMatchups;
            revealConstants = GameConstants.REVEAL_CONSTANTS.fightJustPlaying;
         }
         var matchupsWithUniqueTagsAndCategories:Array = _removeMatchupsWithoutUniqueTagsAndDifferentCategories(_removeMatchupsWithoutContent(getMatchups(),type),type);
         if(matchupsWithUniqueTagsAndCategories.length > 0)
         {
            return new DataAnalysisMatchupMetadata(revealConstants,true,true,matchupsWithUniqueTagsAndCategories);
         }
         var matchupsWithUniqueTags:Array = _removeMatchupsWithoutUniqueTags(_removeMatchupsWithoutContent(getMatchups(),type),type);
         if(matchupsWithUniqueTags.length > 0)
         {
            return new DataAnalysisMatchupMetadata(revealConstants,true,false,matchupsWithUniqueTags);
         }
         var matchupsWithDifferentCategories:Array = _removeMatchupsWithoutDifferentCategories(_removeMatchupsWithoutContent(getMatchups(),type));
         if(matchupsWithDifferentCategories.length > 0)
         {
            return new DataAnalysisMatchupMetadata(revealConstants,false,true,matchupsWithDifferentCategories);
         }
         var matchupsWithContent:Array = _removeMatchupsWithoutContent(getMatchups(),type);
         return new DataAnalysisMatchupMetadata(revealConstants,false,false,matchupsWithContent);
      }
      
      public static function getTagResolutionContent(protoTag:String, record:Boolean) : Array
      {
         return ContentManager.instance.getRandomUnusedContent("RMDataAnalysis",1,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER,function(o:Object, ... args):Boolean
         {
            return ArrayUtil.arrayContainsElement(o.same,protoTag.toLowerCase());
         }],record);
      }
      
      public static function getTagContradictionContent(protoTag1:String, protoTag2:String, record:Boolean) : Array
      {
         return ContentManager.instance.getRandomUnusedContent("RMDataAnalysis",1,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER,function(o:Object, ... args):Boolean
         {
            return ArrayUtil.arrayContainsArray(o.contradiction,[protoTag1.toLowerCase(),protoTag2.toLowerCase()]);
         }],record);
      }
      
      public static function getTagFightContent(protoTag1:String, protoTag2:String, record:Boolean) : Array
      {
         return ContentManager.instance.getRandomUnusedContent("RMDataAnalysis",1,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER,function(o:Object, ... args):Boolean
         {
            return ArrayUtil.arrayContainsArray(o.opposite,[protoTag1.toLowerCase(),protoTag2.toLowerCase()]);
         }],record);
      }
      
      private static function _removeMatchupsWithoutContent(matchups:Array, type:String) : Array
      {
         var matchup:DataAnalysisMatchup = null;
         var validRolePairAndTags:Array = null;
         var rolePairAndTags:RolePairAndTags = null;
         var validTags:Array = null;
         var tagPair:TagPair = null;
         var validMatchups:Array = [];
         for each(matchup in matchups)
         {
            validRolePairAndTags = [];
            for each(rolePairAndTags in matchup.rolesAndTags)
            {
               validTags = [];
               for each(tagPair in rolePairAndTags.tags)
               {
                  if(type == MATCHUP_TYPE_RESOLUTION && getTagResolutionContent(tagPair.tag1.protoTag,false).length > 0 && !GameState.instance.isTagUsedThisRound(tagPair.tag1))
                  {
                     validTags.push(tagPair);
                  }
                  else if(type == MATCHUP_TYPE_CONTRADICTION && getTagContradictionContent(tagPair.tag1.protoTag,tagPair.tag2.protoTag,false).length > 0 && !GameState.instance.isTagUsedThisRound(tagPair.tag1) && !GameState.instance.isTagUsedThisRound(tagPair.tag2))
                  {
                     validTags.push(tagPair);
                  }
                  else if(type == MATCHUP_TYPE_FIGHT && getTagFightContent(tagPair.tag1.protoTag,tagPair.tag2.protoTag,false).length > 0 && !GameState.instance.isTagUsedThisRound(tagPair.tag1) && !GameState.instance.isTagUsedThisRound(tagPair.tag2))
                  {
                     validTags.push(tagPair);
                  }
               }
               rolePairAndTags.tags = validTags;
               if(validTags.length > 0)
               {
                  validRolePairAndTags.push(rolePairAndTags);
               }
            }
            matchup.rolesAndTags = validRolePairAndTags;
            if(validRolePairAndTags.length > 0)
            {
               validMatchups.push(matchup);
            }
         }
         return validMatchups;
      }
      
      private static function _removeMatchupsWithoutUniqueTags(matchups:Array, type:String) : Array
      {
         var matchup:DataAnalysisMatchup = null;
         var validRolePairAndTags:Array = null;
         var rolePairAndTags:RolePairAndTags = null;
         var validTags:Array = null;
         var tagPair:TagPair = null;
         var validMatchups:Array = [];
         for each(matchup in matchups)
         {
            validRolePairAndTags = [];
            for each(rolePairAndTags in matchup.rolesAndTags)
            {
               validTags = [];
               for each(tagPair in rolePairAndTags.tags)
               {
                  if(type == MATCHUP_TYPE_RESOLUTION && !GameState.instance.isTagUsedThisGame(tagPair.tag1))
                  {
                     validTags.push(tagPair);
                  }
                  else if(!GameState.instance.isTagUsedThisGame(tagPair.tag1) && !GameState.instance.isTagUsedThisGame(tagPair.tag2))
                  {
                     validTags.push(tagPair);
                  }
               }
               rolePairAndTags.tags = validTags;
               if(validTags.length > 0)
               {
                  validRolePairAndTags.push(rolePairAndTags);
               }
            }
            matchup.rolesAndTags = validRolePairAndTags;
            if(validRolePairAndTags.length > 0)
            {
               validMatchups.push(matchup);
            }
         }
         return validMatchups;
      }
      
      private static function _removeMatchupsWithoutDifferentCategories(matchups:Array) : Array
      {
         var matchup:DataAnalysisMatchup = null;
         var validRolePairAndTags:Array = null;
         var rolePairAndTags:RolePairAndTags = null;
         var validMatchups:Array = [];
         for each(matchup in matchups)
         {
            validRolePairAndTags = [];
            for each(rolePairAndTags in matchup.rolesAndTags)
            {
               if(rolePairAndTags.role1.idOfCategory != rolePairAndTags.role2.idOfCategory)
               {
                  validRolePairAndTags.push(rolePairAndTags);
               }
            }
            matchup.rolesAndTags = validRolePairAndTags;
            if(validRolePairAndTags.length > 0)
            {
               validMatchups.push(matchup);
            }
         }
         return validMatchups;
      }
      
      private static function _removeMatchupsWithoutUniqueTagsAndDifferentCategories(matchups:Array, type:String) : Array
      {
         var matchup:DataAnalysisMatchup = null;
         var validRolePairAndTags:Array = null;
         var rolePairAndTags:RolePairAndTags = null;
         var validTags:Array = null;
         var tagPair:TagPair = null;
         var validMatchups:Array = [];
         for each(matchup in matchups)
         {
            validRolePairAndTags = [];
            for each(rolePairAndTags in matchup.rolesAndTags)
            {
               validTags = [];
               for each(tagPair in rolePairAndTags.tags)
               {
                  if(type == MATCHUP_TYPE_RESOLUTION && !GameState.instance.isTagUsedThisGame(tagPair.tag1))
                  {
                     validTags.push(tagPair);
                  }
                  else if(!GameState.instance.isTagUsedThisGame(tagPair.tag1) && !GameState.instance.isTagUsedThisGame(tagPair.tag2))
                  {
                     validTags.push(tagPair);
                  }
               }
               rolePairAndTags.tags = validTags;
               if(validTags.length > 0 && rolePairAndTags.role1.idOfCategory != rolePairAndTags.role2.idOfCategory)
               {
                  validRolePairAndTags.push(rolePairAndTags);
               }
            }
            matchup.rolesAndTags = validRolePairAndTags;
            if(validRolePairAndTags.length > 0)
            {
               validMatchups.push(matchup);
            }
         }
         return validMatchups;
      }
   }
}
