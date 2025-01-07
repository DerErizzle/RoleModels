package jackboxgames.ecast.messages
{
   public class TextEcho
   {
      private var _message:String;
      
      public function TextEcho(message:String)
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
         return "TextEcho{message: " + this._message + "\n}";
      }
   }
}

