package jackboxgames.userinput
{
   import jackboxgames.utils.ArrayUtil;
   
   public class UserInputUtil
   {
      public function UserInputUtil()
      {
         super();
      }
      
      public static function inputsContain(inputs:Array, toFind:*) : Boolean
      {
         return ArrayUtil.arrayContainsOneOf(inputs,ArrayUtil.makeArrayIfNecessary(toFind));
      }
   }
}

