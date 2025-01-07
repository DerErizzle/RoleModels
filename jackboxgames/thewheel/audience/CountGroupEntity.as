package jackboxgames.thewheel.audience
{
   import jackboxgames.algorithm.*;
   import jackboxgames.ecast.*;
   import jackboxgames.ecast.messages.*;
   import jackboxgames.entityinteraction.*;
   import jackboxgames.utils.*;
   
   public class CountGroupEntity extends PausableEventDispatcher implements IEntity, IEntityPollerDelegate
   {
      private var _ws:WSClient;
      
      private var _poller:EntityPoller;
      
      private var _name:String;
      
      private var _choices:Array;
      
      private var _counts:Object;
      
      public function CountGroupEntity(ws:WSClient, pollDuration:Duration, name:String, choices:Array)
      {
         super();
         this._ws = ws;
         this._poller = new EntityPoller(this,pollDuration);
         this._name = name;
         this._choices = choices;
      }
      
      public function get counts() : Object
      {
         return this._counts;
      }
      
      public function create() : Promise
      {
         this._counts = {};
         this._choices.forEach(function(c:String, ... args):void
         {
            _counts[c] = 0;
         });
         return this._ws.createCountGroup(this._name,this._choices).then(function(... args):void
         {
            _poller.setIsPolling(true);
         },function(... args):void
         {
            trace("uh oh!");
         });
      }
      
      public function dispose() : Promise
      {
         this._poller.setIsPolling(false);
         return PromiseUtil.RESOLVED(true);
      }
      
      public function update(val:*) : Promise
      {
         return PromiseUtil.RESOLVED();
      }
      
      public function poll() : Promise
      {
         return this._ws.getCountGroup(this._name);
      }
      
      public function onPollReply(re:Reply) : void
      {
         var previous:Object = this._counts;
         this._counts = re.result.choices;
         dispatchEvent(new EntityUpdatedEvent(previous,this._counts));
      }
   }
}

