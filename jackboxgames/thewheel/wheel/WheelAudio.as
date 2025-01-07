package jackboxgames.thewheel.wheel
{
   import jackboxgames.events.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.utils.*;
   
   public class WheelAudio
   {
      private static const SMOOTHING_VALUE:Number = 0.7;
      
      private static const MAX_DISTANCE_PER_SECOND:Number = 10000;
      
      private var _spinEventName:String;
      
      private var _tickEventName:String;
      
      private var _wheel:Wheel;
      
      private var _isLoaded:Boolean;
      
      private var _isActive:Boolean;
      
      private var _spinEvent:AudioEvent;
      
      private var _tickEvent:AudioEvent;
      
      private var _prevSpin:Number;
      
      private var _prevSlice:Slice;
      
      private var _smoothDistancePerSecond:Number;
      
      public function WheelAudio(spinEventName:String, tickEventName:String, supportsLow:Boolean)
      {
         super();
         this._spinEventName = spinEventName;
         this._tickEventName = tickEventName;
         if(supportsLow && (Platform.instance.PlatformFidelity == Platform.PLATFORM_FIDELITY_LOW || Platform.instance.PlatformIdUpperCase == "NX"))
         {
            this._spinEventName += "_low";
            this._tickEventName += "_low";
         }
      }
      
      public function reset() : void
      {
         this.setActive(false);
         this.setLoaded(false,Nullable.NULL_FUNCTION);
         this._wheel = null;
      }
      
      public function setup(w:Wheel) : void
      {
         this._wheel = w;
      }
      
      public function setLoaded(isLoaded:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         if(this._isLoaded == isLoaded)
         {
            doneFn();
            return;
         }
         this._isLoaded = isLoaded;
         if(this._isLoaded)
         {
            c = new Counter(2,doneFn);
            this._spinEvent = AudioSystem.instance.createEventFromName(this._spinEventName);
            this._spinEvent.load(c.generateDoneFn());
            this._tickEvent = AudioSystem.instance.createEventFromName(this._tickEventName);
            this._tickEvent.load(c.generateDoneFn());
         }
         else
         {
            this._spinEvent.dispose();
            this._spinEvent = null;
            this._tickEvent.dispose();
            this._tickEvent = null;
            doneFn();
         }
      }
      
      public function setActive(isActive:Boolean) : void
      {
         if(this._isActive == isActive)
         {
            return;
         }
         this._isActive = isActive;
         if(this._isActive)
         {
            this._prevSpin = 0;
            this._prevSlice = this._wheel.getSliceAtFlapper();
            this._smoothDistancePerSecond = 0;
            this._spinEvent.play();
            TickManager.instance.addEventListener(TickManager.EVENT_TICK,this._onTick);
         }
         else
         {
            TickManager.instance.removeEventListener(TickManager.EVENT_TICK,this._onTick);
            this._spinEvent.stop();
            this._tickEvent.stop();
         }
      }
      
      private function _onTick(evt:EventWithData) : void
      {
         var currentSpin:Number = this._wheel.spin;
         var currentSlice:Slice = this._wheel.getSliceAtFlapper();
         var distance:Number = this._wheel.spin - this._prevSpin;
         var distancePerSecond:Number = distance / evt.data.elapsed.inSec;
         this._smoothDistancePerSecond = this._smoothDistancePerSecond * SMOOTHING_VALUE + distancePerSecond * (1 - SMOOTHING_VALUE);
         var ratio:Number = this._smoothDistancePerSecond / MAX_DISTANCE_PER_SECOND;
         ratio = Math.min(ratio,1);
         var pct:Number = ratio * 100;
         trace("Setting spinRate to: " + pct);
         AudioSystem.instance.setGlobalParameterValue("spinRate",pct);
         if(currentSlice != this._prevSlice)
         {
            this._tickEvent.play();
         }
         this._prevSpin = currentSpin;
         this._prevSlice = currentSlice;
      }
   }
}

