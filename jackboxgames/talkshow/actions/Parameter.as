package jackboxgames.talkshow.actions
{
   import jackboxgames.talkshow.api.IParameter;
   
   public class Parameter implements IParameter
   {
      public static const TYPE_AUDIO:String = "A";
      
      public static const TYPE_BOOLEAN:String = "B";
      
      public static const TYPE_GRAPHIC:String = "G";
      
      public static const TYPE_LIST:String = "L";
      
      public static const TYPE_NUMBER:String = "N";
      
      public static const TYPE_STRING:String = "S";
      
      public static const TYPE_TEXT:String = "T";
      
      private var _name:String;
      
      private var _type:String;
      
      public function Parameter(name:String, type:String)
      {
         super();
         this._name = name;
         this._type = type;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function isMedia() : Boolean
      {
         return this._type == TYPE_AUDIO || this._type == TYPE_GRAPHIC || this._type == TYPE_TEXT;
      }
      
      public function isLoadableMedia() : Boolean
      {
         return this._type == TYPE_AUDIO || this._type == TYPE_GRAPHIC;
      }
   }
}

