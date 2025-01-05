package jackboxgames.rolemodels.data.analysis
{
   import jackboxgames.rolemodels.data.TagData;
   
   public class TagPair
   {
       
      
      private var _tag1:TagData;
      
      private var _tag2:TagData;
      
      public function TagPair(tag1:TagData, tag2:TagData)
      {
         super();
         this._tag1 = tag1;
         this._tag2 = tag2;
      }
      
      public function get tag1() : TagData
      {
         return this._tag1;
      }
      
      public function get tag2() : TagData
      {
         return this._tag2;
      }
   }
}
