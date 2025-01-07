package jackboxgames.talkshow.api
{
   public interface ILoadData
   {
      function get level() : uint;
      
      function decrement() : void;
      
      function add(param1:ILoadable) : Boolean;
      
      function remove(param1:ILoadable) : void;
      
      function get volatile() : Boolean;
      
      function set volatile(param1:Boolean) : void;
      
      function clone() : ILoadData;
   }
}

