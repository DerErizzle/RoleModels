package jackboxgames.engine.componenets.air
{
   import flash.display.*;
   import flash.events.*;
   import flash.external.*;
   import jackboxgames.engine.*;
   import jackboxgames.engine.componenets.*;
   import jackboxgames.flash.*;
   import jackboxgames.loader.ILoader;
   import jackboxgames.loader.JBGLoader;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   import jackboxgames.video.*;
   
   public class AirPlatformComponent extends PausableEventDispatcher implements ILaunchGameComponent, IComponent
   {
       
      
      private var _engine:GameEngine;
      
      private var _loader:ILoader;
      
      private var _commandLineArguments:Object;
      
      public function AirPlatformComponent(engine:GameEngine)
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
         if(true)
         {
            doneFn();
            return;
         }
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         FlashNative.Initialize(this._engine.activeGame.serverUrl,this._engine.activeGame.gameId);
         doneFn();
      }
      
      public function disposeGame() : void
      {
         if(Boolean(this._loader))
         {
            this._loader.dispose();
            this._loader = null;
         }
      }
      
      public function launchGame(gameName:String, gamePath:String, currentGame:String = "") : void
      {
         if(this._engine.activeGame != this._engine.rootGame)
         {
            this._engine.disposeGame();
         }
         this._engine.rootGame.setVisibility(true);
         this._loader = JBGLoader.instance.loadFile("games/" + gameName + "/" + gamePath,function(result:Object):void
         {
            var game:* = undefined;
            if(Boolean(result.success))
            {
               game = result.contentAsMovieClip;
               game.visible = false;
               _engine.rootGame.main.addChild(game);
            }
         },false);
      }
      
      public function hideLoader() : void
      {
         this._engine.rootGame.setVisibility(false);
         this._engine.activeGame.setVisibility(true);
      }
   }
}
