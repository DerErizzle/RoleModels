package jackboxgames.ecast.messages.audience
{
   public class GetAudienceReply
   {
      private var _connections:int;
      
      public function GetAudienceReply(connections:int)
      {
         super();
         this._connections = connections;
      }
      
      public function get connections() : int
      {
         return this._connections;
      }
   }
}

