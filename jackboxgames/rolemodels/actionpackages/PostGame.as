package jackboxgames.rolemodels.actionpackages
{
   import com.greensock.*;
   import com.greensock.easing.*;
   import flash.display.*;
   import jackboxgames.rolemodels.*;
   import jackboxgames.rolemodels.actionpackages.delegates.*;
   import jackboxgames.rolemodels.userinteraction.*;
   import jackboxgames.rolemodels.widgets.lobby.*;
   import jackboxgames.rolemodels.widgets.postgame.*;
   import jackboxgames.talkshow.actions.*;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.userinteraction.*;
   import jackboxgames.utils.*;
   
   public class PostGame extends JBGActionPackage
   {
       
      
      private var _postGameDelegate:RoleModelsPostGame;
      
      private var _playerSummaryWidget:PlayerGameSummaryWidget;
      
      private var _animCanceller:Function;
      
      private var _currentPlayerIndex:int;
      
      public function PostGame(sourceURL:String)
      {
         super(sourceURL);
         this._animCanceller = Nullable.NULL_FUNCTION;
      }
      
      public function handleActionInit(ref:IActionRef, params:Object) : void
      {
         _setLoaded(true,function():void
         {
            _onLoaded();
            ref.end();
         });
      }
      
      private function _onLoaded() : void
      {
         GameState.instance.screenOrganizer.addChild(_mc,0);
         this._postGameDelegate = new RoleModelsPostGame(_mc,GameState.instance);
         this._postGameDelegate.creditsColor = "#ffffff";
         addDelegate(this._postGameDelegate);
         this._playerSummaryWidget = new PlayerGameSummaryWidget(_mc.playerResult);
      }
      
      private function parkEverything() : void
      {
         resetDelegates();
         JBGUtil.reset([this._playerSummaryWidget]);
      }
      
      public function handleActionReset(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         this._animCanceller();
         this._animCanceller = Nullable.NULL_FUNCTION;
         this.parkEverything();
         this._currentPlayerIndex = 0;
         ref.end();
      }
      
      public function handleActionStart(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_ON);
         GameState.instance.updatePlayerPlaces();
         this._currentPlayerIndex = 0;
         ref.end();
      }
      
      public function handleActionEnd(ref:IActionRef, params:Object) : void
      {
         GameState.instance.screenOrganizer.setChildState(_mc,DisplayObjectOrganizer.STATE_OFF);
         this.parkEverything();
         ref.end();
      }
      
      private function loopPlayerResult(timeShown:Duration, timeHidden:Duration) : void
      {
         var sortedPlayers:Array = GameState.instance.players.concat().sortOn("placeIndex",Array.NUMERIC);
         this._playerSummaryWidget.setup(sortedPlayers[this._currentPlayerIndex]);
         this._playerSummaryWidget.shower.setShown(true,function():void
         {
            _animCanceller = JBGUtil.runFunctionAfter(function():void
            {
               _playerSummaryWidget.shower.setShown(false,function():void
               {
                  _currentPlayerIndex = (_currentPlayerIndex + 1) % GameState.instance.players.length;
                  _animCanceller = JBGUtil.runFunctionAfter(function():void
                  {
                     loopPlayerResult(timeShown,timeHidden);
                  },timeHidden);
               });
            },timeShown);
         });
      }
      
      public function handleActionSetPostGamePlayerResultsShown(ref:IActionRef, params:Object) : void
      {
         if(Boolean(params.isShown))
         {
            this.loopPlayerResult(Duration.fromMs(params.timeShownInMs),Duration.fromMs(params.timeHiddenInMs));
         }
         else
         {
            this._animCanceller();
            this._animCanceller = Nullable.NULL_FUNCTION;
            this._playerSummaryWidget.shower.reset();
         }
         ref.end();
      }
   }
}
