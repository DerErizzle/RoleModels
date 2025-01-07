package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class LobbyPlayers
   {
      protected var _mc:MovieClip;
      
      protected var _gs:JBGGameState;
      
      protected var _players:Array;
      
      public function LobbyPlayers(mc:MovieClip, gs:JBGGameState)
      {
         super();
         this._mc = mc;
         this._gs = gs;
         this._players = this._generatePlayers();
      }
      
      protected function _getContainer() : MovieClip
      {
         return this._mc;
      }
      
      protected function _getPlayerClass() : Class
      {
         return LobbyPlayer;
      }
      
      protected function _generatePlayers() : Array
      {
         var playerMCs:Array = MovieClipUtil.getChildrenWithNameInOrder(this._getContainer(),"player");
         return playerMCs.map(function(playerMC:MovieClip, ... args):LobbyPlayer
         {
            var c:* = _getPlayerClass();
            return new c(playerMC);
         });
      }
      
      protected function _doAnimOnSlots(slots:Array, anim:String, doneFn:Function) : void
      {
         var c:Counter = null;
         if(slots.length == 0)
         {
            doneFn();
            return;
         }
         c = new Counter(slots.length,doneFn);
         slots.forEach(function(lp:LobbyPlayer, ... args):void
         {
            lp.doAnim(anim,c.generateDoneFn());
         });
      }
      
      public function dispose() : void
      {
         JBGUtil.dispose(this._players);
         this._players = null;
         this._mc = null;
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._players);
      }
      
      public function setupForNewLobby() : void
      {
         this._players.forEach(function(lp:LobbyPlayer, i:int, a:Array):void
         {
            lp.setupForNewLobby(i);
         });
      }
      
      public function setupForPlayer(i:int, p:JBGPlayer) : void
      {
         var lp:LobbyPlayer = this._players[i];
         lp.setupForPlayer(i,p);
      }
      
      public function getWidgetForPlayer(p:JBGPlayer) : LobbyPlayer
      {
         return this._players[p.index.val];
      }
      
      public function doAnimOnAllAvailablePlayerSlots(anim:String, doneFn:Function) : void
      {
         this._doAnimOnSlots(this._players.slice(0,this._gs.maxPlayers),anim,doneFn);
      }
      
      public function doAnimOnAllUnavailablePlayerSlots(anim:String, doneFn:Function) : void
      {
         this._doAnimOnSlots(this._players.slice(this._gs.maxPlayers),anim,doneFn);
      }
      
      public function doAnimOnUsedPlayerSlots(anim:String, doneFn:Function) : void
      {
         this._doAnimOnSlots(this._players.filter(function(item:*, index:int, array:Array):Boolean
         {
            return index < _gs.players.length;
         }),anim,doneFn);
      }
      
      public function doAnimOnUnusedPlayerSlots(anim:String, doneFn:Function) : void
      {
         this._doAnimOnSlots(this._players.filter(function(item:*, index:int, array:Array):Boolean
         {
            return index >= _gs.players.length && index < _gs.maxPlayers;
         }),anim,doneFn);
      }
   }
}

