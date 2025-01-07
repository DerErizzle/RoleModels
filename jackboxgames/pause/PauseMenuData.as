package jackboxgames.pause
{
   import jackboxgames.utils.*;
   
   public class PauseMenuData implements IToSimpleObject
   {
      private var _data:Object;
      
      private var _items:Array;
      
      public function PauseMenuData(data:Object)
      {
         super();
         this._data = data;
         this._items = this._data.items.map(function(itemData:Object, ... args):PauseMenuItemData
         {
            return new PauseMenuItemData(itemData);
         });
      }
      
      public function get localized() : Boolean
      {
         return this._data.localized;
      }
      
      public function get gameName() : String
      {
         return BuildConfig.instance.configVal("gameName");
      }
      
      public function get title() : String
      {
         return this._data.title;
      }
      
      public function get items() : Array
      {
         return this._items;
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "localized":this.localized,
            "gameName":this.gameName,
            "title":this.title,
            "items":SimpleObjectUtil.deepCopyWithSimpleObjectReplacement(this.items.filter(function(item:PauseMenuItemData, ... args):Boolean
            {
               return item.isVisible;
            }))
         };
      }
   }
}

