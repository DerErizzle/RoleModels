package jackboxgames.thewheel.gameplay
{
   public class ETappingListValue
   {
      public static const NONE:ETappingListValue = new ETappingListValue();
      
      public static const TRUE:ETappingListValue = new ETappingListValue();
      
      public static const FALSE:ETappingListValue = new ETappingListValue();
      
      private static var _enumCreated:Boolean = false;
      
      _enumCreated = true;
      
      public function ETappingListValue()
      {
         super();
         if(_enumCreated)
         {
            throw new Error("The Enum is already defined.");
         }
      }
   }
}

