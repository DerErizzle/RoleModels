package jackboxgames.talkshow.input
{
   import jackboxgames.utils.TSUtil;
   
   internal class TSSingleInput implements ITSInputModule
   {
       
      
      private var _hasReceivedInput:Boolean;
      
      public function TSSingleInput()
      {
         super();
         this._hasReceivedInput = false;
      }
      
      public function input(input:String) : void
      {
         if(!this._hasReceivedInput)
         {
            this._hasReceivedInput = true;
            TSUtil.safeInput(input);
         }
         else
         {
            trace("Received input : " + input + ", but ignored it!");
         }
      }
   }
}
