package jackboxgames.rolemodels.widgets.lobby
{
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.utils.*;
   
   public class LobbyPlayer
   {
       
      
      private var _mc:MovieClip;
      
      private var _player:Player;
      
      private var _avatar:MovieClip;
      
      private var _background:MovieClip;
      
      private var _vipShower:MovieClipShower;
      
      private var _defaultFace:MovieClip;
      
      private var _defaultFaceLabel:String;
      
      private var _border:MovieClip;
      
      private var _shape:Shape;
      
      public function LobbyPlayer(element:MovieClip)
      {
         super();
         this._mc = element;
         this._avatar = element.avatar;
         this._background = this._avatar.background;
         this._vipShower = new MovieClipShower(element.vip);
         this._defaultFace = this._avatar.defaultAvatars;
         this._defaultFaceLabel = ArrayUtil.getRandomElement(MovieClipUtil.getFramesThatStartWith(this._defaultFace,"DefaultFace"));
         this._border = this._avatar.border;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._mc.blobLoop.blob,"Park");
         if(this._player != null)
         {
            this._player.removeEventListener(Player.EVENT_PICTURE_CHANGED,this._onPictureChanged);
            this._player.isCensored.removeEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onCensoredChanged);
            this._player = null;
         }
         this._background.visible = false;
         this._vipShower.reset();
         if(Boolean(this._shape))
         {
            JBGUtil.safeRemoveChild(this._avatar,this._shape);
            this._shape.graphics.clear();
            this._shape = null;
         }
         JBGUtil.gotoFrame(this._defaultFace,"NoFace");
         JBGUtil.gotoFrame(this._border,"Park");
         JBGUtil.gotoFrame(this._border.border,"Park");
      }
      
      public function setup(p:Player) : void
      {
         this.reset();
         this._player = p;
         this._player.addEventListener(Player.EVENT_PICTURE_CHANGED,this._onPictureChanged);
         this._player.isCensored.addEventListener(WatchableValue.EVENT_VALUE_CHANGED,this._onCensoredChanged);
         JBGUtil.gotoFrame(this._mc.blobLoop,"Player" + this._player.index.val);
         JBGUtil.gotoFrame(this._mc.blobLoop.blob,"Loop");
         JBGUtil.gotoFrame(this._defaultFace,"NoFace");
         this._background.visible = true;
         JBGUtil.gotoFrame(this._background,"Player" + this._player.index.val);
         if(this._player.isVIP)
         {
            this._vipShower.setShown(true,Nullable.NULL_FUNCTION);
         }
      }
      
      private function _onPictureChanged(evt:Event) : void
      {
         var xScale:Number = NaN;
         var yScale:Number = NaN;
         var scale:Number = NaN;
         if(Boolean(this._shape))
         {
            JBGUtil.safeRemoveChild(this._avatar,this._shape);
            this._shape.graphics.clear();
            this._shape = null;
         }
         JBGUtil.gotoFrame(this._defaultFace,"NoFace");
         JBGUtil.gotoFrame(this._border,"Appear");
         if(this._player.tookPicture)
         {
            JBGUtil.gotoFrame(this._border.border,"Player" + this._player.index.val);
         }
         else
         {
            JBGUtil.gotoFrame(this._border.border,"Park");
         }
         var matrix:Matrix = new Matrix();
         matrix.scale(this._avatar.size.width / this._player.picture.width,this._avatar.size.height / this._player.picture.height);
         this._shape = new Shape();
         this._shape.graphics.beginBitmapFill(this._player.picture,matrix,false,false);
         this._shape.graphics.drawEllipse(0,0,this._avatar.size.width,this._avatar.size.height);
         this._shape.graphics.endFill();
         xScale = this._avatar.size.width / this._shape.width;
         yScale = this._avatar.size.height / this._shape.height;
         scale = Math.min(xScale,yScale);
         this._shape.scaleX = scale;
         this._shape.scaleY = scale;
         this._shape.x = this._avatar.size.x + this._avatar.size.width / 2 - this._shape.width / 2;
         this._shape.y = this._avatar.size.y + this._avatar.size.height / 2 - this._shape.height / 2;
         this._avatar.addChildAt(this._shape,this._avatar.getChildIndex(this._background) + 1);
      }
      
      private function _onCensoredChanged(evt:EventWithData) : void
      {
         if(Boolean(this._player) && this._player.isCensored.val)
         {
            JBGUtil.gotoFrame(this._border,"Park");
            JBGUtil.gotoFrame(this._border.border,"Park");
            JBGUtil.gotoFrame(this._defaultFace,this._defaultFaceLabel);
            if(Boolean(this._shape))
            {
               JBGUtil.safeRemoveChild(this._avatar,this._shape);
               this._shape.graphics.clear();
               this._shape = null;
            }
            this._player.reset();
            this._player.removeEventListener(Player.EVENT_PICTURE_CHANGED,this._onPictureChanged);
         }
      }
   }
}
