package jackboxgames.thewheel.data
{
   import jackboxgames.localizy.*;
   import jackboxgames.utils.*;
   
   public class TriviaType
   {
      private var _data:Object;
      
      public function TriviaType(data:Object)
      {
         super();
         this._data = data;
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function getName(content:ITriviaContent) : String
      {
         var subTypeKey:String = null;
         if(Boolean(content.subtype))
         {
            subTypeKey = "TRIVIA_TYPE_" + this.id.toUpperCase() + "_" + content.subtype.toUpperCase() + "_NAME";
            if(LocalizationManager.instance.hasValueForKey(subTypeKey))
            {
               return LocalizationManager.instance.getValueForKey(subTypeKey);
            }
         }
         var baseNameKey:String = "TRIVIA_TYPE_" + this.id.toUpperCase() + "_NAME";
         return LocalizationManager.instance.getValueForKey(baseNameKey);
      }
      
      public function get actionPackageName() : String
      {
         return TextUtils.capitalizeFirstCharacter(this.id);
      }
      
      public function get actionPackageClass() : Class
      {
         return this._data.actionPackageClass;
      }
      
      public function get contentType() : String
      {
         return this._data.contentType;
      }
      
      public function get contentClass() : Class
      {
         return this._data.contentClass;
      }
   }
}

