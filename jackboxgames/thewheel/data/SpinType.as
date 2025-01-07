package jackboxgames.thewheel.data
{
   import com.greensock.easing.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.animation.tween.*;
   import jackboxgames.utils.*;
   
   public class SpinType implements IJsonData
   {
      private var _data:Object;
      
      private var _ease:Ease;
      
      public function SpinType()
      {
         super();
      }
      
      public function load(data:Object) : Promise
      {
         this._data = data;
         this._ease = new CustomEase2(this._data.id,this._data.customEaseData,null);
         return PromiseUtil.RESOLVED();
      }
      
      public function get id() : String
      {
         return this._data.id;
      }
      
      public function get category() : String
      {
         return this._data.category;
      }
      
      public function get minPower() : Number
      {
         return this._data.minPower;
      }
      
      public function get maxPower() : Number
      {
         return this._data.maxPower;
      }
      
      public function get duration() : Duration
      {
         return Duration.fromSec(this._data.durationInSec);
      }
      
      public function get ease() : Ease
      {
         return this._ease;
      }
      
      public function get minSpin() : int
      {
         return this._data.minSpin;
      }
      
      public function get maxSpin() : int
      {
         return this._data.maxSpin;
      }
   }
}

