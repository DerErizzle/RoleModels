package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.logger.Logger;
   import jackboxgames.utils.ArrayUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AudioSystem extends PausableEventDispatcher
   {
      
      private static var _instance:AudioSystem;
       
      
      private var _banks:Array;
      
      private var _events:Array;
      
      private var _faderGroups:Array;
      
      public function AudioSystem()
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","AudioSystem",this);
         }
         this._banks = [];
         this._events = [];
         this._faderGroups = [];
      }
      
      public static function Initialize() : void
      {
         _instance = new AudioSystem();
      }
      
      public static function get instance() : AudioSystem
      {
         return _instance;
      }
      
      public function dispose() : void
      {
         var b:AudioBank = null;
         var e:AudioEvent = null;
         var f:AudioFaderGroup = null;
         for each(b in this._banks)
         {
            Logger.error("ERROR: Forgot to dispose of AudioBank: " + b.name);
            b.dispose();
         }
         for each(e in this._events)
         {
            Logger.error("ERROR: Forgot to dispose of AudioEvent: " + e.name);
            e.dispose();
         }
         for each(f in this._faderGroups)
         {
            Logger.error("ERROR: Forgot to dispose of AudioFaderGroup: " + f.name);
            f.dispose();
         }
      }
      
      public function createBank(name:String) : AudioBank
      {
         var b:AudioBank = new AudioBank(name);
         this._banks.push(b);
         return b;
      }
      
      public function disposeBank(bank:AudioBank) : void
      {
         ArrayUtil.removeElementFromArray(this._banks,bank);
         bank.dispose();
      }
      
      public function createEventFromName(name:String) : AudioEvent
      {
         var e:AudioEvent = new AudioEvent(name,null);
         this._events.push(e);
         return e;
      }
      
      public function createEventFromPath(dummyEventName:String, path:String) : AudioEvent
      {
         var e:AudioEvent = new AudioEvent(dummyEventName,path);
         this._events.push(e);
         return e;
      }
      
      public function disposeEvent(event:AudioEvent) : void
      {
         ArrayUtil.removeElementFromArray(this._events,event);
         event.dispose();
      }
      
      public function createFaderGroup(name:String) : AudioFaderGroup
      {
         var f:AudioFaderGroup = new AudioFaderGroup(name);
         this._faderGroups.push(f);
         return f;
      }
      
      public function disposeFaderGroup(group:AudioFaderGroup) : void
      {
         ArrayUtil.removeElementFromArray(this._faderGroups,group);
         group.dispose();
      }
   }
}
