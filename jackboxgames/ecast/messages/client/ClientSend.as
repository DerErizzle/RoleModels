package jackboxgames.ecast.messages.client
{
   public class ClientSend
   {
      private var _to:int;
      
      private var _from:int;
      
      private var _body:Object;
      
      public function ClientSend(to:int, from:int, body:Object)
      {
         super();
         this._to = to;
         this._from = from;
         this._body = body;
      }
      
      public function get to() : int
      {
         return this._to;
      }
      
      public function get from() : int
      {
         return this._from;
      }
      
      public function get body() : Object
      {
         return this._body;
      }
   }
}

