package jackboxgames.logger
{
   import flash.events.Event;
   
   public class LogEvent extends Event
   {
      public static const LOG:String = "log";
      
      private var _level:int;
      
      private var _time:Number;
      
      private var _msg:String;
      
      private var _cat:String;
      
      public function LogEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, level:int = 3, time:Number = 0, cat:String = "", msg:String = "")
      {
         super(type,bubbles,cancelable);
         this._level = level;
         this._time = time;
         this._msg = msg;
         this._cat = cat;
      }
      
      override public function toString() : String
      {
         return "[" + this._time + " " + Logger.levels[this._level] + "] (" + this._cat + ") " + this._msg;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function get message() : String
      {
         return this._msg;
      }
      
      public function get category() : String
      {
         return this._cat;
      }
   }
}

