package jackboxgames.rolemodels.widgets.intro
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.rolemodels.widgets.*;
   import jackboxgames.utils.*;
   
   public class IntroPlayerWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _shower:MovieClipShower;
      
      private var _avatar:PlayerAvatarWidget;
      
      private var _name:PlayerNameWidget;
      
      private var _player:Player;
      
      public function IntroPlayerWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._avatar = new PlayerAvatarWidget(this._mc.avatar.avatarHead);
         this._name = new PlayerNameWidget(this._mc.avatar.playerName.playerName);
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower,this._avatar,this._name]);
         this._player = null;
      }
      
      public function setup(p:Player) : void
      {
         this._player = p;
         if(Boolean(this._avatar))
         {
            this._avatar.setup(this._player);
         }
         if(Boolean(this._name))
         {
            this._name.setup(this._player);
         }
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,function():void
         {
            doneFn();
         });
      }
   }
}
