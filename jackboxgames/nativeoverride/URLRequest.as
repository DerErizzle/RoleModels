package jackboxgames.nativeoverride
{
   import flash.net.URLRequestMethod;
   
   public class URLRequest
   {
      private var mURL:String;
      
      private var mMethod:String;
      
      private var mRequestHeaders:Array;
      
      private var mData:Object;
      
      private var mFatal:Boolean;
      
      public function URLRequest(url:String)
      {
         super();
         this.mURL = url;
         this.mMethod = URLRequestMethod.GET;
         this.mRequestHeaders = [];
         this.mData = null;
         this.mFatal = true;
      }
      
      public function set url(value:String) : void
      {
         this.mURL = value;
      }
      
      public function get url() : String
      {
         return this.mURL;
      }
      
      public function set method(value:String) : void
      {
         this.mMethod = value;
      }
      
      public function get method() : String
      {
         return this.mMethod;
      }
      
      public function get requestHeaders() : Array
      {
         return this.mRequestHeaders;
      }
      
      public function set requestHeaders(value:Array) : void
      {
         this.mRequestHeaders = value;
      }
      
      public function set data(value:Object) : void
      {
         this.mData = value;
      }
      
      public function get data() : Object
      {
         return this.mData;
      }
      
      public function get fatal() : Boolean
      {
         return this.mFatal;
      }
      
      public function set fatal(value:Boolean) : void
      {
         this.mFatal = value;
      }
   }
}

