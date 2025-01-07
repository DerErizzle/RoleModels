package jackboxgames.utils
{
   import jackboxgames.nativeoverride.Save;
   import jackboxgames.talkshow.api.IEngineAPI;
   
   public class SavedTalkShowVariable
   {
      private var _key:String;
      
      private var _cachedValueContainer:Object;
      
      public function SavedTalkShowVariable(ts:IEngineAPI, name:String, initialValue:*)
      {
         super();
         this._key = "SAVED_TALK_SHOW_VARIABLE_" + name;
         if(!Save.instance.loadObject(this._key))
         {
            this._cachedValueContainer = {"value":initialValue};
            Save.instance.saveObject(this._key,this._cachedValueContainer);
         }
         else
         {
            this._cachedValueContainer = Save.instance.loadObject(this._key);
         }
      }
      
      public function get value() : *
      {
         return this._cachedValueContainer.value;
      }
      
      public function set value(val:*) : void
      {
         this._cachedValueContainer = {"value":val};
         Save.instance.saveObject(this._key,this._cachedValueContainer);
      }
   }
}

