package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.utils.Nullable;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class AudioFaderGroup extends PausableEventDispatcher
   {
      private var _name:String;
      
      private var _onLoadCompleteCallback:Function;
      
      private var _onUnloadCompleteCallback:Function;
      
      public var ctorNative:Function;
      
      public var disposeNative:Function;
      
      public var loadNative:Function;
      
      public var unloadNative:Function;
      
      public var setVolumeNative:Function = null;
      
      public var getVolumeNative:Function = null;
      
      public function AudioFaderGroup(name:String)
      {
         super();
         this._name = name;
         this._onLoadCompleteCallback = Nullable.NULL_FUNCTION;
         this._onUnloadCompleteCallback = Nullable.NULL_FUNCTION;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","AudioFaderGroup",this);
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
         this._onLoadCompleteCallback = Nullable.NULL_FUNCTION;
         this._onUnloadCompleteCallback = Nullable.NULL_FUNCTION;
         if(this.disposeNative != null)
         {
            this.disposeNative();
            this.disposeNative = null;
         }
         this.ctorNative = null;
         this.loadNative = null;
         this.unloadNative = null;
         this.setVolumeNative = null;
         this.getVolumeNative = null;
      }
      
      public function get isValid() : Boolean
      {
         return this.ctorNative != null;
      }
      
      public function load(loadComplete:Function) : void
      {
         if(this.loadNative == null)
         {
            loadComplete(false);
            return;
         }
         this._onLoadCompleteCallback = loadComplete;
         this.loadNative();
      }
      
      public function onLoadComplete(success:Boolean) : void
      {
         var callMe:Function = this._onLoadCompleteCallback;
         this._onLoadCompleteCallback = Nullable.NULL_FUNCTION;
         callMe(success);
      }
      
      public function unload(unloadComplete:Function) : void
      {
         if(this.unloadNative == null)
         {
            unloadComplete(false);
            return;
         }
         this._onUnloadCompleteCallback = unloadComplete;
         this.unloadNative();
      }
      
      public function onUnloadComplete(success:Boolean) : void
      {
         var callMe:Function = this._onUnloadCompleteCallback;
         this._onUnloadCompleteCallback = Nullable.NULL_FUNCTION;
         callMe(success);
      }
      
      public function set volume(val:Number) : void
      {
         if(this.setVolumeNative != null)
         {
            this.setVolumeNative(val);
         }
      }
      
      public function get volume() : Number
      {
         return this.getVolumeNative != null ? this.getVolumeNative() : 0;
      }
   }
}

