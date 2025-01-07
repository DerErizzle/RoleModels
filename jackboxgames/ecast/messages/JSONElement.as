package jackboxgames.ecast.messages
{
   import jackboxgames.nativeoverride.JSON;
   
   public class JSONElement
   {
      private var _key:String;
      
      private var _val:Object;
      
      private var _version:int;
      
      public function JSONElement(key:String, val:Object, version:int)
      {
         super();
         this._key = key;
         this._val = val;
         this._version = version;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get val() : Object
      {
         return this._val;
      }
      
      public function get version() : int
      {
         return this._version;
      }
      
      public function toString() : String
      {
         return "JSONElement {\n    key: " + this._key + "\n    val: " + JSON.serialize(this._val) + "\n}";
      }
   }
}

