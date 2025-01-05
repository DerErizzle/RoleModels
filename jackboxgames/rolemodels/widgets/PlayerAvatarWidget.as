package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import flash.geom.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.utils.*;
   
   public class PlayerAvatarWidget
   {
       
      
      private var _player:Player;
      
      private var _avatar:MovieClip;
      
      private var _background:MovieClip;
      
      private var _defaultFace:MovieClip;
      
      private var _defaultFaceLabel:String;
      
      private var _border:MovieClip;
      
      private var _shape:Shape;
      
      public function PlayerAvatarWidget(avatar:MovieClip)
      {
         super();
         this._avatar = avatar;
         this._background = this._avatar.background;
         this._defaultFace = this._avatar.defaultAvatars;
         this._defaultFaceLabel = ArrayUtil.getRandomElement(MovieClipUtil.getFramesThatStartWith(this._defaultFace,"DefaultFace"));
         this._border = this._avatar.border;
      }
      
      public function get visible() : Boolean
      {
         return this._avatar.visible;
      }
      
      public function reset() : void
      {
         JBGUtil.gotoFrame(this._defaultFace,"NoFace");
         JBGUtil.gotoFrame(this._border,"Park");
         JBGUtil.gotoFrame(this._border.border,"Park");
         if(this._avatar.hasOwnProperty("audienceVote"))
         {
            JBGUtil.gotoFrame(this._avatar.audienceVote,"Off");
         }
         this._background.visible = false;
         this._avatar.visible = true;
         this.setAvatarBorderVisible(true);
         if(Boolean(this._shape))
         {
            JBGUtil.safeRemoveChild(this._avatar,this._shape);
            this._shape.graphics.clear();
            this._shape = null;
         }
      }
      
      public function setup(p:Player) : void
      {
         var matrix:Matrix = null;
         var xScale:Number = NaN;
         var yScale:Number = NaN;
         var scale:Number = NaN;
         this.reset();
         this._player = p;
         this._background.visible = true;
         JBGUtil.gotoFrame(this._background,"Player" + this._player.index.val);
         if(this._player.hasPicture)
         {
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
            matrix = new Matrix();
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
         else
         {
            JBGUtil.gotoFrame(this._border,"Park");
            JBGUtil.gotoFrame(this._border.border,"Park");
            JBGUtil.gotoFrame(this._defaultFace,this._defaultFaceLabel);
         }
      }
      
      public function setupAudienceAvatar(p:Player) : void
      {
         this.reset();
         if(!this._avatar.hasOwnProperty("audienceVote"))
         {
            return;
         }
         this._player = p;
         JBGUtil.gotoFrame(this._defaultFace,"NoFace");
         JBGUtil.gotoFrame(this._border,"Park");
         JBGUtil.gotoFrame(this._border.border,"Park");
         JBGUtil.gotoFrame(this._avatar.audienceVote,"On");
         this._background.visible = false;
         this.setAvatarBorderVisible(false);
      }
      
      public function setVisible(isVisible:Boolean) : void
      {
         this._avatar.visible = isVisible;
      }
      
      private function setAvatarBorderVisible(isVisible:Boolean) : void
      {
         if(this._avatar.hasOwnProperty("avatarBorder"))
         {
            MovieClip(this._avatar.avatarBorder).visible = isVisible;
         }
      }
   }
}
