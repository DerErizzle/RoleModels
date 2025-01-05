package jackboxgames.rolemodels.utils
{
   import flash.events.Event;
   import jackboxgames.rolemodels.Player;
   
   public class PlayerBroadcastEvent extends Event
   {
      
      public static const EVENT_PLAYER_BROADCAST:String = "broadcast";
       
      
      private var _player:Player;
      
      private var _broadcastName:String;
      
      private var _data:*;
      
      public function PlayerBroadcastEvent(p:Player, broadcastName:String, data:*)
      {
         super(EVENT_PLAYER_BROADCAST,false,false);
         this._player = p;
         this._broadcastName = broadcastName;
         this._data = data;
      }
      
      public function get player() : Player
      {
         return this._player;
      }
      
      public function get broadcastName() : String
      {
         return this._broadcastName;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}
