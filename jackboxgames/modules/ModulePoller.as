package jackboxgames.modules
{
   import flash.events.TimerEvent;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.PausableTimer;
   
   public class ModulePoller
   {
      private var _pollTimer:PausableTimer;
      
      private var _module:ISessionModule;
      
      private var _pollFn:Function;
      
      private var _options:Object;
      
      public function ModulePoller(module:ISessionModule)
      {
         super();
         this._module = module;
         this._pollTimer = new PausableTimer(1000,0);
      }
      
      public function get module() : ISessionModule
      {
         return this._module;
      }
      
      public function get isPolling() : Boolean
      {
         return this._pollTimer.running;
      }
      
      public function reset() : void
      {
         this._pollTimer.removeEventListener(TimerEvent.TIMER,this._doPoll);
         this._pollTimer.reset();
      }
      
      public function start(options:Object, pollFn:Function, rate:int = 2000) : void
      {
         this.reset();
         this._pollFn = pollFn;
         this._options = options;
         this._pollTimer = new PausableTimer(rate,0);
         this._pollTimer.start();
         this._pollTimer.addEventListener(TimerEvent.TIMER,this._doPoll);
      }
      
      private function _doPoll(evt:TimerEvent) : void
      {
         this._module.getStatus(this._options,function(data:*):void
         {
            if(isPolling)
            {
               _pollFn(data);
               _module.dispatchEvent(new EventWithData(SessionManager.EVENT_GET_STATUS,data));
            }
         });
      }
      
      public function stop() : void
      {
         this.reset();
      }
   }
}

