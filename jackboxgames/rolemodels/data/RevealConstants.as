package jackboxgames.rolemodels.data
{
   public class RevealConstants
   {
      
      public static const REVEAL_DATA_TYPES:Object = {
         "majority":"Majority",
         "tie":"Tiebreaker",
         "justPlaying":"JustPlaying"
      };
      
      private static const REVEAL_BASE_KEYS:Array = ["name","felocity","type","choosable","requiresContent","maximumPerRound","pointsForWinningTie","pointsForWinningTieSelf","pointsForDoublingDown","pointsForDoublingDownSelf","minPlayers","maxPlayers"];
       
      
      private var _data:Object;
      
      public function RevealConstants(data:Object)
      {
         super();
         this._data = data;
      }
      
      public function getProperty(baseKey:String) : *
      {
         if(this._data.hasOwnProperty(baseKey))
         {
            return this._data[baseKey];
         }
         return this._getDefaultValue(baseKey);
      }
      
      private function _getDefaultValue(baseKey:String) : *
      {
         switch(baseKey)
         {
            case "name":
               return null;
            case "felocity":
               return 0;
            case "type":
               return null;
            case "choosable":
               return false;
            case "requiresContent":
               return false;
            case "maximumPerRound":
               return 10;
            case "pointsForWinningTie":
               return 3;
            case "pointsForWinningTieSelf":
               return 4;
            case "pointsForDoublingDown":
               return 1;
            case "pointsForDoublingDownSelf":
               return 2;
            case "minPlayers":
               return 2;
            case "maxPlayers":
               return 3;
            default:
               return undefined;
         }
      }
      
      public function get name() : String
      {
         return this.getProperty("name");
      }
      
      public function get felocity() : int
      {
         return this.getProperty("felocity");
      }
      
      public function get choosable() : Boolean
      {
         return this.getProperty("choosable");
      }
      
      public function get type() : String
      {
         return this.getProperty("type");
      }
      
      public function get requiresContent() : Boolean
      {
         return this.getProperty("requiresContent");
      }
      
      public function get maximumPerRound() : int
      {
         return this.getProperty("maximumPerRound");
      }
      
      public function get pointsForWinningTie() : int
      {
         return this.getProperty("pointsForWinningTie");
      }
      
      public function get pointsForWinningTieSelf() : int
      {
         return this.getProperty("pointsForWinningTieSelf");
      }
      
      public function get pointsForDoublingDown() : int
      {
         return this.getProperty("pointsForDoublingDown");
      }
      
      public function get pointsForDoublingDownSelf() : int
      {
         return this.getProperty("pointsForDoublingDownSelf");
      }
      
      public function get minPlayers() : int
      {
         return this.getProperty("minPlayers");
      }
      
      public function get maxPlayers() : int
      {
         return this.getProperty("maxPlayers");
      }
   }
}
