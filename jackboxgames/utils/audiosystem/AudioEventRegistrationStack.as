package jackboxgames.utils.audiosystem
{
   import jackboxgames.utils.*;
   
   public class AudioEventRegistrationStack
   {
       
      
      private var _stack:Array;
      
      public function AudioEventRegistrationStack()
      {
         super();
         this._stack = [];
      }
      
      public function reset() : void
      {
         this._popAll();
      }
      
      private function _popAll() : void
      {
         while(this._stack.length > 0)
         {
            this.pop(Nullable.NULL_FUNCTION);
         }
      }
      
      public function push(keysDictionary:Object, completeFn:Function) : void
      {
         var frame:AudioSystemEventCollection = new AudioSystemEventCollection(keysDictionary);
         this._stack.push(frame);
         frame.setLoaded(true,completeFn);
      }
      
      public function pop(completeFn:Function) : void
      {
         Assert.assert(this._stack.length > 0);
         var frame:AudioSystemEventCollection = this._stack.pop();
         frame.dispose();
         completeFn(true);
      }
      
      public function play(key:String, doneFn:Function = null) : void
      {
         var audioIsDoneFn:Function = null;
         var keyWasFound:Boolean = false;
         for(var i:int = this._stack.length - 1; i >= 0; i--)
         {
            if(Boolean(this._stack[i].hasAudio(key)))
            {
               this._stack[i].play(key,doneFn);
               keyWasFound = true;
               break;
            }
         }
         if(!keyWasFound)
         {
            audioIsDoneFn = Nullable.convertToNullableIfNecessary(doneFn,Function);
            audioIsDoneFn();
         }
      }
      
      public function stop(key:String) : void
      {
         for(var i:int = this._stack.length - 1; i >= 0; i--)
         {
            if(Boolean(this._stack[i].hasAudio(key)))
            {
               this._stack[i].stop(key);
               break;
            }
         }
      }
   }
}
