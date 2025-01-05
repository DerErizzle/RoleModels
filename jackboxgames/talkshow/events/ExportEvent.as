package jackboxgames.talkshow.events
{
   import flash.events.Event;
   import jackboxgames.talkshow.api.QualifiedID;
   
   public class ExportEvent extends Event
   {
      
      public static const STARTFILE_LOADED:String = "startfile_loaded";
      
      public static const STARTFILE_PROGRESS:String = "startfile_progress";
      
      public static const STARTFILE_ERROR:String = "startfile_error";
      
      public static const EXPORT_READY:String = "export_ready";
      
      public static const STARTFLOWCHART_LOADED:String = "startflowchart_loaded";
      
      public static const STARTFLOWCHART_PROGRESS:String = "startflowchart_progress";
      
      public static const STARTFLOWCHART_ERROR:String = "startflowchart_error";
      
      public static const FLOWCHART_LOADED:String = "flowchart_loaded";
      
      public static const FLOWCHART_PROGRESS:String = "flowchart_progress";
      
      public static const FLOWCHART_ERROR:String = "flowchart_error";
      
      public static const TEMPLATE_LOADED:String = "template_loaded";
      
      public static const TEMPLATE_PROGRESS:String = "template_progress";
      
      public static const TEMPLATE_ERROR:String = "template_error";
       
      
      public var msg:String;
      
      public var id:QualifiedID;
      
      public var data:Object;
      
      public function ExportEvent(type:String, id:QualifiedID, message:String = "", extraData:Object = null)
      {
         super(type);
         this.msg = message;
         this.id = id;
         this.data = extraData;
      }
      
      override public function clone() : Event
      {
         return new ExportEvent(type,this.id,this.msg);
      }
      
      override public function toString() : String
      {
         return formatToString("ExportEvent","id","msg");
      }
   }
}
