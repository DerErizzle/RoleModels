package jackboxgames.ecast.messages.room
{
   public class RoomExit
   {
      public static const ECAST_ROOM_EXIT_CAUSE_NO_EXIT:String = "EcastRoomExitCauseNoExit";
      
      public static const ECAST_ROOM_EXIT_CAUSE_LOBBY_TIMEOUT:String = "EcastRoomExitCauseLobbyTimeout";
      
      public static const ECAST_ROOM_EXIT_CAUSE_JOIN_TIMEOUT:String = "EcastRoomExitCauseJoinTimeout";
      
      public static const ECAST_ROOM_EXIT_CAUSE_GAME_TIMEOUT:String = "EcastRoomExitCauseGameTimeout";
      
      public static const ECAST_ROOM_EXIT_CAUSE_DISCONNECT:String = "EcastRoomExitCauseDisconnect";
      
      public static const ECAST_ROOM_EXIT_CAUSE_BY_REQUEST:String = "EcastRoomExitCauseByRequest";
      
      public static const ECAST_ROOM_EXIT_CAUSE_SHUTTING_DOWN:String = "EcastRoomExitCauseShuttingDown";
      
      public static const ECAST_ROOM_EXIT_CAUSE_UNKNOWN:String = "EcastRoomExitCauseUnknown";
      
      private static const CAUSE_MAP:Object = {
         0:ECAST_ROOM_EXIT_CAUSE_NO_EXIT,
         1:ECAST_ROOM_EXIT_CAUSE_LOBBY_TIMEOUT,
         2:ECAST_ROOM_EXIT_CAUSE_JOIN_TIMEOUT,
         3:ECAST_ROOM_EXIT_CAUSE_GAME_TIMEOUT,
         4:ECAST_ROOM_EXIT_CAUSE_DISCONNECT,
         5:ECAST_ROOM_EXIT_CAUSE_BY_REQUEST,
         6:ECAST_ROOM_EXIT_CAUSE_SHUTTING_DOWN
      };
      
      private static const LOCALIZATION_MAP:Object = {
         1:"ROOM_EXIT_CAUSE_LOBBY_TIMEOUT",
         2:"ROOM_EXIT_CAUSE_JOIN_TIMEOUT",
         3:"ROOM_EXIT_CAUSE_GAME_TIMEOUT",
         4:"ROOM_EXIT_CAUSE_DISCONNECT",
         5:"ROOM_EXIT_CAUSE_BY_REQUEST",
         6:"ROOM_EXIT_CAUSE_SHUTTING_DOWN"
      };
      
      private var _cause:int;
      
      private var _message:String;
      
      private var _localizationKey:String;
      
      public function RoomExit(cause:int)
      {
         super();
         this._cause = cause;
         this._message = !!CAUSE_MAP.hasOwnProperty(this._cause) ? CAUSE_MAP[this._cause] : ECAST_ROOM_EXIT_CAUSE_UNKNOWN;
         this._localizationKey = !!LOCALIZATION_MAP.hasOwnProperty(this._cause) ? LOCALIZATION_MAP[this._cause] : "ROOM_DESTROYED";
      }
      
      public function get cause() : int
      {
         return this._cause;
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function get localizationKey() : String
      {
         return this._localizationKey;
      }
      
      public function toString() : String
      {
         return this._message;
      }
   }
}

