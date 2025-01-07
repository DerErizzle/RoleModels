package jackboxgames.talkshow.core
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.api.events.InputEvent;
   import jackboxgames.talkshow.cells.ActionCell;
   import jackboxgames.talkshow.cells.InputCell;
   import jackboxgames.talkshow.utils.ConfigInfo;
   
   public class InputManager
   {
      private var _engine:PlaybackEngine;
      
      private var _input:String;
      
      private var _raw:*;
      
      private var _inInputMode:Boolean;
      
      private var _currentCell:ICell;
      
      private var _lastInputCell:ICell;
      
      private var _lastActionCell:ICell;
      
      private var _inTimeoutMode:Boolean;
      
      private var _timer:Timer;
      
      private var _inputDelay:Number;
      
      public function InputManager(engine:PlaybackEngine)
      {
         super();
         this._engine = engine;
         this._input = null;
         this._raw = null;
         this._inInputMode = false;
         this._lastInputCell = null;
         this._lastActionCell = null;
         this._inTimeoutMode = false;
         this._inputDelay = Number(engine.getConfigInfo().getValue(ConfigInfo.INPUT_DELAY));
         engine.addEventListener(CellEvent.CELL_STARTED,this.setCurrentCell);
         engine.addEventListener(CellEvent.CELL_JUMP,this.handleJump);
      }
      
      public function handleInput(val:String, raw:* = null) : void
      {
         Logger.debug("Got input : " + val);
         this._input = val;
         this._raw = raw;
         this._inInputMode = true;
         this._engine.timingManager.clear();
         this._engine.dispatchEvent(new InputEvent(InputEvent.INPUT,false,false,val,raw));
         this._timer = new Timer(this._inputDelay,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.startNextCell);
         this._timer.start();
      }
      
      public function cleanup() : void
      {
         this.resetInput();
         if(Boolean(this._timer))
         {
            this._timer.stop();
            this._timer = null;
         }
      }
      
      private function handleJump(evt:CellEvent) : void
      {
         if(this._timer != null)
         {
            this._timer.reset();
         }
         this.resetInput();
      }
      
      private function startNextCell(evt:TimerEvent) : void
      {
         var child:ICell = null;
         (evt.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE,this.startNextCell);
         if(this._inTimeoutMode)
         {
            (this._lastInputCell as InputCell).startBranch(this._input,this._raw);
            this._inTimeoutMode = false;
            return;
         }
         if(this._currentCell is InputCell)
         {
            (this._currentCell as InputCell).startBranch(this._input,this._raw);
         }
         else if(this._currentCell is ActionCell)
         {
            child = (this._currentCell as ActionCell).child;
            if(child != null)
            {
               child.start();
            }
         }
      }
      
      public function resetInput() : void
      {
         this._inInputMode = false;
         this._input = null;
         this._raw = null;
      }
      
      private function setCurrentCell(evt:CellEvent) : void
      {
         this._currentCell = evt.cell;
         if(this._currentCell is InputCell)
         {
            this._inTimeoutMode = false;
            this._lastInputCell = this._currentCell;
         }
         else if(this._currentCell is ActionCell)
         {
            this._lastActionCell = this._currentCell;
         }
      }
      
      public function enterTimeoutMode() : void
      {
         this._inTimeoutMode = true;
      }
      
      public function get input() : String
      {
         return this._input;
      }
      
      public function get raw() : String
      {
         return this._raw;
      }
      
      public function get isInInputMode() : Boolean
      {
         return this._inInputMode;
      }
      
      public function get lastActionCell() : ActionCell
      {
         return this._lastActionCell as ActionCell;
      }
      
      public function stopListening() : void
      {
         this._inTimeoutMode = false;
         if(this._lastInputCell != null)
         {
            this._engine.timingManager.clear();
            this._engine.dispatchEvent(new InputEvent(InputEvent.INPUT,false,false,null,null));
         }
      }
   }
}

