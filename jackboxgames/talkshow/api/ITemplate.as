package jackboxgames.talkshow.api
{
   import flash.events.IEventDispatcher;
   
   public interface ITemplate extends ILoadable, IEventDispatcher
   {
       
      
      function get id() : int;
      
      function get name() : String;
      
      function get handler() : ITemplateHandler;
      
      function get params() : Array;
      
      function getValue(param1:int) : *;
      
      function getCue(param1:int, param2:String) : String;
      
      function isFieldLoaded(param1:int) : Boolean;
      
      function loadField(param1:int) : void;
   }
}
