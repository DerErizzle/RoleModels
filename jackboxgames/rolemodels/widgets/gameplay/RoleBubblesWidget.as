package jackboxgames.rolemodels.widgets.gameplay
{
   import flash.display.*;
   import jackboxgames.events.*;
   import jackboxgames.utils.*;
   
   public class RoleBubblesWidget
   {
       
      
      private var _mc:MovieClip;
      
      private var _roleBubble0:RoleBubbleWidget;
      
      private var _roleBubble1:RoleBubbleWidget;
      
      private var _promptOnScreenDuringAppear:Boolean;
      
      private var _activeBubbles:Array;
      
      public function RoleBubblesWidget(mc:MovieClip)
      {
         super();
         this._mc = mc;
         this._roleBubble0 = new RoleBubbleWidget(this._mc.roleBubble0);
         this._roleBubble1 = new RoleBubbleWidget(this._mc.roleBubble1);
         this._activeBubbles = [];
      }
      
      public function reset() : void
      {
         var activeBubble:RoleBubbleWidget = null;
         for each(activeBubble in this._activeBubbles)
         {
            activeBubble.reset();
         }
         this._activeBubbles = [];
      }
      
      public function setup(primaryStrings:Array, transformedStrings:Array, backgroundColor:String, promptOnScreenDuringAppear:Boolean) : void
      {
         this._promptOnScreenDuringAppear = promptOnScreenDuringAppear;
         if(primaryStrings.length == 2)
         {
            JBGUtil.gotoFrame(this._mc,"BubblesAre2");
            this._activeBubbles = [this._roleBubble0,this._roleBubble1];
         }
         else
         {
            JBGUtil.gotoFrame(this._mc,"BubblesAre1");
            this._activeBubbles = [this._roleBubble0];
         }
         for(var i:int = 0; i < this._activeBubbles.length; i++)
         {
            if(i < primaryStrings.length)
            {
               this._activeBubbles[i].primaryText = primaryStrings[i];
            }
            if(i < transformedStrings.length)
            {
               this._activeBubbles[i].transformedText = transformedStrings[i];
            }
            this._activeBubbles[i].setup(backgroundColor);
         }
      }
      
      public function setShown(isShown:Boolean, doneFn:Function) : void
      {
         var appearCounter:Counter = null;
         var bubbleToAppear:RoleBubbleWidget = null;
         var disappearCounter:Counter = null;
         var bubbleToDisappear:RoleBubbleWidget = null;
         if(isShown)
         {
            appearCounter = new Counter(this._activeBubbles.length,doneFn);
            for each(bubbleToAppear in this._activeBubbles)
            {
               bubbleToAppear.appear(this._promptOnScreenDuringAppear,appearCounter.generateDoneFn());
            }
         }
         else
         {
            disappearCounter = new Counter(this._activeBubbles.length,doneFn);
            for each(bubbleToDisappear in this._activeBubbles)
            {
               bubbleToDisappear.disappear(disappearCounter.generateDoneFn());
            }
         }
      }
      
      public function shiftForPrompt(doneFn:Function) : void
      {
         var bubbleToShift:RoleBubbleWidget = null;
         var c:Counter = new Counter(this._activeBubbles.length,doneFn);
         for each(bubbleToShift in this._activeBubbles)
         {
            bubbleToShift.shift(this._promptOnScreenDuringAppear,c.generateDoneFn());
         }
      }
      
      public function transformToTag(forBubbles:String, doneFn:Function) : void
      {
         var c:Counter = null;
         var activeBubble:RoleBubbleWidget = null;
         if(forBubbles == "All")
         {
            c = new Counter(this._activeBubbles.length,doneFn);
            for each(activeBubble in this._activeBubbles)
            {
               activeBubble.transformToTag(c.generateDoneFn());
            }
         }
         else if(forBubbles == "Left")
         {
            this._activeBubbles[0].transformToTag(doneFn);
         }
         else if(forBubbles == "Right")
         {
            this._activeBubbles[1].transformToTag(doneFn);
         }
         else
         {
            doneFn();
         }
      }
      
      public function awardBubbles(numPlayers:int, winningIndex:int, doneFn:Function) : void
      {
         if(numPlayers == 1)
         {
            if(winningIndex == 0)
            {
               this._activeBubbles[0].disappearToPlayer(1,doneFn);
               this._activeBubbles[1].disappear(Nullable.NULL_FUNCTION);
            }
            else if(winningIndex == 1)
            {
               this._activeBubbles[1].disappearToPlayer(-1,doneFn);
               this._activeBubbles[0].disappear(Nullable.NULL_FUNCTION);
            }
            else
            {
               doneFn();
            }
         }
         else if(numPlayers == 2)
         {
            if(winningIndex == 0)
            {
               this._activeBubbles[0].disappearToPlayer(0,doneFn);
               this._activeBubbles[1].disappear(Nullable.NULL_FUNCTION);
            }
            else if(winningIndex == 1)
            {
               this._activeBubbles[1].disappearToPlayer(0,doneFn);
               this._activeBubbles[0].disappear(Nullable.NULL_FUNCTION);
            }
            else
            {
               doneFn();
            }
         }
         else
         {
            doneFn();
         }
      }
   }
}
