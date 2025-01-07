package jackboxgames.talkshow.utils
{
   import jackboxgames.talkshow.api.IConfigInfo;
   
   public class ConfigInfo implements IConfigInfo
   {
      public static const INPUT_DELAY:String = "tsInputDelay";
      
      public static const EXPORT_PATH:String = "tsExportPath";
      
      public static const DATA_PATH:String = "tsDataPath";
      
      public static const MEDIA_PATH:String = "tsMediaPath";
      
      public static const ACTION_PATH:String = "tsActionPath";
      
      public static const TEMPLATE_PATH:String = "tsTemplatePath";
      
      public static const PLUGIN_PATH:String = "tsPluginPath";
      
      public static const START_FILE:String = "tsAltStartFile";
      
      public static const SCRIPT_BASE:String = "tsScriptBase";
      
      public static const START_VARS:String = "tsStartVars";
      
      public static const XML_PATH:String = "tsUseConfigFile";
      
      public static const VARS_DELIMITER:String = "|";
      
      public static const VALUE_DELIMITER:String = ",";
      
      private static const XML_ROOT:String = "playback-config";
      
      public static const DEFAULTS:Object = {
         "tsInputDelay":33,
         "tsScriptBase":"",
         "tsExportPath":"project/",
         "tsDataPath":"project/data/",
         "tsMediaPath":"project/media/",
         "tsActionPath":"project/actions/",
         "tsTemplatePath":"project/templates/",
         "tsPluginPath":"project/plugins/",
         "tsAltStartFile":"project/data/start.swf"
      };
      
      private var _data:Object;
      
      private var _xml:XML;
      
      public function ConfigInfo(info:Object = null)
      {
         super();
         this._data = info;
         this.parseFlashVars();
      }
      
      private function parseFlashVars() : void
      {
         var prop:String = null;
         if(this._data == null)
         {
            this._data = {};
         }
         for(prop in DEFAULTS)
         {
            if(this._data[prop] == null || this._data[prop] == "")
            {
               this._data[prop] = DEFAULTS[prop];
            }
         }
         this.parseStartVars();
      }
      
      public function buildXmlConfig(x:XML) : void
      {
         var node:XML = null;
         var vars:Object = null;
         var p:String = null;
         if(x != null)
         {
            this._xml = x;
            if(x.localName() == XML_ROOT)
            {
               for each(node in x.*)
               {
                  if(node.localName() == START_VARS)
                  {
                     vars = this.parseXmlStartVars(node);
                     if(vars != null)
                     {
                        for(p in vars)
                        {
                           if(vars[p] != null)
                           {
                              VariableUtil.setVariableValue("g." + p,vars[p]);
                           }
                        }
                     }
                  }
                  else
                  {
                     this._data[node.localName()] = node.toString();
                  }
               }
            }
         }
      }
      
      private function parseXmlStartVars(node:XML) : Object
      {
         var g:XML = null;
         if(node == null)
         {
            return null;
         }
         var out:Object = new Object();
         for each(g in node.*)
         {
            if(VariableUtil.isValidID(g.@id))
            {
               if(Boolean(g.hasComplexContent()))
               {
                  out[g.@id] = this.parseXmlStartVars(g);
               }
               else
               {
                  out[g.@id] = g.toString();
               }
            }
         }
         return out;
      }
      
      private function parseStartVars() : void
      {
         var gvars:Array = null;
         var v:Array = null;
         var i:uint = 0;
         var gstring:String = this.getValue(START_VARS);
         if(gstring != null && gstring.length > 0)
         {
            gvars = gstring.split(VARS_DELIMITER);
            for(i = 0; i < gvars.length; i++)
            {
               v = gvars[i].split(VALUE_DELIMITER);
               if(v.length == 2)
               {
                  if(VariableUtil.isValidID(v[0]))
                  {
                     VariableUtil.setVariableValue("g." + v[0],v[1]);
                  }
               }
            }
         }
      }
      
      public function get flashVars() : Object
      {
         return this._data;
      }
      
      public function getValue(n:String) : *
      {
         return this._data[n];
      }
   }
}

