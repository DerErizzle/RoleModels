package jackboxgames.widgets.lobby
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.moderation.*;
   import jackboxgames.settings.*;
   import jackboxgames.utils.*;
   
   public class LobbySettingsButton
   {
      protected var _mc:MovieClip;
      
      protected var _shower:MovieClipShower;
      
      protected var _gears:MovieClipShower;
      
      protected var _gearCanceler:Function;
      
      public function LobbySettingsButton(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._gears = new MovieClipShower(this._mc.container.gears);
         this._gearCanceler = Nullable.NULL_FUNCTION;
      }
      
      public function dispose() : void
      {
         this._stopGearSpinner();
         this._shower.dispose();
         this._shower = null;
         this._gears.dispose();
         this._gears = null;
         this._mc = null;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._gears,this._shower]);
      }
      
      public function show() : void
      {
         this._shower.setShown(true,Nullable.NULL_FUNCTION);
         this._gears.setShown(true,Nullable.NULL_FUNCTION);
         this._startGearSpinner();
      }
      
      private function _startGearSpinner() : void
      {
         this._gearCanceler = JBGUtil.runFunctionAfter(this._spinGears,Duration.fromSec(5));
      }
      
      private function _spinGears() : void
      {
         this._gears.doAnimation("Stop",Nullable.NULL_FUNCTION);
         this._startGearSpinner();
      }
      
      private function _stopGearSpinner() : void
      {
         this._gearCanceler();
         this._gearCanceler = Nullable.NULL_FUNCTION;
      }
      
      public function dismiss() : void
      {
         this._stopGearSpinner();
         this._shower.setShown(false,Nullable.NULL_FUNCTION);
      }
   }
}

