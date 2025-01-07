package jackboxgames.ecast.messages
{
   import jackboxgames.utils.*;
   
   public class UGCContent implements IToSimpleObject
   {
      private var _contentId:String;
      
      private var _appId:String;
      
      private var _categoryId:String;
      
      private var _author:String;
      
      private var _title:String;
      
      private var _createdTime:Number;
      
      private var _downloads:int;
      
      private var _platformId:String;
      
      private var _platformUserId:String;
      
      private var _blob:Object;
      
      public function UGCContent(ugcResponse:Object)
      {
         super();
         this._contentId = ugcResponse.contentId;
         this._appId = ugcResponse.appId;
         this._categoryId = ugcResponse.categoryId;
         this._author = ugcResponse.metadata.author;
         this._title = ugcResponse.metadata.title;
         this._createdTime = ugcResponse.createdTime;
         this._downloads = ugcResponse.downloads;
         this._platformId = ugcResponse.creator.platformId;
         this._platformUserId = ugcResponse.creator.platformUserId;
         this._blob = ugcResponse.blob;
      }
      
      public function get contentId() : String
      {
         return this._contentId;
      }
      
      public function get appId() : String
      {
         return this._appId;
      }
      
      public function get categoryId() : String
      {
         return this._categoryId;
      }
      
      public function get author() : String
      {
         return this._author;
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function get createdTime() : Number
      {
         return this._createdTime;
      }
      
      public function get downloads() : int
      {
         return this._downloads;
      }
      
      public function get platformId() : String
      {
         return this._platformId;
      }
      
      public function get platformUserId() : String
      {
         return this._platformUserId;
      }
      
      public function get blob() : Object
      {
         return this._blob;
      }
      
      public function get metadata() : Object
      {
         return {
            "author":this._author,
            "title":this._title
         };
      }
      
      public function get creator() : Object
      {
         return {
            "platformId":this._platformId,
            "platformUserId":this._platformUserId
         };
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "contenId":this._contentId,
            "appId":this._appId,
            "categoryId":this._categoryId,
            "createdTime":this._createdTime,
            "downloads":this._downloads,
            "creator":this.creator,
            "metadata":this.metadata,
            "blob":this._blob
         };
      }
   }
}

