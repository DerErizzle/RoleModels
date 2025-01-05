package jackboxgames.blobcast.services
{
   import jackboxgames.utils.*;
   
   public class BlobArtifact
   {
      
      private static var _instance:BlobArtifact;
       
      
      public function BlobArtifact()
      {
         super();
      }
      
      public static function get instance() : BlobArtifact
      {
         return _instance;
      }
      
      public static function initialize() : void
      {
         _instance = new BlobArtifact();
      }
      
      public function artifact(categoryId:String, blob:Object, cb:Function) : void
      {
         var copy:Object = SimpleObjectUtil.deepCopyWithSimpleObjectReplacement(blob);
         BlobCastWebAPI.instance.artifactBlob(categoryId,copy,function(result:Object):void
         {
            if(Boolean(result.success))
            {
               cb(result);
            }
            else
            {
               cb({"success":false});
            }
         });
      }
   }
}
