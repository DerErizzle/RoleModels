package jackboxgames.ecast.messages.client
{
   public class ClientWelcome
   {
      private var _id:int;
      
      private var _entities:Object;
      
      private var _secret:String;
      
      public function ClientWelcome(id:int, entities:Object, secret:String)
      {
         super();
         this._id = id;
         this._entities = entities;
         this._secret = secret;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get entities() : Object
      {
         return this._entities;
      }
      
      public function get secret() : String
      {
         return this._secret;
      }
   }
}

