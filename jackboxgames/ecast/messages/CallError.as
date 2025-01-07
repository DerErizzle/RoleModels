package jackboxgames.ecast.messages
{
   public class CallError
   {
      public static const ECAST_ERROR_SERVER_ERROR:String = "EcastServerError";
      
      public static const ECAST_ERROR_CREATE_ROOM_FAILED:String = "EcastCreateRoomFailed";
      
      public static const ECAST_ERROR_DIAL_ROOM_FAILED:String = "EcastDialRoomFailed";
      
      public static const ECAST_ERROR_SERVER_IS_SHUTTING_DOWN:String = "EcastServerIsShuttingDown";
      
      public static const ECAST_ERROR_CLIENT_ERROR:String = "EcastClientError";
      
      public static const ECAST_ERROR_PARSE_ERROR:String = "EcastParseError";
      
      public static const ECAST_ERROR_REQUEST_IS_MISSING_OPCODE:String = "EcastRequestIsMissingOpcode";
      
      public static const ECAST_ERROR_REQUEST_HAS_INVALID_OPCODE:String = "EcastRequestHasInvalidOpcode";
      
      public static const ECAST_ERROR_REQUEST_HAS_INVALID_ARGUMENTS:String = "EcastRequestHasInvalidArguments";
      
      public static const ECAST_ERROR_ENTITY_NOT_FOUND:String = "EcastEntityNotFound";
      
      public static const ECAST_ERROR_ENTITY_ALREADY_EXISTS:String = "EcastEntityAlreadyExists";
      
      public static const ECAST_ERROR_ENTITY_TYPE_ERROR:String = "EcastEntityTypeError";
      
      public static const ECAST_ERROR_NO_SUCH_CLIENT:String = "EcastNoSuchClient";
      
      public static const ECAST_ERROR_ROOM_IS_LOCKED:String = "EcastRoomIsLocked";
      
      public static const ECAST_ERROR_ROOM_IS_FULL:String = "EcastRoomIsFull";
      
      public static const ECAST_ERROR_LICENSE_NOT_FOUND:String = "EcastLicenseNotFound";
      
      public static const ECAST_ERROR_LICENSE_CHECK_FAILED:String = "EcastLicenseCheckFailed";
      
      public static const ECAST_ERROR_ROOM_NOT_FOUND:String = "EcastRoomNotFound";
      
      public static const ECAST_ERROR_INVALID_ROLE:String = "EcastInvalidRole";
      
      public static const ECAST_ERROR_TWITCH_LOGIN_REQUIRED:String = "EcastTwitchLoginRequired";
      
      public static const ECAST_ERROR_INVALID_OPTION:String = "EcastInvalidOption";
      
      public static const ECAST_ERROR_PASSWORD_REQUIRED:String = "EcastPasswordRequired";
      
      public static const ECAST_ERROR_INVALID_PASSWORD:String = "EcastInvalidPassword";
      
      public static const ECAST_ERROR_NAME_REQUIRED:String = "EcastNameRequired";
      
      public static const ECAST_ERROR_FILTER_ERROR:String = "EcastFilterError";
      
      public static const ECAST_ERROR_NO_SUCH_FILTER:String = "EcastNoSuchFilter";
      
      public static const ECAST_ERROR_PERMISSION_DENIED:String = "EcastPermissionDenied";
      
      public static const ECAST_ERROR_RATE_LIMIT_EXCEEDED:String = "EcastRateLimitExceeded";
      
      public static const ECAST_ERROR_UNKNOWN:String = "EcastUnknownError";
      
      private static const ERROR_MAP:Object = {
         1000:ECAST_ERROR_SERVER_ERROR,
         1001:ECAST_ERROR_CREATE_ROOM_FAILED,
         1002:ECAST_ERROR_DIAL_ROOM_FAILED,
         1003:ECAST_ERROR_SERVER_IS_SHUTTING_DOWN,
         2000:ECAST_ERROR_CLIENT_ERROR,
         2001:ECAST_ERROR_PARSE_ERROR,
         2002:ECAST_ERROR_REQUEST_IS_MISSING_OPCODE,
         2003:ECAST_ERROR_REQUEST_HAS_INVALID_OPCODE,
         2004:ECAST_ERROR_REQUEST_HAS_INVALID_ARGUMENTS,
         2005:ECAST_ERROR_ENTITY_NOT_FOUND,
         2006:ECAST_ERROR_ENTITY_ALREADY_EXISTS,
         2007:ECAST_ERROR_ENTITY_TYPE_ERROR,
         2008:ECAST_ERROR_NO_SUCH_CLIENT,
         2009:ECAST_ERROR_ROOM_IS_LOCKED,
         2010:ECAST_ERROR_ROOM_IS_FULL,
         2011:ECAST_ERROR_LICENSE_NOT_FOUND,
         2012:ECAST_ERROR_LICENSE_CHECK_FAILED,
         2013:ECAST_ERROR_ROOM_NOT_FOUND,
         2014:ECAST_ERROR_INVALID_ROLE,
         2015:ECAST_ERROR_TWITCH_LOGIN_REQUIRED,
         2016:ECAST_ERROR_INVALID_OPTION,
         2017:ECAST_ERROR_PASSWORD_REQUIRED,
         2018:ECAST_ERROR_INVALID_PASSWORD,
         2019:ECAST_ERROR_NAME_REQUIRED,
         2021:ECAST_ERROR_FILTER_ERROR,
         2022:ECAST_ERROR_NO_SUCH_FILTER,
         2023:ECAST_ERROR_PERMISSION_DENIED,
         2420:ECAST_ERROR_RATE_LIMIT_EXCEEDED
      };
      
      private var _message:String;
      
      private var _code:int;
      
      private var _error:String;
      
      public function CallError(message:String, code:int)
      {
         super();
         this._message = message;
         this._code = code;
         this._error = !!ERROR_MAP.hasOwnProperty(this._code) ? ERROR_MAP[code] : ECAST_ERROR_UNKNOWN;
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function get code() : int
      {
         return this._code;
      }
      
      public function get error() : String
      {
         return this._error;
      }
   }
}

