package jackboxgames.engine
{
   import flash.events.*;
   import jackboxgames.engine.componenets.*;
   import jackboxgames.engine.componentLists.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.*;
   
   public class GameEngine extends PausableEventDispatcher
   {
      
      private static var _instance:GameEngine;
       
      
      private var _rootGame:IGame;
      
      private var _activeGame:IGame;
      
      private var _console:DeveloperConsole;
      
      private var _error:ErrorWidget;
      
      private var _componentList:IComponentList;
      
      public function GameEngine(rootGame:IGame, componentList:IComponentList)
      {
         super();
         this._rootGame = rootGame;
         this._componentList = componentList;
      }
      
      public static function Initialize(gameId:String, configList:Array, game:IGame, componentList:IComponentList) : void
      {
         var onAddedToStage:Function = null;
         onAddedToStage = function(evt:Event):void
         {
            game.main.removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
            BuildConfig.instance.init(configList);
            BuildConfig.instance.load(function():void
            {
               if(Boolean(_instance))
               {
                  game.init();
                  _instance.startGame(game,Nullable.NULL_FUNCTION);
                  return;
               }
               _instance = new GameEngine(game,componentList);
               _instance.init(function():void
               {
                  game.init();
                  _instance.startGame(game,Nullable.NULL_FUNCTION);
               });
            });
         };
         if(Boolean(game.main.stage))
         {
            onAddedToStage(null);
         }
         else
         {
            game.main.addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
         }
      }
      
      public static function get instance() : GameEngine
      {
         return _instance;
      }
      
      public function get priority() : uint
      {
         return 0;
      }
      
      public function get rootGame() : IGame
      {
         return this._rootGame;
      }
      
      public function get activeGame() : IGame
      {
         return this._activeGame;
      }
      
      public function get error() : ErrorWidget
      {
         return this._error;
      }
      
      private function _getComponents() : Array
      {
         return this._componentList.components.concat();
      }
      
      public function init(doneFn:Function) : void
      {
         this._error = new ErrorWidget();
         this._componentList.build(this);
         var asyncSequence:AsyncFunctionSequence = new AsyncFunctionSequence(this._getComponents(),"init");
         asyncSequence.run(doneFn);
      }
      
      public function dispose() : void
      {
         var c:IComponent = null;
         if(this._rootGame != null)
         {
            this._rootGame.dispose();
            this._rootGame = null;
         }
         var components:Array = this._getComponents();
         for each(c in components)
         {
            c.dispose();
         }
      }
      
      public function startGame(game:IGame, doneFn:Function) : void
      {
         var asyncSequence:AsyncFunctionSequence;
         this._activeGame = game;
         asyncSequence = new AsyncFunctionSequence(this._getComponents(),"startGame");
         asyncSequence.run(function():void
         {
            game.start();
            doneFn();
         });
      }
      
      public function disposeGame() : void
      {
         var components:Array = null;
         var c:IComponent = null;
         if(Boolean(this._activeGame) && !this._activeGame.preventDispose)
         {
            components = this._getComponents();
            for each(c in components)
            {
               c.disposeGame();
            }
            this._activeGame.dispose();
            if(Boolean(this._activeGame.main.parent))
            {
               this._activeGame.main.parent.removeChild(this._activeGame.main);
            }
            if(this._activeGame == this._rootGame)
            {
               this._rootGame = null;
            }
            this._activeGame = null;
         }
      }
      
      public function reset() : void
      {
         this._activeGame.restart();
      }
      
      public function get supportsExit() : Boolean
      {
         var component:IExitComponent = this._getComponentOfTypeByPriority(IExitComponent) as IExitComponent;
         return component.supportsExit;
      }
      
      public function exit() : void
      {
         this.disposeGame();
         this.dispose();
         var component:IExitComponent = this._getComponentOfTypeByPriority(IExitComponent) as IExitComponent;
         component.exit();
      }
      
      public function launchGame(gameName:String, gamePath:String, currentGame:String = "") : void
      {
         var component:ILaunchGameComponent = this._getComponentOfTypeByPriority(ILaunchGameComponent) as ILaunchGameComponent;
         component.launchGame(gameName,gamePath,currentGame);
      }
      
      public function hideLoader() : void
      {
         var component:ILaunchGameComponent = this._getComponentOfTypeByPriority(ILaunchGameComponent) as ILaunchGameComponent;
         component.hideLoader();
      }
      
      public function setPauseEnabled(enabled:Boolean) : void
      {
         var component:IPauseComponent = this._getComponentOfTypeByPriority(IPauseComponent) as IPauseComponent;
         component.setPauseEnabled(enabled);
      }
      
      public function setPauseType(type:String) : void
      {
         var component:IPauseComponent = this._getComponentOfTypeByPriority(IPauseComponent) as IPauseComponent;
         component.setPauseType(type);
      }
      
      public function get isPaused() : Boolean
      {
         var component:IPauseComponent = this._getComponentOfTypeByPriority(IPauseComponent) as IPauseComponent;
         return component.isPaused;
      }
      
      public function get canPause() : Boolean
      {
         var component:IPauseComponent = this._getComponentOfTypeByPriority(IPauseComponent) as IPauseComponent;
         return component.canPause;
      }
      
      public function pause() : Boolean
      {
         var component:IPauseComponent = this._getComponentOfTypeByPriority(IPauseComponent) as IPauseComponent;
         return component.pause();
      }
      
      public function resume() : void
      {
         var component:IPauseComponent = this._getComponentOfTypeByPriority(IPauseComponent) as IPauseComponent;
         component.resume();
      }
      
      public function get supportsFullscreen() : Boolean
      {
         var component:IFullscreenComponent = this._getComponentOfTypeByPriority(IFullscreenComponent) as IFullscreenComponent;
         return component.supportsFullscreen;
      }
      
      public function setFullscreen(isFull:Boolean) : void
      {
         var component:IFullscreenComponent = this._getComponentOfTypeByPriority(IFullscreenComponent) as IFullscreenComponent;
         component.setFullscreen(isFull);
      }
      
      public function setVolume(percent:Number) : void
      {
         var component:IVolumeComponent = this._getComponentOfTypeByPriority(IVolumeComponent) as IVolumeComponent;
         component.setVolume(percent);
      }
      
      public function prepare(id:String, doneFn:Function) : void
      {
         var component:IPrepareComponent = this._getComponentOfTypeByPriority(IPrepareComponent) as IPrepareComponent;
         component.prepare(id,doneFn);
      }
      
      private function _getComponentOfType(type:Class) : Array
      {
         return this._componentList.components.filter(function(c:*, i:int, arr:Array):Boolean
         {
            return c is type;
         });
      }
      
      private function _getComponentOfTypeByPriority(type:Class) : *
      {
         var componentsOfType:Array = this._getComponentOfType(type);
         if(componentsOfType.length == 0)
         {
            return null;
         }
         componentsOfType.sortOn("priority",Array.NUMERIC | Array.DESCENDING);
         return componentsOfType[0];
      }
   }
}
