package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.engine.IPreparable;
   
   public class Trophy implements IPreparable
   {
      private static var _instance:Trophy;
      
      private var _prepareCallback:Function;
      
      public var prepareNative:Function = null;
      
      public var unlockNative:Function = null;
      
      public function Trophy()
      {
         super();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("InitializeNativeOverride","Trophy",this);
         }
      }
      
      public static function Initialize() : void
      {
      }
      
      public static function get instance() : Trophy
      {
         if(!_instance)
         {
            _instance = new Trophy();
         }
         return _instance;
      }
      
      public function get prepareFailError() : String
      {
         return "";
      }
      
      public function get needsPrepare() : Boolean
      {
         return this.prepareNative != null;
      }
      
      public function prepare(id:String, doneFn:Function) : void
      {
         if(this.prepareNative != null)
         {
            this._prepareCallback = doneFn;
            this.prepareNative();
         }
         else if(doneFn != null)
         {
            doneFn(true);
         }
      }
      
      public function prepareDone(success:Boolean) : void
      {
         if(this._prepareCallback != null)
         {
            this._prepareCallback(success);
            this._prepareCallback = null;
         }
      }
      
      public function unlock(trophyName:String) : void
      {
         if(License.instance.isDemo)
         {
            return;
         }
         if(this.unlockNative != null)
         {
            this.unlockNative(trophyName);
         }
      }
   }
}

