package jackboxgames.utils
{
   import jackboxgames.logger.*;
   import jackboxgames.model.*;
   
   public class TextDescriptions
   {
      private static const ECAST_KEY:String = "textDescriptions";
      
      private var _gs:JBGGameState;
      
      private var _currentId:int;
      
      private var _data:Object;
      
      private var _descriptions:Array;
      
      public function TextDescriptions(gs:JBGGameState)
      {
         super();
         this._gs = gs;
         this._currentId = 0;
         this._data = {};
         this._descriptions = [];
      }
      
      public function reset() : void
      {
         this._data = {};
         this._descriptions = [];
      }
      
      public function setupForNewLobby() : void
      {
         this._gs.client.createObject(ECAST_KEY,this._generateEntity());
      }
      
      public function setTextData(id:String, text:String) : void
      {
         this._data[id] = text;
      }
      
      public function addTextDescription(category:String, ... args) : void
      {
         var text:String = LocalizationUtil.getPrintfText.apply(null,[category].concat(args));
         if(text == null || text == "")
         {
            return;
         }
         this._descriptions.push(new TextDescription(this._currentId,category,TextUtils.htmlUnescape(text)));
         ++this._currentId;
      }
      
      public function updateEntity() : void
      {
         this._gs.client.updateObject(ECAST_KEY,this._generateEntity());
         this._descriptions = [];
      }
      
      private function _generateEntity() : Object
      {
         return {
            "data":this._data,
            "latestDescriptions":this._descriptions.map(function(d:TextDescription, ... args):Object
            {
               return {
                  "id":d.id,
                  "category":d.category,
                  "text":d.description
               };
            })
         };
      }
   }
}

class TextDescription implements IToSimpleObject
{
   private var _id:int;
   
   private var _category:String;
   
   private var _description:String;
   
   public function TextDescription(newId:int, newCategory:String, text:String)
   {
      super();
      this._id = newId;
      this._category = newCategory;
      this._description = text;
   }
   
   public function get id() : int
   {
      return this._id;
   }
   
   public function get category() : String
   {
      return this._category;
   }
   
   public function get description() : String
   {
      return this._description;
   }
   
   public function toSimpleObject() : Object
   {
      return {
         "id":this._id,
         "category":this._category,
         "text":this._description
      };
   }
}

