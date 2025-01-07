package jackboxgames.moderation
{
   import jackboxgames.events.*;
   import jackboxgames.moderation.model.*;
   import jackboxgames.utils.*;
   
   public class UserDataManager extends PausableEventDispatcher
   {
      public static const USER_DATA_ADDED:String = "UserDataAdded";
      
      public static const USER_DATA_REMOVED:String = "UserDataRemoved";
      
      private var _id:int;
      
      private var _userData:Object;
      
      public function UserDataManager()
      {
         super();
         this._id = 0;
         this._userData = {};
      }
      
      public function add(userData:IUserData) : void
      {
         userData.moderationStatus = ModerationConstants.MODERATION_STATUS_QUEUED;
         userData.id = ++this._id;
         this._userData[userData.moderationKey] = userData;
         dispatchEvent(new EventWithData(USER_DATA_ADDED,userData));
      }
      
      public function remove(key:String) : void
      {
         var userData:IUserData = this._userData[key];
         if(userData != null)
         {
            dispatchEvent(new EventWithData(USER_DATA_REMOVED,userData));
            delete this._userData[key];
         }
      }
      
      public function dispose() : void
      {
         var key:String = null;
         if(this._userData == null)
         {
            return;
         }
         for(key in this._userData)
         {
            this.remove(key);
         }
         this._userData = null;
      }
      
      public function reset() : void
      {
         this.dispose();
         this._userData = {};
      }
      
      public function getUserDataWithKey(key:String) : IUserData
      {
         return this._userData[key];
      }
      
      public function removeUserDataOfType(type:String) : void
      {
         var dataToRemove:Array = this.getUserDataOfType(type);
         dataToRemove.forEach(function(userData:IUserData, ... args):void
         {
            remove(userData.moderationKey);
         });
      }
      
      public function getUserDataOfType(type:String) : Array
      {
         var data:Object = ObjectUtil.filter(this._userData,function(userData:IUserData, ... args):Boolean
         {
            return userData.dataType == type;
         });
         return ObjectUtil.getValues(data);
      }
      
      public function getUserDataFrom(from:int) : Array
      {
         var data:Object = ObjectUtil.filter(this._userData,function(userData:IUserData, ... args):Boolean
         {
            return userData.from == from;
         });
         return ObjectUtil.getValues(data);
      }
      
      public function getDataWaitingForModerationOfType(type:String) : Array
      {
         var data:Array = this.getUserDataOfType(type).filter(function(userData:IUserData, ... args):Boolean
         {
            return userData.moderationStatus == ModerationConstants.MODERATION_STATUS_PENDING;
         });
         return data;
      }
      
      public function getDataWaitingForModerationFrom(from:int) : Array
      {
         var data:Array = this.getUserDataFrom(from).filter(function(userData:IUserData, ... args):Boolean
         {
            return userData.moderationStatus == ModerationConstants.MODERATION_STATUS_PENDING;
         });
         return data;
      }
   }
}

