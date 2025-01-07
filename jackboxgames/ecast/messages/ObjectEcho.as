package jackboxgames.ecast.messages
{
   import jackboxgames.nativeoverride.JSON;
   
   public class ObjectEcho
   {
      private var _message:Object;
      
      public function ObjectEcho(message:Object)
      {
         super();
         this._message = message;
      }
      
      public function get message() : Object
      {
         return this._message;
      }
      
      public function toString() : String
      {
         return "ObjectEcho {\n    message: " + JSON.serialize(this._message) + "\n}";
      }
   }
}

