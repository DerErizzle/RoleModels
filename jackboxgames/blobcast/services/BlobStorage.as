package jackboxgames.blobcast.services
{
   import jackboxgames.nativeoverride.Platform;
   
   public class BlobStorage
   {
      
      private static var _instance:BlobStorage;
       
      
      public function BlobStorage()
      {
         super();
      }
      
      public static function get instance() : BlobStorage
      {
         return _instance;
      }
      
      public static function initialize() : void
      {
         _instance = new BlobStorage();
      }
      
      private function _getPlatformInfo() : Object
      {
         return {
            "platformId":Platform.instance.PlatformIdUpperCase,
            "platformUserId":(Boolean(Platform.instance.user) ? Platform.instance.user.id : null)
         };
      }
      
      public function postContent(categoryId:String, metadata:Object, blob:Object, cb:Function) : void
      {
         BlobCastWebAPI.instance.postContent(categoryId,metadata,blob,this._getPlatformInfo(),function(result:Object):void
         {
            cb(result);
         });
      }
      
      public function getContent(id:String, cb:Function) : void
      {
         BlobCastWebAPI.instance.getContent(id,this._getPlatformInfo().platformId,function(result:Object):void
         {
            cb(result);
         });
      }
      
      public function getList(id:String, cb:Function) : void
      {
         BlobCastWebAPI.instance.getList(id,function(result:Object):void
         {
            cb(result);
         });
      }
   }
}
