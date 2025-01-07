package jackboxgames.thewheel.wheel
{
   import jackboxgames.thewheel.data.SliceTypePotentialEffect;
   
   public class SpinResult
   {
      private var _chosenPotentialEffect:SliceTypePotentialEffect;
      
      private var _effect:ISliceEffect;
      
      private var _potChange:int;
      
      public function SpinResult()
      {
         super();
      }
      
      public function get chosenPotentialEffect() : SliceTypePotentialEffect
      {
         return this._chosenPotentialEffect;
      }
      
      public function set chosenPotentialEffect(val:SliceTypePotentialEffect) : void
      {
         this._chosenPotentialEffect = val;
      }
      
      public function set effect(val:ISliceEffect) : void
      {
         this._effect = val;
      }
      
      public function get effect() : ISliceEffect
      {
         return this._effect;
      }
      
      public function get potChange() : int
      {
         return this._potChange;
      }
      
      public function set potChange(val:int) : void
      {
         this._potChange = val;
      }
   }
}

