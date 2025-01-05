package jackboxgames.rolemodels.utils
{
   import jackboxgames.loader.*;
   
   public class TagCorpusManager
   {
      
      private static const CORPUS_FILE:String = "TagCorpus.jet";
      
      public static const OPPOSITE_TAGS:Array = ["ETHICAL,EVIL","CUTE,SPOOKY","DEPENDABLE,WILD CARD","AGGRESSIVE,SWEETHEART","PARTY DUDE,SQUARE","CAREFREE,WORRIER","CAUTIOUS,THRILLSEEKER","LEADER,SIDEKICK","STYLISH,MESSY","CHILDLIKE,MATURE","SHOW-OFF,INTROVERT","FUNNY,SERIOUS","SMART,FOOLISH","LAZY,HARD-WORKING","FRIENDLY,GRUMPY","BRAVE,COWARD","CONFIDENT,ANXIOUS"];
      
      public static const NOUN_PUNCHUPS:Array = ["SUPER-","MEGA-"];
      
      public static const ADJECTIVE_PUNCHUPS:Array = ["SUPER ","EXTREMELY ","VERY "];
      
      public static const NOUN_PUNCHDOWNS:Array = ["SEMI-","QUASI-","PSEUDO-","WANNABE "];
      
      public static const ADJECTIVE_PUNCHDOWNS:Array = ["NOT VERY ","BARELY ","NOT SO "];
      
      public static const STEAL_POWER_TAGS:Array = ["SNEAKY"];
      
      public static const DONATE_POWER_TAGS:Array = ["WEALTHY"];
      
      public static const GIVE_POWER_TAGS:Array = ["HERO"];
      
      private static var _instance:TagCorpusManager;
       
      
      private var _corpus:Object;
      
      public function TagCorpusManager()
      {
         var loader:ILoader = null;
         super();
         this._corpus = null;
         loader = JBGLoader.instance.loadFile(CORPUS_FILE,function(result:Object):void
         {
            _corpus = Boolean(result.success) ? result.contentAsJSON : null;
            loader.dispose();
         });
      }
      
      public static function get instance() : TagCorpusManager
      {
         return _instance;
      }
      
      public static function initialize() : void
      {
         _instance = new TagCorpusManager();
      }
      
      public function hasDefinition(tag:String) : Boolean
      {
         return this._corpus.hasOwnProperty(tag);
      }
      
      public function getType(tag:String) : String
      {
         return this._corpus[tag].word_type;
      }
      
      public function getProtoTag(tag:String) : String
      {
         return this._corpus[tag].proto_tag;
      }
      
      public function getProtoTagType(tag:String) : String
      {
         return this._corpus[tag].proto_tag_type;
      }
   }
}
