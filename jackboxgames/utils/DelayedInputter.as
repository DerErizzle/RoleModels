package jackboxgames.utils
{
   import jackboxgames.talkshow.input.TSInputHandler;
   
   public class DelayedInputter
   {
      private var _input:String;
      
      private var _waitTime:Duration;
      
      private var _isActive:Boolean;
      
      private var _canceler:Function;
      
      public function DelayedInputter(input:String, waitTime:Duration)
      {
         super();
         this._input = input;
         this._waitTime = waitTime;
         this._isActive = false;
         this._canceler = Nullable.NULL_FUNCTION;
      }
      
      public function reset() : void
      {
         this.isActive = false;
      }
      
      public function get isActive() : Boolean
      {
         return this._isActive;
      }
      
      public function set isActive(val:Boolean) : void
      {
         if(this._isActive == val)
         {
            return;
         }
         this._isActive = val;
         if(this._isActive)
         {
            this._rescheduleTimer();
         }
         else
         {
            this._canceler();
            this._canceler = Nullable.NULL_FUNCTION;
         }
      }
      
      public function poke() : void
      {
         if(!this._isActive)
         {
            return;
         }
         this._rescheduleTimer();
      }
      
      private function _rescheduleTimer() : void
      {
         this._canceler();
         this._canceler = JBGUtil.runFunctionAfter(function():void
         {
            reset();
            _doInput();
         },this._waitTime);
      }
      
      private function _doInput() : void
      {
         TSInputHandler.instance.input(this._input);
      }
   }
}

