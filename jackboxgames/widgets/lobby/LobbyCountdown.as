package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class LobbyCountdown
   {
      protected var _mc:MovieClip;
      
      private var _startCanceler:Function;
      
      private var _cancelCanceler:Function;
      
      public function LobbyCountdown(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._startCanceler = Nullable.NULL_FUNCTION;
         this._cancelCanceler = Nullable.NULL_FUNCTION;
      }
      
      protected function _getRootMC() : MovieClip
      {
         return this._mc.roomInfoActions;
      }
      
      protected function _getGameStartBehavior() : String
      {
         return "GameStartAppear";
      }
      
      protected function _getCancelBehavior() : String
      {
         return "GameStartCancel";
      }
      
      public function dispose() : void
      {
         this.reset();
         this._mc = null;
      }
      
      public function reset() : void
      {
         this._startCanceler();
         this._startCanceler = Nullable.NULL_FUNCTION;
         this._cancelCanceler();
         this._cancelCanceler = Nullable.NULL_FUNCTION;
      }
      
      public function start(doneFn:Function) : void
      {
         Assert.assert(Nullable.isNull(this._startCanceler));
         this._cancelCanceler();
         this._cancelCanceler = Nullable.NULL_FUNCTION;
         this._startCanceler = JBGUtil.eventOnce(this._getRootMC(),MovieClipEvent.EVENT_COUNTDOWN_DONE,function():void
         {
            _startCanceler = Nullable.NULL_FUNCTION;
            doneFn();
         });
         JBGUtil.gotoFrame(this._getRootMC(),this._getGameStartBehavior());
      }
      
      public function cancel(doneFn:Function) : void
      {
         Assert.assert(!Nullable.isNull(this._startCanceler));
         this._startCanceler();
         this._startCanceler = Nullable.NULL_FUNCTION;
         this._cancelCanceler = JBGUtil.eventOnce(this._getRootMC(),MovieClipEvent.EVENT_CANCEL_DONE,function(evt:MovieClipEvent):void
         {
            _cancelCanceler = Nullable.NULL_FUNCTION;
            JBGUtil.gotoFrame(_getRootMC(),"Appear");
            doneFn();
         });
         JBGUtil.gotoFrame(this._getRootMC(),this._getCancelBehavior());
      }
   }
}

