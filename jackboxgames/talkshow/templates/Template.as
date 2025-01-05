package jackboxgames.talkshow.templates
{
   import jackboxgames.swftemplatehandler.TemplateHandler;
   import jackboxgames.talkshow.api.IExport;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.ILoadable;
   import jackboxgames.talkshow.api.ITemplate;
   import jackboxgames.talkshow.api.ITemplateHandler;
   import jackboxgames.talkshow.api.QualifiedID;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.events.ExportEvent;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class Template extends PausableEventDispatcher implements ITemplate
   {
       
      
      protected var _name:String;
      
      protected var _id:int;
      
      protected var _fields:Object;
      
      protected var _params:Array;
      
      protected var _templateHandler:ITemplateHandler;
      
      protected var _url:String;
      
      protected var _qid:QualifiedID;
      
      protected var _currentParams:Object;
      
      protected var _loadStatus:int;
      
      protected var _export:IExport;
      
      protected var _loadData:ILoadData;
      
      public function Template(id:int, name:String, params:Array, fields:Object, export:IExport = null)
      {
         super();
         this._name = name;
         this._id = id;
         this._templateHandler = null;
         this._export = export;
         this._fields = fields;
         this._params = params;
         this._loadStatus = LoadStatus.STATUS_NONE;
         this._currentParams = null;
      }
      
      public static function createID(internalID:uint) : String
      {
         return "T_" + internalID;
      }
      
      override public function toString() : String
      {
         return "[Template name=" + this._name + "]";
      }
      
      public function setHandler(h:ITemplateHandler, export:IExport = null) : void
      {
         if(this._templateHandler == null)
         {
            this._templateHandler = h;
            if(export != null)
            {
               this._export = export;
            }
         }
      }
      
      public function setUrl(s:String) : void
      {
         this._url = s;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get qualifiedID() : QualifiedID
      {
         if(this._qid == null)
         {
            this._qid = new QualifiedID(this._export.id,createID(this._id),this._id);
         }
         return this._qid;
      }
      
      public function get handler() : ITemplateHandler
      {
         return this._templateHandler;
      }
      
      public function get params() : Array
      {
         return this._params;
      }
      
      public function getValue(fid:int) : *
      {
         var tf:TemplateField = this._fields["F" + fid];
         if(tf == null)
         {
            return null;
         }
         var val:* = this.handler.getValue(tf.name);
         if(val == null)
         {
            val = this.getDefaultValue(tf,true);
         }
         return val;
      }
      
      public function getCue(fieldId:int, cueName:String) : String
      {
         var tf:TemplateField = this._fields["F" + fieldId];
         if(tf == null)
         {
            return "N";
         }
         return this.handler.getCue(tf.name,cueName);
      }
      
      public function isFieldLoaded(fid:int) : Boolean
      {
         var tf:TemplateField = this._fields["F" + fid];
         if(tf == null)
         {
            return false;
         }
         var val:* = this.handler.getValue(tf.name);
         if(val == null)
         {
            val = this.getDefaultValue(tf,false);
            if(val is ILoadable)
            {
               return (val as ILoadable).isLoaded();
            }
            return true;
         }
         return this.handler.isFieldLoaded(tf.name);
      }
      
      public function loadField(fid:int) : void
      {
         var tf:TemplateField = this._fields["F" + fid];
         if(tf == null)
         {
            return;
         }
         var val:* = this.handler.getValue(tf.name);
         if(val == null)
         {
            val = this.getDefaultValue(tf,false);
            if(val is ILoadable)
            {
               (val as ILoadable).load();
            }
         }
         else
         {
            this.handler.loadField(tf.name);
         }
      }
      
      private function getDefaultValue(tf:TemplateField, commit:Boolean = false) : *
      {
         var val:* = undefined;
         if(tf.type == "A" || tf.type == "G")
         {
            val = this._export.getMedia(int(tf.defaultValue));
            if(val != null)
            {
               val = val.getNextRandomVersion(commit);
            }
         }
         else if(tf.type == "N")
         {
            val = Number(tf.defaultValue);
         }
         else
         {
            val = tf.defaultValue;
         }
         return val;
      }
      
      public function setActiveRecord(params:Object) : void
      {
         var tf:TemplateField = null;
         var v:String = null;
         this.handler.setActiveRecord(params);
         this._currentParams = params;
         for each(tf in this._fields)
         {
            if(tf.type != TemplateField.TYPE_AUDIO && tf.type != TemplateField.TYPE_GRAPHIC)
            {
               v = tf.variable;
               if(v != null && v.length > 2)
               {
                  PlaybackEngine.getInstance().setVariableValue(v,this.handler.getValue(tf.name));
               }
            }
         }
      }
      
      public function getCurrentParams() : Object
      {
         return this._currentParams;
      }
      
      public function load(data:ILoadData = null) : void
      {
         if(this._loadStatus == LoadStatus.STATUS_NONE)
         {
            this._loadStatus = LoadStatus.STATUS_LOADING;
            this._loadData = data;
            this._templateHandler = new TemplateHandler();
            this.initTemplateHandler();
         }
      }
      
      public function isLoaded() : Boolean
      {
         return this._loadStatus == LoadStatus.STATUS_LOADED || this._loadStatus == LoadStatus.STATUS_FAILED;
      }
      
      public function get loadStatus() : int
      {
         return this._loadStatus;
      }
      
      private function initTemplateHandler() : void
      {
         if(this._templateHandler != null)
         {
            this._templateHandler.init(PlaybackEngine.getInstance());
            this._loadStatus = LoadStatus.STATUS_LOADED;
         }
         dispatchEvent(new ExportEvent(ExportEvent.TEMPLATE_LOADED,this.qualifiedID,"Template loaded and parsed",this._loadData));
         this._loadData = null;
      }
   }
}
