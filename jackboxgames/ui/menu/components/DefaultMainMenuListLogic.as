package jackboxgames.ui.menu.components
{
   import flash.display.*;
   import flash.events.*;
   import jackboxgames.events.*;
   import jackboxgames.flash.*;
   import jackboxgames.loader.*;
   import jackboxgames.localizy.*;
   import jackboxgames.ui.menu.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class DefaultMainMenuListLogic implements IMainMenuListLogic
   {
      private static const DEFAULT_CONFIG_FILE:String = "menu.jet";
      
      public static const EVENT_ITEM_SELECTED:String = "Menu.ItemSelected";
      
      public static const EVENT_HIGHLIGHTED_ITEM_CHANGED:String = "Menu.HighlightedItemChanged";
      
      private var _source:String;
      
      protected var _mainMenu:IMainMenu;
      
      private var _mc:MovieClip;
      
      private var _itemClass:Class;
      
      private var _items:Array;
      
      private var _listeningForInput:Boolean = false;
      
      private var _animationDelay:Duration;
      
      private var _configFile:String = "menu.jet";
      
      private var _config:Object;
      
      public function DefaultMainMenuListLogic(mc:MovieClip, mainMenu:IMainMenu, itemClass:Class, animationDelay:Duration = null)
      {
         super();
         this._mc = mc.menu;
         this._mainMenu = mainMenu;
         this._itemClass = itemClass;
         this._animationDelay = Boolean(animationDelay) ? animationDelay.clone() : Duration.fromMs(200);
         this._items = JBGUtil.getPropertiesOfNameInOrder(this._mc,"item").map(function(clip:MovieClip, i:int, arr:Array):IMainMenuItem
         {
            return new _itemClass(clip);
         });
      }
      
      public function set configFile(val:String) : void
      {
         this._configFile = val;
      }
      
      public function get config() : Object
      {
         return this._config;
      }
      
      public function get itemsInUse() : Array
      {
         return this._config.items.map(function(item:Object, i:int, arr:Array):IMainMenuItem
         {
            return _items[i];
         });
      }
      
      public function set listenForInput(val:Boolean) : void
      {
         if(val == this._listeningForInput)
         {
            return;
         }
         this._listeningForInput = val;
         if(this._listeningForInput)
         {
            UserInputDirector.instance.addEventListener(UserInputDirector.EVENT_INPUT,this._onGamepad);
            MouseManager.instance.addEventListener(MouseManager.EVENT_MOUSE_WHEEL,this._onMouseWheel);
            this._items.forEach(function(item:IMainMenuItem, ... args):void
            {
               item.mc.addEventListener(MouseEvent.MOUSE_OVER,_onMouseOver);
               item.mc.addEventListener(MouseEvent.MOUSE_DOWN,_onMouseDown);
            });
         }
         else
         {
            UserInputDirector.instance.removeEventListener(UserInputDirector.EVENT_INPUT,this._onGamepad);
            MouseManager.instance.removeEventListener(MouseManager.EVENT_MOUSE_WHEEL,this._onMouseWheel);
            this._items.forEach(function(item:IMainMenuItem, ... args):void
            {
               item.mc.removeEventListener(MouseEvent.MOUSE_OVER,_onMouseOver);
               item.mc.removeEventListener(MouseEvent.MOUSE_DOWN,_onMouseDown);
            });
         }
      }
      
      public function init(doneFn:Function) : void
      {
         this.listenForInput = false;
         JBGLoader.instance.loadFile(this._configFile,function(result:Object):void
         {
            if(Boolean(result.success))
            {
               _config = result.loader.contentAsJSON;
               _config.items = _config.items.filter(function(element:Object, index:int, a:Array):Boolean
               {
                  if(element.hasOwnProperty("hideWhenBuildConfigIs"))
                  {
                     if(BuildConfig.instance.hasConfigVal(element.hideWhenBuildConfigIs.id))
                     {
                        return BuildConfig.instance.configVal(element.hideWhenBuildConfigIs.id) != element.hideWhenBuildConfigIs.value;
                     }
                  }
                  return true;
               });
            }
            _setupMenuItems();
            doneFn();
         });
      }
      
      public function initWithConfig(newConfig:Object, source:String) : void
      {
         this.listenForInput = false;
         this._config = newConfig;
         this._source = source;
         this._setupMenuItems();
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._items);
         this.listenForInput = false;
         LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this._onLocaleChanged);
      }
      
      public function show(doneFn:Function, params:Object) : void
      {
         LocalizationManager.instance.addEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this._onLocaleChanged);
         this._setupMenuItems();
         this.itemsInUse.forEach(function(item:IMainMenuItem, i:int, arr:Array):void
         {
            JBGUtil.runFunctionAfter(function():void
            {
               item.show(Nullable.NULL_FUNCTION);
            },Duration.scale(_animationDelay,i));
         });
         JBGUtil.runFunctionAfter(function():void
         {
            _mainMenu.onMainMenuHighlight(0,0);
            listenForInput = true;
            doneFn();
         },Duration.scale(this._animationDelay,this.itemsInUse.length));
      }
      
      public function dismiss(doneFn:Function, params:Object) : void
      {
         var items:Array;
         var c:Counter = null;
         this.listenForInput = false;
         LocalizationManager.instance.removeEventListener(LocalizationManager.EVENT_LOCALE_CHANGED,this._onLocaleChanged);
         items = this.itemsInUse;
         c = new Counter(items.length,doneFn);
         this.itemsInUse.forEach(function(item:IMainMenuItem, i:int, arr:Array):void
         {
            item.dismiss(item == _mainMenu.selectedItem,c.generateDoneFn());
         });
      }
      
      private function _setupMenuItems() : void
      {
         this._config.items.forEach(function(element:Object, i:int, arr:Array):void
         {
            var item:IMainMenuItem = _items[i];
            item.setup(element,_source);
         });
      }
      
      private function _onLocaleChanged(event:EventWithData) : void
      {
         this._setupMenuItems();
      }
      
      protected function _onGamepad(evt:EventWithData) : void
      {
         var newSelected:int = 0;
         var lastIndex:int = 0;
         var item:IMainMenuItem = null;
         var items:Array = this.itemsInUse;
         if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_SELECT))
         {
            this._mainMenu.onMainMenuSelect(this._mainMenu.selectedIndex,this._mainMenu.selectedItem.action);
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_BACK))
         {
            if(!EnvUtil.isMobile())
            {
               return;
            }
            lastIndex = this.itemsInUse.length - 1;
            item = this.itemsInUse[lastIndex];
            this._mainMenu.onMainMenuSelect(lastIndex,item.action);
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_DOWN))
         {
            newSelected = this._mainMenu.selectedIndex == this.itemsInUse.length - 1 ? 0 : int(this._mainMenu.selectedIndex + 1);
            this._mainMenu.onMainMenuHighlight(this._mainMenu.selectedIndex,newSelected);
         }
         else if(UserInputUtil.inputsContain(evt.data.inputs,UserInputDirector.INPUT_UP))
         {
            newSelected = this._mainMenu.selectedIndex == 0 ? this.itemsInUse.length - 1 : int(this._mainMenu.selectedIndex - 1);
            this._mainMenu.onMainMenuHighlight(this._mainMenu.selectedIndex,newSelected);
         }
      }
      
      private function _onMouseWheel(evt:EventWithData) : void
      {
         if(Boolean(evt.data.wheelUp))
         {
            if(this._mainMenu.selectedIndex > 0)
            {
               this._mainMenu.onMainMenuHighlight(this._mainMenu.selectedIndex,this._mainMenu.selectedIndex - 1);
            }
         }
         else if(this._mainMenu.selectedIndex < this.itemsInUse.length - 1)
         {
            this._mainMenu.onMainMenuHighlight(this._mainMenu.selectedIndex,this._mainMenu.selectedIndex + 1);
         }
      }
      
      private function _onMouseOver(evt:MouseEvent) : void
      {
         var itemMCs:Array = JBGUtil.getPropertiesOfNameInOrder(this._mc,"item");
         var index:int = int(itemMCs.indexOf(evt.target));
         if(index != this._mainMenu.selectedIndex)
         {
            this._mainMenu.onMainMenuHighlight(this._mainMenu.selectedIndex,index);
         }
      }
      
      private function _onMouseDown(evt:MouseEvent) : void
      {
         var itemMCs:Array = JBGUtil.getPropertiesOfNameInOrder(this._mc,"item");
         var index:int = int(itemMCs.indexOf(evt.target));
         var item:IMainMenuItem = this._items[index];
         this._mainMenu.onMainMenuSelect(index,item.action);
      }
   }
}

