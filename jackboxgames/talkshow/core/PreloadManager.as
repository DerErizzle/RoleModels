package jackboxgames.talkshow.core
{
   internal class PreloadManager
   {
      private var _playbackPct:Number;
      
      private var _startPct:Number;
      
      private var _flowchartPct:Number;
      
      private var _mediaPct:Number;
      
      private var _preloader:IPreloader = null;
      
      private var _isDone:Boolean;
      
      private var _engineBytes:uint;
      
      public function PreloadManager()
      {
         super();
         this._playbackPct = 0;
         this._startPct = 0;
         this._flowchartPct = 0;
         this._mediaPct = 0;
         this._engineBytes = 0;
         this._isDone = false;
      }
      
      public function get engineBytes() : uint
      {
         return this._engineBytes;
      }
      
      internal function setEngineBytes(bytes:uint) : void
      {
         this._engineBytes = bytes;
      }
      
      internal function playbackLoad(bytesLoaded:uint, bytesTotal:uint) : void
      {
         this._playbackPct = bytesLoaded / bytesTotal;
         this.update();
      }
      
      internal function startLoad(bytesLoaded:uint, bytesTotal:uint) : void
      {
         this._startPct = bytesLoaded / bytesTotal;
         this.update();
      }
      
      internal function flowchartLoad(bytesLoaded:uint, bytesTotal:uint) : void
      {
         this._flowchartPct = bytesLoaded / bytesTotal;
         this.update();
      }
      
      internal function mediaLoad(percent:Number) : void
      {
         if(isNaN(percent))
         {
            return;
         }
         this._mediaPct = percent;
         this.update();
      }
      
      public function get percentage() : Number
      {
         return this._playbackPct * 0.05 + this._startPct * 0.05 + this._flowchartPct * 0.1 + this._mediaPct * 0.8;
      }
      
      public function setPreloadUi(preloader:IPreloader) : void
      {
         this._preloader = preloader;
      }
      
      public function get preloadUi() : IPreloader
      {
         return this._preloader;
      }
      
      private function update() : void
      {
         var pct:Number = NaN;
         if(this._preloader != null && !this._isDone)
         {
            pct = this.percentage;
            this._preloader.preloadPercent(pct);
            if(pct >= 1)
            {
               this._preloader.preloadDone();
               this._isDone = true;
            }
         }
      }
   }
}

