package jackboxgames.pause
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.events.*;
   import jackboxgames.expressionparser.*;
   import jackboxgames.localizy.*;
   import jackboxgames.settings.*;
   import jackboxgames.ui.menu.*;
   import jackboxgames.ui.menu.components.*;
   import jackboxgames.ui.settings.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class PauseMenu implements IMainMenu
   {
      private var _mc:MovieClip;
      
      private var _canPause:Boolean;
      
      private var _expressionDelegate:IExpressionDataDelegate;
      
      private var _settingsLogic:IMainMenuSettingsLogic;
      
      private var _menuSelectedIndex:int;
      
      private var _listLogic:PauseMenuListLogic;
      
      private var _menuShower:MovieClipShower;
      
      private var _titleShower:MovieClipShower;
      
      private var _backShower:MovieClipShower;
      
      private var _selectShower:MovieClipShower;
      
      private var _backgroundShower:MovieClipShower;
      
      private var _showers:Array;
      
      private var _showersInUse:Array;
      
      private var _confirmation:PauseConfirmation;
      
      private var _listenForinput:Boolean;
      
      private var _context:String;
      
      public function PauseMenu(mc:MovieClip)
      {
         super();
         this._mc = mc.pauseMenu;
         this._expressionDelegate = new PropertyDataDelegate(this);
         this._menuSelectedIndex = 0;
         this._canPause = BuildConfig.instance.configVal("needExitbutton") == true || BuildConfig.instance.configVal("isBundle") == true;
         LocalizedTextFieldManager.instance.addFromRoot(this._mc,PauseMenuManager.PAUSE_MENU_NAME);
         ButtonCalloutManager.instance.addFromRoot(this._mc,PauseMenuManager.PAUSE_MENU_NAME);
         this._listLogic = PauseMenuListLogic(this._createList());
         this._menuShower = this._createShowerForClip(this._mc);
         this._titleShower = this._createShowerForClip(this._mc.title);
         this._backShower = this._createShowerForClip(BuildConfig.instance.configVal("uiNotchTopCenter") ? this._mc.backLeft : this._mc.back);
         this._selectShower = this._createShowerForClip(this._mc.select);
         this._backgroundShower = this._createShowerForClip(this._mc.background);
         this._showers = [this._titleShower,this._backShower,this._selectShower,this._backgroundShower,this._menuShower].filter(function(shower:MovieClipShower, ... args):Boolean
         {
            return shower != null;
         });
         this._confirmation = new PauseConfirmation(mc.confirmation);
      }
      
      public function get listLogic() : DefaultMainMenuListLogic
      {
         return this._listLogic;
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
      
      public function get context() : String
      {
         return this._context;
      }
      
      protected function _getItemClass() : Class
      {
         return DefaultMainMenuItem;
      }
      
      protected function _createSettings() : IMainMenuSettingsLogic
      {
         return new DefaultMainMenuSettingsLogic(this);
      }
      
      private function _createShowerForClip(mc:MovieClip) : MovieClipShower
      {
         if(mc == null)
         {
            return null;
         }
         return new MovieClipShower(mc);
      }
      
      protected function _createList() : IMainMenuListLogic
      {
         this._listLogic = new PauseMenuListLogic(this._mc,this,this._getItemClass(),Duration.ZERO);
         this._listLogic.configFile = PauseMenuManager.PAUSE_MENU_DATA_FILE;
         return this._listLogic;
      }
      
      public function reset() : void
      {
         this.listenForInput = false;
         JBGUtil.reset(this._showers);
         JBGUtil.reset([this._listLogic]);
      }
      
      public function init(doneFn:Function) : void
      {
         this._listLogic.init(doneFn);
      }
      
      public function onMainMenuHighlight(currentIndex:int, newIndex:int) : void
      {
         if(newIndex != this._menuSelectedIndex)
         {
            this.selectedItem.unhighlight(Nullable.NULL_FUNCTION);
         }
         this._menuSelectedIndex = newIndex;
         PauseMenuManager.instance.menuItemHighlighted(currentIndex,newIndex);
         this.selectedItem.highlight(Nullable.NULL_FUNCTION);
      }
      
      public function onSettingChanged(settingName:String, setting:SettingsValue) : void
      {
      }
      
      public function onSettingHighlight(currentIndex:int, newIndex:int) : void
      {
      }
      
      public function onSettingsShown() : void
      {
         if(Boolean(this._settingsLogic))
         {
            this._settingsLogic.onSettingsShown();
         }
      }
      
      public function onSettingsClosing() : void
      {
      }
      
      public function onSettingsClosed() : void
      {
      }
      
      public function disableMenu() : void
      {
         this._listLogic.listenForInput = false;
      }
      
      public function enableMenu() : void
      {
         this._listLogic.listenForInput = true;
         this.selectedItem.highlight(Nullable.NULL_FUNCTION);
      }
      
      public function onPause(evt:Event) : void
      {
      }
      
      public function onResume(evt:Event) : void
      {
      }
      
      public function onMainMenuSelect(index:int, action:String) : void
      {
         var item:PauseMenuItemData;
         if(index != this._menuSelectedIndex)
         {
            this.onMainMenuHighlight(this._menuSelectedIndex,index);
         }
         this.selectedItem.select(Nullable.NULL_FUNCTION);
         item = new PauseMenuItemData(this._listLogic.config.items[index]);
         if(Boolean(item.confirmation))
         {
            JBGUtil.eventOnce(this._confirmation,PauseConfirmation.PAUSE_CONFIRMATION_EVENT,function(event:EventWithData):void
            {
               _confirmation.setShown(false,function():void
               {
                  PauseMenuManager.instance.menuItemConfirmed(event.data.value);
                  if(event.data.value == PauseConfirmation.PAUSE_CONFIRMATION_CANCELED)
                  {
                     listenForInput = true;
                     return;
                  }
                  PauseMenuManager.instance.menuItemSelected(index,action,false);
               });
            });
            this.listenForInput = false;
            this._confirmation.setup(item.confirmation,this._listLogic.config.gameName);
            this._confirmation.setShown(true,Nullable.NULL_FUNCTION);
            PauseMenuManager.instance.menuConfirmRequested();
         }
         else if(item.action == PauseMenuManager.PAUSE_ACTION_SETTINGS)
         {
            this.listenForInput = false;
            PauseMenuManager.instance.menuHide(true);
            this._menuShower.setShown(false,function():void
            {
               JBGUtil.eventOnce(SettingsMenu.instance,SettingsMenu.EVENT_CLOSED,function(evt:EventWithData):void
               {
                  PauseMenuManager.instance.menuHide(false);
                  _menuShower.setShown(true,function():void
                  {
                     listenForInput = true;
                  });
               });
               SettingsMenu.instance.prepare("pause","main");
               SettingsMenu.instance.open();
            });
         }
         else
         {
            PauseMenuManager.instance.menuItemSelected(index,action,true);
         }
      }
      
      private function _addShowerIfNeeded(needed:Boolean, shower:MovieClipShower) : void
      {
         if(needed && Boolean(shower))
         {
            this._showersInUse.push(shower);
         }
      }
      
      private function _selectShowersToUse(pauseMenuData:Object) : void
      {
         this._showersInUse = [];
         this._addShowerIfNeeded(true,this._menuShower);
         this._addShowerIfNeeded(true,this._titleShower);
         this._addShowerIfNeeded(!pauseMenuData.hideBackButton,this._backShower);
         this._addShowerIfNeeded(!pauseMenuData.hideSelectButton,this._selectShower);
         this._addShowerIfNeeded(!pauseMenuData.hideBackground,this._backgroundShower);
      }
      
      protected function set listenForInput(value:Boolean) : void
      {
         if(this._listenForinput == value)
         {
            return;
         }
         this._listenForinput = value;
         if(value)
         {
            this.enableMenu();
            UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,this._onGamepad);
         }
         else
         {
            this.disableMenu();
            UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._onGamepad);
         }
      }
      
      public function updateMenu(pauseMenuData:Object, context:String) : void
      {
         var parser:ExpressionParser = null;
         this._context = context;
         parser = new ExpressionParser();
         pauseMenuData.items = pauseMenuData.items.filter(function(itemData:Object, ... args):Boolean
         {
            var res:* = undefined;
            var exp:* = undefined;
            if(Boolean(itemData.hasOwnProperty("isValid")) && itemData.isValid is String)
            {
               res = parser.parse(itemData.isValid);
               if(Boolean(res.succeeded))
               {
                  exp = res.payload;
                  return exp.evaluate(_expressionDelegate);
               }
               Assert.assert(false,res.payload);
            }
            return true;
         });
         this._listLogic.initWithConfig(pauseMenuData,PauseMenuManager.PAUSE_MENU_NAME);
         this._selectShowersToUse(pauseMenuData);
         if(!this._backgroundShower)
         {
            return;
         }
         if(Boolean(pauseMenuData.gameName) && MovieClipUtil.frameExists(this._mc.background,"Appear" + pauseMenuData.gameName))
         {
            this._backgroundShower.behaviorTranslator = function(s:String):String
            {
               return s == "Appear" || s == "Disappear" ? s + pauseMenuData.gameName : s;
            };
         }
         else
         {
            this._backgroundShower.behaviorTranslator = null;
         }
      }
      
      public function show(doneFn:Function, params:Object) : void
      {
         var c:Counter = null;
         this._menuSelectedIndex = 0;
         c = new Counter(2,function():void
         {
            listenForInput = true;
            doneFn();
         });
         MovieClipShower.setMultiple(this._showersInUse,true,Duration.ZERO,c.generateDoneFn());
         LocalizationManager.instance.currentLocale = SettingsManager.instance.getValue(LocalizationManager.SETTING_LOCALE).val;
         this._listLogic.show(function():void
         {
            selectedItem.highlight(c.generateDoneFn());
         },params);
      }
      
      public function dismiss(doneFn:Function, params:Object) : void
      {
         var c:Counter;
         this.listenForInput = false;
         c = new Counter(1,doneFn);
         MovieClipShower.setMultiple(this._showersInUse,false,Duration.ZERO,c.generateDoneFn());
         this._listLogic.dismiss(function():void
         {
         },params);
      }
      
      private function _onGamepad(evt:EventWithData) : void
      {
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_BACK))
         {
            this.listenForInput = false;
            PauseMenuManager.instance.menuItemSelected(-1,PauseMenuManager.PAUSE_ACTION_RESUME,true);
         }
      }
   }
}

