package jackboxgames.thewheel.gameplay
{
   public class ScoreChange
   {
      private var _amount:int;
      
      private var _multipliers:Array;
      
      public function ScoreChange()
      {
         super();
         this._amount = 0;
         this._multipliers = [];
      }
      
      public function getAmount(includeMultipliers:Boolean) : int
      {
         var t:int = this._amount;
         if(includeMultipliers)
         {
            t = Math.floor(t * this.totalMultiplier);
         }
         return t;
      }
      
      public function get totalMultiplier() : Number
      {
         var t:Number = NaN;
         t = 1;
         this._multipliers.forEach(function(sm:ScoreChangeMultiplier, ... args):void
         {
            t *= sm.val;
         });
         return t;
      }
      
      public function withAmount(amount:int) : ScoreChange
      {
         this._amount = amount;
         return this;
      }
      
      public function withMultiplier(m:ScoreChangeMultiplier) : ScoreChange
      {
         this._multipliers.push(m);
         return this;
      }
   }
}

