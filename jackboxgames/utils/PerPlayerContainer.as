package jackboxgames.utils
{
   import jackboxgames.blobcast.model.*;
   
   public class PerPlayerContainer
   {
       
      
      private var _dataPerUserId:Object;
      
      public function PerPlayerContainer()
      {
         super();
         this.reset();
      }
      
      public function dispose() : void
      {
         if(!this._dataPerUserId)
         {
            return;
         }
         this._dataPerUserId = null;
      }
      
      public function reset() : void
      {
         this._dataPerUserId = {};
      }
      
      public function setDataForPlayer(p:BlobCastPlayer, data:*) : void
      {
         this._dataPerUserId[p.userId.val] = data;
      }
      
      public function hasDataForPlayer(p:BlobCastPlayer) : Boolean
      {
         return this._dataPerUserId.hasOwnProperty(p.userId.val);
      }
      
      public function hasDataForAllOfThesePlayers(players:Array) : Boolean
      {
         var p:BlobCastPlayer = null;
         for each(p in players)
         {
            if(!this.hasDataForPlayer(p))
            {
               return false;
            }
         }
         return true;
      }
      
      public function getDataForPlayer(p:BlobCastPlayer) : *
      {
         return this.hasDataForPlayer(p) ? this._dataPerUserId[p.userId.val] : null;
      }
      
      public function getDataForPlayers(players:Array) : Array
      {
         return players.filter(function(p:BlobCastPlayer, ... args):Boolean
         {
            return hasDataForPlayer(p);
         }).map(function(p:BlobCastPlayer, ... args):*
         {
            return getDataForPlayer(p);
         });
      }
      
      public function removeDataForPlayer(p:BlobCastPlayer) : void
      {
         delete this._dataPerUserId[p.userId.val];
      }
      
      public function getAllData() : Array
      {
         return ObjectUtil.getValues(this._dataPerUserId);
      }
      
      public function forEach(f:Function) : void
      {
         ObjectUtil.forEach(this._dataPerUserId,function(o:*, key:String, source:Object):void
         {
            f(o,key,source);
         });
      }
   }
}
