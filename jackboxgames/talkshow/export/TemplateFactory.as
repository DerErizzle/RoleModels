package jackboxgames.talkshow.export
{
   internal class TemplateFactory
   {
      private static const DELIMITER_TEMPLATES:String = "^";
      
      private static const DELIMITER_TEMPLATE_DATA:String = "|";
      
      private static const DELIMITER_FIELD:String = "!";
      
      private static const DELIMITER_FIELD_DATA:String = ",";
      
      private static const DELIMITER_PARAMETER:String = "!";
      
      public function TemplateFactory()
      {
         super();
      }
      
      public static function buildTemplates(export:Export, templateData:String, dict:ExportDictionary) : void
      {
         var data:Array = null;
         var tpl:Template = null;
         var tid:int = 0;
         var tplStr:String = null;
         var params:Array = null;
         var x:Array = null;
         var i:String = null;
         var fields:Object = null;
         var fData:Array = null;
         var def:* = undefined;
         var f:TemplateField = null;
         if(templateData == null || templateData == "")
         {
            return;
         }
         var templates:Array = templateData.split(DELIMITER_TEMPLATES);
         var type:String = "";
         var parent:int = -1;
         for each(tplStr in templates)
         {
            data = tplStr.split(DELIMITER_TEMPLATE_DATA);
            tid = int(data[0]);
            parent = int(data[1]);
            if(export.getTemplate(tid) == null)
            {
               params = [];
               x = data[3].split(DELIMITER_PARAMETER);
               for each(i in x)
               {
                  params.push(dict.lookup(uint(i)));
               }
               fields = {};
               x = data[4].split(DELIMITER_FIELD);
               for each(i in x)
               {
                  fData = i.split(DELIMITER_FIELD_DATA);
                  type = fData[2];
                  def = type == "A" || type == "G" ? fData[3] : dict.lookup(fData[3]);
                  f = new TemplateField(int(fData[0]),dict.lookup(fData[1]),type,def,dict.lookup(fData[4]));
                  fields["F" + f.id] = f;
               }
               tpl = new Template(tid,dict.lookup(data[2]),params,fields,export);
               export.addTemplate(tpl,parent);
            }
         }
      }
   }
}

