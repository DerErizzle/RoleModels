package jackboxgames.ecast.messages.client
{
   public class ClientConnected
   {
      public static const ROLE_HOST:String = "host";
      
      public static const ROLE_MODERATOR:String = "moderator";
      
      public static const ROLE_OBSERVER:String = "observer";
      
      public static const ROLE_PLAYER:String = "player";
      
      private var _id:int;
      
      private var _userId:String;
      
      private var _name:String;
      
      private var _role:String;
      
      private var _reconnect:Boolean;
      
      public function ClientConnected(id:int, userId:String, name:String, role:String, reconnect:Boolean)
      {
         super();
         this._id = id;
         this._userId = userId;
         this._name = name;
         this._role = role;
         this._reconnect = reconnect;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get userId() : String
      {
         return this._userId;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get role() : String
      {
         return this._role;
      }
      
      public function get reconnect() : Boolean
      {
         return this._reconnect;
      }
   }
}

