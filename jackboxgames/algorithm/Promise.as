package jackboxgames.algorithm
{
   public class Promise
   {
      private var _state:PromiseState;
      
      private var _consequences:Array;
      
      private var _parameterValue:*;
      
      private var _completionValue:*;
      
      public function Promise()
      {
         super();
         this._state = PromiseState.PENDING;
         this._consequences = [];
         this._parameterValue = undefined;
         this._completionValue = undefined;
      }
      
      public function then(onFulfilled:Function = null, onRejected:Function = null) : Promise
      {
         var consequence:Consequence = new Consequence(onFulfilled,onRejected);
         if(this._state != PromiseState.PENDING)
         {
            this._trigger(consequence,this._state,this._parameterValue);
         }
         else
         {
            this._consequences.push(consequence);
         }
         return consequence.promise;
      }
      
      public function otherwise(onRejected:Function = null) : Promise
      {
         return this.then(null,onRejected);
      }
      
      public function resolve(value:*) : void
      {
         if(this._state == PromiseState.PENDING)
         {
            if(value is Promise)
            {
               value.then(this.resolve,this.reject);
            }
            else
            {
               this._complete(PromiseState.FULFILLED,value);
            }
         }
      }
      
      public function reject(value:*) : void
      {
         if(this._state == PromiseState.PENDING)
         {
            this._complete(PromiseState.REJECTED,value);
         }
      }
      
      private function _trigger(consequence:Consequence, result:PromiseState, value:*) : void
      {
         switch(result)
         {
            case PromiseState.FULFILLED:
               this._callResultFunction(consequence.promise,consequence.onFullfilled,value);
               break;
            case PromiseState.REJECTED:
               this._callResultFunction(consequence.promise,consequence.onRejected,value);
         }
      }
      
      private function _callResultFunction(thenPromise:Promise, resultFunction:Function, value:*) : void
      {
         var returnPromise:Promise = null;
         try
         {
            this._completionValue = resultFunction.call(null,value);
         }
         catch(error:*)
         {
            thenPromise.reject(error);
            return;
         }
         if(this._completionValue is Promise)
         {
            returnPromise = this._completionValue as Promise;
            if(returnPromise._state == PromiseState.FULFILLED)
            {
               thenPromise.resolve(returnPromise._completionValue);
            }
            else if(returnPromise._state == PromiseState.REJECTED)
            {
               thenPromise.reject(returnPromise._completionValue);
            }
            else
            {
               returnPromise.then(thenPromise.resolve,thenPromise.reject);
            }
         }
         else
         {
            thenPromise.resolve(this._completionValue);
         }
      }
      
      private function _complete(result:PromiseState, value:*) : void
      {
         var consequence:Consequence = null;
         this._state = result;
         this._parameterValue = value;
         if(this._consequences.length == 0 && this._state == PromiseState.REJECTED)
         {
            throw this._parameterValue;
         }
         for each(consequence in this._consequences)
         {
            this._trigger(consequence,this._state,this._parameterValue);
         }
         this._consequences = [];
      }
   }
}

class Consequence
{
   private var _onFulfilled:Function;
   
   private var _onRejected:Function;
   
   private var _promise:Promise;
   
   public function Consequence(onFulfilled:Function, onRejected:Function)
   {
      super();
      this._onFulfilled = onFulfilled != null ? onFulfilled : identity;
      this._onRejected = onRejected != null ? onRejected : thrower;
      this._promise = new Promise();
   }
   
   private static function identity(arg:*) : *
   {
      return arg;
   }
   
   private static function thrower(error:*) : void
   {
      throw error;
   }
   
   public function get onFullfilled() : Function
   {
      return this._onFulfilled;
   }
   
   public function get onRejected() : Function
   {
      return this._onRejected;
   }
   
   public function get promise() : Promise
   {
      return this._promise;
   }
}

class PromiseState
{
   public static const FULFILLED:PromiseState = new PromiseState();
   
   public static const REJECTED:PromiseState = new PromiseState();
   
   public static const PENDING:PromiseState = new PromiseState();
   
   private static var _enumLoaded:Boolean = false;
   
   _enumLoaded = true;
   
   public function PromiseState()
   {
      super();
      if(_enumLoaded)
      {
         throw new Error("PromiseState is already defined.");
      }
   }
}

