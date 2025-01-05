package jackboxgames.talkshow.api
{
   import flash.events.IEventDispatcher;
   
   public interface ITemplateHandler extends IEventDispatcher
   {
       
      
      function init(param1:IEngineAPI) : void;
      
      function loadRecord(param1:Object) : void;
      
      function isRecordLoaded(param1:Object) : Boolean;
      
      function setActiveRecord(param1:Object) : void;
      
      function getValue(param1:String) : *;
      
      function getCue(param1:String, param2:String) : String;
      
      function loadField(param1:String) : void;
      
      function isFieldLoaded(param1:String) : Boolean;
   }
}
