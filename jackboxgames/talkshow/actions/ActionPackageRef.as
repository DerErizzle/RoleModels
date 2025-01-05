package jackboxgames.talkshow.actions
{
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.api.ActionPackageType;
   import jackboxgames.talkshow.api.IAction;
   import jackboxgames.talkshow.api.IActionPackage;
   import jackboxgames.talkshow.api.IActionPackageRef;
   import jackboxgames.talkshow.api.IExport;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.utils.ConfigInfo;
   import jackboxgames.talkshow.utils.LoadStatus;
   
   public class ActionPackageRef implements IActionPackageRef
   {
       
      
      protected var _name:String;
      
      protected var _id:int;
      
      protected var _actions:Object;
      
      protected var _actionPackage:IActionPackage;
      
      protected var _type:String;
      
      protected var _url:String;
      
      protected var _loadStatus:int;
      
      protected var _export:IExport;
      
      public function ActionPackageRef(type:String, id:int, name:String, export:IExport = null)
      {
         super();
         this._name = name;
         this._id = id;
         this._type = type;
         this._actionPackage = null;
         this._export = export;
         this._actions = new Object();
         this._loadStatus = LoadStatus.STATUS_NONE;
      }
      
      public function toString() : String
      {
         return "[ActionPackageRef name=" + this._name + "]";
      }
      
      public function setPackage(pkg:IActionPackage, export:IExport = null) : void
      {
         if(this._actionPackage == null)
         {
            this._actionPackage = pkg;
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
      
      public function get type() : String
      {
         return this._actionPackage.type;
      }
      
      public function addAction(action:IAction) : void
      {
         this._actions["a" + (action.id < 0 ? "_" + Math.abs(action.id) : action.id)] = action;
      }
      
      public function getAction(actionId:int) : IAction
      {
         return this._actions["a" + (actionId < 0 ? "_" + Math.abs(actionId) : actionId)];
      }
      
      public function get actionPackage() : IActionPackage
      {
         return this._actionPackage;
      }
      
      public function getExport() : IExport
      {
         if(this._type == ActionPackageType.TYPE_INTERNAL || this._export == null)
         {
            return PlaybackEngine.getInstance().activeExport;
         }
         return this._export;
      }
      
      public function load(data:ILoadData = null) : void
      {
         this.initActionPackage();
      }
      
      public function isLoaded() : Boolean
      {
         return this._loadStatus == LoadStatus.STATUS_LOADED || this._loadStatus == LoadStatus.STATUS_FAILED;
      }
      
      public function get loadStatus() : int
      {
         return this._loadStatus;
      }
      
      private function initActionPackage() : void
      {
         var apClass:Class = null;
         var url:String = null;
         if(this._actionPackage == null)
         {
            apClass = ActionPackageClassManager.instance.getClass(this._name);
            if(!apClass)
            {
               Logger.debug("ERROR -- Action Package : " + this._name + " does not have a registered class!");
               return;
            }
            url = this._url != null ? this._url : this.getExport().configInfo.getValue(ConfigInfo.ACTION_PATH) + this._id + ".swf";
            this._actionPackage = new apClass(url);
         }
         switch(this._type)
         {
            case ActionPackageType.TYPE_SWF:
            case ActionPackageType.TYPE_CODE:
            case ActionPackageType.TYPE_INTERNAL:
               this._actionPackage.init(PlaybackEngine.getInstance());
         }
         this._loadStatus = LoadStatus.STATUS_LOADED;
      }
   }
}
