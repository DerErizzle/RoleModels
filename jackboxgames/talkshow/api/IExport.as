package jackboxgames.talkshow.api
{
   import flash.events.IEventDispatcher;
   import jackboxgames.talkshow.media.AbstractMedia;
   
   public interface IExport extends ICodeSpace, IEventDispatcher, ILoadable
   {
      function getAllProjects() : Array;
      
      function getFlowchart(param1:*) : IFlowchart;
      
      function getMedia(param1:int) : IMedia;
      
      function getAction(param1:int) : IAction;
      
      function getActionPackage(param1:*) : IActionPackageRef;
      
      function getTemplate(param1:*) : ITemplate;
      
      function getTemplateByName(param1:String) : ITemplate;
      
      function get id() : String;
      
      function get configInfo() : IConfigInfo;
      
      function get startCellID() : uint;
      
      function get startFlowchartID() : uint;
      
      function getStartCell() : ICell;
      
      function get timeStamp() : Number;
      
      function get workspaceName() : String;
      
      function get projectName() : String;
      
      function onMediaLoaded(param1:IMedia, param2:IFlowchart) : void;
      
      function onReturnFromFlowchart(param1:IFlowchart) : void;
      
      function getLoadedMedia() : Array;
      
      function mediaWasLoadedByFlowchart(param1:AbstractMedia, param2:IFlowchart) : Boolean;
      
      function unloadMedia(param1:AbstractMedia) : void;
      
      function unloadAllMedia() : void;
      
      function filterAllMediaForLocale(param1:String) : void;
      
      function destroy() : void;
   }
}

