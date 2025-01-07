package jackboxgames.entityinteraction
{
   import flash.events.IEventDispatcher;
   import jackboxgames.algorithm.Promise;
   
   public interface IEntity extends IEventDispatcher
   {
      function create() : Promise;
      
      function dispose() : Promise;
      
      function update(param1:*) : Promise;
   }
}

