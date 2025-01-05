package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.MovieClip;
   import jackboxgames.events.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.utils.*;
   
   public class WinnerScreenPlayerContainer
   {
       
      
      private var _mc:MovieClip;
      
      private var _playerWidgets:Array;
      
      private var _playerLineupAvatarAnimations:MovieClip;
      
      private var _playerWidgetsPerPlayerCount:Object;
      
      public function WinnerScreenPlayerContainer(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._playerWidgetsPerPlayerCount = {};
         JBGUtil.gotoFrame(this._mc,"Park");
         JBGUtil.getPropertiesOfNameInOrder(this._mc,"avatars",GameConstants.MIN_PLAYERS).forEach(function(avatarMC:MovieClip, i:int, ... args):void
         {
            var widgets:Array = JBGUtil.getPropertiesOfNameInOrder(avatarMC,"player").map(function(playerMC:MovieClip, ... args):WinnerScreenPlayerWidget
            {
               return new WinnerScreenPlayerWidget(playerMC);
            });
            _playerWidgetsPerPlayerCount[GameConstants.MIN_PLAYERS + i] = widgets;
         });
      }
      
      public function reset() : void
      {
         JBGUtil.reset(this._playerWidgets);
         JBGUtil.gotoFrame(this._mc,"Park");
         if(Boolean(this._playerLineupAvatarAnimations))
         {
            JBGUtil.gotoFrame(this._playerLineupAvatarAnimations,"Park");
         }
      }
      
      public function setup(sortedPlayers:Array) : void
      {
         JBGUtil.gotoFrame(this._mc,"Players" + sortedPlayers.length);
         this._playerWidgets = this._playerWidgetsPerPlayerCount[sortedPlayers.length];
         this._playerLineupAvatarAnimations = this._mc["avatars" + sortedPlayers.length];
         sortedPlayers.shift();
         this._playerWidgets.forEach(function(widget:WinnerScreenPlayerWidget, i:int, ... args):void
         {
            widget.setup(sortedPlayers[i]);
         });
      }
      
      public function setShown(isShown:Boolean, timeBetweenAppears:Duration, timeAfterAppearUntilShrink:Duration, doneFn:Function) : void
      {
         var c:Counter = null;
         var appearTime:Duration = null;
         var playerIndex:int = 0;
         c = new Counter(this._playerWidgets.length,doneFn);
         appearTime = Duration.ZERO;
         playerIndex = this._playerWidgets.length - 1;
         this._playerWidgets.reverse().forEach(function(widget:WinnerScreenPlayerWidget, index:int, ... args):void
         {
            if(isShown)
            {
               JBGUtil.runFunctionAfter(function():void
               {
                  JBGUtil.gotoFrameWithFn(_playerLineupAvatarAnimations,"AppearPlayer" + String(playerIndex - index),MovieClipEvent.EVENT_APPEAR_DONE,Nullable.NULL_FUNCTION);
                  widget.setShown(true,function():void
                  {
                     JBGUtil.runFunctionAfter(function():void
                     {
                        JBGUtil.gotoFrameWithFn(_playerLineupAvatarAnimations,"ShrinkPlayer" + String(playerIndex - index),MovieClipEvent.EVENT_ANIMATION_DONE,c.generateDoneFn());
                     },timeAfterAppearUntilShrink);
                  });
               },appearTime);
               appearTime.add(timeBetweenAppears);
            }
            else
            {
               widget.setShown(false,c.generateDoneFn());
            }
         });
      }
   }
}
