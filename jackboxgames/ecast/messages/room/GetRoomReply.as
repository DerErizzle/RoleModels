package jackboxgames.ecast.messages.room
{
   public class GetRoomReply
   {
      private var _appId:String;
      
      private var _appTag:String;
      
      private var _audienceEnabled:Boolean;
      
      private var _code:String;
      
      private var _host:String;
      
      private var _passwordRequired:Boolean;
      
      private var _twitchLocked:Boolean;
      
      public function GetRoomReply(appId:String, appTag:String, audienceEnabled:Boolean, code:String, host:String, passwordRequired:Boolean, twitchLocked:Boolean)
      {
         super();
         this._appId = appId;
         this._appTag = this._appTag;
         this._audienceEnabled = audienceEnabled;
         this._code = code;
         this._host = host;
         this._passwordRequired = passwordRequired;
         this._twitchLocked = twitchLocked;
      }
      
      public function get appId() : String
      {
         return this._appId;
      }
      
      public function get appTag() : String
      {
         return this._appTag;
      }
      
      public function get audienceEnabled() : Boolean
      {
         return this._audienceEnabled;
      }
      
      public function get code() : String
      {
         return this._code;
      }
      
      public function get host() : String
      {
         return this._host;
      }
      
      public function get passwordRequired() : Boolean
      {
         return this._passwordRequired;
      }
      
      public function get twitchLocked() : Boolean
      {
         return this._twitchLocked;
      }
   }
}

