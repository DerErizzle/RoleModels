package jackboxgames.rolemodels.model
{
   public class Ellipse
   {
       
      
      private var _centerH:Number;
      
      private var _centerK:Number;
      
      private var _horizontalRadius:Number;
      
      private var _verticalRadius:Number;
      
      public function Ellipse(centerH:Number, centerK:Number, horizontalRadius:Number, verticalRadius:Number)
      {
         super();
         this._centerH = centerH;
         this._centerK = centerK;
         this._horizontalRadius = horizontalRadius;
         this._verticalRadius = verticalRadius;
      }
      
      public function isPointInside(x:Number, y:Number) : Boolean
      {
         var xComponent:Number = Math.pow(x - this._centerH,2) / Math.pow(this._horizontalRadius,2);
         var yComponent:Number = Math.pow(y - this._centerK,2) / Math.pow(this._verticalRadius,2);
         return xComponent + yComponent <= 1;
      }
      
      public function findXOnEllipse(x:Number, y:Number) : Number
      {
         var yComponent:Number = Math.pow(y - this._centerK,2) / Math.pow(this._verticalRadius,2);
         var modifier:Number = x < this._centerH ? -1 : 1;
         return modifier * Math.sqrt((1 - yComponent) * Math.pow(this._horizontalRadius,2)) + this._centerH;
      }
      
      public function findYOnEllipse(x:Number, y:Number) : Number
      {
         var xComponent:Number = Math.pow(x - this._centerH,2) / Math.pow(this._horizontalRadius,2);
         var modifier:Number = y < this._centerK ? -1 : 1;
         return modifier * Math.sqrt((1 - xComponent) * Math.pow(this._verticalRadius,2)) + this._centerK;
      }
   }
}
