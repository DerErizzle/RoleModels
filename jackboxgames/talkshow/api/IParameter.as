package jackboxgames.talkshow.api
{
   public interface IParameter
   {
       
      
      function get name() : String;
      
      function get type() : String;
      
      function isMedia() : Boolean;
      
      function isLoadableMedia() : Boolean;
   }
}
