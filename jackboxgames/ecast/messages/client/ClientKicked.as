package jackboxgames.ecast.messages.client
{
   public class ClientKicked
   {
      private var _id:int;
      
      public function ClientKicked(id:int)
      {
         super();
         this._id = id;
      }
      
      public function get id() : int
      {
         return this._id;
      }
   }
}

