package jackboxgames.thewheel.data
{
   public class JsonDataDef
   {
      private var _file:String;
      
      private var _type:Class;
      
      private var _property:String;
      
      public function JsonDataDef(file:String, type:Class, property:String)
      {
         super();
         this._file = file;
         this._type = type;
         this._property = property;
      }
      
      public function get file() : String
      {
         return this._file;
      }
      
      public function get type() : Class
      {
         return this._type;
      }
      
      public function get property() : String
      {
         return this._property;
      }
   }
}

