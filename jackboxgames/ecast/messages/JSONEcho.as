package jackboxgames.ecast.messages
{
   import jackboxgames.nativeoverride.JSON;
   
   public class JSONEcho
   {
      private var _message:Object;
      
      public function JSONEcho(message:Object)
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
         return "JSONEcho {\n    message: " + JSON.serialize(this._message) + "\n}";
      }
   }
}

