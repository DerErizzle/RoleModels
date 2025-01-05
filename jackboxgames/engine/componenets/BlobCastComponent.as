package jackboxgames.engine.componenets
{
   import jackboxgames.blobcast.services.BlobArtifact;
   import jackboxgames.blobcast.services.BlobCastWebAPI;
   import jackboxgames.blobcast.services.BlobStorage;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.nativeoverride.BlobCast;
   import jackboxgames.nativeoverride.Platform;
   import jackboxgames.utils.BuildConfig;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class BlobCastComponent extends PausableEventDispatcher implements IComponent
   {
       
      
      private var _engine:GameEngine;
      
      public function BlobCastComponent(engine:GameEngine)
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
         BlobStorage.initialize();
         BlobArtifact.initialize();
         doneFn();
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         BlobCast.Initialize(this._engine.activeGame.serverUrl,this._engine.activeGame.gameId);
         BlobCastWebAPI.initialize(this._engine.activeGame.gameId,BlobCast.instance.UserId,this._engine.activeGame.serverUrl,this._engine.activeGame.protocol);
         BlobCast.instance.uaSetup(BuildConfig.instance.configVal("uaAppName"),BuildConfig.instance.configVal("uaAppId") + "-" + Platform.instance.PlatformId,BuildConfig.instance.configVal("uaVersionId"));
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}
