package jackboxgames.services
{
   import flash.system.Security;
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   
   public class RestAPI
   {
      private var _apiUrl:String;
      
      private var _autoSerialize:Boolean = true;
      
      public function RestAPI(domain:String, protocol:String = "https://", autoSerialzie:Boolean = true)
      {
         super();
         this._apiUrl = domain.indexOf("http") < 0 ? protocol + domain : domain;
         Security.loadPolicyFile(this._apiUrl + "/crossdomain.xml");
         this._autoSerialize = autoSerialzie;
      }
      
      public function GET(location:String, outgoingData:*, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return JBGLoader.instance.getRequest(this._apiUrl + location,outgoingData,function(result:Object):void
         {
            if(callback != null)
            {
               callback(Boolean(result.success) ? getData(result.data) : result);
            }
         },additionalHeaders);
      }
      
      public function POST(location:String, outgoingData:*, outgoingDataFormat:String, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return JBGLoader.instance.postRequest(this._apiUrl + location,outgoingData,outgoingDataFormat,function(result:Object):void
         {
            if(callback != null)
            {
               callback(Boolean(result.success) ? getData(result.data) : result);
            }
         },additionalHeaders);
      }
      
      public function PUT(location:String, outgoingData:*, outgoingDataFormat:String, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return JBGLoader.instance.putRequest(this._apiUrl + location,outgoingData,outgoingDataFormat,function(result:Object):void
         {
            if(callback != null)
            {
               callback(Boolean(result.success) ? getData(result.data) : result);
            }
         },additionalHeaders);
      }
      
      public function DELETE(location:String, outgoingData:*, outgoingDataFormat:String, callback:Function = null, additionalHeaders:Array = null) : ILoader
      {
         return JBGLoader.instance.deleteRequest(this._apiUrl + location,outgoingData,outgoingDataFormat,function(result:Object):void
         {
            if(callback != null)
            {
               callback(Boolean(result.success) ? getData(result.data) : result);
            }
         },additionalHeaders);
      }
      
      private function getData(data:*) : *
      {
         if(this._autoSerialize)
         {
            return JSON.deserialize(data);
         }
         return data;
      }
   }
}

