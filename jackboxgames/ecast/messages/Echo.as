package jackboxgames.ecast.messages
{
   public class Echo
   {
      private var _message:String;
      
      public function Echo(message:String)
      {
         super();
         this._message = message;
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function toString() : String
      {
         return "Echo{message: " + this._message + "\n}";
      }
   }
}

