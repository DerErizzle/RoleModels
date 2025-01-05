package jackboxgames.talkshow.api
{
   public interface ILoadable
   {
       
      
      function load(param1:ILoadData = null) : void;
      
      function isLoaded() : Boolean;
      
      function get loadStatus() : int;
   }
}
