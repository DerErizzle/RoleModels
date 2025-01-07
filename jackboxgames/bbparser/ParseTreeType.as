package jackboxgames.bbparser
{
   public class ParseTreeType
   {
      public static const ROOT:ParseTreeType = new ParseTreeType();
      
      public static const TEXT:ParseTreeType = new ParseTreeType();
      
      public static const TAG:ParseTreeType = new ParseTreeType();
      
      private static var _enumCreated:Boolean = false;
      
      _enumCreated = true;
      
      public function ParseTreeType()
      {
         super();
         if(_enumCreated)
         {
            throw new Error("Parse Tree Type is already defined!!!!");
         }
      }
   }
}

