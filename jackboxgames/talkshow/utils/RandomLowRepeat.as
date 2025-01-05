package jackboxgames.talkshow.utils
{
   public class RandomLowRepeat
   {
       
      
      private var _reserve:uint;
      
      private var _played:Array;
      
      private var _unplayed:Array;
      
      private var _lastFetch:int = -1;
      
      public function RandomLowRepeat(radix:uint, reservePct:Number = 10)
      {
         super();
         var reserveCount:uint = 0;
         if(reservePct >= 1)
         {
            reserveCount = Math.round(radix * reservePct / 100);
            if(reserveCount < 1)
            {
               reserveCount = reservePct > 0 ? 1 : 0;
            }
         }
         if(reserveCount >= radix)
         {
            reserveCount = uint(radix - 1);
         }
         this._reserve = reserveCount;
         this._played = new Array();
         this._unplayed = new Array();
         for(var i:uint = 0; i < radix; i++)
         {
            this._unplayed.push(i);
         }
      }
      
      public function getNextIndex() : uint
      {
         var hold:Array = null;
         if(this._lastFetch >= 0)
         {
            return this._lastFetch;
         }
         if(this._unplayed.length <= this._reserve)
         {
            if(this._unplayed.length > 0)
            {
               this._lastFetch = this._unplayed[Math.round(Math.random() * (this._unplayed.length - 1))];
            }
            hold = this._unplayed;
            this._unplayed = this._played;
            this._played = hold;
            if(this._lastFetch >= 0)
            {
               return this._lastFetch;
            }
         }
         var entry:uint = Math.round(Math.random() * (this._unplayed.length - 1));
         this._lastFetch = this._unplayed[entry];
         this._played.push(this._lastFetch);
         this._unplayed.splice(entry,1);
         return this._lastFetch;
      }
      
      public function commit() : void
      {
         this._lastFetch = -1;
      }
   }
}
