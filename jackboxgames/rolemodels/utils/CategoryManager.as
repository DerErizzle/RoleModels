package jackboxgames.rolemodels.utils
{
   import jackboxgames.rolemodels.GameConstants;
   import jackboxgames.rolemodels.GameState;
   import jackboxgames.settings.SettingsUtil;
   import jackboxgames.utils.ContentManager;
   
   public class CategoryManager
   {
      
      private static var _instance:CategoryManager;
       
      
      private var _forcedCategories:Array;
      
      public function CategoryManager()
      {
         super();
         this._forcedCategories = [];
      }
      
      public static function get instance() : CategoryManager
      {
         if(!_instance)
         {
            _instance = new CategoryManager();
         }
         return _instance;
      }
      
      public function addCategory(categories:Array) : void
      {
         this._forcedCategories = this._forcedCategories.concat(categories);
      }
      
      private function _getForcedContentWhilePossible(forcedContent:Array) : Array
      {
         var designedContent:Array = null;
         var content:Array = [];
         while(content.length < GameConstants.NUMBER_OF_CATEGORY_OPTIONS)
         {
            if(forcedContent.length <= 0)
            {
               designedContent = [];
               switch(GameState.instance.roundIndex)
               {
                  case 0:
                     designedContent = designedContent.concat(ContentManager.instance.getRandomUnusedContent("RMPopCulturePrompt",3,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER]));
                     designedContent = designedContent.concat(ContentManager.instance.getRandomUnusedContent("RMSituationalPrompt",2,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER]));
                     break;
                  case 1:
                     designedContent = designedContent.concat(ContentManager.instance.getRandomUnusedContent("RMSituationalPrompt",3,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER]));
                     designedContent = designedContent.concat(ContentManager.instance.getRandomUnusedContent("RMPopCulturePrompt",2,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER]));
                     break;
                  case 2:
                     designedContent = designedContent.concat(ContentManager.instance.getRandomUnusedContent("RMSituationalPrompt",3,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER]));
                     designedContent = designedContent.concat(ContentManager.instance.getRandomUnusedContent("RMPopCulturePrompt",2,[SettingsUtil.FAMILY_FRIENDLY_CONTENT_FILTER]));
               }
               return content.concat(designedContent.slice(content.length));
            }
            content.push(forcedContent.shift());
         }
         return content;
      }
      
      public function getCategories() : Array
      {
         return this._getForcedContentWhilePossible(this._forcedCategories);
      }
   }
}
