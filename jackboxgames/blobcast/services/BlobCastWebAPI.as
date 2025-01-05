package jackboxgames.blobcast.services
{
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.services.RestAPI;
   
   public class BlobCastWebAPI
   {
      
      private static var _instance:BlobCastWebAPI;
       
      
      private var _restAPI:RestAPI;
      
      private var _appId:String;
      
      private var _userId:String;
      
      private var _accessToken:String;
      
      public function BlobCastWebAPI(appId:String, userId:String, domain:String, protocol:String)
      {
         super();
         this._restAPI = new RestAPI(domain,protocol);
         this._appId = appId;
         this._userId = userId;
      }
      
      public static function get instance() : BlobCastWebAPI
      {
         return _instance;
      }
      
      public static function initialize(appId:String, userId:String, domain:String, protocol:String = "https://") : void
      {
         _instance = new BlobCastWebAPI(appId,userId,domain,protocol);
      }
      
      public function getRoom(onResult:Function) : void
      {
         this._restAPI.GET("/room",null,onResult);
      }
      
      public function getRoomById(roomId:String, onResult:Function) : void
      {
         this._restAPI.GET("/room/" + roomId,null,onResult);
      }
      
      public function getMe(onResult:Function) : void
      {
         this._restAPI.GET("/me",null,onResult);
      }
      
      public function updateAccessToken(roomId:String, onResult:Function) : void
      {
         var v:Object = {
            "appId":this._appId,
            "roomId":roomId,
            "userId":this._userId
         };
         this._restAPI.POST("/accessToken",v,RequestLoader.OUTGOING_DATA_FORMAT_DEFAULT,function(result:Object):void
         {
            if(Boolean(result.success))
            {
               _accessToken = result.accessToken;
               onResult(result);
            }
            else
            {
               onResult({"success":false});
            }
         });
      }
      
      public function postContent(categoryId:String, metadata:Object, blob:Object, creator:Object, onResult:Function) : void
      {
         var v:Object = {
            "appId":this._appId,
            "categoryId":categoryId,
            "userId":this._userId,
            "metadata":metadata,
            "blob":blob,
            "creator":creator,
            "accessToken":this._accessToken
         };
         this._restAPI.POST("/storage/content",v,RequestLoader.OUTGOING_DATA_FORMAT_JSON_COMPRESSED,onResult);
      }
      
      public function getContent(id:String, platformId:String, onResult:Function) : void
      {
         var v:Object = {
            "accessToken":this._accessToken,
            "platformId":platformId
         };
         this._restAPI.GET("/storage/content/" + id,v,onResult);
      }
      
      public function getList(id:String, onResult:Function) : void
      {
         var v:Object = {"accessToken":this._accessToken};
         this._restAPI.GET("/storage/list/" + id,v,onResult);
      }
      
      public function artifactBlob(categoryId:String, blob:Object, onResult:Function) : void
      {
         var v:Object = {
            "appId":this._appId,
            "categoryId":categoryId,
            "userId":this._userId,
            "blob":blob,
            "accessToken":this._accessToken
         };
         this._restAPI.POST("/artifact",v,RequestLoader.OUTGOING_DATA_FORMAT_JSON_COMPRESSED,onResult);
      }
   }
}
