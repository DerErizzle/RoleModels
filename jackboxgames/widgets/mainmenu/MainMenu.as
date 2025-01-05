package jackboxgames.widgets.mainmenu
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import jackboxgames.engine.GameEngine;
   import jackboxgames.events.*;
   import jackboxgames.localizy.LocalizedTextFieldManager;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.utils.*;
   import jackboxgames.widgets.Menu;
   
   public class MainMenu
   {
       
      
      private var _mc:MovieClip;
      
      private var _audioHandler:IMainMenuAudioHandler;
      
      private var _mainMenu:Menu;
      
      private var _settingsMenu:DynamicSettingsMenu;
      
      private var _selectButton:PlatformButton;
      
      public function MainMenu(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._mainMenu = new Menu(this._mc.menu);
         this._settingsMenu = new DynamicSettingsMenu(this._mc.settings.base);
         this._selectButton = new PlatformButton(this._mc.select,this._mc.select.container.button,["SELECT","A"]);
         LocalizedTextFieldManager.instance.add([this._mc.select.container.tf]);
         this._audioHandler = new AudioEventMainMenuAudioHandler();
      }
      
      public function setAudioHandler(val:IMainMenuAudioHandler) : void
      {
         this._audioHandler = val;
      }
      
      public function get mainMenu() : Menu
      {
         return this._mainMenu;
      }
      
      public function get settingsMenu() : DynamicSettingsMenu
      {
         return this._settingsMenu;
      }
      
      public function init(callback:Function) : void
      {
         this._mainMenu.setup(function():void
         {
            _settingsMenu.setup(function():void
            {
               callback();
            });
         });
      }
      
      public function reset() : void
      {
         JBGUtil.arrayGotoFrame([this._mc.select],"Park");
         GameEngine.instance.removeEventListener("resume",this._onResumeMenu);
         GameEngine.instance.removeEventListener("pause",this._onPauseMenu);
         this._audioHandler.shutdown();
      }
      
      public function handleActionShowMenu(ref:IActionRef, params:Object) : void
      {
         this._audioHandler.setup(params);
         this._mainMenu.show(function():void
         {
            _mainMenu.addEventListener(Menu.EVENT_ITEM_SELECTED,_onMenuItemSelected);
            ref.end();
         });
         JBGUtil.gotoFrame(this._mc.select,"Appear");
         this._mainMenu.addEventListener(Menu.EVENT_HIGHLIGHTED_ITEM_CHANGED,this._onMenuHighlightChanged);
         GameEngine.instance.setPauseEnabled(true);
         GameEngine.instance.setPauseType("kill");
         GameEngine.instance.addEventListener("pause",this._onPauseMenu);
      }
      
      private function _onMenuHighlightChanged(evt:EventWithData) : void
      {
         this._audioHandler.onMenuHighlightChanged(evt.data.newSelected,evt.data.oldSelected);
      }
      
      protected function _onSettingChanged(evt:EventWithData) : void
      {
         this._audioHandler.onSettingToggled(evt.data.settingName,evt.data.setting);
      }
      
      protected function _setupSoundListenersForSettings(on:Boolean) : void
      {
         if(on)
         {
            SettingsManager.instance.addEventListener(SettingsManager.EVENT_SETTING_CHANGED,this._onSettingChanged);
         }
         else
         {
            SettingsManager.instance.removeEventListener(SettingsManager.EVENT_SETTING_CHANGED,this._onSettingChanged);
         }
      }
      
      private function _onSettingsMenuHighlightChanged(evt:EventWithData) : void
      {
         this._audioHandler.onSettingsMenuHighlightChanged(evt.data.newSelected,evt.data.oldSelected);
      }
      
      public function handleActionDismissMenu(ref:IActionRef, params:Object) : void
      {
         this._mainMenu.removeEventListener(Menu.EVENT_HIGHLIGHTED_ITEM_CHANGED,this._onMenuHighlightChanged);
         this._settingsMenu.removeEventListener(DynamicSettingsMenu.EVENT_HIGHLIGHTED_ITEM_CHANGED,this._onSettingsMenuHighlightChanged);
         this._setupSoundListenersForSettings(false);
         this._mainMenu.dismiss(function():void
         {
            ref.end();
         });
      }
      
      public function doPlayGame() : void
      {
         this._mainMenu.listenForInput = false;
         GameEngine.instance.setPauseEnabled(false);
         JBGUtil.gotoFrame(this._mc.select,"Disappear");
         GameEngine.instance.removeEventListener("pause",this._onPauseMenu);
         TSUtil.safeInput("PlayGame");
      }
      
      public function doUGC() : void
      {
         this._mainMenu.listenForInput = false;
         GameEngine.instance.setPauseEnabled(false);
         Platform.instance.checkPrivilege("UGC",function(success:Boolean):void
         {
            if(!success)
            {
               _mainMenu.listenForInput = true;
               GameEngine.instance.setPauseEnabled(true);
               return;
            }
            JBGUtil.gotoFrame(_mc.select,"Disappear");
            GameEngine.instance.removeEventListener("pause",_onPauseMenu);
            TSUtil.safeInput("Create");
         });
      }
      
      public function doSettings() : void
      {
         JBGUtil.gotoFrame(this._mc.select,"Disappear");
         this._mainMenu.listenForInput = false;
         GameEngine.instance.setPauseEnabled(false);
         this._audioHandler.onSettingsMenuShownChanged(true);
         this._settingsMenu.addEventListener(DynamicSettingsMenu.EVENT_HIGHLIGHTED_ITEM_CHANGED,this._onSettingsMenuHighlightChanged);
         this._setupSoundListenersForSettings(true);
         this._settingsMenu.show(null);
         JBGUtil.eventOnce(this._settingsMenu,DynamicSettingsMenu.EVENT_CLOSING,function(evt:Event):void
         {
            _audioHandler.onSettingsMenuShownChanged(false);
         });
         JBGUtil.eventOnce(this._settingsMenu,DynamicSettingsMenu.EVENT_CLOSED,function(evt:Event):void
         {
            _mainMenu.listenForInput = true;
            GameEngine.instance.setPauseEnabled(true);
            _settingsMenu.removeEventListener(DynamicSettingsMenu.EVENT_HIGHLIGHTED_ITEM_CHANGED,_onSettingsMenuHighlightChanged);
            _setupSoundListenersForSettings(false);
            JBGUtil.gotoFrame(_mc.select,"Appear");
         });
      }
      
      public function doBackToPack() : void
      {
         this._mainMenu.listenForInput = false;
         GameEngine.instance.addEventListener("resume",this._onResumeMenu);
         GameEngine.instance.pause();
      }
      
      public function doNothing() : void
      {
      }
      
      private function _onMenuItemSelected(evt:EventWithData) : void
      {
         this._audioHandler.onMenuItemSelected(evt.data.choice,evt.data.action);
         this[evt.data.action]();
      }
      
      private function _onPauseMenu(evt:Event) : void
      {
         this._mainMenu.listenForInput = false;
         GameEngine.instance.addEventListener("resume",this._onResumeMenu);
      }
      
      private function _onResumeMenu(evt:Event) : void
      {
         this._mainMenu.listenForInput = true;
         GameEngine.instance.removeEventListener("resume",this._onResumeMenu);
      }
   }
}
