package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.Player;
   
   public class RoleData
   {
      
      public static const ROLE_SOURCE:Object = {
         "CONSOLATION":"consolation",
         "SPLIT":"split",
         "INITIAL":"initial"
      };
       
      
      private var _source:String;
      
      private var _name:String;
      
      private var _shortName:String;
      
      private var _tags:Array;
      
      private var _indexInContent:int;
      
      private var _idOfCategory:String;
      
      private var _categoryName:String;
      
      private var _required:Boolean;
      
      private var _playerAssignedRole:Player;
      
      public function RoleData(name:String, shortName:String, source:String, tags:Array, indexInContent:int, idOfCategory:String, categoryName:String, required:Boolean = false)
      {
         super();
         this._name = name;
         this._shortName = shortName;
         this._source = source;
         this._tags = tags.map(function(tag:String, ... args):TagData
         {
            return new TagData(tag.toUpperCase());
         });
         this._indexInContent = indexInContent;
         this._idOfCategory = idOfCategory;
         this._categoryName = categoryName;
         this._required = required;
         this._playerAssignedRole = null;
      }
      
      public function get source() : String
      {
         return this._source;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get shortName() : String
      {
         return this._shortName;
      }
      
      public function get tags() : Array
      {
         return this._tags;
      }
      
      public function get indexInContent() : int
      {
         return this._indexInContent;
      }
      
      public function get idOfCategory() : String
      {
         return this._idOfCategory;
      }
      
      public function get categoryName() : String
      {
         return this._categoryName;
      }
      
      public function get required() : Boolean
      {
         return this._required;
      }
      
      public function get playerAssignedRole() : Player
      {
         return this._playerAssignedRole;
      }
      
      public function set playerAssignedRole(p:Player) : void
      {
         this._playerAssignedRole = p;
      }
      
      public function get usedInDataAnalysis() : Boolean
      {
         var tag:TagData = null;
         for each(tag in this._tags)
         {
            if(tag.wasModified || tag.usedPower)
            {
               return true;
            }
         }
         return false;
      }
   }
}
