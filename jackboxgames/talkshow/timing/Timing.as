package jackboxgames.talkshow.timing
{
   public class Timing
   {
      protected var _start:Boolean;
      
      protected var _time:Number;
      
      public function Timing(start:Boolean, time:Number)
      {
         super();
         this._start = start;
         this._time = time;
      }
      
      public function toString() : String
      {
         return (this._start ? "S" : "E") + (this._time >= 0 ? "+" : "") + this._time;
      }
      
      public function get fromStart() : Boolean
      {
         return this._start;
      }
      
      public function get seconds() : Number
      {
         return this._time;
      }
      
      public function get never() : Boolean
      {
         return false;
      }
   }
}

