package jackboxgames.widgets.postgame
{
   import flash.display.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class PostGameRoomCode
   {
      protected var _mc:MovieClip;
      
      protected var _shower:MovieClipShower;
      
      protected var _roomCodeTf:ExtendableTextField;
      
      protected var _joinUrlTf:ExtendableTextField;
      
      public function PostGameRoomCode(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._createShower();
         this._createTfs();
      }
      
      protected function _createShower() : void
      {
         this._shower = new MovieClipShower(this._mc.roomCodeActions);
      }
      
      protected function _createTfs() : void
      {
         this._roomCodeTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.roomCodeActions.roomCode);
         this._joinUrlTf = ETFHelperUtil.buildExtendableTextFieldFromRoot(this._mc.roomCodeActions.joinUrl);
      }
      
      public function dispose() : void
      {
         JBGUtil.dispose([this._shower,this._roomCodeTf,this._joinUrlTf]);
         this._shower = null;
         this._roomCodeTf = null;
         this._joinUrlTf = null;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower]);
      }
      
      public function setup(roomCode:String, joinUrl:String) : void
      {
         this._roomCodeTf.text = roomCode;
         this._joinUrlTf.text = joinUrl;
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,doneFn);
      }
   }
}

