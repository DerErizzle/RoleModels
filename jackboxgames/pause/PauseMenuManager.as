package jackboxgames.pause
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.intermoviecommunication.*;
   import jackboxgames.loader.*;
   import jackboxgames.localizy.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class PauseMenuManager extends IMCModule
   {
      private static var _instance:PauseMenuManager;
      
      public static const PAUSE_MENU_NAME:String = "PauseMenu";
      
      public static const PAUSE_LOCALIZATION_FILE:String = "LocalizationPause.json";
      
      public static const EVENT_PAUSE_MENU_LOCALIZATION_LOADED:String = "PauseMenuLocalizationLoaded";
      
      public static const EVENT_PAUSE_MENU_DATA_LOADED:String = "PauseMenuDataLoaded";
      
      public static const EVENT_PAUSE_MENU_CONTENT_LOADED:String = "PauseMenuContentLoaded";
      
      public static const EVENT_PAUSE_MENU_SHOWN:String = "PauseMenuShown";
      
      public static const EVENT_PAUSE_MENU_VISIBILITY:String = "PauseMenuVisibility";
      
      public static const EVENT_PAUSE_MENU_SELECTED:String = "PauseMenuSelected";
      
      public static const EVENT_PAUSE_MENU_CONFIRMED:String = "PauseMenuConfirmed";
      
      public static const EVENT_PAUSE_MENU_HIGHLIGHTED:String = "PauseMenuHighlighted";
      
      public static const EVENT_PAUSE_MENU_DONE:String = "PauseMenuDone";
      
      public static const PAUSE_MENU_CONTENT_FILE:String = "PauseMenu.swf";
      
      public static const PAUSE_MENU_DATA_FILE:String = "pause_menu.jet";
      
      public static const PAUSE_ACTION_RESUME:String = "doResumeGame";
      
      public static const PAUSE_ACTION_RESTART_GAME:String = "doRestartGame";
      
      public static const PAUSE_ACTION_SETTINGS:String = "doSettings";
      
      public static const PAUSE_ACTION_BACK_TO_PACK:String = "doBackToPack";
      
      public static const PAUSE_ACTION_EXIT_TO_DESKTOP:String = "doExitToDesktop";
      
      private var _mc:MovieClip;
      
      private var _pauseMenu:PauseMenu;
      
      private var _pauseMenuData:PauseMenuData;
      
      private var _pauseAudio:PauseAudio;
      
      private var _menuLoader:ILoader;
      
      private var _callingGameName:String;
      
      public function PauseMenuManager()
      {
         super(PAUSE_MENU_NAME,IMCModule.MOVIE_ID_PAUSE);
      }
      
      public static function initialize() : void
      {
         if(Boolean(_instance))
         {
            return;
         }
         _instance = new PauseMenuManager();
      }
      
      public static function get instance() : PauseMenuManager
      {
         return _instance;
      }
      
      public function get pauseMenuData() : PauseMenuData
      {
         return this._pauseMenuData;
      }
      
      public function get pauseMc() : MovieClip
      {
         return this._mc;
      }
      
      public function reset() : void
      {
         if(Boolean(this._menuLoader))
         {
            this._menuLoader.stop();
            this._menuLoader.dispose();
            this._menuLoader = null;
         }
         this._disposeAudio();
      }
      
      public function dispose() : void
      {
         this.reset();
      }
      
      private function _disposeAudio() : void
      {
         JBGUtil.dispose([this._pauseAudio]);
         this._pauseAudio = null;
      }
      
      public function loadMenuData(dataPath:String, doneFn:Function) : void
      {
         this._menuLoader = JBGLoader.instance.loadFile(dataPath,function(result:Object):void
         {
            if(!_menuLoader)
            {
               return;
            }
            if(Boolean(result.success))
            {
               _pauseMenuData = new PauseMenuData(result.loader.contentAsJSON);
            }
            _menuLoader.dispose();
            _menuLoader = null;
            doneFn();
         });
      }
      
      public function loadMenuContent(swfPath:String) : void
      {
         _doFunctionBehavior("loadMenuContent",function(swfPath:String):void
         {
            JBGLoader.instance.loadFile(swfPath,function(result:Object):void
            {
               _mc = result.data;
               _mc.tabEnabled = false;
               _mc.tabChildren = false;
               PlatformMovieClipManager.instance.init(function(success:Boolean):void
               {
                  JBGUtil.eventOnce(LocalizationManager.instance,LocalizationManager.EVENT_LOAD_COMPLETE,function():void
                  {
                     AudioSystem.Initialize();
                     _pauseMenu = new PauseMenu(_mc);
                     _pauseMenu.init(function():void
                     {
                        dispatchEvent(new EventWithData(EVENT_PAUSE_MENU_CONTENT_LOADED,{"loaded":true}));
                     });
                  });
                  LocalizationManager.instance.load(PauseMenuManager.PAUSE_LOCALIZATION_FILE,PAUSE_MENU_NAME);
               });
            });
         },swfPath);
      }
      
      public function resetPauseMenu(doneFn:Function) : void
      {
         _doFunctionBehavior("resetPauseMenu",function():void
         {
            _pauseMenu.reset();
         });
      }
      
      public function updateMenu(menuData:Object, context:String) : void
      {
         _doFunctionBehavior("updateMenu",function(menuData:Object, context:String):void
         {
            _pauseMenu.updateMenu(menuData,context);
            _callingGameName = menuData.gameName;
         },menuData,context);
      }
      
      public function menuItemSelected(index:int, action:String, playAudio:Boolean) : void
      {
         _doFunctionBehavior("menuItemSelected",function(index:int, action:String, playAudio:Boolean):void
         {
            if(playAudio)
            {
               _pauseAudio.play(PauseAudio.SFX_MENU_SELECT,Nullable.NULL_FUNCTION);
            }
            dispatchEvent(new EventWithData(EVENT_PAUSE_MENU_SELECTED,{
               "index":index,
               "action":action
            }));
         },index,action,playAudio);
      }
      
      public function menuItemHighlighted(currentIndex:int, newIndex:int) : void
      {
         _doFunctionBehavior("menuItemHighlighted",function(currentIndex:int, newIndex:int):void
         {
            _pauseAudio.play(PauseAudio.SFX_MENU_SCROLL,Nullable.NULL_FUNCTION);
         },currentIndex,newIndex);
      }
      
      public function menuConfirmRequested() : void
      {
         _doFunctionBehavior("menuConfirmRequested",function():void
         {
            _pauseAudio.play(PauseAudio.SFX_MENU_SELECT,Nullable.NULL_FUNCTION);
         });
      }
      
      public function menuItemConfirmed(decision:String) : void
      {
         _doFunctionBehavior("menuItemConfirmed",function(decision:String):void
         {
            _pauseAudio.play(decision == PauseConfirmation.PAUSE_CONFIRMATION_CONFIRMED ? PauseAudio.SFX_CONFIRM_YES : PauseAudio.SFX_CONFIRM_NO,Nullable.NULL_FUNCTION);
            dispatchEvent(new EventWithData(EVENT_PAUSE_MENU_CONFIRMED,{"value":decision}));
         },decision);
      }
      
      public function menuHide(hide:Boolean) : void
      {
         _doFunctionBehavior("menuHide",function(hide:Boolean):void
         {
            _pauseAudio.play(hide ? PauseAudio.SFX_MENU_OFF : PauseAudio.SFX_MENU_ON,Nullable.NULL_FUNCTION);
         },hide);
      }
      
      public function setMenuShown(isShown:Boolean) : void
      {
         _doFunctionBehavior("setMenuShown",function(isShown:Boolean):void
         {
            if(isShown)
            {
               LocalizationManager.GameSource = PAUSE_MENU_NAME;
               _disposeAudio();
               _pauseAudio = new PauseAudio();
               _pauseAudio.setLoaded(true,function():void
               {
                  _pauseAudio.play(PauseAudio.SFX_MENU_ON,Nullable.NULL_FUNCTION);
                  _pauseMenu.show(function():void
                  {
                     dispatchEvent(new EventWithData(EVENT_PAUSE_MENU_VISIBILITY,{"isVisible":true}));
                  },null);
               });
            }
            else
            {
               _pauseAudio.play(PauseAudio.SFX_MENU_OFF,Nullable.NULL_FUNCTION);
               _pauseMenu.dismiss(function():void
               {
                  _disposeAudio();
                  LocalizationManager.GameSource = _callingGameName;
                  dispatchEvent(new EventWithData(EVENT_PAUSE_MENU_VISIBILITY,{"isVisible":false}));
                  dispatchEvent(new EventWithData(EVENT_PAUSE_MENU_DONE,null));
               },null);
            }
         },isShown);
      }
   }
}

