package jackboxgames.ugc
{
   import com.laiyonghao.Uuid;
   import jackboxgames.blobcast.services.BlobStorage;
   import jackboxgames.nativeoverride.Save;
   import jackboxgames.utils.*;
   
   public class UGCContentProvider
   {
      
      public static const MAX_REMOTE_CONTENT_TO_REMEMBER:int = 100;
      
      private static var _instance:UGCContentProvider;
      
      private static const SAVE_KEY:String = "UGCContentProvider";
       
      
      private var _list:Array;
      
      public function UGCContentProvider()
      {
         super();
         this._list = [];
      }
      
      public static function get instance() : UGCContentProvider
      {
         if(!_instance)
         {
            _instance = new UGCContentProvider();
         }
         return _instance;
      }
      
      public static function FORMAT_CONTENT_ID(s:String) : String
      {
         if(!s)
         {
            return null;
         }
         var upper:String = s.toUpperCase();
         if(upper.length < 7)
         {
            return upper;
         }
         return upper.substr(0,3) + "-" + upper.substr(3);
      }
      
      public function reloadFromSave() : void
      {
         var data:Object = Save.instance.loadObject(SAVE_KEY);
         if(Boolean(data))
         {
            this._list = data.list;
            if(this._list == null)
            {
               this._list = [];
            }
         }
         else
         {
            this._list = [];
         }
      }
      
      private function _getData(id:String) : Object
      {
         var o:* = undefined;
         for each(o in this._list)
         {
            if(Boolean(o.localContentId) && TextUtils.caseInsensitiveCompare(o.localContentId,id))
            {
               return o;
            }
         }
         for each(o in this._list)
         {
            if(Boolean(o.remoteContentId) && TextUtils.caseInsensitiveCompare(o.remoteContentId,id))
            {
               return o;
            }
         }
         return null;
      }
      
      private function _saveData() : void
      {
         Save.instance.saveObject(SAVE_KEY,{"list":this._list});
      }
      
      private function _createPreparedData(sourceData:Object) : Object
      {
         var preparedData:Object = null;
         preparedData = JBGUtil.primitiveDeepCopy(sourceData);
         preparedData.save = function(doneFn:Function):void
         {
            var newData:Object = null;
            if(Boolean(preparedData.remoteContentID))
            {
               doneFn({"success":false});
               return;
            }
            if(!preparedData.categoryId || !preparedData.blob || !preparedData.metadata)
            {
               doneFn({"success":false});
               return;
            }
            var existingData:Object = _getData(preparedData.localContentId);
            if(Boolean(existingData))
            {
               existingData.categoryId = preparedData.categoryId;
               existingData.blob = preparedData.blob;
               existingData.metadata = preparedData.metadata;
            }
            else
            {
               preparedData.localContentId = new Uuid().toString();
               preparedData.remoteContentId = null;
               newData = {
                  "localContentId":preparedData.localContentId,
                  "remoteContentId":preparedData.remoteContentId,
                  "categoryId":preparedData.categoryId,
                  "blob":preparedData.blob,
                  "metadata":preparedData.metadata
               };
               _list.push(newData);
            }
            _saveData();
            doneFn({"success":true});
         };
         preparedData.remove = function():void
         {
            _list = _list.filter(function(o:Object, ... args):Boolean
            {
               var shouldRemove:* = o.localContentId && o.localContentId == preparedData.localContentId || o.remoteContentId && o.remoteContentId == preparedData.remoteContentId;
               return !shouldRemove;
            });
            _saveData();
         };
         preparedData.submit = function(doneFn:Function):void
         {
            if(!preparedData.localContentId || Boolean(preparedData.remoteContentId))
            {
               doneFn({"success":false});
               return;
            }
            BlobStorage.instance.postContent(preparedData.categoryId,preparedData.metadata,preparedData.blob,function(result:Object):void
            {
               var existingData:Object = null;
               if(result.hasOwnProperty("contentId"))
               {
                  preparedData.remoteContentId = result.contentId;
                  existingData = _getData(preparedData.localContentId);
                  if(Boolean(existingData))
                  {
                     existingData.remoteContentId = preparedData.remoteContentId;
                  }
                  _saveData();
               }
               doneFn(result);
            });
         };
         preparedData.markAsSeen = function():void
         {
            var existingData:Object = null;
            var now:Date = new Date();
            preparedData.lastSeen = now.time;
            if(Boolean(preparedData.localContentId))
            {
               existingData = _getData(preparedData.localContentId);
               if(Boolean(existingData))
               {
                  existingData.lastSeen = now.time;
                  _saveData();
                  return;
               }
            }
            if(Boolean(preparedData.remoteContentId))
            {
               existingData = _getData(preparedData.remoteContentId);
               if(Boolean(existingData))
               {
                  existingData.lastSeen = now.time;
                  _saveData();
               }
            }
         };
         return preparedData;
      }
      
      public function createContent() : Object
      {
         return this._createPreparedData({});
      }
      
      public function getContent(id:String) : Object
      {
         var data:Object = this._getData(id);
         if(!data)
         {
            return null;
         }
         return this._createPreparedData(data);
      }
      
      private function _getSortedArray(a:Array) : Array
      {
         return ArrayUtil.copy(a).sort(function(a:Object, b:Object):Number
         {
            var timeSeenA:* = a.hasOwnProperty("lastSeen") ? a.lastSeen : Number.MIN_VALUE;
            var timeSeenB:* = b.hasOwnProperty("lastSeen") ? b.lastSeen : Number.MIN_VALUE;
            return timeSeenB - timeSeenA;
         });
      }
      
      public function getAllContent() : Array
      {
         return this._getSortedArray(this._list).map(function(o:Object, ... args):Object
         {
            return _createPreparedData(o);
         });
      }
      
      public function getLocalContent() : Array
      {
         return this._getSortedArray(this._list.filter(function(o:Object, ... args):Boolean
         {
            return o.localContentId != null;
         })).map(function(o:Object, ... args):Object
         {
            return _createPreparedData(o);
         });
      }
      
      public function getRemoteOnlyContent() : Array
      {
         return this._getSortedArray(this._list.filter(function(o:Object, ... args):Boolean
         {
            return o.localContentId == null;
         })).map(function(o:Object, ... args):Object
         {
            return _createPreparedData(o);
         });
      }
      
      public function retrieveRemoteContent(id:String, doneFn:Function) : void
      {
         BlobStorage.instance.getContent(id,function(result:Object):void
         {
            var dataToReturn:Object = null;
            if(!result.success)
            {
               doneFn(result);
               return;
            }
            var numContentToKeep:int = MAX_REMOTE_CONTENT_TO_REMEMBER - 1;
            var remoteContent:Array = getRemoteOnlyContent();
            for(var i:int = numContentToKeep; i < remoteContent.length; i++)
            {
               trace("Removing : " + remoteContent[i].remoteContentId);
               remoteContent[i].remove();
            }
            var existingData:Object = _getData(id);
            var newData:Object = {
               "localContentId":null,
               "remoteContentId":result.contentId,
               "categoryId":result.categoryId,
               "blob":result.blob,
               "metadata":result.metadata,
               "creator":result.creator
            };
            if(Boolean(existingData))
            {
               existingData.categoryId = newData.categoryId;
               existingData.blob = newData.blob;
               existingData.metadata = newData.metadata;
               existingData.creator = newData.creator;
               dataToReturn = _createPreparedData(existingData);
            }
            else
            {
               _list.push(newData);
               dataToReturn = _createPreparedData(newData);
            }
            _saveData();
            doneFn({
               "success":true,
               "data":dataToReturn
            });
         });
      }
   }
}
