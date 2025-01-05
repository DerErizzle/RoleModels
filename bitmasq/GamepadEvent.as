package bitmasq
{
   import flash.events.Event;
   
   public class GamepadEvent extends Event
   {
      
      public static const CHANGE:String = "change";
      
      public static const DEVICE_ADDED:String = "device_added";
      
      public static const DEVICE_REMOVED:String = "device_removed";
       
      
      public var control:Number;
      
      public var value:Number;
      
      public var device:Object;
      
      public var deviceIndex:Number;
      
      public function GamepadEvent(type:String, _control:Number, _value:Number, _device:Object, _deviceIndex:Number)
      {
         super(type,true,false);
         this.control = _control;
         this.value = _value;
         this.device = _device;
         this.deviceIndex = _deviceIndex;
      }
      
      override public function clone() : Event
      {
         return new GamepadEvent(type,this.control,this.value,this.device,this.deviceIndex);
      }
   }
}
