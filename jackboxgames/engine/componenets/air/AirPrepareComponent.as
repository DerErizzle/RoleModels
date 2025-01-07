package jackboxgames.engine.componenets.air
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.engine.*;
   import jackboxgames.engine.componenets.IComponent;
   import jackboxgames.engine.componenets.IPrepareComponent;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.utils.*;
   import jackboxgames.video.*;
   
   public class AirPrepareComponent extends PausableEventDispatcher implements IPrepareComponent, IComponent
   {
      private var _engine:GameEngine;
      
      public function AirPrepareComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
      }
      
      public function get priority() : uint
      {
         return 1;
      }
      
      public function init(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      public function prepare(id:String, doneFn:Function) : void
      {
         var modulesPrepared:int = 0;
         var modulesSucceeded:int = 0;
         var target:int = 0;
         var modulesToPrepare:Vector.<IPreparable> = new Vector.<IPreparable>();
         if(Platform.instance.needsPrepare)
         {
            modulesToPrepare.push(Platform.instance);
         }
         modulesPrepared = 0;
         modulesSucceeded = 0;
         target = int(modulesToPrepare.length);
         modulesToPrepare.forEach(function(module:IPreparable, i:int, v:Vector.<IPreparable>):void
         {
            var prepareResult:Function = null;
            prepareResult = function(success:Boolean):void
            {
               ++modulesPrepared;
               if(success)
               {
                  ++modulesSucceeded;
               }
               else
               {
                  _engine.error.handleError(module.prepareFailError);
               }
               if(modulesPrepared == target)
               {
                  doneFn(modulesSucceeded == target);
               }
            };
            module.prepare(id,prepareResult);
         });
      }
   }
}

