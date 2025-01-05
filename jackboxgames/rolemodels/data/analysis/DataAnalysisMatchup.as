package jackboxgames.rolemodels.data.analysis
{
   import jackboxgames.rolemodels.Player;
   
   public class DataAnalysisMatchup
   {
       
      
      private var _p1:Player;
      
      private var _p2:Player;
      
      private var _rolesAndTags:Array;
      
      public function DataAnalysisMatchup(p1:Player, p2:Player, rolesAndTags:Array)
      {
         super();
         this._p1 = p1;
         this._p2 = p2;
         this._rolesAndTags = rolesAndTags;
      }
      
      public function get p1() : Player
      {
         return this._p1;
      }
      
      public function get p2() : Player
      {
         return this._p2;
      }
      
      public function get rolesAndTags() : Array
      {
         return this._rolesAndTags;
      }
      
      public function set rolesAndTags(val:Array) : void
      {
         this._rolesAndTags = val;
      }
   }
}
