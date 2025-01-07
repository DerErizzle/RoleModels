package jackboxgames.utils
{
   import jackboxgames.nativeoverride.Save;
   
   public class SavedValue
   {
      private var _key:String;
      
      private var _cachedValueContainer:Object;
      
      public function SavedValue(id:String, initial:*)
      {
         super();
         this._key = id;
         if(!Save.instance.loadObject(this._key))
         {
            this._cachedValueContainer = {"val":initial};
            Save.instance.saveObject(this._key,this._cachedValueContainer);
         }
         else
         {
            this._cachedValueContainer = Save.instance.loadObject(this._key);
         }
      }
      
      public function get val() : *
      {
         return this._cachedValueContainer.val;
      }
      
      public function set val(val:*) : void
      {
         this._cachedValueContainer = {"val":val};
         this.save();
      }
      
      public function save() : void
      {
         Save.instance.saveObject(this._key,this._cachedValueContainer);
      }
   }
}

