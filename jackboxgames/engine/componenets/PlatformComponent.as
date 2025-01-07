package jackboxgames.engine.componenets
{
   import flash.display.*;
   import flash.events.*;
   import flash.external.ExternalInterface;
   import jackboxgames.engine.*;
   import jackboxgames.events.EventWithData;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.settings.SettingsManager;
   import jackboxgames.utils.*;
   
   public class PlatformComponent extends PausableEventDispatcher implements ILaunchGameComponent, IComponent
   {
      private var _engine:GameEngine;
      
      public function PlatformComponent(engine:GameEngine)
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
         Platform.Initialize();
         Platform.instance.addEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
         PlatformMovieClipManager.instance.init(function(success:Boolean):void
         {
            doneFn();
         });
      }
      
      public function dispose() : void
      {
         Platform.instance.removeEventListener(Platform.EVENT_NATIVE_MESSAGE_RECEIVED,this._onNativeMessage);
      }
      
      public function startGame(doneFn:Function) : void
      {
         if(!EnvUtil.isAIR())
         {
            ExternalInterface.call("setGameScreen",this._engine.activeGame);
         }
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
      
      public function launchGame(gameName:String, gamePath:String, currentGame:String = "") : void
      {
         this._engine.disposeGame();
         var gameswf:String = gamePath != "" ? "games/" + gameName + "/" + gamePath : "";
         ExternalInterface.call("launchGame",gameswf,currentGame,false);
      }
      
      public function hideLoader() : void
      {
         ExternalInterface.call("hideLoader");
      }
      
      private function _onNativeMessage(evt:EventWithData) : void
      {
         if(evt.data.message == "BackgroundStateChanged" && Boolean(evt.data.parameter))
         {
            this._engine.pause();
         }
         if(evt.data.message == "SetFullScreen")
         {
            SettingsManager.instance.getValue(SettingsConstants.SETTING_FULL_SCREEN).val = evt.data.parameter;
         }
         if(evt.data.message == "HandleError")
         {
            this._engine.error.handleError(evt.data.parameter);
         }
         if(BuildConfig.instance.configVal("isBundle") != true)
         {
            return;
         }
         if(evt.data.message == "ReturnToStart")
         {
            this._engine.launchGame("","","");
         }
         if(evt.data.message == "CurrentUserChanged")
         {
            this._engine.launchGame("","","");
         }
      }
   }
}

