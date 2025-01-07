package jackboxgames.metrics
{
   import flash.utils.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.entityinteraction.entities.*;
   import jackboxgames.logger.*;
   import jackboxgames.model.*;
   import jackboxgames.utils.*;
   
   public class GameMetrics
   {
      public static const KEY_SETTINGS:String = ":settings";
      
      public static const KEY_PLATFORM:String = ":platform";
      
      private static const KEY_PREFIX:String = "meta:";
      
      private var _gs:JBGGameState;
      
      private var _metricsEntities:Dictionary;
      
      public function GameMetrics(gs:JBGGameState)
      {
         super();
         this._gs = gs;
         this._metricsEntities = new Dictionary();
      }
      
      public function dispose() : void
      {
      }
      
      public function reset() : void
      {
      }
      
      public function reportMetrics(keySuffix:String, value:Object) : Promise
      {
         if(!BuildConfig.instance.configVal("reportMetrics"))
         {
            Logger.debug("GameMetrics disabled");
            return PromiseUtil.RESOLVED(true);
         }
         var key:String = KEY_PREFIX + BuildConfig.instance.configVal("gameTag") + keySuffix;
         Logger.debug("GameMetrics reporting key => " + key + " with value => " + TraceUtil.objectRecursive(value,"Value"));
         var entity:ObjectEntity = this._metricsEntities[key];
         if(!entity)
         {
            entity = new ObjectEntity(this._gs.client,key,value);
            this._metricsEntities[key] = entity;
            return entity.create();
         }
         return entity.setValue(value);
      }
   }
}

