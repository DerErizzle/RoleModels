package jackboxgames.talkshow.core
{
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.IPausable;
   import jackboxgames.talkshow.api.IPauseManager;
   import jackboxgames.talkshow.api.PauseType;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.api.events.PauseEvent;
   import jackboxgames.utils.PausableEventDispatcher;
   
   internal final class PauseManager extends PausableEventDispatcher implements IPauseManager
   {
      
      public static const PLAY:String = "play";
      
      public static const STOP:String = "stop";
      
      public static const BUFFER_DELAY:Number = 1000;
       
      
      private var _engine:PlaybackEngine;
      
      private var _playing:Dictionary;
      
      private var _pauseType:int;
      
      private var _paused:Boolean;
      
      private var _allowUserPause:Boolean;
      
      private var _bufferDelay:Timer;
      
      public function PauseManager(engine:PlaybackEngine)
      {
         super();
         this._playing = new Dictionary();
         this._paused = false;
         this._allowUserPause = true;
         this._engine = engine;
         this._bufferDelay = new Timer(BUFFER_DELAY);
         engine.container.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKey,false,1000);
         engine.container.addEventListener(PLAY,this.clipPlayed,true,0,true);
         engine.container.addEventListener(STOP,this.clipStopped,true,0,true);
         engine.addEventListener(CellEvent.CELL_JUMP,this.handleJump);
         this._bufferDelay.addEventListener(TimerEvent.TIMER,this.loadBufferOn);
         this.resetBuiltInPausableItems();
      }
      
      private function resetBuiltInPausableItems() : void
      {
      }
      
      private function handleJump(evt:CellEvent) : void
      {
         this.clear();
      }
      
      private function handleKey(evt:KeyboardEvent) : void
      {
         if(this._paused)
         {
            evt.stopImmediatePropagation();
         }
      }
      
      private function clipPlayed(evt:Event) : void
      {
         if(evt.target is IPausable)
         {
            delete this._playing[evt.target];
            this._playing[evt.target] = true;
         }
         evt.stopPropagation();
      }
      
      private function clipStopped(evt:Event) : void
      {
         if(evt.target is IPausable)
         {
            delete this._playing[evt.target];
         }
         evt.stopPropagation();
      }
      
      private function pause(type:int) : void
      {
         var key:Object = null;
         this._paused = true;
         this._pauseType = type;
         for(key in this._playing)
         {
            (key as IPausable).pause(type);
         }
         dispatchEvent(new PauseEvent(PauseEvent.PAUSE,type));
      }
      
      private function resume() : void
      {
         var key:Object = null;
         this._paused = false;
         for(key in this._playing)
         {
            (key as IPausable).resume();
         }
         dispatchEvent(new PauseEvent(PauseEvent.RESUME,this._pauseType));
         this._pauseType = -1;
      }
      
      private function clear() : void
      {
         this._playing = new Dictionary();
         this.resetBuiltInPausableItems();
      }
      
      public function addItem(obj:IPausable) : void
      {
         this._playing[obj] = true;
      }
      
      public function removeItem(obj:IPausable) : void
      {
         if(Boolean(this._playing[obj]))
         {
            delete this._playing[obj];
         }
      }
      
      public function userPause() : void
      {
         if(this._allowUserPause && !this._paused)
         {
            Logger.info("User Pause","pause");
            this.pause(PauseType.TYPE_USER);
         }
      }
      
      public function userResume() : void
      {
         if(this._allowUserPause && this._paused)
         {
            Logger.info("User Resume","pause");
            this.resume();
         }
      }
      
      public function loadPause() : void
      {
         if(!this._paused)
         {
            this.pause(PauseType.TYPE_LOAD);
         }
         this._bufferDelay.start();
      }
      
      private function loadBufferOn(e:TimerEvent) : void
      {
         this._engine.preloadManager.preloadUi.bufferOn();
         this._engine.loadMonitor.addEventListener(ProgressEvent.PROGRESS,this.loadBuffer);
         this._engine.dispatchEvent(new PauseEvent(PauseEvent.PAUSE,PauseType.TYPE_LOAD));
         this._bufferDelay.stop();
      }
      
      private function loadBuffer(e:ProgressEvent) : void
      {
         var pct:Number = e.bytesLoaded / e.bytesTotal;
         this._engine.preloadManager.preloadUi.bufferPercent(pct);
      }
      
      public function loadResume() : void
      {
         if(this._paused)
         {
            this.resume();
         }
         this._engine.loadMonitor.removeEventListener(ProgressEvent.PROGRESS,this.loadBuffer);
         this._engine.preloadManager.preloadUi.bufferDone();
         if(this._bufferDelay.running)
         {
            this._bufferDelay.stop();
         }
      }
      
      public function disableUserPause() : void
      {
         this._allowUserPause = false;
      }
      
      public function enableUserPause() : void
      {
         this._allowUserPause = true;
      }
      
      public function get isPaused() : Boolean
      {
         return this._paused;
      }
   }
}
