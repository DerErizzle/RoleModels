package jackboxgames.talkshow.templates
{
   public class TemplateField
   {
      public static const TYPE_AUDIO:String = "A";
      
      public static const TYPE_BOOLEAN:String = "B";
      
      public static const TYPE_GRAPHIC:String = "G";
      
      public static const TYPE_NUMBER:String = "N";
      
      public static const TYPE_STRING:String = "S";
      
      protected var _name:String;
      
      protected var _id:int;
      
      protected var _type:String;
      
      protected var _def:String;
      
      protected var _var:String;
      
      public function TemplateField(id:int, name:String, type:String, def:String, variable:String)
      {
         super();
         this._name = name;
         this._id = id;
         this._type = type;
         this._def = def;
         this._var = variable;
      }
      
      public function toString() : String
      {
         return "[TemplateField name=" + this._name + "]";
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get defaultValue() : String
      {
         return this._def;
      }
      
      public function get variable() : String
      {
         return this._var;
      }
      
      public function getCue(cueId:int) : String
      {
         return "S+0.00";
      }
   }
}

