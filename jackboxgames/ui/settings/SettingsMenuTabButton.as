package jackboxgames.ui.settings
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import jackboxgames.userinput.UserInputDirector;
   import jackboxgames.userinput.UserInputUtil;
   
   public class SettingsMenuTabButton extends SettingsMenuItem
   {
      public function SettingsMenuTabButton(mc:MovieClip, data:ISettingsMenuElementData, menuDelegate:ISettingsMenuItemDelegate)
      {
         super(mc,data,menuDelegate);
      }
      
      private function get _tabData() : SettingsMenuConfigTab
      {
         return SettingsMenuConfigTab(_data);
      }
      
      override protected function _onMouseDown(evt:MouseEvent) : void
      {
         _menuDelegate.handleSwitchToTabRequest(this._tabData);
      }
      
      override public function onGamepadInput(inputs:Array) : void
      {
         if(UserInputUtil.inputsContain(inputs,[UserInputDirector.INPUT_SELECT]))
         {
            _menuDelegate.handleSwitchToTabRequest(this._tabData);
         }
      }
   }
}

