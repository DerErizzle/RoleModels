package jackboxgames.engine.componentLists
{
   import jackboxgames.engine.GameEngine;
   import jackboxgames.engine.componenets.AudioComponent;
   import jackboxgames.engine.componenets.DevConsoleComponent;
   import jackboxgames.engine.componenets.InputComponent;
   import jackboxgames.engine.componenets.LocalizationComponent;
   import jackboxgames.engine.componenets.NativeComponent;
   import jackboxgames.engine.componenets.NetworkComponent;
   import jackboxgames.engine.componenets.PauseComponent;
   import jackboxgames.engine.componenets.PlatformComponent;
   import jackboxgames.engine.componenets.PrepareComponent;
   import jackboxgames.engine.componenets.SaveComponent;
   import jackboxgames.engine.componenets.SettingsComponent;
   import jackboxgames.engine.componenets.ToolsComponent;
   import jackboxgames.engine.componenets.VideoComponent;
   import jackboxgames.engine.componenets.WindowComponent;
   import jackboxgames.engine.componenets.air.AirAudioComponent;
   import jackboxgames.engine.componenets.air.AirInputComponent;
   import jackboxgames.engine.componenets.air.AirManagerComponent;
   import jackboxgames.engine.componenets.air.AirNetworkComponent;
   import jackboxgames.engine.componenets.air.AirPauseComponent;
   import jackboxgames.engine.componenets.air.AirPlatformComponent;
   import jackboxgames.engine.componenets.air.AirPrepareComponent;
   import jackboxgames.engine.componenets.air.AirWindowComponent;
   import jackboxgames.utils.EnvUtil;
   
   public class DefaultGameComponentList implements IComponentList
   {
      private var _components:Array;
      
      public function DefaultGameComponentList()
      {
         super();
         this._components = new Array();
      }
      
      public function get components() : Array
      {
         return this._components;
      }
      
      public function build(engine:GameEngine) : void
      {
         this._components.push(new WindowComponent(engine));
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirWindowComponent(engine));
         }
         this._components.push(new VideoComponent(engine));
         this._components.push(new InputComponent(engine));
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirInputComponent(engine));
         }
         this._components.push(new PlatformComponent(engine));
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirPlatformComponent(engine));
         }
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirNetworkComponent(engine));
         }
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirManagerComponent());
         }
         this._components.push(new DevConsoleComponent(engine));
         this._components.push(new SaveComponent(engine));
         this._components.push(new ToolsComponent(engine));
         this._components.push(new SettingsComponent(engine));
         this._components.push(new AudioComponent(engine));
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirAudioComponent(engine));
         }
         this._components.push(new NetworkComponent(engine));
         this._components.push(new LocalizationComponent(engine));
         this._components.push(new PauseComponent(engine));
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirPauseComponent(engine));
         }
         this._components.push(new PrepareComponent(engine));
         if(EnvUtil.isAIR())
         {
            this._components.push(new AirPrepareComponent(engine));
         }
         this._components.push(new NativeComponent(engine));
      }
   }
}

