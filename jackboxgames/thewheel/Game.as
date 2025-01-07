package jackboxgames.thewheel
{
   import flash.display.MovieClip;
   import jackboxgames.engine.TalkshowGame;
   import jackboxgames.settings.SettingConfig;
   import jackboxgames.settings.SettingsConstants;
   import jackboxgames.thewheel.actionpackages.AnswerWheel;
   import jackboxgames.thewheel.actionpackages.AudienceActionPackage;
   import jackboxgames.thewheel.actionpackages.Gameplay;
   import jackboxgames.thewheel.actionpackages.Global;
   import jackboxgames.thewheel.actionpackages.Intro;
   import jackboxgames.thewheel.actionpackages.Lobby;
   import jackboxgames.thewheel.actionpackages.Menu;
   import jackboxgames.thewheel.actionpackages.Players;
   import jackboxgames.thewheel.actionpackages.PostGame;
   import jackboxgames.thewheel.actionpackages.SpinTheWheel;
   import jackboxgames.thewheel.actionpackages.Trivia;
   import jackboxgames.thewheel.actionpackages.Winner;
   import jackboxgames.utils.DeveloperConsole;
   
   public class Game extends TalkshowGame
   {
      public function Game(rootMC:MovieClip)
      {
         super(rootMC);
         _registeredActionPackages = [{
            "name":"Global",
            "c":Global,
            "resetData":{"hard":true}
         },{
            "name":"Menu",
            "c":Menu
         },{
            "name":"Lobby",
            "c":Lobby
         },{
            "name":"Gameplay",
            "c":Gameplay
         },{
            "name":"Audience",
            "c":AudienceActionPackage
         },{
            "name":"Intro",
            "c":Intro
         },{
            "name":"Players",
            "c":Players
         },{
            "name":"Trivia",
            "c":Trivia
         },{
            "name":"SpinTheWheel",
            "c":SpinTheWheel
         },{
            "name":"Winner",
            "c":Winner
         },{
            "name":"AnswerWheel",
            "c":AnswerWheel
         },{
            "name":"PostGame",
            "c":PostGame
         }];
      }
      
      override public function restart() : void
      {
         GameState.instance.goBackToMenu();
      }
      
      override public function dispose() : void
      {
         GameState.instance.destroy();
         super.dispose();
      }
      
      override public function get settings() : Array
      {
         var settings:Array = super.settings;
         settings.push(new SettingConfig(SettingsConstants.SETTING_MAX_PLAYERS,GameConstants.MAX_PLAYERS,true));
         settings.push(new SettingConfig(GameConstants.SETTING_ALLOW_PLAYER_CONTENT_ON_SCREEN,true,true));
         return settings;
      }
      
      override protected function configFinished() : void
      {
         GameState.initialize(ts);
         GameState.instance.registerContentActionPackages();
         if(DeveloperConsole.isEnabled())
         {
            DeveloperConsole.API = GameState.instance.debug;
         }
         super.configFinished();
      }
   }
}

