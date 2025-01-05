package jackboxgames.talkshow.cells
{
   import flash.events.Event;
   import jackboxgames.logger.Logger;
   import jackboxgames.talkshow.actions.ActionRef;
   import jackboxgames.talkshow.actions.StartNextActionRef;
   import jackboxgames.talkshow.api.Constants;
   import jackboxgames.talkshow.api.IActionRef;
   import jackboxgames.talkshow.api.ICell;
   import jackboxgames.talkshow.api.IFlowchart;
   import jackboxgames.talkshow.api.ILoadData;
   import jackboxgames.talkshow.api.IMediaParamValue;
   import jackboxgames.talkshow.api.IMediaVersion;
   import jackboxgames.talkshow.api.events.CellEvent;
   import jackboxgames.talkshow.core.PlaybackEngine;
   import jackboxgames.talkshow.timing.CueTiming;
   import jackboxgames.talkshow.utils.LoadStatus;
   
   public class ActionCell extends AbstractCell
   {
      
      public static const MODE_LOCKED:uint = 0;
      
      public static const MODE_TIMING:uint = 1;
      
      public static const MODE_ACTION:uint = 2;
       
      
      private var _childId:int;
      
      private var _mode:uint;
      
      private var _primary:ActionRef;
      
      private var _secondary:Array;
      
      private var _timeout:ActionRef;
      
      private var _startComplete:Boolean;
      
      private var _primaryComplete:Boolean;
      
      private var _childrenRun:Boolean;
      
      private var _startedNext:Boolean;
      
      private var _startStateSignature:String;
      
      public function ActionCell(f:IFlowchart, id:uint, target:String, childId:int, mode:uint, primary:ActionRef)
      {
         super(f,id,target,Constants.CELL_ACTION);
         this._childId = childId;
         this._primary = primary;
         this._primary.setParent(this);
         this._secondary = new Array();
         this._mode = mode;
      }
      
      override public function toString() : String
      {
         return "[ActionCell id=" + flowchart.flowchartName + ":" + _id + "(" + flowchart.id + ":" + _id + ")]";
      }
      
      public function addSecondaryAction(ref:ActionRef, version:uint = 0) : void
      {
         ref.setParent(this);
         if(this._secondary[version] == null)
         {
            this._secondary[version] = new Array();
         }
         this._secondary[version].push(ref);
      }
      
      internal function setTimeoutBranchActionRef(ref:ActionRef) : void
      {
         this._timeout = ref;
      }
      
      override public function start() : void
      {
         Logger.info("Start Cell: " + this + " startNext=" + PlaybackEngine.getInstance().startNextManager,"Cell");
         if(PlaybackEngine.getInstance().inputManager.isInInputMode)
         {
            if(this._childId == 0)
            {
               return;
            }
            PlaybackEngine.getInstance().startNextManager.reset();
            _f.getCellByID(this._childId).start();
            return;
         }
         PlaybackEngine.getInstance().dispatchEvent(new CellEvent(CellEvent.ACTION_CELL_REACHED,this));
      }
      
      public function play() : void
      {
         if(!this.isLoaded())
         {
            Logger.info("Tried to play : " + this + " and it isn\'t loaded yet!");
            this.load(new LoadData(0));
            if(!this.isLoaded())
            {
               this._startStateSignature = PlaybackEngine.getInstance().startNextManager.stateSignature;
               PlaybackEngine.getInstance().loadPause(this);
               PlaybackEngine.getInstance().loadMonitor.purge();
               PlaybackEngine.getInstance().loadMonitor.addEventListener(Event.COMPLETE,this.cellIsLoaded);
               return;
            }
         }
         if(this.child != null)
         {
            this.child.load(new LoadData(LoadData.DEFAULT_LOAD_DEPTH));
         }
         this._childrenRun = false;
         Logger.info("Play Cell: " + this,"Cell");
         PlaybackEngine.getInstance().dispatchEvent(new CellEvent(CellEvent.CELL_STARTED,this));
         this._timeout = null;
         this._startedNext = false;
         this.manageStartActions();
      }
      
      public function runChildren() : void
      {
         if(this._childrenRun)
         {
            return;
         }
         var c:ICell = _f.getCellByID(this._childId);
         if(Boolean(c))
         {
            c.start();
         }
         this._childrenRun = true;
      }
      
      private function cellIsLoaded(evt:Event) : void
      {
         PlaybackEngine.getInstance().loadMonitor.removeEventListener(Event.COMPLETE,this.cellIsLoaded);
         PlaybackEngine.getInstance().loadResume(this);
         if(PlaybackEngine.getInstance().startNextManager.stateSignature == this._startStateSignature)
         {
            this.play();
         }
      }
      
      public function primaryComplete() : void
      {
         if(!this._startComplete)
         {
            this._primaryComplete = true;
         }
         else
         {
            this.manageEndActions();
         }
      }
      
      protected function manageStartActions() : void
      {
         var acts:Array = null;
         var aref:ActionRef = null;
         this._startComplete = false;
         this._primaryComplete = false;
         var idx:int = this.getSecondaryVersionIndex();
         this._primary.start(true);
         if(idx > -1)
         {
            acts = new Array();
            for each(aref in this._secondary[idx])
            {
               if(aref is StartNextActionRef)
               {
                  PlaybackEngine.getInstance().startNextManager.check(aref as StartNextActionRef);
               }
            }
            for each(aref in this._secondary[idx])
            {
               if(aref.timing is CueTiming)
               {
                  (aref.timing as CueTiming).reset();
               }
               if(!aref.timing.never)
               {
                  if(aref.timing.fromStart && aref.timing.seconds == 0)
                  {
                     aref.start();
                  }
                  else if(aref.timing.fromStart || !aref.timing.fromStart && aref.timing.seconds < 0)
                  {
                     acts.push(aref);
                  }
               }
            }
            if(acts.length > 0)
            {
               PlaybackEngine.getInstance().queueActions(acts,true,this._primary);
            }
            this.checkTimeout(true);
         }
         this._startComplete = true;
         if(this._primaryComplete)
         {
            this.primaryComplete();
         }
      }
      
      protected function manageEndActions() : void
      {
         var acts:Array = null;
         var aref:ActionRef = null;
         var idx:int = this.getSecondaryVersionIndex(true);
         if(idx > -1)
         {
            acts = new Array();
            for each(aref in this._secondary[idx])
            {
               if(!aref.timing.never)
               {
                  if(!aref.timing.fromStart && aref.timing.seconds >= 0)
                  {
                     acts.push(aref);
                  }
               }
            }
            if(acts.length > 0)
            {
               PlaybackEngine.getInstance().queueActions(acts,false,this._primary);
            }
            this.checkTimeout(false);
         }
      }
      
      private function checkTimeout(start:Boolean) : void
      {
         if(this._timeout == null)
         {
            return;
         }
         if(this._timeout.timing.fromStart == start && this._timeout.timing.seconds == 0)
         {
            this._timeout.start();
         }
         PlaybackEngine.getInstance().queueActions([this._timeout],start,this._primary);
      }
      
      protected function getSecondaryVersionIndex(end:Boolean = false) : int
      {
         var param:IMediaParamValue = null;
         var v:IMediaVersion = null;
         var ver:int = -1;
         if(this._secondary.length > 0)
         {
            switch(this._mode)
            {
               case MODE_ACTION:
               case MODE_TIMING:
                  param = this._primary.getPrimaryMediaParamValue();
                  if(Boolean(param))
                  {
                     v = end ? param.previous : param.getCurrentVersion();
                     if(Boolean(v))
                     {
                        ver = int(v.idx);
                     }
                  }
                  break;
               case MODE_LOCKED:
                  ver = 0;
            }
         }
         return ver;
      }
      
      override public function load(data:ILoadData = null) : void
      {
         var a:ActionRef = null;
         var c:ICell = null;
         if(data == null || !data.add(this))
         {
            return;
         }
         if(Boolean(data.volatile) || !this._primary.isLoaded())
         {
            Logger.info("Loading primary : " + this);
            this._primary.load(data);
         }
         var ver:int = -1;
         var decr:Boolean = true;
         ver = this.getSecondaryVersionIndex();
         if(ver > -1)
         {
            for each(a in this._secondary[ver])
            {
               if(Boolean(data.volatile) || !a.isLoaded())
               {
                  a.load(data);
               }
               if(a is StartNextActionRef)
               {
                  if(a.timing.fromStart && a.timing.seconds < 0.5)
                  {
                     decr = false;
                  }
               }
            }
         }
         if(data.level > 0)
         {
            c = _f.getCellByID(this._childId);
            if(Boolean(c))
            {
               if(decr)
               {
                  data.decrement();
               }
               data.volatile = false;
               c.load(data);
            }
         }
      }
      
      override public function isLoaded() : Boolean
      {
         var ver:int = 0;
         var a:ActionRef = null;
         Logger.info("isLoaded()? : " + this);
         if(!this._primary.isLoaded())
         {
            Logger.info("Primary is not loaded : " + this._primary);
            return false;
         }
         if(this._secondary.length > 0)
         {
            ver = -1;
            ver = this.getSecondaryVersionIndex();
            if(ver > -1)
            {
               for each(a in this._secondary[ver])
               {
                  if(!a.isLoaded())
                  {
                     Logger.info("Secondary is not loaded : " + a);
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      override public function get loadStatus() : int
      {
         if(this.isLoaded())
         {
            _loadStatus = LoadStatus.STATUS_LOADED;
         }
         else
         {
            _loadStatus = LoadStatus.STATUS_INVALIDATED;
         }
         return _loadStatus;
      }
      
      public function get child() : ICell
      {
         return _f.getCellByID(this._childId);
      }
      
      public function get primaryAction() : IActionRef
      {
         return this._primary;
      }
      
      public function hasStartedNext() : Boolean
      {
         return this._startedNext;
      }
      
      public function startedNext() : void
      {
         this._startedNext = true;
      }
   }
}
