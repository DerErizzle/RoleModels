package jackboxgames.logger
{
   import flash.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class Logger extends PausableEventDispatcher
   {
      
      public static var console:DeveloperConsole;
      
      internal static const levels:Array = ["","Debug","Info","Warn","Error"];
      
      private static var _inst:Logger;
      
      private static var MAX_LOG_LENGTH:int = 500;
      
      private static var _log:Vector.<String> = new Vector.<String>();
       
      
      public function Logger()
      {
         super();
      }
      
      public static function isEnabled() : Boolean
      {
         return BuildConfig.instance.configVal("logging");
      }
      
      public static function getFullLog() : String
      {
         var entry:String = null;
         var fullLog:String = "";
         for each(entry in _log)
         {
            fullLog += entry + "\n";
         }
         return fullLog;
      }
      
      public static function error(msg:String, cat:String = "Log") : void
      {
         getInstance().log(4,msg,cat);
      }
      
      public static function warning(msg:String, cat:String = "Log") : void
      {
         getInstance().log(3,msg,cat);
      }
      
      public static function debug(msg:String, cat:String = "Log") : void
      {
         if(EnvUtil.isDebug())
         {
            getInstance().log(1,msg,cat);
         }
      }
      
      public static function info(msg:String, cat:String = "Log") : void
      {
         getInstance().log(2,msg,cat);
      }
      
      public static function getInstance() : Logger
      {
         if(_inst == null)
         {
            _inst = new Logger();
         }
         return _inst;
      }
      
      public static function openConsole() : void
      {
         if(DeveloperConsole.isEnabled())
         {
            if(Boolean(console))
            {
               console.open();
            }
         }
      }
      
      private function log(level:int, msg:String, cat:String) : void
      {
         var msgBody:String = null;
         var logToConsole:Boolean = false;
         if(isEnabled())
         {
            msgBody = Platform.instance.getTimer() + " [" + String(levels[level]).toUpperCase() + "] " + msg;
            TraceUtil.log(msgBody);
            _log.push(msgBody);
            if(_log.length > MAX_LOG_LENGTH)
            {
               _log.shift();
            }
            if(console != null)
            {
               logToConsole = console.isOpen();
               if(EnvUtil.isDebug())
               {
                  logToConsole = true;
               }
               if(logToConsole)
               {
                  console.log(level,msgBody);
               }
            }
            dispatchEvent(new LogEvent(LogEvent.LOG,false,false,level,Platform.instance.getTimer(),cat,msg));
         }
      }
   }
}
