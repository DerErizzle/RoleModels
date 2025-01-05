package jackboxgames.audio
{
   public class JBGCrossFader
   {
       
      
      private var _soundA:JBGSound;
      
      private var _soundB:JBGSound;
      
      private var _initialVolumeForA:Number;
      
      private var _targetVolumeForB:Number;
      
      private var _fadeAmount:Number;
      
      public function JBGCrossFader(soundA:JBGSound, soundB:JBGSound, targetVolume:Number)
      {
         super();
         this._soundA = soundA;
         this._soundB = soundB;
         this._initialVolumeForA = Boolean(this._soundA) ? this._soundA.volume : 0;
         this._targetVolumeForB = targetVolume;
         this._fadeAmount = 0;
      }
      
      public function get fadeAmount() : Number
      {
         return this._fadeAmount;
      }
      
      public function set fadeAmount(val:Number) : void
      {
         this._fadeAmount = Math.min(Math.max(0,val),1);
         if(Boolean(this._soundA))
         {
            this._soundA.volume = (1 - this._fadeAmount) * this._initialVolumeForA;
         }
         if(Boolean(this._soundB))
         {
            this._soundB.volume = this._fadeAmount * this._targetVolumeForB;
         }
      }
   }
}
