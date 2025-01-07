package jackboxgames.model
{
   import jackboxgames.nativeoverride.Save;
   
   public class GameStateDictionaries
   {
      private static const SAVE_KEY:String = "GameStateDictionaries";
      
      private var _saved:Object;
      
      private var _perRun:Object;
      
      private var _perSetOfPlayers:Object;
      
      private var _perGame:Object;
      
      public function GameStateDictionaries()
      {
         super();
         this._saved = Save.instance.loadObject(SAVE_KEY);
         if(!this._saved)
         {
            this._saved = {};
            this.commitSaved();
         }
         this._perRun = {};
         this._perSetOfPlayers = {};
         this._perGame = {};
      }
      
      public function get saved() : Object
      {
         return this._saved;
      }
      
      public function resetSaved() : void
      {
         this._saved = {};
         this.commitSaved();
      }
      
      public function commitSaved() : void
      {
         Save.instance.saveObject(SAVE_KEY,this._saved);
      }
      
      public function get perRun() : Object
      {
         return this._perRun;
      }
      
      public function resetPerRun() : void
      {
         this._perRun = {};
      }
      
      public function get perSetOfPlayers() : Object
      {
         return this._perSetOfPlayers;
      }
      
      public function resetPerSetOfPlayers() : void
      {
         this._perSetOfPlayers = {};
      }
      
      public function get perGame() : Object
      {
         return this._perGame;
      }
      
      public function resetPerGame() : void
      {
         this._perGame = {};
      }
   }
}

