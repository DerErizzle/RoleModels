package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.audio.*;
   import jackboxgames.events.*;
   import jackboxgames.localizy.*;
   import jackboxgames.logger.*;
   import jackboxgames.utils.*;
   
   public class AudioSystem extends PausableEventDispatcher
   {
      private static var _instance:AudioSystem;
      
      private var _banks:Array;
      
      private var _events:Array;
      
      private var _faderGroups:Array;
      
      public var setGlobalParameterValueNative:Function = null;
      
      public var getGlobalParameterValueNative:Function = null;
      
      private var _lastAudioNotifierEvent:AudioEvent;
      
      private var _lastAudioNotifierId:String;
      
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
            this._shutdownEventForAudioNotifier(e);
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
         this._setupEventForAudioNotifier(e);
         this._events.push(e);
         return e;
      }
      
      public function createEventFromPath(dummyEventName:String, path:String) : AudioEvent
      {
         var e:AudioEvent = new AudioEvent(dummyEventName,path);
         this._setupEventForAudioNotifier(e);
         this._events.push(e);
         return e;
      }
      
      public function disposeEvent(event:AudioEvent) : void
      {
         this._shutdownEventForAudioNotifier(event);
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
      
      public function setGlobalParameterValue(name:String, val:Number) : void
      {
         if(this.setGlobalParameterValueNative != null)
         {
            this.setGlobalParameterValueNative(name,val);
         }
      }
      
      public function getGlobalParameterValue(name:String) : Number
      {
         return this.getGlobalParameterValueNative != null ? this.getGlobalParameterValueNative(name) : 0;
      }
      
      private function _setupEventForAudioNotifier(e:AudioEvent) : void
      {
         e.addEventListener(AudioEvent.EVENT_TIMELINE_MARKER,this._onTimelineMarker);
      }
      
      private function _shutdownEventForAudioNotifier(e:AudioEvent) : void
      {
         e.removeEventListener(AudioEvent.EVENT_TIMELINE_MARKER,this._onTimelineMarker);
         if(e == this._lastAudioNotifierEvent)
         {
            AudioNotifier.instance.notifyEndAudio(this._lastAudioNotifierId);
            this._lastAudioNotifierEvent = null;
            this._lastAudioNotifierId = null;
         }
      }
      
      private function _onTimelineMarker(evt:EventWithData) : void
      {
         var e:AudioEvent = AudioEvent(evt.target);
         var localizationKey:String = evt.data.name;
         var isStart:Boolean = true;
         if(localizationKey.indexOf("/") == 0)
         {
            isStart = false;
            localizationKey = localizationKey.substr(1);
         }
         if(!LocalizationManager.instance.hasValueForKey(localizationKey))
         {
            return;
         }
         var id:String = localizationKey;
         var category:String = "lyric";
         var text:String = LocalizationManager.instance.getValueForKey(localizationKey);
         var metadata:Object = {};
         if(isStart)
         {
            this._lastAudioNotifierEvent = e;
            this._lastAudioNotifierId = id;
            AudioNotifier.instance.notifyStartAudio(id,category,text,metadata);
         }
         else
         {
            this._lastAudioNotifierEvent = null;
            this._lastAudioNotifierId = null;
            AudioNotifier.instance.notifyEndAudio(id);
         }
      }
   }
}

