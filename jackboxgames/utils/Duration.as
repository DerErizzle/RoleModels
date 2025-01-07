package jackboxgames.utils
{
   public class Duration
   {
      private var _tInMs:Number;
      
      public function Duration(tInMs:Number)
      {
         super();
         this._tInMs = tInMs;
      }
      
      public static function get ZERO() : Duration
      {
         return fromMs(0);
      }
      
      public static function fromSec(tInSec:Number) : Duration
      {
         return new Duration(tInSec * 1000);
      }
      
      public static function fromMs(tInMs:Number) : Duration
      {
         return new Duration(tInMs);
      }
      
      public static function add(a:Duration, b:Duration) : Duration
      {
         var res:Duration = a.clone();
         res.add(b);
         return res;
      }
      
      public static function sub(a:Duration, b:Duration) : Duration
      {
         var res:Duration = a.clone();
         res.sub(b);
         return res;
      }
      
      public static function scale(a:Duration, s:Number) : Duration
      {
         var res:Duration = a.clone();
         res.scale(s);
         return res;
      }
      
      public static function ratio(a:Duration, b:Duration) : Number
      {
         return a.inMs / b.inMs;
      }
      
      public static function between(a:Duration, b:Duration) : Duration
      {
         if(a.isGreaterThan(b))
         {
            return a;
         }
         return Duration.fromMs(a.inMs + Math.floor(Random.instance.nextRandomNumber() * Number(b.inMs - a.inMs)));
      }
      
      public static function max(a:Duration, b:Duration) : Duration
      {
         return b.isGreaterThan(a) ? b : a;
      }
      
      public static function min(a:Duration, b:Duration) : Duration
      {
         return b.isLessThan(a) ? b : a;
      }
      
      public function clone() : Duration
      {
         return new Duration(this._tInMs);
      }
      
      public function get inSec() : Number
      {
         return this._tInMs / 1000;
      }
      
      public function get inMs() : Number
      {
         return this._tInMs;
      }
      
      public function add(d:Duration) : Duration
      {
         this._tInMs += d.inMs;
         return this;
      }
      
      public function sub(d:Duration) : Duration
      {
         this._tInMs -= d.inMs;
         return this;
      }
      
      public function scale(s:Number) : Duration
      {
         this._tInMs *= s;
         return this;
      }
      
      public function isEqualTo(d:Duration) : Boolean
      {
         return this.inMs == d.inMs;
      }
      
      public function isLessThan(d:Duration) : Boolean
      {
         return this.inMs < d.inMs;
      }
      
      public function isGreaterThan(d:Duration) : Boolean
      {
         return this.inMs > d.inMs;
      }
      
      public function isLessThanOrEqualTo(d:Duration) : Boolean
      {
         return this.inMs <= d.inMs;
      }
      
      public function isGreaterThanOrEqualTo(d:Duration) : Boolean
      {
         return this.inMs >= d.inMs;
      }
   }
}

