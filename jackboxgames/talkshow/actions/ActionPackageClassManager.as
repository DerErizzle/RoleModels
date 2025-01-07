package jackboxgames.talkshow.actions
{
   import flash.utils.Dictionary;
   
   public class ActionPackageClassManager
   {
      public static var _instance:ActionPackageClassManager;
      
      private var _classMetadata:Dictionary;
      
      public function ActionPackageClassManager()
      {
         super();
         this._classMetadata = new Dictionary();
      }
      
      public static function get instance() : ActionPackageClassManager
      {
         if(!_instance)
         {
            _instance = new ActionPackageClassManager();
         }
         return _instance;
      }
      
      public function registerClass(name:String, c:Class, resetData:Object) : void
      {
         this._classMetadata[name] = {
            "name":name,
            "c":c,
            "resetData":resetData
         };
      }
      
      public function getClass(name:String) : Class
      {
         return this._classMetadata[name].c;
      }
      
      public function getResetData(name:String) : Object
      {
         return this._classMetadata[name].resetData;
      }
   }
}

