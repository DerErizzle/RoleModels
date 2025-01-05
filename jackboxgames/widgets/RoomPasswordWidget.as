package jackboxgames.widgets
{
   import flash.display.MovieClip;
   import jackboxgames.blobcast.model.*;
   import jackboxgames.events.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class RoomPasswordWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _manager:RoomPasswordManager;
      
      private var _shower:MovieClipShower;
      
      private var _tf:ExtendableTextField;
      
      public function RoomPasswordWidget(mc:MovieClip, manager:RoomPasswordManager)
      {
         super();
         this._mc = mc;
         this._manager = manager;
         this._shower = new MovieClipShower(this._mc);
         this._tf = new ExtendableTextField(this._mc.tf,[],[]);
         manager.addEventListener(RoomPasswordManager.EVENT_PASSWORD_CHANGED,this._updateVisuals);
         this._updateVisuals();
      }
      
      private function _updateVisuals(... args) : void
      {
         if(this._manager.hasPassword)
         {
            this._tf.text = this._manager.password;
            this._shower.setShown(true,Nullable.NULL_FUNCTION);
         }
         else
         {
            this._shower.setShown(false,Nullable.NULL_FUNCTION);
         }
      }
   }
}
