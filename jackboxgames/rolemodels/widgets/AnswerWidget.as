package jackboxgames.rolemodels.widgets
{
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.utils.*;
   import jackboxgames.text.*;
   import jackboxgames.utils.*;
   
   public class AnswerWidget extends PausableEventDispatcher
   {
       
      
      private var _mc:MovieClip;
      
      private var _tf:ExtendableTextField;
      
      private var _shower:MovieClipShower;
      
      private var _playerName:PlayerNameWidget;
      
      private var _nameShower:MovieClipShower;
      
      private var _player:Player;
      
      public function AnswerWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._shower = new MovieClipShower(this._mc);
         this._playerName = new PlayerNameWidget(this._mc.answer.playerName.playerName);
         this._nameShower = new MovieClipShower(this._mc.answer.playerName);
         this._tf = new ExtendableTextField(this._mc.answer.tf,[],[PostEffectFactory.createDynamicResizerEffect(2),PostEffectFactory.createBalancerEffect(TextUtils.BALANCE_CENTER)]);
      }
      
      public function get player() : Player
      {
         return this._player;
      }
      
      public function reset() : void
      {
         JBGUtil.reset([this._shower,this._nameShower,this._playerName]);
         if(Boolean(this._player))
         {
            this._player.removeEventListener(PlayerBroadcastEvent.EVENT_PLAYER_BROADCAST,this._onPlayerBroadcast);
         }
         this._player = null;
      }
      
      public function setup(p:Player) : void
      {
         this._player = p;
         this._playerName.setup(this._player);
         this._player.addEventListener(PlayerBroadcastEvent.EVENT_PLAYER_BROADCAST,this._onPlayerBroadcast);
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         this._shower.setShown(isShown,function():void
         {
            doneFn();
         });
      }
      
      public function showPlayerName(doneFn:Function) : void
      {
         this._nameShower.setShown(true,doneFn);
      }
      
      public function setText(text:String) : void
      {
         this._tf.text = text.toUpperCase();
      }
      
      private function _onPlayerBroadcast(evt:PlayerBroadcastEvent) : void
      {
         if(evt.broadcastName == "AnswerSubmitted")
         {
            this._tf.text = evt.data.answer.toUpperCase();
         }
         if(evt.broadcastName == "ShowAnswer")
         {
            this._shower.setShown(true,function():void
            {
               evt.data.doneFn();
            });
         }
      }
   }
}
