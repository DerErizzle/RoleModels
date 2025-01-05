package jackboxgames.rolemodels
{
   import flash.display.*;
   import jackboxgames.engine.*;
   import jackboxgames.rolemodels.actionpackages.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class Game extends TalkshowGame
   {
       
      
      public function Game(rootMC:MovieClip)
      {
         super(rootMC);
         _registeredActionPackages = [{
            "name":"Global",
            "c":Global
         },{
            "name":"Lobby",
            "c":Lobby
         },{
            "name":"Gameplay",
            "c":Gameplay
         },{
            "name":"Menu",
            "c":Menu
         },{
            "name":"PostGame",
            "c":PostGame
         },{
            "name":"InitialVote",
            "c":InitialVote
         },{
            "name":"Judgement",
            "c":Judgement
         },{
            "name":"Recount",
            "c":Recount
         },{
            "name":"Majority",
            "c":Majority
         },{
            "name":"GetInCharacter",
            "c":GetInCharacter
         },{
            "name":"Reveal",
            "c":Reveal
         },{
            "name":"FightJustPlaying",
            "c":FightJustPlaying
         },{
            "name":"Powers",
            "c":Powers
         },{
            "name":"Split",
            "c":Split
         },{
            "name":"MethodAct",
            "c":MethodAct
         },{
            "name":"Trivia",
            "c":Trivia
         },{
            "name":"FightTiebreaker",
            "c":FightTiebreaker
         },{
            "name":"Intro",
            "c":Intro
         },{
            "name":"Abundance",
            "c":Abundance
         },{
            "name":"Freebie",
            "c":Freebie
         },{
            "name":"TagChoice",
            "c":TagChoice
         },{
            "name":"TagResolution",
            "c":TagResolution
         },{
            "name":"TagContradiction",
            "c":TagContradiction
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
      
      override public function get initialSettings() : Object
      {
         var initialValues:Object = super.initialSettings;
         initialValues[BuildConfig.instance.configVal("gameName") + SettingsConstants.SETTING_MAX_PLAYERS] = GameConstants.MAX_PLAYERS;
         initialValues[BuildConfig.instance.configVal("gameName") + GameConstants.SETTING_PREVENT_PICTURES] = false;
         return initialValues;
      }
      
      override protected function configFinished() : void
      {
         GameState.initialize(ts);
         if(DeveloperConsole.isEnabled())
         {
            DeveloperConsole.API = new DeveloperConsoleAPI(this.ts);
         }
         super.configFinished();
      }
   }
}
