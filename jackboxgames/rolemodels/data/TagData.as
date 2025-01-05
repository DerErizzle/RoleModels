package jackboxgames.rolemodels.data
{
   import jackboxgames.rolemodels.utils.TagCorpusManager;
   import jackboxgames.utils.ArrayUtil;
   
   public class TagData
   {
      
      public static const TYPE_NOUN:String = "noun";
      
      public static const TYPE_ADJECTIVE:String = "adjective";
       
      
      private var _rawString:String;
      
      private var _wasModified:Boolean;
      
      private var _usedPower:Boolean;
      
      private var _type:String;
      
      private var _protoTag:String;
      
      private var _protoTagType:String;
      
      public function TagData(rawString:String)
      {
         super();
         this._rawString = rawString;
         this._wasModified = false;
         this._usedPower = false;
         if(TagCorpusManager.instance.hasDefinition(this._rawString))
         {
            this._type = TagCorpusManager.instance.getType(this._rawString);
            this._protoTag = TagCorpusManager.instance.getProtoTag(this._rawString);
            this._protoTagType = TagCorpusManager.instance.getProtoTagType(this._rawString);
         }
         else
         {
            this._type = TYPE_ADJECTIVE;
            this._protoTag = rawString;
            this._protoTagType = TYPE_ADJECTIVE;
         }
      }
      
      public static function tagsAreOpposites(tag1:TagData, tag2:TagData) : Boolean
      {
         return tag1.rawString != tag2.rawString && ArrayUtil.arrayContainsElement(TagCorpusManager.OPPOSITE_TAGS,tag1.protoTag + "," + tag2.protoTag);
      }
      
      public static function getRawStrings(arrayOfTags:Array) : Array
      {
         return arrayOfTags.map(function(tag:TagData, ... args):String
         {
            return tag.rawString;
         });
      }
      
      public static function differentTags(firstArrayOfTags:Array, secondArrayOfTags:Array) : Array
      {
         return firstArrayOfTags.filter(function(tag:TagData, ... args):Boolean
         {
            return !ArrayUtil.arrayContainsElement(getRawStrings(secondArrayOfTags),tag.rawString);
         });
      }
      
      public function get rawString() : String
      {
         return this._rawString;
      }
      
      public function get wasModified() : Boolean
      {
         return this._wasModified;
      }
      
      public function get usedPower() : Boolean
      {
         return this._usedPower;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get protoTag() : String
      {
         return this._protoTag;
      }
      
      public function get protoTagType() : String
      {
         return this._protoTagType;
      }
      
      public function usePower() : void
      {
         this._usedPower = true;
      }
      
      public function punchUp() : void
      {
         this._wasModified = true;
         this._rawString = this._type == TYPE_NOUN ? ArrayUtil.getRandomElement(TagCorpusManager.NOUN_PUNCHUPS) + this._rawString : ArrayUtil.getRandomElement(TagCorpusManager.ADJECTIVE_PUNCHUPS) + this._rawString;
      }
      
      public function punchDown() : void
      {
         this._wasModified = true;
         this._rawString = this._type == TYPE_NOUN ? ArrayUtil.getRandomElement(TagCorpusManager.NOUN_PUNCHDOWNS) + this._rawString : ArrayUtil.getRandomElement(TagCorpusManager.ADJECTIVE_PUNCHDOWNS) + this._rawString;
      }
   }
}
