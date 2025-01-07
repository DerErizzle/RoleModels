package jackboxgames.ecast.messages.room
{
   public class CreateRoomReply
   {
      private var _code:String;
      
      private var _token:String;
      
      private var _host:String;
      
      public function CreateRoomReply(code:String, token:String, host:String)
      {
         super();
         this._code = code;
         this._token = token;
         this._host = host;
      }
      
      public function get code() : String
      {
         return this._code;
      }
      
      public function get token() : String
      {
         return this._token;
      }
      
      public function get host() : String
      {
         return this._host;
      }
   }
}

