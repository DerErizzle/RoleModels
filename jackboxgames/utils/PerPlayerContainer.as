package jackboxgames.utils
{
   import flash.utils.*;
   import jackboxgames.model.*;
   
   public class PerPlayerContainer
   {
      private var _dataPerPlayerObject:Dictionary;
      
      public function PerPlayerContainer()
      {
         super();
         this.reset();
      }
      
      public function dispose() : void
      {
         if(!this._dataPerPlayerObject)
         {
            return;
         }
         this._dataPerPlayerObject = null;
      }
      
      public function clone() : PerPlayerContainer
      {
         var p:Object = null;
         var newClone:PerPlayerContainer = new PerPlayerContainer();
         if(Boolean(this._dataPerPlayerObject))
         {
            for(p in this._dataPerPlayerObject)
            {
               newClone._dataPerPlayerObject[p] = this._dataPerPlayerObject[p];
            }
         }
         return newClone;
      }
      
      public function reset() : void
      {
         this._dataPerPlayerObject = new Dictionary();
      }
      
      public function setDataForPlayer(p:JBGPlayer, data:*) : void
      {
         this._dataPerPlayerObject[p] = data;
      }
      
      public function hasDataForPlayer(p:JBGPlayer) : Boolean
      {
         return p in this._dataPerPlayerObject;
      }
      
      public function hasDataForAllOfThesePlayers(players:Array) : Boolean
      {
         var p:JBGPlayer = null;
         for each(p in players)
         {
            if(!this.hasDataForPlayer(p))
            {
               return false;
            }
         }
         return true;
      }
      
      public function getDataForPlayer(p:JBGPlayer) : *
      {
         return this.hasDataForPlayer(p) ? this._dataPerPlayerObject[p] : null;
      }
      
      public function getDataForPlayers(players:Array) : Array
      {
         return players.filter(function(p:JBGPlayer, ... args):Boolean
         {
            return hasDataForPlayer(p);
         }).map(function(p:JBGPlayer, ... args):*
         {
            return getDataForPlayer(p);
         });
      }
      
      public function removeDataForPlayer(p:JBGPlayer) : void
      {
         delete this._dataPerPlayerObject[p];
      }
      
      public function getAllData() : Array
      {
         var p:Object = null;
         var values:Array = [];
         for(p in this._dataPerPlayerObject)
         {
            values.push(this._dataPerPlayerObject[p]);
         }
         return values;
      }
      
      public function forEach(f:Function) : void
      {
         var p:Object = null;
         for(p in this._dataPerPlayerObject)
         {
            f(this._dataPerPlayerObject[p],p,this._dataPerPlayerObject);
         }
      }
      
      public function incrementDataForPlayer(p:JBGPlayer) : void
      {
         ++this._dataPerPlayerObject[p];
      }
      
      public function decrementDataForPlayer(p:JBGPlayer) : void
      {
         --this._dataPerPlayerObject[p];
      }
   }
}

