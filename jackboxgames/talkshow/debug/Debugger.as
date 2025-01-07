package jackboxgames.talkshow.debug
{
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.system.System;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.JSON;
   import jackboxgames.talkshow.api.*;
   import jackboxgames.talkshow.api.events.*;
   import jackboxgames.talkshow.cells.*;
   import jackboxgames.talkshow.utils.*;
   import jackboxgames.utils.*;
   
   public class Debugger
   {
      public static var DEFAULT_FONT:String = "Courier New";
      
      private var _jump:Object;
      
      private var _log:Array;
      
      private var _showCells:Boolean;
      
      private var _cellNumClip:MovieClip;
      
      private var _cellField:TextField;
      
      private var _lastCell:ICell;
      
      private var _connected:Boolean;
      
      private var _debugging:Boolean;
      
      private var _ts:IEngineAPI;
      
      public function Debugger(ts:IEngineAPI)
      {
         super();
         this._log = new Array();
         this._showCells = false;
         this._connected = false;
         this._debugging = ts.flashVars.debugging == 1;
         this._ts = ts;
         this._ts.addEventListener(CellEvent.CELL_STARTED,this.handleCellStarted);
         this._ts.addEventListener(CellEvent.NO_REF_BRANCH,this.handleNoRefBranch);
         Logger.getInstance().addEventListener(LogEvent.LOG,this.handleLogMessage);
         if(ts.flashVars.debugging == 1)
         {
            this.connect();
         }
         this.setupKeyListener();
         if(EnvUtil.isDebug())
         {
            this._ts.container.stage.addEventListener(KeyboardEvent.KEY_UP,this.handleStatsKeypress);
         }
      }
      
      protected function handleStatsKeypress(evt:KeyboardEvent) : void
      {
         switch(evt.keyCode)
         {
            case Keyboard.F12:
               if(evt.ctrlKey || evt.shiftKey)
               {
               }
         }
      }
      
      public function get isDebugging() : Boolean
      {
         return this._debugging;
      }
      
      public function setupKeyListener() : void
      {
         this._ts.container.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleKey,false,3000);
      }
      
      private function handleKey(event:KeyboardEvent) : void
      {
         var item:LogEvent = null;
         var vars:Array = null;
         var l:String = "";
         if(event.keyCode == Keyboard.F6)
         {
            if(event.ctrlKey)
            {
               if(event.shiftKey)
               {
                  vars = [];
                  this.getVariableArray({
                     "g":this._ts.g,
                     "l":this._ts.l
                  },"",false,vars);
                  vars.sort();
                  System.setClipboard(vars.join("\n"));
               }
               else
               {
                  for each(item in this._log)
                  {
                     if(item is LogEvent)
                     {
                        l += item.toString() + "\n";
                     }
                  }
                  System.setClipboard(l);
               }
            }
            else
            {
               for each(item in this._log)
               {
                  if(item is LogEvent && item.level > 3)
                  {
                     l += item.toString() + "\n";
                  }
               }
               if(l == "")
               {
                  l = "No Errors";
               }
               System.setClipboard(l);
            }
         }
         else if(event.keyCode == Keyboard.F7 && event.ctrlKey && event.shiftKey)
         {
            this._showCells = this._showCells ? false : true;
            if(this._showCells)
            {
               this.showCellNumbers();
            }
            else
            {
               this.hideCellNumbers();
            }
         }
      }
      
      public function getLog() : String
      {
         var item:* = undefined;
         var log:String = "";
         for each(item in this._log)
         {
            if(item is LogEvent)
            {
               log += item.toString() + "\n";
            }
         }
         return log;
      }
      
      private function showCellNumbers() : void
      {
         this._cellNumClip = new MovieClip();
         this._cellField = new TextField();
         var fmt:TextFormat = new TextFormat();
         fmt.color = 16777215;
         fmt.bold = true;
         fmt.font = DEFAULT_FONT;
         fmt.size = 12;
         this._cellField.defaultTextFormat = fmt;
         this._cellNumClip.addChild(this._cellField);
         this._ts.container.addChild(this._cellNumClip);
         this.drawNumber(this._lastCell);
      }
      
      private function hideCellNumbers() : void
      {
         this._ts.container.removeChild(this._cellNumClip);
      }
      
      private function drawNumber(c:ICell) : void
      {
         if(c == null)
         {
            this._cellField.text = "Unknown Cell";
         }
         else if(c.flowchart == null)
         {
            this._cellField.text = "Unknown Flowchart:" + c.id;
         }
         else
         {
            this._cellField.text = c.flowchart.flowchartName + " : " + c.id;
         }
         this._cellField.width = this._cellField.textWidth + 10;
         this._cellNumClip.graphics.clear();
         this._cellNumClip.graphics.beginFill(0);
         this._cellNumClip.graphics.drawRect(0,0,this._cellField.textWidth + 3,this._cellField.textHeight + 3);
      }
      
      private function handleCellStarted(event:CellEvent) : void
      {
         if(this._connected)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("__cell__",event.cell.id,event.cell.flowchart.id);
            }
            if(event.cell is ActionCell || event.cell is InputCell || event.cell is ReferenceCell || event.cell is TemplateCell)
            {
               this.sendVariables();
            }
         }
         this._lastCell = event.cell;
         if(this._showCells)
         {
            this.drawNumber(this._lastCell);
         }
      }
      
      private function handleLogMessage(event:LogEvent) : void
      {
         this._log.push(event);
         if(this._connected)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("__log__",new Date().time,event.level,event.message,event.category);
            }
         }
      }
      
      private function handleDebugStart(c:int, f:int) : void
      {
         this._jump = new Object();
         this._jump.c = c;
         this._jump.f = f;
      }
      
      public function getVariableArray(obj:*, prefix:String, isArray:Boolean, vars:Array) : int
      {
         var key:String = null;
         var a:Boolean = false;
         var result:int = 0;
         var str:String = "";
         var count:int = 0;
         for(key in obj)
         {
            a = obj[key] is Array;
            if(typeof obj[key] == "object" || a)
            {
               result = this.getVariableArray(obj[key],prefix + key + (a ? "" : "."),a,vars);
               if(result == 0)
               {
                  vars.push(prefix + key + " {" + (a ? "array" : typeof obj[key]) + "}");
                  count++;
               }
            }
            else
            {
               count++;
               if(isArray)
               {
                  vars.push(prefix + "[" + key + "]=" + obj[key] + " {" + typeof obj[key] + "}");
               }
               else
               {
                  vars.push(prefix + key + "=" + obj[key] + " {" + typeof obj[key] + "}");
               }
            }
         }
         return count;
      }
      
      private function sendVariables() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("__vars__",JSON.serialize({
               "g":this._ts.g,
               "l":this._ts.l
            }));
         }
      }
      
      private function handlePause() : void
      {
         this._ts.pauser.userPause();
      }
      
      private function handleResume() : void
      {
         this._ts.pauser.userResume();
      }
      
      private function handleSetVars(jsonString:String) : void
      {
         var variableList:Array = JSON.deserialize(jsonString) as Array;
         Assert.assert(variableList != null);
         for(var i:uint = 0; i < variableList.length; i += 2)
         {
            this._ts.setVariableValue(variableList[i],variableList[i + 1]);
            Logger.warning("Set variable: " + variableList[i] + "=" + variableList[i + 1]);
         }
      }
      
      public function connect() : void
      {
         this._connected = true;
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("debugPause",this.handlePause);
               ExternalInterface.addCallback("debugResume",this.handleResume);
               ExternalInterface.addCallback("debugStart",this.handleDebugStart);
               ExternalInterface.addCallback("setVariables",this.handleSetVars);
               ExternalInterface.call("__ready__");
            }
         }
         catch(error:SecurityError)
         {
            handleLogMessage(new LogEvent("log",false,false,3,0,"cat","SecurityError: " + error.message));
         }
         catch(error:Error)
         {
            handleLogMessage(new LogEvent("log",false,false,3,0,"cat","Error: " + error.message));
         }
         this._jump = null;
      }
      
      public function getJump() : Object
      {
         return this._jump;
      }
      
      private function handleNoRefBranch(evt:CellEvent) : void
      {
         var refVar:String;
         var tf:TextField;
         var txt:String;
         var refCell:IBranchingCell = null;
         var clip:MovieClip = null;
         var b:IBranch = null;
         var style:StyleSheet = null;
         var hover:Object = null;
         var link:Object = null;
         var onBranchClick:Function = null;
         var hitlist:Array = null;
         (this._ts as Object).startNextManager.reset();
         refCell = evt.cell as IBranchingCell;
         refVar = (evt.cell as Object).referenceVariable;
         clip = new MovieClip();
         tf = new TextField();
         txt = "<body>No matching branch for reference cell: " + refVar + "=" + VariableUtil.getVariableValue(refVar);
         for each(b in refCell.branches)
         {
            hitlist = (b as Object).hitlist;
            if(hitlist == null || hitlist[0].length == 0)
            {
               txt += "\n     <a href=\"event:" + b.branchId + "\">[Branch " + b.branchId + "]</a>";
            }
            else
            {
               txt += "\n     <a href=\"event:" + b.branchId + "\">" + hitlist[0] + "</a>";
            }
         }
         txt += "</body>";
         style = new StyleSheet();
         hover = new Object();
         hover.fontWeight = "bold";
         hover.color = "#DDDDFF";
         link = new Object();
         link.fontWeight = "bold";
         link.textDecoration = "underline";
         link.color = "#9999FF";
         style.setStyle("a",link);
         style.setStyle("a:hover",hover);
         style.setStyle("body",{
            "fontFamily":DEFAULT_FONT,
            "marginLeft":20,
            "color":"#FFFFFF"
         });
         tf.styleSheet = style;
         tf.htmlText = txt;
         onBranchClick = function(evt2:TextEvent):void
         {
            var b:IBranch = null;
            for each(b in refCell.branches)
            {
               if(String(b.branchId) == evt2.text)
               {
                  if(_ts.container.contains(clip))
                  {
                     _ts.container.removeChild(clip);
                  }
                  b.start();
                  return;
               }
            }
         };
         tf.addEventListener(TextEvent.LINK,onBranchClick);
         tf.width = this._ts.container.stage.stageWidth - 80;
         tf.height = tf.textHeight + 20;
         clip.graphics.beginFill(0,0.8);
         clip.graphics.lineStyle(2,16777215,0.5);
         clip.graphics.drawRoundRect(20,10,this._ts.container.stage.stageWidth - 40,tf.textHeight + 20,20,20);
         clip.addChild(tf);
         tf.selectable = false;
         tf.x = 20;
         tf.y = 20;
         this._ts.container.addChild(clip);
      }
   }
}

