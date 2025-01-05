package jackboxgames.nativeoverride
{
   import flash.external.ExternalInterface;
   import jackboxgames.engine.IPreparable;
   import jackboxgames.utils.EnvUtil;
   
   public class Save implements IPreparable
   {
      
      public static var GamePrefix:String = "";
      
      private static var _instance:Save;
       
      
      private var _prepareCallback:Function;
      
      public var prepareNative:Function = null;
      
      public var saveObjectNative:Function = null;
      
      public var loadObjectNative:Function = null;
      
      public var deleteObjectNative:Function = null;
      
      public var saveSecureStringNative:Function = null;
      
      public var loadSecureStringNative:Function = null;
      
      public var deleteSecureStringNative:Function = null;
      
      public function Save()
      {
         super();
         if(!EnvUtil.isAIR())
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("InitializeNativeOverride","Save",this);
            }
         }
      }
      
      public static function Initialize() : void
      {
      }
      
      public static function get instance() : Save
      {
         if(!_instance)
         {
            _instance = new Save();
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
      
      public function saveObject(key:String, obj:*) : void
      {
         if(this.saveObjectNative != null)
         {
            this.saveObjectNative(GamePrefix + key,obj);
         }
      }
      
      public function loadObject(key:String) : *
      {
         if(this.loadObjectNative != null)
         {
            return this.loadObjectNative(GamePrefix + key);
         }
         return null;
      }
      
      public function deleteObject(key:String) : void
      {
         if(this.deleteObjectNative != null)
         {
            this.deleteObjectNative(GamePrefix + key);
         }
      }
      
      public function saveGlobalObject(key:String, obj:*) : void
      {
         if(this.saveObjectNative != null)
         {
            this.saveObjectNative(key,obj);
         }
      }
      
      public function loadGlobalObject(key:String) : *
      {
         if(this.loadObjectNative != null)
         {
            return this.loadObjectNative(key);
         }
         return null;
      }
      
      public function deleteGlobalObject(key:String) : void
      {
         if(this.deleteObjectNative != null)
         {
            this.deleteObjectNative(key);
         }
      }
      
      public function saveSecureString(key:String, s:String) : void
      {
         if(this.saveSecureStringNative != null)
         {
            this.saveSecureStringNative(GamePrefix + key,s);
         }
      }
      
      public function loadSecureString(key:String) : String
      {
         if(this.loadSecureStringNative != null)
         {
            return this.loadSecureStringNative(GamePrefix + key);
         }
         return null;
      }
      
      public function deleteSecureString(key:String) : void
      {
         if(this.deleteSecureStringNative != null)
         {
            this.deleteSecureStringNative(GamePrefix + key);
         }
      }
   }
}
