package jackboxgames.rolemodels
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.utils.*;
   
   public class Player extends BlobCastPlayer
   {
      
      public static var STUB_PLAYER:Player = new Player();
      
      public static var AUDIENCE_PLAYER:Player = new Player();
      
      public static const EVENT_PICTURE_CHANGED:String = "PictureChanged";
      
      public static const EVENT_IS_CHOOSING_ACTIVE_CHANGED:String = "IsChoosingActiveChanged";
      
      public static const AVATAR_SOURCE:Object = {
         "NONE":"None",
         "DRAWING":"Drawing",
         "PICTURE":"Picture"
      };
       
      
      private var _profilePicture:BitmapData;
      
      private var _placeIndex:int;
      
      private var _isChoosingActive:Boolean;
      
      private var _avatarSource:String;
      
      public function Player()
      {
         super();
      }
      
      public static function SET_PLAYERS_CHOOSING_ACTIVE(players:Array, isActive:Boolean) : void
      {
         players.forEach(function(p:Player, ... args):void
         {
            p.isChoosingActive = isActive;
         });
      }
      
      public static function PROPERTY_FUNCTION_SCORE(p:Player) : int
      {
         return p.score.val;
      }
      
      public function get picture() : BitmapData
      {
         return this._profilePicture;
      }
      
      public function get hasPicture() : Boolean
      {
         return this._profilePicture != null;
      }
      
      public function set picture(val:BitmapData) : void
      {
         this._profilePicture = val;
         dispatchEvent(new Event(EVENT_PICTURE_CHANGED));
      }
      
      public function set avatarSource(val:String) : void
      {
         this._avatarSource = val;
      }
      
      public function get drewAvatar() : Boolean
      {
         return this._avatarSource == AVATAR_SOURCE.DRAWING;
      }
      
      public function get tookPicture() : Boolean
      {
         return this._avatarSource == AVATAR_SOURCE.PICTURE;
      }
      
      public function get placeIndex() : int
      {
         return this._placeIndex;
      }
      
      public function set placeIndex(index:int) : void
      {
         this._placeIndex = index;
      }
      
      public function get isChoosingActive() : Boolean
      {
         return this._isChoosingActive;
      }
      
      public function set isChoosingActive(val:Boolean) : void
      {
         if(this._isChoosingActive == val)
         {
            return;
         }
         this._isChoosingActive = val;
         dispatchEvent(new EventWithData(EVENT_IS_CHOOSING_ACTIVE_CHANGED,this._isChoosingActive));
      }
      
      public function setup() : void
      {
         this._placeIndex = this.index.val;
      }
      
      override public function reset() : void
      {
         JBGUtil.unloadBitmapIds(["PLAYER_" + index.val]);
         if(Boolean(this._profilePicture))
         {
            this._profilePicture.dispose();
            this._profilePicture = null;
         }
         this._avatarSource = AVATAR_SOURCE.NONE;
      }
      
      override public function updatePlayerBlob(blob:Object) : Object
      {
         var newBlob:Object = super.updatePlayerBlob(blob);
         newBlob.playerInfo.playerColor = GameConstants.PLAYER_COLORS[index.val];
         return newBlob;
      }
      
      public function broadcast(broadcastName:String, data:*) : void
      {
         dispatchEvent(new PlayerBroadcastEvent(this,broadcastName,data));
      }
   }
}
