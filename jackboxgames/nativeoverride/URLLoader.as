package jackboxgames.nativeoverride
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoaderDataFormat;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class URLLoader extends PausableEventDispatcher
   {
      private var mDataFormat:String;
      
      private var mData:*;
      
      private var mBytesTotal:int;
      
      private var mBytesLoaded:int;
      
      public var loadNative:Function = null;
      
      public var closeNative:Function = null;
      
      public function URLLoader()
      {
         super();
         this.mDataFormat = URLLoaderDataFormat.TEXT;
         this.mData = null;
         this.mBytesTotal = 0;
         this.mBytesLoaded = 0;
         ExternalInterface.call("InitializeNativeOverride","URLLoader",this);
      }
      
      public static function Initialize() : void
      {
      }
      
      public function get data() : *
      {
         return this.mData;
      }
      
      public function set dataFormat(value:String) : void
      {
         this.mDataFormat = value;
      }
      
      public function get dataFormat() : String
      {
         return this.mDataFormat;
      }
      
      public function get bytesTotal() : int
      {
         return this.mBytesTotal;
      }
      
      public function set bytesTotal(value:int) : void
      {
         this.mBytesTotal = value;
      }
      
      public function get bytesLoaded() : int
      {
         return this.mBytesLoaded;
      }
      
      public function set bytesLoaded(value:int) : void
      {
         this.mBytesLoaded = value;
      }
      
      public function load(request:URLRequest) : void
      {
         if(this.loadNative != null)
         {
            this.loadNative(request);
            return;
         }
      }
      
      public function close() : void
      {
         if(this.closeNative != null)
         {
            this.closeNative();
         }
      }
      
      public function onComplete(data:*) : void
      {
         this.mData = data;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function onProgress() : void
      {
         dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
      }
      
      public function onError() : void
      {
         dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
      }
   }
}

