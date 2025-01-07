package jackboxgames.ecast
{
   import com.laiyonghao.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.messages.*;
   import jackboxgames.ecast.messages.room.*;
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class APIClient
   {
      private var _host:String;
      
      private var _scheme:String;
      
      private var _appId:String;
      
      private var _userId:String;
      
      public function APIClient(appId:String, host:String, scheme:String = "http")
      {
         super();
         Assert.assert(host != null,"unable to create ecast APIClient: missing host");
         Assert.assert(appId != null,"unable to create ecast APIClient: missing appId");
         this._appId = appId;
         this._host = host;
         this._scheme = scheme;
         this._userId = new Uuid().toString();
      }
      
      private function _url(rel:String, queryObject:Object = null) : String
      {
         var url:String = this._scheme + "://" + this._host + "/api/v2" + rel;
         if(queryObject != null)
         {
            url += "?" + ObjectUtil.convertToQueryString(queryObject,false);
         }
         return url;
      }
      
      public function createRoom(options:Object) : Promise
      {
         var promise:Promise = null;
         var url:String = this._url("/rooms");
         promise = new Promise();
         options.userId = this._userId;
         options.appId = this._appId;
         options.time = new Date().getTime();
         JBGLoader.instance.postRequest(url,options,RequestLoader.OUTGOING_DATA_FORMAT_JSON,function(result:Object):void
         {
            var respData:Object = null;
            if(Boolean(result.success))
            {
               respData = JSON.deserialize(result.data);
               if(respData == null)
               {
                  promise.reject(new Error("parsing response from post request failed"));
               }
               else if(!respData.ok)
               {
                  promise.reject(new Error("failed to create room" + respData.error));
               }
               else
               {
                  promise.resolve(new CreateRoomReply(respData.body.code,respData.body.token,respData.body.host));
               }
            }
            else
            {
               promise.reject(result.error);
            }
         });
         return promise;
      }
      
      public function getRoom(code:String) : Promise
      {
         var promise:Promise = null;
         var url:String = this._url("/rooms/" + code);
         var v:Object = {"time":new Date().getTime()};
         promise = new Promise();
         JBGLoader.instance.getRequest(url,v,function(result:Object):void
         {
            var respData:Object = null;
            if(Boolean(result.success))
            {
               respData = JSON.deserialize(result.data);
               if(respData == null)
               {
                  promise.reject(new Error("parsing response from get room request failed"));
               }
               else if(!respData.ok)
               {
                  promise.reject(new Error("failed to get room " + code + ": " + respData.error));
               }
               else
               {
                  promise.resolve(new GetRoomReply(respData.body.appId,respData.body.appTag,respData.body.audienceEnabled,respData.body.code,_host,respData.body.passwordRequired,respData.body.twitchLocked));
               }
            }
            else
            {
               promise.reject(result.error);
            }
         });
         return promise;
      }
      
      public function getList(listId:String) : Promise
      {
         var promise:Promise = null;
         var url:String = this._scheme + "://" + this._host + "/storage/list/" + listId;
         var v:Object = {};
         promise = new Promise();
         JBGLoader.instance.getRequest(url,v,function(result:Object):void
         {
            var respData:Object = null;
            if(Boolean(result.success))
            {
               respData = JSON.deserialize(result.data);
               if(respData == null)
               {
                  promise.reject(new Error("parsing response from get list request failed"));
               }
               else if(!respData.success)
               {
                  promise.reject(new Error("failed to get list " + listId + ": " + respData.error));
               }
               else
               {
                  promise.resolve(respData);
               }
            }
            else
            {
               promise.reject(result.error);
            }
         });
         return promise;
      }
      
      public function getContent(contentId:String) : Promise
      {
         var promise:Promise = null;
         var url:String = this._scheme + "://" + this._host + "/storage/content/" + contentId + "?platformId=" + Platform.instance.PlatformIdUpperCase;
         var v:Object = {};
         promise = new Promise();
         JBGLoader.instance.getRequest(url,v,function(result:Object):void
         {
            var respData:Object = null;
            if(Boolean(result.success))
            {
               respData = JSON.deserialize(result.data);
               if(respData == null)
               {
                  promise.reject(new Error("parsing response from get content request failed"));
               }
               else if(!respData.success)
               {
                  promise.reject(new Error("failed to get content " + contentId + ": " + respData.error,respData.error_code));
               }
               else
               {
                  promise.resolve(new UGCContent(respData));
               }
            }
            else
            {
               promise.reject(result.error);
            }
         });
         return promise;
      }
      
      public function sendContent(categoryId:String, metadata:Object, blob:Object) : Promise
      {
         var promise:Promise = null;
         var url:String = this._scheme + "://" + this._host + "/storage/content";
         var v:Object = {
            "appId":this._appId,
            "userId":this._userId,
            "categoryId":categoryId,
            "blob":blob,
            "creator":{
               "platformId":Platform.instance.PlatformIdUpperCase,
               "platformUserId":(Boolean(Platform.instance.user) ? Platform.instance.user.id : null)
            },
            "metadata":metadata
         };
         promise = new Promise();
         JBGLoader.instance.postRequest(url,v,RequestLoader.OUTGOING_DATA_FORMAT_JSON_COMPRESSED,function(result:Object):void
         {
            var respData:Object = null;
            if(Boolean(result.success))
            {
               respData = JSON.deserialize(result.data);
               if(respData == null)
               {
                  promise.reject(new Error("parsing response from send content request failed"));
               }
               else if(!respData.success)
               {
                  promise.reject(respData.error);
               }
               else
               {
                  promise.resolve(new SendContentReply(respData));
               }
            }
            else
            {
               promise.reject(result.error);
            }
         });
         return promise;
      }
   }
}

