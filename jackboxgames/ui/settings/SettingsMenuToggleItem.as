package jackboxgames.ui.settings
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   
   public class SettingsMenuToggleItem extends SettingsMenuItemForSetting
   {
      private static const DEFAULT_OPTION_ON:String = "ON";
      
      private static const DEFAULT_OPTION_OFF:String = "OFF";
      
      private var _onOption:String;
      
      private var _offOption:String;
      
      public function SettingsMenuToggleItem(mc:MovieClip, data:ISettingsMenuElementData, menuDelegate:ISettingsMenuItemDelegate)
      {
         super(mc,data,menuDelegate);
         this._onOption = DEFAULT_OPTION_ON;
         this._offOption = DEFAULT_OPTION_OFF;
         if(Boolean(_itemData.options))
         {
            this._onOption = _itemData.options[0];
            this._offOption = _itemData.options[1];
         }
      }
      
      override public function update(instant:Boolean = false) : void
      {
         super.update(instant);
         var mcs:Array = [_mc.toggle];
         if(Boolean(_mc.sticker))
         {
            mcs.push(_mc.sticker);
         }
         var frame:String = _settingValue.val ? this._onOption : this._offOption;
         if(instant)
         {
            frame += "Static";
         }
         JBGUtil.arrayGotoFrame(mcs,frame);
      }
      
      override public function onGamepadInput(inputs:Array) : void
      {
         if(!_isInteractable)
         {
            return;
         }
         if(UserInputUtil.inputsContain(inputs,[UserInputDirector.INPUT_SELECT]))
         {
            _settingValue.val = !_settingValue.val;
         }
      }
      
      override protected function _onMouseDown(evt:MouseEvent) : void
      {
         if(!_isInteractable)
         {
            return;
         }
         _menuDelegate.handleSelectionRequest(this);
         _settingValue.val = !_settingValue.val;
      }
   }
}

