package jackboxgames.talkshow.input
{
   import jackboxgames.utils.TSUtil;
   
   internal class TSAnyInput implements ITSInputModule
   {
       
      
      public function TSAnyInput()
      {
         super();
      }
      
      public function input(input:String) : void
      {
         TSUtil.safeInput(input);
      }
   }
}
