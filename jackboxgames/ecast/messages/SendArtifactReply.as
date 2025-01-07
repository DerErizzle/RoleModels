package jackboxgames.ecast.messages
{
   import jackboxgames.utils.IToSimpleObject;
   
   public class SendArtifactReply implements IToSimpleObject
   {
      private var _rootId:String;
      
      private var _categoryId:String;
      
      private var _artifactId:String;
      
      public function SendArtifactReply(rootId:String, categoryId:String, artifactId:String)
      {
         super();
         this._rootId = rootId;
         this._categoryId = categoryId;
         this._artifactId = artifactId;
      }
      
      public function get rootId() : String
      {
         return this._rootId;
      }
      
      public function get categoryId() : String
      {
         return this._categoryId;
      }
      
      public function get artifactId() : String
      {
         return this._artifactId;
      }
      
      public function toSimpleObject() : Object
      {
         return {
            "artifactId":this._artifactId,
            "categoryId":this._categoryId,
            "rootId":this._rootId
         };
      }
   }
}

