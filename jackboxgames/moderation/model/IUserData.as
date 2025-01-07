package jackboxgames.moderation.model
{
   public interface IUserData
   {
      function get id() : int;
      
      function set id(param1:int) : void;
      
      function get type() : String;
      
      function get from() : int;
      
      function get context() : *;
      
      function get data() : *;
      
      function get moderationKey() : String;
      
      function get moderationStatus() : String;
      
      function set moderationStatus(param1:String) : void;
      
      function get dataType() : String;
   }
}

