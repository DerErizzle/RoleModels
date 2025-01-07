package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AudioMeter extends PausableEventDispatcher
   {
      public static const EVENT_ON_UPDATE:String = "OnUpdate";
      
      private var _name:String;
      
      public var ctorNative:Function;
      
      public var disposeNative:Function;
      
      public function AudioMeter(name:String)
      {
         super();
         this._name = name;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","AudioMeter",this);
            if(this.ctorNative != null)
            {
               this.ctorNative(name);
            }
         }
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function dispose() : void
      {
         this._name = null;
         if(this.disposeNative != null)
         {
            this.disposeNative();
            this.disposeNative = null;
         }
         this.ctorNative = null;
      }
      
      public function get isValid() : Boolean
      {
         return this.ctorNative != null;
      }
      
      public function onUpdate(data:Object) : void
      {
         dispatchEvent(new EventWithData(AudioMeter.EVENT_ON_UPDATE,data));
      }
   }
}

