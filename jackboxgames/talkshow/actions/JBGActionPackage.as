package jackboxgames.talkshow.actions
{
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class JBGActionPackage extends SWFActionPackage
   {
      protected var _delegates:Array;
      
      public function JBGActionPackage(apRef:IActionPackageRef)
      {
         super(apRef);
         this._delegates = [];
      }
      
      public function addDelegate(d:Object) : void
      {
         this._delegates.push(d);
      }
      
      public function removeDelegate(d:Object) : void
      {
         if(this._delegates.indexOf(d) >= 0)
         {
            this._delegates.splice(this._delegates.indexOf(d),1);
         }
      }
      
      public function resetDelegates() : void
      {
         JBGUtil.reset(this._delegates);
      }
      
      public function disposeOfDelegates() : void
      {
         var d:* = undefined;
         for each(d in this._delegates)
         {
            try
            {
               d.dispose();
            }
            catch(err:Error)
            {
            }
         }
         this._delegates = [];
      }
      
      private function _callHandler(source:*, ref:IActionRef, params:Object) : Boolean
      {
         var actionName:String = "handleAction" + ref.action.name;
         if(!source.hasOwnProperty(actionName) || source[actionName] == null || !(source[actionName] is Function))
         {
            return false;
         }
         var returnVal:* = source[actionName](ref,params);
         if(returnVal !== undefined)
         {
            l["lastReturnFrom" + ref.action.name] = returnVal;
         }
         return true;
      }
      
      override public function handleAction(ref:IActionRef, params:Object) : void
      {
         var s:* = undefined;
         var sources:Array = [this];
         sources = sources.concat(this._delegates);
         for each(s in sources)
         {
            if(this._callHandler(s,ref,params))
            {
               return;
            }
         }
         trace("JBGActionPackage : " + this + " failed to handle action " + ref.action.name);
      }
   }
}

