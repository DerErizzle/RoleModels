package jackboxgames.engine.componenets
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.engine.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   import jackboxgames.video.*;
   
   public class PrepareComponent extends PausableEventDispatcher implements IPrepareComponent, IComponent
   {
       
      
      private var _engine:GameEngine;
      
      public function PrepareComponent(engine:GameEngine)
      {
         super();
         this._engine = engine;
      }
      
      public function get priority() : uint
      {
         return 0;
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
         if(Save.instance.needsPrepare)
         {
            modulesToPrepare.push(Save.instance);
         }
         if(EnvUtil.isMobile() && License.instance.needsPrepare)
         {
            modulesToPrepare.push(License.instance);
         }
         if(EnvUtil.isConsole() && Trophy.instance.needsPrepare)
         {
            modulesToPrepare.push(Trophy.instance);
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
