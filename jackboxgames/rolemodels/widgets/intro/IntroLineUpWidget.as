package jackboxgames.rolemodels.widgets.intro
{
   import flash.display.*;
   import jackboxgames.utils.*;
   
   public class IntroLineUpWidget
   {
       
      
      private var _players:Array;
      
      private var _mc:MovieClip;
      
      private var _playerWidgets:Array;
      
      private var _playerWidgetsInPlay:Array;
      
      public function IntroLineUpWidget(mc:MovieClip)
      {
         var playerMCs:Array;
         super();
         this._mc = mc;
         playerMCs = JBGUtil.getPropertiesOfNameInOrder(this._mc,"avatar");
         this._playerWidgets = playerMCs.map(function(playerMC:MovieClip, ... args):IntroPlayerWidget
         {
            return new IntroPlayerWidget(playerMC);
         });
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._playerWidgets);
         this._players = null;
         this._playerWidgetsInPlay = [];
      }
      
      public function setup(players:Array) : void
      {
         this.reset();
         this._players = players;
         this._playerWidgetsInPlay = this._playerWidgets.filter(function(pw:IntroPlayerWidget, i:int, a:Array):Boolean
         {
            return i < _players.length;
         });
         this._playerWidgetsInPlay.forEach(function(pw:IntroPlayerWidget, i:int, a:Array):void
         {
            pw.setup(_players[i]);
         });
         JBGUtil.gotoFrame(this._mc,"PlayersIs" + this._players.length);
      }
      
      public function setPlayersShown(isShown:Boolean, doneFn:Function) : void
      {
         var c:Counter = null;
         c = new Counter(this._playerWidgetsInPlay.length,doneFn);
         this._playerWidgetsInPlay.forEach(function(pw:IntroPlayerWidget, ... args):void
         {
            pw.setShown(isShown,c.generateDoneFn());
         });
      }
   }
}
