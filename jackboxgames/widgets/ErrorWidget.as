package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import jackboxgames.localizy.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class ErrorWidget extends JBGMovieClip
   {
      private static var _timer:PausableTimer;
      
      private static var _message:String;
      
      private var _widget:MovieClipShower;
      
      private var _widgetTf:ExtendableTextField;
      
      public function ErrorWidget()
      {
         super();
      }
      
      public function set widget(val:MovieClip) : void
      {
         this._widget = new MovieClipShower(val);
         this._widgetTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(val.tf);
         this._widgetTf.text = "";
      }
      
      public function handleError(s:String = "", timeout:int = 6000) : void
      {
         if(!s)
         {
            return;
         }
         if(s == "")
         {
            return;
         }
         if(!this._widget)
         {
            return;
         }
         var errorMessage:String = LocalizationManager.instance.getText(s);
         if(!errorMessage)
         {
            errorMessage = s;
         }
         if(_message != errorMessage)
         {
            this.reset();
            _message = errorMessage;
         }
         this._widgetTf.text = errorMessage;
         this._widget.setShown(true,Nullable.NULL_FUNCTION);
         this._startTimer(timeout);
      }
      
      private function _timerComplete(evt:Event) : void
      {
         this._widget.setShown(false,Nullable.NULL_FUNCTION);
      }
      
      private function _startTimer(timeout:int) : void
      {
         this._resetTimer();
         _timer = new PausableTimer(timeout,1);
         _timer.start();
         _timer.addEventListener(TimerEvent.TIMER_COMPLETE,this._timerComplete);
      }
      
      private function _resetTimer() : void
      {
         if(Boolean(_timer))
         {
            _timer.reset();
            _timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this._timerComplete);
            _timer = null;
         }
      }
      
      public function reset() : void
      {
         this._resetTimer();
         this._widget.reset();
      }
   }
}

