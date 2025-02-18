package jackboxgames.modules
{
   import jackboxgames.utils.*;
   
   public class SessionManager extends PausableEventDispatcher
   {
      public static const EVENT_GET_STATUS:String = "SessionManager.GetStatus";
      
      private var _modules:Object;
      
      private var _pollingList:Object;
      
      public function SessionManager()
      {
         super();
         this._modules = {};
         this._pollingList = {};
      }
      
      private function _getModuleId(module:String, name:String) : String
      {
         return module + "_" + name;
      }
      
      public function reset() : void
      {
         var module:ISessionModule = null;
         for each(module in this._modules)
         {
            module.reset();
         }
         this.stopAllPolling();
      }
      
      public function registerModule(module:ISessionModule) : ISessionModule
      {
         this._modules[module.moduleId] = module;
         return module;
      }
      
      public function unregisterModule(module:ISessionModule) : void
      {
         delete this._modules[module.moduleId];
      }
      
      public function getModule(moduleId:String, name:String) : ISessionModule
      {
         return this._modules[this._getModuleId(moduleId,name)];
      }
      
      public function startPolling(module:ISessionModule, options:Object, pollFn:Function, rate:int = 2000) : void
      {
         var poller:ModulePoller = null;
         if(Boolean(this._pollingList[module.moduleId]))
         {
            poller = this._pollingList[module.moduleId];
         }
         else
         {
            poller = new ModulePoller(module);
            this._pollingList[module.moduleId] = poller;
         }
         if(!poller.isPolling)
         {
            poller.start(options,pollFn,rate);
         }
      }
      
      public function stopPolling(module:ISessionModule) : void
      {
         var poller:ModulePoller = this._pollingList[module.moduleId];
         if(Boolean(poller) && poller.isPolling)
         {
            poller.stop();
         }
      }
      
      public function isPolling(module:ISessionModule) : Boolean
      {
         var poller:ModulePoller = this._pollingList[module.moduleId];
         return Boolean(poller) && poller.isPolling;
      }
      
      public function stopAllPolling() : void
      {
         var poller:ModulePoller = null;
         for each(poller in this._pollingList)
         {
            poller.stop();
         }
      }
   }
}

