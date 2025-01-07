package jackboxgames.thewheel.gameplay
{
   public class ScoreChangeMultiplier
   {
      private var _val:Number;
      
      public function ScoreChangeMultiplier(val:Number)
      {
         super();
         this._val = val;
      }
      
      public function get val() : Number
      {
         return this._val;
      }
   }
}

