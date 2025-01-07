package jackboxgames.talkshow.api
{
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import jackboxgames.talkshow.api.events.CellEvent;
   
   public class ActionPackage implements IActionPackage
   {
      protected var _ts:IEngineAPI;
      
      protected var _init:Boolean;
      
      public function ActionPackage()
      {
         super();
         this._init = false;
      }
      
      internal static function getDefaultDuration(ref:IActionRef) : uint
      {
         var param:IMediaParamValue = null;
         var ver:IMediaVersion = null;
         var d:* = ref.getValueByName("_duration");
         if(isNaN(d))
         {
            param = ref.getPrimaryMediaParamValue();
            if(param != null)
            {
               ver = param.previous;
               if(ver is IAudioVersion)
               {
                  if((ver as IAudioVersion).audio == null)
                  {
                     return 0;
                  }
                  return IAudioVersion(ver).audio.length;
               }
            }
            return 0;
         }
         return uint(d);
      }
      
      public function init(ts:IEngineAPI, ... initInfo) : void
      {
         if(!this._init)
         {
            this._ts = ts;
            this._init = true;
            (this._ts as EventDispatcher).addEventListener(CellEvent.CELL_JUMP,this.handleJump,false,0,true);
         }
         this.doInit();
      }
      
      protected function doInit() : void
      {
      }
      
      protected function handleJump(evt:CellEvent) : void
      {
      }
      
      public function get ts() : IEngineAPI
      {
         return this._ts;
      }
      
      public function get g() : Object
      {
         return this._ts.g;
      }
      
      public function get l() : Object
      {
         return this._ts.l;
      }
      
      public function get type() : String
      {
         return ActionPackageType.TYPE_CODE;
      }
      
      public function isInit() : Boolean
      {
         return this._init;
      }
      
      public function handleAction(ref:IActionRef, params:Object) : void
      {
      }
      
      public function getDuration(ref:IActionRef) : uint
      {
         return getDefaultDuration(ref);
      }
      
      public function getDisplayObject(ref:IActionRef, params:Object, isRuntime:Boolean = false) : DisplayObject
      {
         return null;
      }
   }
}

