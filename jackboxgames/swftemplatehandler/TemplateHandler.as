package jackboxgames.swftemplatehandler
{
   import flash.events.Event;
   import jackboxgames.loader.*;
   import jackboxgames.logger.*;
   import jackboxgames.swftemplatehandler.media.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   
   public class TemplateHandler extends PausableEventDispatcher implements ITemplateHandler
   {
      private var _engine:IEngineAPI;
      
      private var _records:Object;
      
      private var _recordPath:String;
      
      private var _recordSet:String;
      
      private var _loadingRecordId:String = null;
      
      private var _active:String;
      
      private var _lastLoaded:String = "";
      
      public function TemplateHandler()
      {
         super();
      }
      
      public function init(engine:IEngineAPI) : void
      {
         this._engine = engine;
         this._active = null;
         this._records = {};
      }
      
      public function loadRecord(params:Object) : void
      {
         var rs:String = null;
         var rid:String = null;
         rs = params.recordSet;
         rid = params.recordId;
         if(this._records[rid] != null)
         {
            return;
         }
         this._loadingRecordId = rid;
         if(this._engine.g.templateRootPath != null && this._engine.g.templateRootPath.length > 0)
         {
            this._recordPath = this._engine.g.templateRootPath + "/";
         }
         else
         {
            this._recordPath = "";
         }
         if(rs != null && rs.length > 0)
         {
            this._recordPath += rs + "/";
         }
         this._recordPath += rid + "/";
         Logger.debug("TemplateHandler: Loading record from : " + this._recordPath + "data.jet");
         JBGLoader.instance.loadFile(this._recordPath + "data.jet",function(result:Object):void
         {
            if(Boolean(result.success))
            {
               Logger.info("TemplateHandler: Loaded: " + _recordPath + "data.jet","Load");
               parseRecord(rs,rid,result.loader.contentAsJSON);
            }
            else
            {
               Logger.error("TemplateHandler: Unable to Load Record:" + _recordPath + "data.jet");
            }
         });
      }
      
      public function isRecordLoaded(params:Object) : Boolean
      {
         var r:Object = this._records[params.recordId];
         if(r == null || !r.loaded)
         {
            return false;
         }
         return true;
      }
      
      public function setActiveRecord(params:Object) : void
      {
         var id:String = null;
         var key:String = null;
         var v:* = undefined;
         this._active = params == null ? null : params.recordId;
         if(params == null || this._engine == null)
         {
            return;
         }
         var setName:String = params.recordSet == null ? "unknown" : params.recordSet;
         this._engine.setVariableValue("g.templates." + setName + ".activeId",params.recordId);
         for(id in this._records)
         {
            if(id != this._active)
            {
               for(key in this._records[id])
               {
                  v = this._records[id][key];
                  if(v is TemplateAudioVersion || v is TemplateGraphicVersion)
                  {
                     v.unload();
                  }
               }
               delete this._records[id];
            }
         }
      }
      
      public function getValue(field:String) : *
      {
         var r:Object = this._records[this._active];
         if(r == null)
         {
            return null;
         }
         return r[field];
      }
      
      public function getCue(field:String, cue:String) : String
      {
         var r:Object = this._records[this._active];
         if(r == null)
         {
            return null;
         }
         return r["$" + field + "$" + cue];
      }
      
      public function loadField(field:String) : void
      {
         var v:* = this.getValue(field);
         if(v is TemplateAudioVersion || v is TemplateGraphicVersion)
         {
            v.load();
         }
      }
      
      public function isFieldLoaded(field:String) : Boolean
      {
         var v:* = this.getValue(field);
         if(v is TemplateAudioVersion || v is TemplateGraphicVersion)
         {
            return v.isLoaded();
         }
         return true;
      }
      
      private function getRecord(id:String) : Object
      {
         return this._records["R_" + id];
      }
      
      private function parseRecord(rs:String, rid:String, jsonData:Object) : void
      {
         var field:Object = null;
         var recordId:String = this._loadingRecordId;
         var r:Object = {};
         for each(field in jsonData.fields)
         {
            if(!field.hasOwnProperty("v"))
            {
               r[field.n] = null;
            }
            else if(field.t == "A")
            {
               field.v += BuildConfig.instance.configVal("audio-extension");
               r[field.n] = new TemplateAudioVersion(this._engine,rs,field.n,this._recordPath + field.v,!!field.hasOwnProperty("s") ? field.s : "");
            }
            else if(field.t == "G")
            {
               field.v += ".png";
               r[field.n] = new TemplateGraphicVersion(this._engine,rs,field.n,this._recordPath + field.v);
            }
            else
            {
               r[field.n] = field.v;
            }
         }
         r.loaded = true;
         this._records[recordId] = r;
         this._loadingRecordId = null;
         Logger.info("TemplateHander: Record parsed: " + recordId,"Template");
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

