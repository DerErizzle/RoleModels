package jackboxgames.ui.settings
{
   import flash.display.*;
   import flash.utils.*;
   import jackboxgames.events.*;
   import jackboxgames.expressionparser.*;
   import jackboxgames.intermoviecommunication.*;
   import jackboxgames.localizy.*;
   import jackboxgames.settings.*;
   import jackboxgames.text.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   import jackboxgames.utils.audiosystem.*;
   
   public class SettingsMenu extends IMCModule implements ISettingsMenuItemDelegate
   {
      private static var _instance:SettingsMenu;
      
      public static const SETTINGS_LOCALIZATION_SOURCE:String = "Manager";
      
      private static const NUM_VISIBLE_ROWS:int = 6;
      
      private static const TAB_PADDING:Number = 16;
      
      public static const EVENT_OPENING:String = "SettingsMenu.Opening";
      
      public static const EVENT_OPENED:String = "SettingsMenu.Opened";
      
      public static const EVENT_CLOSING:String = "SettingsMenu.Closing";
      
      public static const EVENT_CLOSED:String = "SettingsMenu.Closed";
      
      public static const ITEM_TYPE_TOGGLE:String = "Toggle";
      
      public static const ITEM_TYPE_RANGE:String = "Range";
      
      public static const ITEM_TYPE_LIST:String = "List";
      
      public static const ITEM_TYPE_WIDE_LIST:String = "WideList";
      
      public static const ITEM_TYPE_PASSWORD:String = "Password";
      
      public static const ITEM_TYPE_LANGUAGE:String = "Language";
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _passwordManager:RoomPasswordManager;
      
      private var _closeShower:MovieClipShower;
      
      private var _tabContainerMc:MovieClip;
      
      private var _paneMC:MovieClip;
      
      private var _rowHeight:Number;
      
      private var _expressionDataDelegate:IExpressionDataDelegate;
      
      private var _currentContext:String;
      
      private var _listeningForInput:Boolean;
      
      private var _configs:SettingsMenuConfigSet;
      
      private var _activeConfig:SettingsMenuConfig;
      
      private var _currentTabButtons:Array;
      
      private var _currentItems:Array;
      
      private var _directions:Array;
      
      private var _currentTab:SettingsMenuConfigTab;
      
      private var _selectedItem:SettingsMenuItem;
      
      private var _isOpen:Boolean;
      
      private var _warningTf:ExtendableTextField;
      
      private var _audioHandler:SettingsMenuAudio;
      
      public function SettingsMenu()
      {
         super("SettingsMenu",IMCModule.MOVIE_ID_MANAGER);
         this._isOpen = false;
      }
      
      public static function initialize() : void
      {
         if(Boolean(_instance))
         {
            return;
         }
         _instance = new SettingsMenu();
      }
      
      public static function get instance() : SettingsMenu
      {
         return _instance;
      }
      
      public function get currentContext() : String
      {
         return this._currentContext;
      }
      
      private function get _numVisibleRows() : int
      {
         return NUM_VISIBLE_ROWS;
      }
      
      private function _getRowHeight() : Number
      {
         return this._rowHeight;
      }
      
      private function _getDirectionsForItem(item:SettingsMenuItem) : SettingsMenuItemDirections
      {
         return ArrayUtil.find(this._directions,function(d:SettingsMenuItemDirections, ... args):Boolean
         {
            return d.from == item;
         });
      }
      
      public function initWithMc(mc:MovieClip, passwordManager:RoomPasswordManager) : void
      {
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._passwordManager = passwordManager;
         this._closeShower = new MovieClipShower(BuildConfig.instance.configVal("uiNotchTopCenter") ? this._mc.base.closeLeft : this._mc.base.close);
         this._warningTf = ETFHelperUtil.buildExtendableTextFieldFromHelper(this._mc.base.warningTf.helper);
         this._currentItems = [];
         this._currentTabButtons = [];
         this._selectedItem = null;
         this._directions = [];
         this._tabContainerMc = this._mc.base.tabs;
         this._paneMC = this._mc.base.listPane.pane;
         var d:MultipleDataDelegate = new MultipleDataDelegate();
         d.add(BuildConfig.instance);
         d.add(new PropertyDataDelegate(this));
         this._expressionDataDelegate = d;
         SettingsManager.instance.addEventListener(SettingsManager.EVENT_SETTING_CHANGED,this._onSettingChanged);
      }
      
      private function _reset() : void
      {
         JBGUtil.reset([this._shower,this._closeShower]);
         this._setListeningForInput(false);
         this._disposeOfItems();
         this._disposeOfTabs();
         this._disposeAudio();
         this._activeConfig = null;
         this._currentTab = null;
         this._selectedItem = null;
         this._isOpen = false;
      }
      
      public function reset() : void
      {
         _doFunctionBehavior("reset",function():void
         {
            _reset();
         });
      }
      
      public function setConfigs(configs:SettingsMenuConfigSet) : void
      {
         _doFunctionBehavior("setConfigs",function(configs:SettingsMenuConfigSet):void
         {
            _configs = configs;
         },configs);
      }
      
      private function _changeSelection(item:SettingsMenuItem) : void
      {
         if(item == this._selectedItem || !item)
         {
            return;
         }
         if(Boolean(this._selectedItem))
         {
            this._selectedItem.setHighlighted(false);
         }
         this._selectedItem = item;
         this._selectedItem.setHighlighted(true);
         this._playAudio(SettingsMenuAudio.SFX_ITEM_HIGHLIGHT);
      }
      
      public function prepare(context:String, configName:String) : void
      {
         _doFunctionBehavior("prepare",function(context:String, configName:String):void
         {
            _currentTab = null;
            _selectedItem = null;
            _currentContext = context;
            _activeConfig = _configs.getConfig(configName);
            _warningTf.text = LocalizationManager.instance.getValueForKey("SETTINGS_WARNING_" + context.toUpperCase(),SETTINGS_LOCALIZATION_SOURCE);
            _disposeOfTabs();
            _buildTabs();
            _switchToTab(ArrayUtil.first(_activeConfig.tabs));
            _changeSelection(ArrayUtil.first(_currentTabButtons));
         },context,configName);
      }
      
      private function _buildTabs() : void
      {
         var currentX:Number = NaN;
         currentX = 0;
         this._currentTabButtons = this._activeConfig.tabs.map(function(tab:SettingsMenuConfigTab, i:int, a:Array):SettingsMenuItem
         {
            var item:* = _buildTab(tab);
            _tabContainerMc.addChild(item.mc);
            item.mc.x = currentX;
            currentX += item.width;
            currentX += TAB_PADDING;
            item.update();
            return item;
         });
         this._directions = this._directions.concat(this._currentTabButtons.map(function(item:SettingsMenuItem, i:int, a:Array):SettingsMenuItemDirections
         {
            var d:* = new SettingsMenuItemDirections(item);
            if(a.length == 1)
            {
               return d;
            }
            if(i > 0)
            {
               d.setDirection(UserInputDirector.INPUT_LEFT,a[i - 1]);
            }
            if(i < a.length - 1)
            {
               d.setDirection(UserInputDirector.INPUT_RIGHT,a[i + 1]);
            }
            return d;
         }));
      }
      
      private function _buildTab(tab:SettingsMenuConfigTab) : SettingsMenuItem
      {
         var c:Class = Class(getDefinitionByName("SettingsTabWidget"));
         var itemMc:MovieClip = new c();
         LocalizedTextFieldManager.instance.addFromRoot(itemMc,SETTINGS_LOCALIZATION_SOURCE);
         return new SettingsMenuTabButton(itemMc,tab,this);
      }
      
      private function _disposeOfTabs() : void
      {
         if(this._currentTabButtons.length == 0)
         {
            return;
         }
         this._tabContainerMc.removeChildren();
         this._currentTabButtons.forEach(function(item:SettingsMenuTabButton, ... args):void
         {
            item.dispose();
         });
         this._directions = this._directions.filter(function(d:SettingsMenuItemDirections, ... args):Boolean
         {
            return !ArrayUtil.arrayContainsElement(_currentTabButtons,d.from);
         });
         this._currentTabButtons = [];
      }
      
      private function _getButtonForConfigTab(tab:SettingsMenuConfigTab) : SettingsMenuTabButton
      {
         return ArrayUtil.find(this._currentTabButtons,function(tb:SettingsMenuTabButton, ... args):Boolean
         {
            return tb.data == tab;
         });
      }
      
      private function _switchToTab(tab:SettingsMenuConfigTab) : void
      {
         var itemsInTab:Array;
         this._changeSelection(this._getButtonForConfigTab(tab));
         this._disposeOfItems();
         if(Boolean(this._currentTab))
         {
            this._getButtonForConfigTab(this._currentTab).setSelected(false);
         }
         this._currentTab = tab;
         this._getButtonForConfigTab(this._currentTab).setSelected(true);
         this._playAudio(SettingsMenuAudio.SFX_TAB_SELECT);
         itemsInTab = this._currentTab.sources.map(function(source:String, ... args):SettingsMenuConfigItem
         {
            return ArrayUtil.find(_activeConfig.items,function(item:SettingsMenuConfigItem, ... args):Boolean
            {
               return item.source == source;
            });
         }).filter(function(item:SettingsMenuConfigItem, ... args):Boolean
         {
            return item != null;
         });
         this._buildItems(itemsInTab);
      }
      
      private function _buildItem(ci:SettingsMenuConfigItem) : SettingsMenuItem
      {
         var c:Class = Class(getDefinitionByName("Settings" + ci.type + "Widget"));
         var itemMc:MovieClip = new c();
         LocalizedTextFieldManager.instance.addFromRoot(itemMc,SETTINGS_LOCALIZATION_SOURCE);
         switch(ci.type)
         {
            case ITEM_TYPE_RANGE:
               return new SettingsMenuRangeItem(itemMc,ci,this);
            case ITEM_TYPE_LIST:
            case ITEM_TYPE_WIDE_LIST:
               return new SettingsMenuListItem(itemMc,ci,this);
            case ITEM_TYPE_PASSWORD:
               return new SettingsMenuPasswordItem(itemMc,ci,this,this._passwordManager);
            case ITEM_TYPE_LANGUAGE:
               return new SettingsMenuLanguageItem(itemMc,ci,this);
            case ITEM_TYPE_TOGGLE:
               return new SettingsMenuToggleItem(itemMc,ci,this);
            default:
               Assert.assert(false);
               return null;
         }
      }
      
      private function _buildItems(configItems:Array) : void
      {
         var currentY:Number = NaN;
         var firstEnabled:SettingsMenuItem = null;
         var getItemInDirection:Function = function(start:int, dir:int):SettingsMenuItem
         {
            var index:int = start + dir;
            while(index >= -1 && index < _currentItems.length)
            {
               if(index == -1)
               {
                  return _currentTabButtons[_activeConfig.tabs.indexOf(_currentTab)];
               }
               if(Boolean(_currentItems[index].enabled))
               {
                  return _currentItems[index];
               }
               index += dir;
            }
            return null;
         };
         currentY = 0;
         this._currentItems = configItems.map(function(ci:SettingsMenuConfigItem, ... args):SettingsMenuItem
         {
            var item:* = _buildItem(ci);
            if(!ci.getIsEnabled(_expressionDataDelegate))
            {
               item.setEnabled(false);
            }
            _paneMC.addChild(item.mc);
            item.mc.y = currentY;
            currentY += item.height;
            item.update(true);
            return item;
         });
         this._directions = this._directions.concat(this._currentItems.map(function(item:SettingsMenuItem, i:int, a:Array):SettingsMenuItemDirections
         {
            var d:* = new SettingsMenuItemDirections(item);
            var upItem:* = getItemInDirection(i,-1);
            var downItem:* = getItemInDirection(i,1);
            if(upItem)
            {
               d.setDirection(UserInputDirector.INPUT_UP,upItem);
            }
            if(downItem)
            {
               d.setDirection(UserInputDirector.INPUT_DOWN,downItem);
            }
            return d;
         }));
         firstEnabled = ArrayUtil.find(this._currentItems,function(item:SettingsMenuItem, ... args):Boolean
         {
            return item.enabled;
         });
         this._currentTabButtons.forEach(function(tb:SettingsMenuTabButton, ... args):void
         {
            _getDirectionsForItem(tb).setDirection(UserInputDirector.INPUT_DOWN,firstEnabled);
         });
         this._rowHeight = this._currentItems.length > 0 ? Number(ArrayUtil.first(this._currentItems).mc.height) : 0;
      }
      
      private function _disposeOfItems() : void
      {
         if(this._currentItems.length == 0)
         {
            return;
         }
         this._paneMC.removeChildren();
         this._currentItems.forEach(function(item:SettingsMenuItem, ... args):void
         {
            item.dispose();
         });
         this._directions = this._directions.filter(function(d:SettingsMenuItemDirections, ... args):Boolean
         {
            return !ArrayUtil.arrayContainsElement(_currentItems,d.from);
         });
         this._currentItems = [];
      }
      
      public function open() : void
      {
         _doFunctionBehavior("open",function():void
         {
            _isOpen = true;
            _prepareAudio(function():void
            {
               _setListeningForInput(true);
               LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,_onLocaleChanged);
               _onLocaleChanged(null);
               _playAudio(SettingsMenuAudio.SFX_MENU_ON);
               _closeShower.setShown(true,Nullable.NULL_FUNCTION);
               _shower.setShown(true,function():void
               {
                  dispatchEvent(new EventWithData(EVENT_OPENED,null));
               });
            });
            dispatchEvent(new EventWithData(EVENT_OPENING,null));
         });
      }
      
      public function closeIfOpen() : void
      {
         _doFunctionBehavior("closeIfOpen",function():void
         {
            if(_isOpen)
            {
               _close();
            }
         });
      }
      
      private function _close() : void
      {
         var _this:SettingsMenu = null;
         this._setListeningForInput(false);
         this._closeShower.setShown(false,Nullable.NULL_FUNCTION);
         LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this._onLocaleChanged);
         this._playAudio(SettingsMenuAudio.SFX_MENU_OFF);
         _this = this;
         this._shower.setShown(false,function():void
         {
            _disposeAudio();
            _this.dispatchEvent(new EventWithData(EVENT_CLOSED,null));
         });
         this._isOpen = false;
         dispatchEvent(new EventWithData(EVENT_CLOSING,null));
      }
      
      private function _onSettingChanged(evt:EventWithData) : void
      {
         if(this._isOpen)
         {
            switch(evt.data.settingName)
            {
               case SettingsConstants.SETTING_FULL_SCREEN:
                  this._playAudio(SettingsMenuAudio.SFX_ITEM_FULLSCREEN_TOGGLE);
                  break;
               case SettingsConstants.SETTING_VOLUME:
                  this._playAudio(SettingsMenuAudio.SFX_VOLUME_MASTER_CHANGED);
                  break;
               case SettingsConstants.SETTING_VOLUME_HOST:
                  AudioSystemUtil.setFaderGroupVolume(AudioSystemUtil.FADER_GROUP_NAME_HOST,evt.data.setting.val);
                  this._playAudio(SettingsMenuAudio.SFX_VOLUME_HOST_CHANGED);
                  break;
               case SettingsConstants.SETTING_VOLUME_MUSIC:
                  AudioSystemUtil.setFaderGroupVolume(AudioSystemUtil.FADER_GROUP_NAME_MUSIC,evt.data.setting.val);
                  this._playAudio(SettingsMenuAudio.SFX_VOLUME_MUSIC_CHANGED);
                  break;
               case SettingsConstants.SETTING_VOLUME_SFX:
                  AudioSystemUtil.setFaderGroupVolume(AudioSystemUtil.FADER_GROUP_NAME_SFX,evt.data.setting.val);
                  this._playAudio(SettingsMenuAudio.SFX_VOLUME_SFX_CHANGED);
                  break;
               case SettingsConstants.SETTING_PLAYER_CONTENT_FILTERING:
               case SettingsConstants.SETTING_MAX_PLAYERS:
               case LocalizationManager.SETTING_LOCALE:
                  this._playAudio(SettingsMenuAudio.SFX_ITEM_WIDELIST_TOGGLE);
                  break;
               default:
                  this._playAudio(SettingsMenuAudio.SFX_ITEM_TOGGLE);
            }
         }
      }
      
      private function _setListeningForInput(val:Boolean) : void
      {
         if(val == this._listeningForInput)
         {
            return;
         }
         this._listeningForInput = val;
         if(this._listeningForInput)
         {
            UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,this._onGamepad);
         }
         else
         {
            UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._onGamepad);
         }
      }
      
      private function _onGamepad(evt:EventWithData) : void
      {
         var dir:String = null;
         var inputs:Array = evt.data.inputs;
         if(UserInputUtil.inputsContain(inputs,UserInputDirector.INPUT_BACK))
         {
            this._close();
            return;
         }
         this._selectedItem.onGamepadInput(inputs);
         var d:SettingsMenuItemDirections = this._getDirectionsForItem(this._selectedItem);
         for each(dir in UserInputDirector.DIRECTIONAL_INPUTS)
         {
            if(UserInputUtil.inputsContain(inputs,dir) && d.hasDirection(dir))
            {
               this._changeSelection(d.getItemInDirection(dir));
               break;
            }
         }
      }
      
      private function _onLocaleChanged(event:EventWithData) : void
      {
         this._currentItems.forEach(function(item:SettingsMenuItem, ... args):void
         {
            item.onLocaleChanged();
         });
         this._currentTabButtons.forEach(function(item:SettingsMenuTabButton, ... args):void
         {
            item.onLocaleChanged();
         });
      }
      
      public function get isListeningForInput() : Boolean
      {
         return this._listeningForInput;
      }
      
      public function handleSelectionRequest(item:SettingsMenuItem) : void
      {
         this._changeSelection(item);
      }
      
      public function handleSwitchToTabRequest(tab:SettingsMenuConfigTab) : void
      {
         this._switchToTab(tab);
      }
      
      private function _disposeAudio() : void
      {
         JBGUtil.dispose([this._audioHandler]);
         this._audioHandler = null;
      }
      
      private function _prepareAudio(doneFn:Function) : void
      {
         this._disposeAudio();
         this._audioHandler = new SettingsMenuAudio();
         this._audioHandler.setLoaded(true,doneFn);
      }
      
      private function _playAudio(key:String) : void
      {
         if(Boolean(this._audioHandler))
         {
            this._audioHandler.play(key,Nullable.NULL_FUNCTION);
         }
      }
   }
}

class SettingsMenuItemDirections
{
   private var _from:SettingsMenuItem;
   
   private var _to:Object;
   
   public function SettingsMenuItemDirections(from:SettingsMenuItem)
   {
      super();
      this._from = from;
      this._to = {};
   }
   
   public function get from() : SettingsMenuItem
   {
      return this._from;
   }
   
   public function setDirection(dir:String, item:SettingsMenuItem) : void
   {
      this._to[dir] = item;
   }
   
   public function hasDirection(dir:String) : Boolean
   {
      return dir in this._to;
   }
   
   public function getItemInDirection(dir:String) : SettingsMenuItem
   {
      return this._to[dir];
   }
}

