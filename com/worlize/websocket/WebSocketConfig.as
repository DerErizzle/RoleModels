package com.worlize.websocket
{
   public class WebSocketConfig
   {
      public var maxReceivedFrameSize:uint = 2097152;
      
      public var maxMessageSize:uint = 8388608;
      
      public var fragmentOutgoingMessages:Boolean = true;
      
      public var fragmentationThreshold:uint = 16384;
      
      public var assembleFragments:Boolean = true;
      
      public var closeTimeout:uint = 5000;
      
      public function WebSocketConfig()
      {
         super();
      }
   }
}

