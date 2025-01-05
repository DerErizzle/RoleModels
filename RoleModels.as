package
{
   import flash.display.MovieClip;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.engine.componentLists.DefaultGameComponentList;
   import jackboxgames.rolemodels.Game;
   
   [SWF(width="1280",height="720",frameRate="30",backgroundColor="0x000000")]
   public dynamic class RoleModels extends MovieClip
   {
       
      
      public function RoleModels()
      {
         super();
         GameEngine.Initialize("RoleModels",["games/RoleModels/jbg.config.jet","jbg.config.jet"],new Game(this),new DefaultGameComponentList());
      }
   }
}
