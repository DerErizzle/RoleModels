package jackboxgames.rolemodels.data.analysis
{
   import jackboxgames.rolemodels.data.RevealConstants;
   
   public class DataAnalysisMatchupMetadata
   {
       
      
      private var _revealConstants:RevealConstants;
      
      private var _usesUniqueProtoTags:Boolean;
      
      private var _rolesAreFromDifferentCategory:Boolean;
      
      private var _matchups:Array;
      
      public function DataAnalysisMatchupMetadata(revealConstants:RevealConstants, usesUniqueProtoTags:Boolean, rolesAreFromDifferentCategory:Boolean, matchups:Array)
      {
         super();
         this._revealConstants = revealConstants;
         this._usesUniqueProtoTags = usesUniqueProtoTags;
         this._rolesAreFromDifferentCategory = rolesAreFromDifferentCategory;
         this._matchups = matchups;
      }
      
      public function get revealConstants() : RevealConstants
      {
         return this._revealConstants;
      }
      
      public function get usesUniqueProtoTags() : Boolean
      {
         return this._usesUniqueProtoTags;
      }
      
      public function get rolesAreFromDifferentCategory() : Boolean
      {
         return this._rolesAreFromDifferentCategory;
      }
      
      public function get matchups() : Array
      {
         return this._matchups;
      }
      
      public function get weight() : int
      {
         var weight:int = 0;
         if(this._usesUniqueProtoTags)
         {
            weight += 2;
         }
         if(this._rolesAreFromDifferentCategory)
         {
            weight += 1;
         }
         return weight;
      }
   }
}
