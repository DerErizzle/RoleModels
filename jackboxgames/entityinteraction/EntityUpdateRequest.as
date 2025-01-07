package jackboxgames.entityinteraction
{
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class EntityUpdateRequest
   {
      private var _sharedEntities:Array;
      
      private var _playerEntities:PerPlayerContainer;
      
      public function EntityUpdateRequest()
      {
         super();
         this._sharedEntities = [];
         this._playerEntities = new PerPlayerContainer();
      }
      
      public function get sharedEntityUpdates() : Array
      {
         return this._sharedEntities;
      }
      
      public function get playerEntityUpdates() : PerPlayerContainer
      {
         return this._playerEntities;
      }
      
      public function dispose() : void
      {
         this._sharedEntities = [];
         this._playerEntities.dispose();
      }
      
      public function withSharedEntity(sharedEntityKey:String) : EntityUpdateRequest
      {
         this._sharedEntities.push(sharedEntityKey);
         return this;
      }
      
      public function withPlayerEntity(playerOrPlayers:*, playerEntityKey:String) : EntityUpdateRequest
      {
         var players:Array = ArrayUtil.makeArrayIfNecessary(playerOrPlayers);
         players.forEach(function(p:JBGPlayer, ... args):void
         {
            if(_playerEntities.hasDataForPlayer(p))
            {
               if(playerEntityKey == "main")
               {
                  _playerEntities.getDataForPlayer(p).push(playerEntityKey);
               }
               else
               {
                  _playerEntities.getDataForPlayer(p).insertAt(0,playerEntityKey);
               }
            }
            else
            {
               _playerEntities.setDataForPlayer(p,[playerEntityKey]);
            }
         });
         return this;
      }
      
      public function withPlayerMainEntity(p:*) : EntityUpdateRequest
      {
         return this.withPlayerEntity(p,"main");
      }
   }
}

