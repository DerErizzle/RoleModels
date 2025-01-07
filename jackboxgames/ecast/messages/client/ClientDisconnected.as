package jackboxgames.ecast.messages.client
{
   public class ClientDisconnected
   {
      private var _id:int;
      
      private var _userId:String;
      
      private var _role:String;
      
      public function ClientDisconnected(id:int, userId:String, role:String)
      {
         super();
         this._id = id;
         this._userId = userId;
         this._role = role;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get userId() : String
      {
         return this._userId;
      }
      
      public function get role() : String
      {
         return this._role;
      }
   }
}

