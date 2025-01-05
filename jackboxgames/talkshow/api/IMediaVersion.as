package jackboxgames.talkshow.api
{
   public interface IMediaVersion
   {
       
      
      function get idx() : uint;
      
      function get id() : int;
      
      function get locale() : String;
      
      function get tag() : String;
      
      function get text() : String;
      
      function get metadata() : Object;
   }
}
