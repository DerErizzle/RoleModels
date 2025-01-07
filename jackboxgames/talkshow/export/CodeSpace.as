package jackboxgames.talkshow.export
{
   import jackboxgames.talkshow.api.ICodeSpace;
   
   public class CodeSpace implements ICodeSpace
   {
      private var _g:Object;
      
      private var _l:Object;
      
      public function CodeSpace()
      {
         super();
         this._g = new Object();
         this._l = new Object();
      }
      
      public function get g() : Object
      {
         return null;
      }
      
      public function get l() : Object
      {
         return null;
      }
   }
}

