package jackboxgames.ui.settings
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import jackboxgames.localizy.*;
   import jackboxgames.text.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuListItem extends SettingsMenuItemForSetting
   {
      protected var _options:Array;
      
      protected var _defaultIndex:int;
      
      protected var _valueTf:ExtendableTextField;
      
      public function SettingsMenuListItem(mc:MovieClip, data:ISettingsMenuElementData, menuDelegate:ISettingsMenuItemDelegate)
      {
         super(mc,data,menuDelegate);
         this._options = ArrayUtil.copy(_itemData.options);
         this._defaultIndex = _itemData.defaultValueIndex;
         this._valueTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(_mc.tf);
         this._updateValue();
      }
      
      public function get selectedValue() : *
      {
         if(_settingValue.val == null)
         {
            return this._options[this._defaultIndex];
         }
         return _settingValue.val;
      }
      
      public function get selectedIndex() : int
      {
         if(_settingValue.val == null)
         {
            return this._defaultIndex;
         }
         return this._options.indexOf(_settingValue.val);
      }
      
      protected function _updateValue() : void
      {
         this._valueTf.text = this.selectedValue is String ? LocalizationManager.instance.getValueForKey(this.selectedValue,SettingsMenu.SETTINGS_LOCALIZATION_SOURCE) : String(this.selectedValue);
      }
      
      override protected function _updateDescription() : void
      {
         _description.text = _itemData.getDescriptionForListItem(this.selectedIndex);
      }
      
      override public function onLocaleChanged() : void
      {
         super.onLocaleChanged();
         this._updateValue();
      }
      
      override public function update(instant:Boolean = false) : void
      {
         super.update(instant);
         this._updateValue();
      }
      
      override public function onGamepadInput(inputs:Array) : void
      {
         var dir:int = 0;
         var idx:int = 0;
         if(!_isInteractable)
         {
            return;
         }
         if(UserInputUtil.inputsContain(inputs,[UserInputDirector.INPUT_LEFT,UserInputDirector.INPUT_RIGHT]))
         {
            dir = UserInputUtil.inputsContain(inputs,[UserInputDirector.INPUT_LEFT]) ? -1 : 1;
            idx = Math.min(Math.max(this.selectedIndex + dir,0),_itemData.options.length - 1);
            _settingValue.val = this._options[idx];
         }
      }
      
      override protected function _onMouseDown(evt:MouseEvent) : void
      {
         if(!_isInteractable)
         {
            return;
         }
         _menuDelegate.handleSelectionRequest(this);
         var percent:Number = Math.min(Math.max(_getRatioForRange(new Point(evt.stageX,evt.stageY)),0),1);
         var direction:int = percent < 0.5 ? -1 : 1;
         var idx:int = Math.min(Math.max(this.selectedIndex + direction,0),_itemData.options.length - 1);
         _settingValue.val = this._options[idx];
      }
   }
}

