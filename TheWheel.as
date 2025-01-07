package
{
   import flash.display.MovieClip;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.engine.componentLists.DefaultGameComponentList;
   import jackboxgames.intermoviecommunication.IMCModule;
   import jackboxgames.thewheel.Game;
   
   [SWF(width="1280",height="720",frameRate="30",backgroundColor="0x000000")]
   public dynamic class TheWheel extends MovieClip
   {
      public function TheWheel()
      {
         super();
         IMCModule.SET_MOVIE_ID(IMCModule.MOVIE_ID_GAME);
         GameEngine.Initialize("TheWheel",["games/TheWheel/jbg.config.jet","jbg.config.jet"],new Game(this),new DefaultGameComponentList());
      }
   }
}

