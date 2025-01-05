package jackboxgames.utils
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MovieClipPauser
   {
      
      private static var _instance:MovieClipPauser;
       
      
      private var pausedArr:Array;
      
      private var _paused:Boolean;
      
      private var _steppedFrames:int;
      
      public function MovieClipPauser()
      {
         this.pausedArr = [];
         super();
         this._paused = false;
         this._steppedFrames = 0;
      }
      
      public static function get instance() : MovieClipPauser
      {
         return Boolean(_instance) ? _instance : (_instance = new MovieClipPauser());
      }
      
      public function get isPaused() : Boolean
      {
         return this._paused;
      }
      
      public function pause(mc:*) : void
      {
         if(this._paused)
         {
            return;
         }
         this._paused = true;
         this.recursivePause(mc,true);
      }
      
      public function recursivePause(mc:*, rootObj:Boolean = false) : void
      {
         var i:int = 0;
         if(mc is MovieClip)
         {
            if(rootObj)
            {
               this.pausedArr = [];
               this._steppedFrames = 0;
               mc.addEventListener(Event.ENTER_FRAME,this.stepOneFrame);
            }
            this.pausedArr.push({
               "mc":mc,
               "frame":mc.currentFrame,
               "paused":false
            });
         }
         if(mc.numChildren > 0)
         {
            for(i = mc.numChildren - 1; i >= 0; i--)
            {
               if(mc.getChildAt(i) is DisplayObjectContainer)
               {
                  this.recursivePause(mc.getChildAt(i));
               }
            }
         }
      }
      
      public function resume() : void
      {
         if(!this._paused)
         {
            return;
         }
         this._paused = false;
         for(var i:int = 0; i < this.pausedArr.length; i++)
         {
            if(this.pausedArr[i].mc && this.pausedArr[i].mc is MovieClip && Boolean(this.pausedArr[i].paused))
            {
               this.pausedArr[i].mc.play();
            }
         }
         this.pausedArr = [];
      }
      
      private function stepOneFrame(e:Event) : void
      {
         if(this._steppedFrames == 1)
         {
            this.pausedArr[0].mc.removeEventListener(Event.ENTER_FRAME,this.stepOneFrame);
         }
         ++this._steppedFrames;
         for(var i:int = 0; i < this.pausedArr.length; i++)
         {
            if(this.pausedArr[i].mc is MovieClip && this.pausedArr[i].mc.currentFrame != this.pausedArr[i].frame)
            {
               this.pausedArr[i].mc.gotoAndStop(this.pausedArr[i].frame);
               this.pausedArr[i].paused = true;
               this.pausedArr[i].mc as MovieClip;
            }
         }
      }
   }
}
