package jackboxgames.ui.menu
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.engine.*;
   import jackboxgames.logger.*;
   import jackboxgames.model.*;
   import jackboxgames.settings.*;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.ui.menu.components.*;
   import jackboxgames.utils.*;
   
   public class DefaultMainMenu implements IMainMenu
   {
      protected var _mc:MovieClip;
      
      protected var _components:Array;
      
      protected var _canPause:Boolean;
      
      private var _listLogic:IMainMenuListLogic;
      
      private var _settingsLogic:IMainMenuSettingsLogic;
      
      private var _audioHandler:IMainMenuAudioHandler;
      
      private var _selectButton:IMainMenuSelectButton;
      
      private var _menuSelectedIndex:int;
      
      public function DefaultMainMenu(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._components = [];
         this._menuSelectedIndex = 0;
         this._canPause = BuildConfig.instance.configVal("needExitbutton") == true || BuildConfig.instance.configVal("isBundle") == true;
         this._listLogic = this._createList();
         this._audioHandler = this._createAudioHandler();
         this._selectButton = this._createSelectButton();
         this._settingsLogic = this._createSettings();
      }
      
      public function get selectedIndex() : int
      {
         return this._menuSelectedIndex;
      }
      
      public function get selectedItem() : IMainMenuItem
      {
         return this.items[this.selectedIndex];
      }
      
      public function get items() : Array
      {
         return this._listLogic.itemsInUse;
      }
      
      protected function set listenForInput(listenForInput:Boolean) : void
      {
         this._listLogic.listenForInput = listenForInput;
      }
      
      protected function _getItemClass() : Class
      {
         return DefaultMainMenuItem;
      }
      
      protected function _createList() : IMainMenuListLogic
      {
         return new DefaultMainMenuListLogic(this._mc,this,this._getItemClass());
      }
      
      protected function _createAudioHandler() : IMainMenuAudioHandler
      {
         return new AudioEventMainMenuAudioHandler();
      }
      
      protected function _createSelectButton() : IMainMenuSelectButton
      {
         return new DefaultMainMenuSelectButton(this._mc.select,this);
      }
      
      protected function _createSettings() : IMainMenuSettingsLogic
      {
         return new DefaultMainMenuSettingsLogic(this);
      }
      
      public function init(doneFn:Function) : void
      {
         this._listLogic.init(function():void
         {
            _settingsLogic.init(doneFn);
         });
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._listLogic,this._selectButton]);
         this._audioHandler.shutdown();
         this._selectButton.reset();
         this._settingsLogic.reset();
         GameEngine.instance.removeEventListener("resume",this.onResume);
         GameEngine.instance.removeEventListener("pause",this.onPause);
      }
      
      public function handleActionShowMenu(ref:IActionRef, params:Object) : void
      {
         this.show(TSUtil.createRefEndFn(ref),params);
      }
      
      public function handleActionDismissMenu(ref:IActionRef, params:Object) : void
      {
         this.dismiss(TSUtil.createRefEndFn(ref),params);
      }
      
      public function show(doneFn:Function, params:Object) : void
      {
         this._audioHandler.setup(params);
         this._selectButton.show(Nullable.NULL_FUNCTION,params);
         GameEngine.instance.setPauseEnabled(this._canPause);
         GameEngine.instance.setPauseContext("menu");
         GameEngine.instance.addEventListener("pause",this.onPause);
         this._listLogic.show(doneFn,params);
      }
      
      public function dismiss(doneFn:Function, params:Object) : void
      {
         this._selectButton.dismiss(Nullable.NULL_FUNCTION,params);
         if(Boolean(this._settingsLogic))
         {
            this._settingsLogic.dismiss(Nullable.NULL_FUNCTION,params);
         }
         GameEngine.instance.removeEventListener("pause",this.onPause);
         this._listLogic.dismiss(doneFn,params);
      }
      
      public function onMainMenuHighlight(currentIndex:int, newIndex:int) : void
      {
         if(newIndex != this._menuSelectedIndex)
         {
            this.selectedItem.unhighlight(Nullable.NULL_FUNCTION);
         }
         this._menuSelectedIndex = newIndex;
         this._audioHandler.onMenuHighlightChanged(this._menuSelectedIndex,newIndex);
         this.selectedItem.highlight(Nullable.NULL_FUNCTION);
      }
      
      public function onMainMenuSelect(index:int, action:String) : void
      {
         if(index != this._menuSelectedIndex)
         {
            this.onMainMenuHighlight(this._menuSelectedIndex,index);
         }
         this._audioHandler.onMenuItemSelected(this._menuSelectedIndex,action);
         this.selectedItem.select(Nullable.NULL_FUNCTION);
         if(!this.hasOwnProperty(action) || this[action] == null || !(this[action] is Function))
         {
            return;
         }
         this[action]();
      }
      
      public function onSettingChanged(settingName:String, setting:SettingsValue) : void
      {
         this._audioHandler.onSettingToggled(settingName,setting);
      }
      
      public function onSettingHighlight(currentIndex:int, newIndex:int) : void
      {
         this._audioHandler.onSettingsMenuHighlightChanged(currentIndex,newIndex);
      }
      
      public function onSettingsShown() : void
      {
         if(Boolean(this._settingsLogic))
         {
            this._settingsLogic.onSettingsShown();
         }
         this._audioHandler.onSettingsMenuShownChanged(true);
      }
      
      public function onSettingsClosing() : void
      {
         this._audioHandler.onSettingsMenuShownChanged(false);
      }
      
      public function onSettingsClosed() : void
      {
      }
      
      public function disableMenu() : void
      {
         this._listLogic.listenForInput = false;
         GameEngine.instance.setPauseEnabled(false);
      }
      
      public function enableMenu() : void
      {
         this._listLogic.listenForInput = true;
         GameEngine.instance.setPauseEnabled(this._canPause);
         this.selectedItem.highlight(Nullable.NULL_FUNCTION);
      }
      
      public function doPlayGame() : void
      {
         this.disableMenu();
         GameEngine.instance.removeEventListener("pause",this.onResume);
         TSUtil.safeInput("PlayGame");
      }
      
      public function doSettings() : void
      {
         this.disableMenu();
         this.onSettingsShown();
      }
      
      public function doBackToPack() : void
      {
         GameEngine.instance.setPauseEnabled(this._canPause);
         GameEngine.instance.pause();
      }
      
      public function doNothing() : void
      {
      }
      
      public function onPause(evt:Event) : void
      {
         this._listLogic.listenForInput = false;
         GameEngine.instance.addEventListener("resume",this.onResume);
      }
      
      public function onResume(evt:Event) : void
      {
         this._listLogic.listenForInput = true;
         GameEngine.instance.removeEventListener("resume",this.onResume);
         this.selectedItem.highlight(Nullable.NULL_FUNCTION);
      }
   }
}

