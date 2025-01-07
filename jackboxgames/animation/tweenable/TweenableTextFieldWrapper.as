package jackboxgames.animation.tweenable
{
   public class TweenableTextFieldWrapper
   {
      private var _tf:*;
      
      private var _num:Number;
      
      private var _formatter:Function;
      
      public function TweenableTextFieldWrapper(tf:*, formatter:Function = null, startingNum:Number = 0)
      {
         super();
         this._tf = tf;
         this._formatter = formatter != null ? formatter : function(num:Number):String
         {
            return String(Math.floor(num));
         };
         this.num = startingNum;
      }
      
      public function get num() : Number
      {
         return this._num;
      }
      
      public function set num(val:Number) : void
      {
         this._num = val;
         this._tf.text = this._formatter(this._num);
      }
   }
}

