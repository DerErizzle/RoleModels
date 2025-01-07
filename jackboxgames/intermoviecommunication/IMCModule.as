package jackboxgames.intermoviecommunication
{
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import jackboxgames.events.EventWithData;
   import jackboxgames.pause.PauseMenuManager;
   import jackboxgames.utils.Assert;
   import jackboxgames.utils.EnvUtil;
   import jackboxgames.utils.PausableEventDispatcher;
   
   public class IMCModule extends PausableEventDispatcher
   {
      private static var MOVIE_ID:String;
      
      public static const MOVIE_ID_LOADER:String = "loader";
      
      public static const MOVIE_ID_MANAGER:String = "manager";
      
      public static const MOVIE_ID_PAUSE:String = "pause";
      
      public static const MOVIE_ID_GAME:String = "game";
      
      public static const ROLE_PRIMARY:String = "primary";
      
      public static const ROLE_DRONE:String = "drone";
      
      private var _id:String;
      
      private var _role:String;
      
      private var _isPauseMovie:Boolean;
      
      public var callFunctionOnPrimaryModuleNative:Function = null;
      
      public var dispatchEventInDroneModulesNative:Function = null;
      
      public function IMCModule(id:String, primaryMovieId:String)
      {
         super();
         this._id = id;
         this._role = _getRole(primaryMovieId);
         this._isPauseMovie = this._id == PauseMenuManager.PAUSE_MENU_NAME;
         switch(this._role)
         {
            case ROLE_PRIMARY:
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("RegisterPrimaryIMCModule",id,this);
               }
               this._doPrimaryInitialization();
               break;
            case ROLE_DRONE:
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("RegisterDroneIMCModule",id,this);
               }
               this._doDroneInitialization();
         }
      }
      
      public static function SET_MOVIE_ID(movieId:String) : void
      {
         if(EnvUtil.isAIR())
         {
            return;
         }
         MOVIE_ID = movieId;
      }
      
      private static function _getRole(primaryMovieId:String) : String
      {
         if(EnvUtil.isAIR())
         {
            return ROLE_PRIMARY;
         }
         return primaryMovieId == MOVIE_ID ? ROLE_PRIMARY : ROLE_DRONE;
      }
      
      protected function _doPrimaryInitialization() : void
      {
      }
      
      protected function _doDroneInitialization() : void
      {
      }
      
      protected function _doFunctionBehavior(fnName:String, fn:Function, ... args) : *
      {
         switch(this._role)
         {
            case ROLE_PRIMARY:
               return fn.apply(null,args);
            case ROLE_DRONE:
               if(this.callFunctionOnPrimaryModuleNative != null)
               {
                  return this.callFunctionOnPrimaryModuleNative.call(null,this._id,fnName,args);
               }
               return undefined;
               break;
            default:
               return;
         }
      }
      
      override public function dispatchEvent(e:Event) : Boolean
      {
         Assert.assert(this._role == ROLE_PRIMARY);
         Assert.assert(e is EventWithData);
         var ewd:EventWithData = EventWithData(e);
         var res:Boolean = this._isPauseMovie ? super.dispatchEventImmediate(ewd) : super.dispatchEvent(ewd);
         if(this.dispatchEventInDroneModulesNative != null)
         {
            this.dispatchEventInDroneModulesNative(this._id,ewd.type,ewd.data);
         }
         return res;
      }
      
      public function dispatchEventFromPrimary(type:String, data:Object) : void
      {
         if(this._isPauseMovie)
         {
            super.dispatchEventImmediate(new EventWithData(type,data));
         }
         else
         {
            super.dispatchEvent(new EventWithData(type,data));
         }
      }
   }
}

