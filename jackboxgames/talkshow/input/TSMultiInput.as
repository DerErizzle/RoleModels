package jackboxgames.talkshow.input
{
   internal class TSMultiInput implements ITSInputModule
   {
      private var _requiredInput:Array;
      
      private var _inputToSend:String;
      
      private var _inputReceived:Array;
      
      public function TSMultiInput(requiredInput:Array, inputToSend:String)
      {
         super();
         this._requiredInput = requiredInput;
         this._inputToSend = inputToSend;
         this._inputReceived = [];
      }
      
      public function input(input:String) : void
      {
         var i:String = null;
         this._inputReceived.push(input);
         for each(i in this._requiredInput)
         {
            if(!ArrayUtil.arrayContainsElement(this._inputReceived,i))
            {
               return;
            }
         }
         TSUtil.safeInput(this._inputToSend);
      }
   }
}

