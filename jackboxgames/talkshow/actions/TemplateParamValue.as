package jackboxgames.talkshow.actions
{
   import jackboxgames.talkshow.api.ITemplate;
   import jackboxgames.talkshow.core.PlaybackEngine;
   
   public class TemplateParamValue
   {
       
      
      private var _templateId:int;
      
      private var _fieldId:int;
      
      public function TemplateParamValue(tid:int, fid:int)
      {
         super();
         this._templateId = tid;
         this._fieldId = fid;
      }
      
      public function getValue() : *
      {
         var tpl:ITemplate = PlaybackEngine.getInstance().activeExport.getTemplate(this._templateId);
         if(tpl == null)
         {
            return null;
         }
         return tpl.getValue(this._fieldId);
      }
      
      public function isLoaded() : Boolean
      {
         var tpl:ITemplate = PlaybackEngine.getInstance().activeExport.getTemplate(this._templateId);
         if(tpl == null)
         {
            return false;
         }
         return tpl.isFieldLoaded(this._fieldId);
      }
      
      public function load() : void
      {
         var tpl:ITemplate = PlaybackEngine.getInstance().activeExport.getTemplate(this._templateId);
         if(tpl == null)
         {
            return;
         }
         return tpl.loadField(this._fieldId);
      }
      
      public function getCueTiming(cueName:String) : String
      {
         var tpl:ITemplate = PlaybackEngine.getInstance().activeExport.getTemplate(this._templateId);
         return tpl.getCue(this._fieldId,cueName);
      }
   }
}
