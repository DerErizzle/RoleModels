package jackboxgames.talkshow.actions
{
   import flash.display.DisplayObject;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.IAction;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.ILoadable;
   import jackboxgames.talkshow.api.IMediaParamValue;
   import jackboxgames.talkshow.api.IMediaVersion;
   import jackboxgames.talkshow.api.IParameter;
   import jackboxgames.talkshow.cells.ActionCell;
   import jackboxgames.talkshow.cells.LoadData;
   import jackboxgames.talkshow.timing.Timing;
   import jackboxgames.talkshow.utils.LoadStatus;
   import jackboxgames.talkshow.utils.VariableUtil;
   
   public class ActionRef implements ILoadable, IActionRef
   {
      private const VAR_CHECK:String = "\\{\\{((g|l)\\.[A-Za-z_$]([A-Za-z0-9_$]*|\\.[A-Za-z0-9_$])*)\\}\\}";
      
      protected var _timing:Timing;
      
      private var _values:Array;
      
      private var _action:IAction;
      
      private var _parentCell:ActionCell;
      
      private var _primary:Boolean;
      
      protected var _loadStatus:int;
      
      public function ActionRef(a:IAction, timing:Timing)
      {
         super();
         this._action = a;
         this._timing = timing;
         this._values = new Array();
         this._loadStatus = LoadStatus.STATUS_NONE;
         this._parentCell = null;
      }
      
      public function toString() : String
      {
         return "[ActionRef" + (this._action == null ? "" : " action=" + this._action.name) + " timing=" + this._timing + "]";
      }
      
      public function start(isPrimary:Boolean = false) : void
      {
         if(this._action == null)
         {
            Logger.warning("Missing Action: " + this);
            return;
         }
         Logger.info("Start ActionRef " + this,"Action");
         this._primary = isPrimary;
         if(this._action.actionPackage.actionPackage != null)
         {
            this._action.actionPackage.actionPackage.handleAction(this,this.prepareValues());
         }
      }
      
      public function getDisplayObject() : DisplayObject
      {
         if(this._action == null)
         {
            return null;
         }
         if(this._action.actionPackage.actionPackage != null)
         {
            return this._action.actionPackage.actionPackage.getDisplayObject(this,this.prepareValues(),true);
         }
         return null;
      }
      
      public function end() : void
      {
         if(this._primary)
         {
            this._parentCell.primaryComplete();
         }
      }
      
      private function prepareValues() : Object
      {
         var p:IParameter = null;
         var value:MediaParamValue = null;
         var version:Object = null;
         var txt:String = null;
         var params:Object = {};
         for(var i:uint = 0; i < this._values.length; i++)
         {
            p = this._action.getParameter(i);
            if(this._values[i] is TemplateParamValue)
            {
               params[p.name] = (this._values[i] as TemplateParamValue).getValue();
               continue;
            }
            switch(p.type)
            {
               case Parameter.TYPE_AUDIO:
               case Parameter.TYPE_GRAPHIC:
                  value = this._values[i] as MediaParamValue;
                  if(value == null)
                  {
                     Logger.warning("Action references missing media: " + this + " param=" + p.name);
                  }
                  else
                  {
                     params[p.name] = value.getCurrentVersion(true);
                  }
                  break;
               case Parameter.TYPE_TEXT:
                  value = this._values[i] as MediaParamValue;
                  if(value == null)
                  {
                     Logger.warning("Action references missing media: " + this + " param=" + p.name);
                  }
                  else
                  {
                     version = value.getCurrentVersion(true);
                     if(version == null)
                     {
                        Logger.warning("Action references missing version: " + this + " param=" + p.name);
                        txt = "";
                     }
                     else
                     {
                        txt = version.text;
                     }
                     params[p.name] = VariableUtil.replaceVariables(txt);
                  }
                  break;
               case Parameter.TYPE_NUMBER:
                  if(this._values[i] is String)
                  {
                     if(!isNaN(Number(this._values[i])))
                     {
                        params[p.name] = Number(this._values[i]);
                     }
                     else
                     {
                        params[p.name] = VariableUtil.replaceVariables(this._values[i]);
                     }
                  }
                  else
                  {
                     params[p.name] = this._values[i];
                  }
                  break;
               default:
                  if(this._values[i] is String)
                  {
                     params[p.name] = VariableUtil.replaceVariables(this._values[i]);
                  }
                  else
                  {
                     params[p.name] = this._values[i];
                  }
                  break;
            }
         }
         return params;
      }
      
      public function setParent(c:ActionCell) : void
      {
         if(this._parentCell == null)
         {
            this._parentCell = c;
         }
      }
      
      public function get parent() : ActionCell
      {
         return this._parentCell;
      }
      
      public function setValue(paramIndex:uint, paramValue:*) : void
      {
         this._values[paramIndex] = paramValue;
      }
      
      public function getValueByIndex(paramIndex:int) : *
      {
         return this._values[paramIndex];
      }
      
      public function getValueByName(paramName:String) : *
      {
         var idx:int = int(this._action.getParameterIdxByName(paramName));
         if(idx < 0)
         {
            return null;
         }
         return this._values[idx];
      }
      
      public function get action() : IAction
      {
         return this._action;
      }
      
      public function get isPrimary() : Boolean
      {
         return this._primary;
      }
      
      public function get timing() : Timing
      {
         return this._timing;
      }
      
      public function getPrimaryMediaParamValue() : IMediaParamValue
      {
         var param:IMediaParamValue = null;
         var idx:int = int(this._action.getPrimaryMediaParameterIdx());
         if(idx > -1)
         {
            param = this.getValueByIndex(idx) as IMediaParamValue;
         }
         return param;
      }
      
      private function _shouldLoadAllVersions(val:IMediaParamValue) : Boolean
      {
         var regex:RegExp = new RegExp(this.VAR_CHECK);
         return (val.selType == MediaParamValue.SEL_INDEX || val.selType == MediaParamValue.SEL_TAG) && Boolean(regex.test(val.selValue)) && val.media.numVersions < LoadData.MAX_VOLATILE;
      }
      
      private function _loadAllValues(val:IMediaParamValue, data:ILoadData) : void
      {
         var ver:IMediaVersion = null;
         for(var i:int = 0; i < val.media.numVersions; i++)
         {
            ver = val.media.getVersionByIndex(i);
            if(ver != null && ver is ILoadable)
            {
               if(!ILoadable(ver).isLoaded())
               {
                  ILoadable(ver).load(data);
               }
            }
         }
      }
      
      public function load(data:ILoadData = null) : void
      {
         var pv:* = undefined;
         var val:IMediaParamValue = null;
         var ver:IMediaVersion = null;
         var primaryVal:IMediaParamValue = null;
         if(this._action == null)
         {
            return;
         }
         if(!this._action.actionPackage.isLoaded())
         {
            this._action.actionPackage.load();
         }
         for each(pv in this._values)
         {
            if(pv is IMediaParamValue)
            {
               val = IMediaParamValue(pv);
               if(Boolean(val.media))
               {
                  val.media.onMediaLoaded(this._parentCell.flowchart);
               }
               if(this._shouldLoadAllVersions(val))
               {
                  this._loadAllValues(val,data);
               }
               else
               {
                  if(val.selType == MediaParamValue.SEL_PRIMARY)
                  {
                     primaryVal = this.getPrimaryMediaParamValue();
                     if(this._shouldLoadAllVersions(primaryVal))
                     {
                        this._loadAllValues(val,data);
                        continue;
                     }
                  }
                  ver = val.getCurrentVersion();
                  if(ver is ILoadable && !ILoadable(ver).isLoaded())
                  {
                     ILoadable(ver).load(data);
                  }
               }
            }
            else if(pv is TemplateParamValue)
            {
               (pv as TemplateParamValue).load();
            }
         }
      }
      
      public function isLoaded() : Boolean
      {
         var pv:* = undefined;
         var ver:IMediaVersion = null;
         if(this._action == null)
         {
            return true;
         }
         if(!this._action.actionPackage.isLoaded())
         {
            return false;
         }
         for each(pv in this._values)
         {
            if(pv is IMediaParamValue)
            {
               ver = IMediaParamValue(pv).getCurrentVersion();
               if(ver is ILoadable)
               {
                  if(!ILoadable(ver).isLoaded())
                  {
                     return false;
                  }
               }
            }
            else if(pv is TemplateParamValue)
            {
               return (pv as TemplateParamValue).isLoaded();
            }
         }
         return true;
      }
      
      public function get loadStatus() : int
      {
         if(this.isLoaded())
         {
            this._loadStatus = LoadStatus.STATUS_LOADED;
         }
         else
         {
            this._loadStatus = LoadStatus.STATUS_INVALIDATED;
         }
         return this._loadStatus;
      }
   }
}

