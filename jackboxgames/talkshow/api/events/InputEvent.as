package jackboxgames.talkshow.api.events
{
   import flash.events.Event;
   
   public class InputEvent extends Event
   {
      public static const INPUT:String = "input";
      
      public static const USER_INPUT:String = "userInput";
      
      private var _input:String;
      
      private var _raw:*;
      
      public function InputEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, val:String = null, raw:* = null)
      {
         super(type,bubbles,cancelable);
         this._input = val;
         this._raw = raw;
      }
      
      public function get input() : String
      {
         return this._input;
      }
      
      public function get raw() : *
      {
         return this._raw;
      }
   }
}

