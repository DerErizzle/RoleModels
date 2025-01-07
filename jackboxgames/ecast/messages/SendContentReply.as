package jackboxgames.ecast.messages
{
   import jackboxgames.utils.*;
   
   public class SendContentReply implements IToSimpleObject
   {
      private var _categoryId:String;
      
      private var _contentId:String;
      
      private var _result:Object;
      
      public function SendContentReply(result:Object)
      {
         super();
         this._result = result;
      }
      
      public function get categoryId() : String
      {
         return this._result.categoryId;
      }
      
      public function get contentId() : String
      {
         return this._result.contentId;
      }
      
      public function get result() : Object
      {
         return this._result;
      }
      
      public function toSimpleObject() : Object
      {
         return {"result":this._result};
      }
   }
}

