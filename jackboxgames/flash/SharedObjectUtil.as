package jackboxgames.flash
{
   import flash.errors.IllegalOperationError;
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import flash.net.SharedObjectFlushStatus;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class SharedObjectUtil extends PausableEventDispatcher
   {
      protected static var _instance:SharedObjectUtil;
      
      protected static const INSTANCE_ERROR_MSG:String = "class SharedObjectUtil is a singleton.  new instances may not be created using the \'new\' keyword";
      
      public function SharedObjectUtil(e:SharedObjectUtilEnforcer)
      {
         super();
         if(e == null || !(e is SharedObjectUtilEnforcer))
         {
            throw new IllegalOperationError(INSTANCE_ERROR_MSG);
         }
      }
      
      public static function get instance() : SharedObjectUtil
      {
         return Boolean(_instance) ? _instance : (_instance = new SharedObjectUtil(new SharedObjectUtilEnforcer()));
      }
      
      public function getData(id:String) : Object
      {
         var sharedObj:SharedObject = null;
         var data:Object = {};
         try
         {
            sharedObj = SharedObject.getLocal(id);
            data = sharedObj.data;
         }
         catch(err:Error)
         {
            data = {};
         }
         return data;
      }
      
      public function writeData(id:String, data:Object) : void
      {
         var sharedObj:SharedObject = null;
         var varName:String = null;
         var flushStatus:String = null;
         try
         {
            sharedObj = SharedObject.getLocal(id);
            for(varName in data)
            {
               sharedObj.data[varName] = data[varName];
            }
            flushStatus = sharedObj.flush();
            switch(flushStatus)
            {
               case SharedObjectFlushStatus.FLUSHED:
                  break;
               case SharedObjectFlushStatus.PENDING:
               default:
                  sharedObj.addEventListener(NetStatusEvent.NET_STATUS,this.flushStatusCallback);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      public function clearData(id:String) : void
      {
         var sharedObj:SharedObject = null;
         try
         {
            sharedObj = SharedObject.getLocal(id);
            sharedObj.clear();
            sharedObj.flush();
         }
         catch(err:Error)
         {
         }
      }
      
      protected function flushStatusCallback(evt:NetStatusEvent) : void
      {
         try
         {
            switch(evt.info.code)
            {
               case "SharedObject.Flush.Success":
                  break;
               case "SharedObject.Flush.Failed":
            }
            evt.target.removeEventListener(NetStatusEvent.NET_STATUS,this.flushStatusCallback);
         }
         catch(err:Error)
         {
         }
      }
   }
}

final class SharedObjectUtilEnforcer
{
   public function SharedObjectUtilEnforcer()
   {
      super();
   }
}

