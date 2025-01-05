package jackboxgames.localizy
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import jackboxgames.logger.Logger;
   
   public class LocalizedTextFieldManager
   {
      
      private static var _instance:LocalizedTextFieldManager;
       
      
      private var _mapPerSource:Object;
      
      public function LocalizedTextFieldManager()
      {
         super();
         this._mapPerSource = {};
      }
      
      public static function get instance() : LocalizedTextFieldManager
      {
         if(!_instance)
         {
            _instance = new LocalizedTextFieldManager();
         }
         return _instance;
      }
      
      public function add(array:Array) : void
      {
         var element:* = undefined;
         var source:String = LocalizationManager.GameSource;
         if(array == null || array.length == 0)
         {
            return;
         }
         if(this._mapPerSource[source] == null)
         {
            this._mapPerSource[source] = new Dictionary(true);
         }
         for each(element in array)
         {
            if(this._mapPerSource[source][element] == null)
            {
               if(element is TextField)
               {
                  this._mapPerSource[source][element] = new LocalizedTextField(element.parent as MovieClip);
               }
               else
               {
                  Logger.error("Invalid object type for LocalizedTextFieldManager.");
               }
            }
         }
      }
      
      public function remove(array:Array) : void
      {
         var element:* = undefined;
         var item:* = undefined;
         var source:String = LocalizationManager.GameSource;
         if(array == null || array.length == 0 || this._mapPerSource[source] == null)
         {
            return;
         }
         for each(element in array)
         {
            if(this._mapPerSource[source][element] != null)
            {
               item = this._mapPerSource[source][element];
               if(item is LocalizedTextField)
               {
                  (item as LocalizedTextField).destroy();
               }
               delete this._mapPerSource[source][element];
            }
         }
      }
      
      public function clear() : void
      {
         var element:* = undefined;
         var item:* = undefined;
         var source:String = LocalizationManager.GameSource;
         if(this._mapPerSource[source] == null)
         {
            return;
         }
         for each(element in this._mapPerSource[source])
         {
            item = this._mapPerSource[source][element];
            if(item != null && item is LocalizedTextField)
            {
               (item as LocalizedTextField).destroy();
            }
            delete this._mapPerSource[source][element];
         }
      }
   }
}
