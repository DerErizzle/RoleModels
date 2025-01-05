package jackboxgames.utils
{
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   
   public class DeveloperConsole extends Sprite
   {
      
      public static var API:* = {};
      
      public static var DEFAULT_FONT:String = "Courier New";
      
      internal static const levels:Array = ["","debug","info","warn","error"];
       
      
      public var consoleHeight:Number = 300;
      
      public var maxSuggestions:int = 14;
      
      public var showTypes:Boolean = true;
      
      public var createVarsThatDontExist:Boolean = true;
      
      public var slideAnimation:Boolean = true;
      
      public var slideAnimation_speed:Number = 15;
      
      public var tracerView:Boolean = true;
      
      public var tracerActualTrace:Boolean = false;
      
      public var tracerActualTraceFPS:Boolean = false;
      
      public var tracerActualTraceLayout:String = "name : value";
      
      public var tracerOneCiclePerLine:Boolean = true;
      
      public var tracerOneCiclePerLine_seperator:String = "   ";
      
      private const colour_type:String = "06C1FF";
      
      private const colour_param_type:String = "B5B5B5";
      
      private const colour_method_name:String = "FFFFFF";
      
      private const VERSION_NAME:String = "Torrunt\'s AS3 Developer Console";
      
      private const HELP:String = " - Type \'clear\' to clear the console\n" + " - Type \'author\' to get info on the author of this console\n" + " - Use Quotations when you want enter string literal with spaces (\"\")\n" + " - Use Square Brackets when you want to use an arral literal (e.g:[0][1])\n" + " - You can do multiple commands at once by seperating them with \';\'s\n" + " - You can also put x# after a \';\' to do that command # many times\n" + " - Calculations are allowed when assigning or in parameters (+,-,*,/,%). BIMDAS is not supported\n" + " - Type \'trace:something\' to start tracing something or \'stoptrace:something\' to stop tracing it\n" + " - You can also use \'trace:fps\' to check your fps\n" + " - Toggle Fullscreen console with the F7 key\n" + " - Use the Up/Down arrow keys to go through your previous used commands or suggestions\n" + " - Use PAGE UP/DOWN and HOME/END on your keyboard to scroll up and down";
      
      private const AUTHOR:String = this.VERSION_NAME + " was programmed by Corey Zeke Womack (Torrunt)\nme@torrunt.net\nhttp://torrunt.net";
      
      private const INPUTTEXT_HEIGHT:int = 21;
      
      private const SUGGESTTEXT_HEIGHT:int = 20;
      
      private var opened:Boolean = false;
      
      private var container:Sprite;
      
      private var suggestText:TextField;
      
      private var consoleTextFormat:TextFormat;
      
      private var historyText:TextField;
      
      private var inputText:TextField;
      
      private var cmdSuggest:Array;
      
      private var cmdhistory:Array;
      
      private var cicle:Array;
      
      private var hpos:int = -1;
      
      private const consoleHeight_default:Number = this.consoleHeight;
      
      private var tempVarNames:Array;
      
      private var tempVars:Array;
      
      private var slideAnimation_animating:Boolean = false;
      
      private var slideAnimation_target:Number = 0;
      
      private var tracer:TextField;
      
      private var tracerNames:TextField;
      
      private var traceVars:Array;
      
      private var tracerAlignX:Number;
      
      private var tracerAlignY:Number;
      
      public var fps:String;
      
      private var last:uint;
      
      private var ticks:uint = 0;
      
      private const MAXIMUM_LINES:int = 25;
      
      private var lines:Array;
      
      private var echo_arguments:Array;
      
      private const KEY_CODES:Object = {
         "default":{
            "Backspace":Keyboard.BACKSPACE,
            "Enter":Keyboard.ENTER,
            "PageUp":Keyboard.PAGE_UP,
            "PageDown":Keyboard.PAGE_DOWN,
            "Home":Keyboard.HOME,
            "End":Keyboard.END,
            "Up":Keyboard.UP,
            "Down":Keyboard.DOWN,
            "ToggleFullScreen":Keyboard.F7,
            "OpenClose":Keyboard.BACKQUOTE
         },
         "ps4":{
            "Backspace":42,
            "Enter":40,
            "PageUp":75,
            "PageDown":78,
            "Home":74,
            "End":77,
            "Up":82,
            "Down":81,
            "ToggleFullScreen":64,
            "OpenClose":53
         },
         "mobile":{
            "Backspace":67,
            "Enter":66,
            "PageUp":92,
            "PageDown":93,
            "Home":122,
            "End":123,
            "Up":19,
            "Down":20,
            "ToggleFullScreen":137,
            "OpenClose":68
         }
      };
      
      private var pressedUp:Boolean = false;
      
      private var areSuggestions:Boolean = false;
      
      private var hitMax:Boolean = false;
      
      private var keyDict:Dictionary;
      
      public function DeveloperConsole(stage:Stage)
      {
         this.container = new Sprite();
         this.cmdSuggest = new Array();
         this.cmdhistory = new Array();
         this.tempVarNames = new Array();
         this.tempVars = new Array();
         this.traceVars = new Array();
         this.last = getTimer();
         super();
         this.echo_arguments = new Array();
         this.lines = new Array();
         this.container.visible = false;
         addChild(this.container);
         this.consoleTextFormat = new TextFormat();
         this.consoleTextFormat.size = 12;
         this.consoleTextFormat.font = DEFAULT_FONT;
         this.consoleTextFormat.color = 16777215;
         this.historyText = new TextField();
         this.container.addChild(this.historyText);
         this.historyText.width = stage.stageWidth;
         this.historyText.height = this.consoleHeight - this.INPUTTEXT_HEIGHT;
         this.historyText.alpha = 0.65;
         this.historyText.selectable = false;
         this.historyText.multiline = true;
         this.historyText.condenseWhite = true;
         this.historyText.wordWrap = true;
         this.historyText.embedFonts = true;
         this.historyText.defaultTextFormat = this.consoleTextFormat;
         this.historyText.background = true;
         this.historyText.backgroundColor = 0;
         this.inputText = new TextField();
         this.inputText.type = TextFieldType.INPUT;
         this.container.addChild(this.inputText);
         this.inputText.width = stage.stageWidth;
         this.inputText.height = this.INPUTTEXT_HEIGHT;
         this.inputText.y = this.historyText.height;
         this.inputText.x = 0;
         this.inputText.alpha = 0.85;
         this.inputText.defaultTextFormat = this.consoleTextFormat;
         this.inputText.background = true;
         this.inputText.backgroundColor = 4934475;
         this.suggestText = new TextField();
         this.container.addChild(this.suggestText);
         this.suggestText.width = 150;
         this.suggestText.height = this.SUGGESTTEXT_HEIGHT;
         this.suggestText.y = this.inputText.y + this.inputText.height;
         this.suggestText.alpha = 0.85;
         this.suggestText.selectable = false;
         this.suggestText.defaultTextFormat = this.consoleTextFormat;
         this.suggestText.background = true;
         this.suggestText.backgroundColor = 0;
         this.suggestText.autoSize = TextFieldAutoSize.LEFT;
         this.suggestText.visible = false;
         this.suggestText.multiline = true;
         this.tracerAlignX = stage.stageWidth - 5;
         this.tracerAlignY = 5;
         this.consoleTextFormat.bold = true;
         this.tracer = new TextField();
         addChild(this.tracer);
         this.tracer.alpha = 0.75;
         this.tracer.selectable = false;
         this.consoleTextFormat.align = "right";
         this.tracer.defaultTextFormat = this.consoleTextFormat;
         this.tracer.background = true;
         this.tracer.backgroundColor = 6710886;
         this.tracer.autoSize = TextFieldAutoSize.LEFT;
         this.tracer.y = -this.tracer.height;
         this.tracer.visible = false;
         this.tracerNames = new TextField();
         addChild(this.tracerNames);
         this.tracerNames.alpha = 0.75;
         this.tracerNames.selectable = false;
         this.consoleTextFormat.align = "left";
         this.tracerNames.defaultTextFormat = this.consoleTextFormat;
         this.tracerNames.background = true;
         this.tracerNames.backgroundColor = 6710886;
         this.tracerNames.autoSize = TextFieldAutoSize.LEFT;
         this.tracerNames.y = -this.tracerNames.height;
         this.tracerNames.visible = false;
         if(this.slideAnimation)
         {
            this.container.y = -(this.historyText.height + this.inputText.height + this.suggestText.height);
         }
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyToggle,false,int.MAX_VALUE);
         if(Logger.isEnabled())
         {
            Logger.console = this;
         }
         this.keyDict = this.getKeyboardDict();
      }
      
      public static function isEnabled() : Boolean
      {
         return BuildConfig.instance.configVal("dev-console");
      }
      
      public function open() : void
      {
         if(this.opened)
         {
            return;
         }
         this.opened = true;
         this.printHistory();
         if(!EnvUtil.isAIR())
         {
            Input.instance.setConsoleMode(true);
            Platform.instance.sendMessageToNative("DeveloperConsoleIsVisible",true);
         }
         parent.setChildIndex(this,parent.numChildren - 1);
         this.container.visible = true;
         parent.stage.focus = this.inputText;
         parent.stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUp,false,int.MAX_VALUE - 1);
         parent.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDown,false,int.MAX_VALUE - 1);
         this.inputText.addEventListener(TextEvent.TEXT_INPUT,this.onTextInput);
         if(this.slideAnimation)
         {
            this.startSlideAnimation(true);
         }
      }
      
      public function close() : void
      {
         if(!this.opened)
         {
            return;
         }
         if(!EnvUtil.isAIR())
         {
            Input.instance.setConsoleMode(false);
            Platform.instance.sendMessageToNative("DeveloperConsoleIsVisible",false);
         }
         this.container.visible = false;
         this.opened = false;
         this.inputText.text = "";
         this.hpos = -1;
         parent.stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUp,false);
         parent.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDown,false);
         this.inputText.removeEventListener(TextEvent.TEXT_INPUT,this.onTextInput);
         if(this.slideAnimation)
         {
            this.startSlideAnimation(false);
         }
      }
      
      public function toggle() : void
      {
         if(this.opened)
         {
            this.close();
         }
         else
         {
            this.open();
         }
      }
      
      public function isOpen() : Boolean
      {
         return this.opened;
      }
      
      private function _getKeyCodesToUse() : Object
      {
         if(this.KEY_CODES.hasOwnProperty(Platform.instance.PlatformId.toLowerCase()))
         {
            return this.KEY_CODES[Platform.instance.PlatformId.toLowerCase()];
         }
         if(EnvUtil.isMobile())
         {
            return this.KEY_CODES["mobile"];
         }
         return this.KEY_CODES["default"];
      }
      
      private function keyDown(e:KeyboardEvent) : void
      {
         e.stopImmediatePropagation();
         var keyCodesToUse:Object = this._getKeyCodesToUse();
         if(e.keyCode == keyCodesToUse["Enter"] && this.inputText.text != "")
         {
            this.echo(this.inputText.text,"#999999");
            if(this.cmdhistory[this.cmdhistory.length - 1] != this.inputText.text)
            {
               this.cmdhistory.push(this.inputText.text);
               this.hpos = -1;
            }
            this.eval(this.inputText.text);
            this.inputText.text = "";
            this.hideSuggestions();
            return;
         }
         if(e.keyCode == keyCodesToUse["Backspace"])
         {
            if(EnvUtil.isConsole())
            {
               if(this.inputText.length > 0)
               {
                  this.inputText.text = this.inputText.text.substr(0,this.inputText.length - 1);
               }
            }
            if(this.inputText.length - 1 <= 0)
            {
               this.hideSuggestions();
            }
            else
            {
               this.showSuggestions(this.inputText.text.substr(0,this.inputText.length - 1));
            }
            return;
         }
         if(this.suggestText.visible)
         {
            this.cicle = this.cmdSuggest;
         }
         else
         {
            this.cicle = this.cmdhistory;
         }
         if(e.keyCode == keyCodesToUse["Up"] && this.cicle[this.cicle.length - 1 - (this.hpos + 1)] != null)
         {
            ++this.hpos;
            this.changeInputbox();
            this.pressedUp = true;
            return;
         }
         if(e.keyCode == keyCodesToUse["Down"])
         {
            if(this.cicle[this.cicle.length - 1 - (this.hpos - 1)] != null)
            {
               --this.hpos;
               this.changeInputbox();
            }
            else if(this.cicle == this.cmdhistory)
            {
               this.inputText.text = "";
               this.hpos = -1;
            }
            return;
         }
         if(e.keyCode == keyCodesToUse["PageUp"])
         {
            --this.historyText.scrollV;
            return;
         }
         if(e.keyCode == keyCodesToUse["PageDown"])
         {
            ++this.historyText.scrollV;
            return;
         }
         if(e.keyCode == keyCodesToUse["Home"])
         {
            this.historyText.scrollV = 0;
            return;
         }
         if(e.keyCode == keyCodesToUse["End"])
         {
            this.historyText.scrollV = this.historyText.maxScrollV;
            return;
         }
         if(e.keyCode == keyCodesToUse["ToggleFullScreen"])
         {
            this.toggleFullscreen();
            return;
         }
      }
      
      private function keyUp(e:KeyboardEvent) : void
      {
         e.stopImmediatePropagation();
         if(this.pressedUp)
         {
            this.inputText.setSelection(this.inputText.length,this.inputText.length);
            this.pressedUp = false;
         }
      }
      
      private function keyToggle(e:KeyboardEvent) : void
      {
         var keyCodesToUse:Object = this._getKeyCodesToUse();
         if(e.keyCode == keyCodesToUse["OpenClose"])
         {
            e.preventDefault();
            this.toggle();
         }
      }
      
      private function changeInputbox() : void
      {
         var symbols:Array = null;
         var ls:int = 0;
         var i:int = 0;
         if(this.cicle == this.cmdSuggest)
         {
            if(this.inputText.text.lastIndexOf("();") + 3 == this.inputText.length)
            {
               this.inputText.text = this.inputText.text.substr(0,this.inputText.length - 3);
            }
            symbols = this.fillArrayWithIndexsOf(symbols,this.inputText.text,["."," ","(",",","-","+","/","*","%",";",":","["]);
            ls = int(symbols[0]);
            for(i = 1; i < symbols.length; i++)
            {
               if(symbols[i] > ls)
               {
                  ls = int(symbols[i]);
               }
            }
            if(this.inputText.text.charAt(ls) == "(" && ls == this.inputText.length - 1)
            {
               this.inputText.text = this.inputText.text.substr(0,ls);
               this.changeInputbox();
               return;
            }
            this.inputText.text = this.inputText.text.substr(0,ls + 1);
            this.inputText.appendText(this.cicle[this.cicle.length - 1 - this.hpos]);
         }
         else
         {
            this.inputText.text = this.cicle[this.cicle.length - 1 - this.hpos];
         }
         this.inputText.setSelection(this.inputText.length,this.inputText.length);
      }
      
      private function onTextInput(e:TextEvent) : void
      {
         var realText:String = e.text;
         if(!EnvUtil.isAIR())
         {
            realText = realText.charAt(0);
         }
         if(realText == "`" || this.inputText.text == "`")
         {
            this.inputText.text = this.inputText.text.slice(0,-1);
         }
         this.showSuggestions(this.inputText.text + realText);
      }
      
      private function showSuggestions(str:String) : void
      {
         var startFrom:int;
         var s:int;
         var symbols:Array = null;
         var ob:* = undefined;
         var stre:String = null;
         var description:XML = null;
         var type:String = null;
         var variable:XMLList = null;
         var v:XML = null;
         var variableName:String = null;
         var variableType:String = null;
         var accessor:XMLList = null;
         var a:XML = null;
         var accessorName:String = null;
         var accessorType:String = null;
         var methods:XMLList = null;
         var m:XML = null;
         var methodName:String = null;
         var text:String = null;
         var returnType:String = null;
         var first:Boolean = false;
         var parameter:XMLList = null;
         var p:XML = null;
         var parameterType:String = null;
         this.hideSuggestions();
         this.areSuggestions = false;
         this.hitMax = false;
         if(str.length == 0)
         {
            return;
         }
         if(str.indexOf(";") > 1)
         {
            str = str.slice(str.lastIndexOf(";") + 1,str.length);
         }
         str = this.stringReplaceAll(str," ");
         symbols = this.fillArrayWithIndexsOf(symbols,str,["(","=",",","-","+","/","*","%",":","["]);
         if(this.characterCount(str,"]") == this.characterCount(str,"["))
         {
            symbols.pop();
         }
         if(this.characterCount(str,")") == this.characterCount(str,"("))
         {
            symbols.shift();
         }
         startFrom = int(symbols[0]);
         for(s = 1; s < symbols.length; s++)
         {
            if(symbols[s] > startFrom)
            {
               startFrom = int(symbols[s]);
            }
         }
         str = str.substring(startFrom + 1,str.length);
         if(str != "")
         {
            try
            {
               ob = this.stringToVarWithCalculation(str,API,true);
               stre = str.substring(str.lastIndexOf(".") + 1,str.length);
               description = describeType(ob);
               type = "";
               if(description.*.length() > 3)
               {
                  if(description.variable != undefined)
                  {
                     variable = description.variable;
                     for each(v in variable)
                     {
                        if(this.suggestText.numLines >= this.maxSuggestions)
                        {
                           this.hitMax = true;
                           break;
                        }
                        variableName = v.@name;
                        if(variableName.indexOf(stre) == 0)
                        {
                           if(this.showTypes)
                           {
                              variableType = v.@type;
                              type = "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">: </font>" + "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_type + "\">" + variableType + "</font>";
                           }
                           this.cmdSuggest.push(variableName);
                           this.suggestText.htmlText += "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">" + variableName + " </font>" + type + "<br>";
                           this.areSuggestions = true;
                        }
                     }
                  }
                  if(description.accessor != undefined)
                  {
                     accessor = description.accessor;
                     for each(a in accessor)
                     {
                        if(this.suggestText.numLines >= this.maxSuggestions)
                        {
                           this.hitMax = true;
                           break;
                        }
                        accessorName = a.@name;
                        if(accessorName.indexOf(stre) == 0)
                        {
                           if(this.showTypes)
                           {
                              accessorType = v.@type;
                              type = "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">: </font>" + "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_type + "\">" + accessorType + "</font>";
                           }
                           this.cmdSuggest.push(accessorName);
                           this.suggestText.htmlText += "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">" + accessorName + " </font>" + type + " <font face=\"" + DEFAULT_FONT + "\" color=\"#818181\">(accessor)</font><br>";
                           this.areSuggestions = true;
                        }
                     }
                  }
                  if(description.method != undefined)
                  {
                     methods = description.method;
                     for each(m in methods)
                     {
                        if(this.suggestText.numLines >= this.maxSuggestions)
                        {
                           this.hitMax = true;
                           break;
                        }
                        methodName = m.@name;
                        if(methodName.indexOf(stre) == 0)
                        {
                           if(this.showTypes)
                           {
                              returnType = m.@returnType;
                              type = "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">: </font>" + "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_type + "\">" + returnType + "</font>";
                           }
                           text = "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">" + methodName + " (</font>";
                           this.areSuggestions = true;
                           if(m.parameter != undefined)
                           {
                              first = true;
                              parameter = m.parameter;
                              for each(p in parameter)
                              {
                                 if(!first)
                                 {
                                    text += "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">, </font>";
                                 }
                                 first = false;
                                 parameterType = p.@type;
                                 text += "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_param_type + "\">" + parameterType + "</font>";
                              }
                              this.cmdSuggest.push(methodName + "(");
                           }
                           else
                           {
                              this.cmdSuggest.push(methodName + "();");
                           }
                           this.suggestText.htmlText += text + "<font face=\"" + DEFAULT_FONT + "\" color=\"#" + this.colour_method_name + "\">) </font>" + type + "<br>";
                        }
                     }
                  }
               }
               if(this.areSuggestions)
               {
                  if(this.hitMax)
                  {
                     this.suggestText.htmlText += "...";
                  }
                  if(this.consoleHeight == parent.stage.stageHeight)
                  {
                     this.suggestText.y = this.inputText.y - this.suggestText.height;
                  }
                  else
                  {
                     this.suggestText.y = this.inputText.y + this.inputText.height;
                  }
                  this.suggestText.visible = true;
                  this.hpos = this.cmdSuggest.length;
               }
               else
               {
                  this.suggestText.htmlText = "";
               }
            }
            catch(er:Error)
            {
               Logger.error("DeveloperConsole::showSuggestions => " + str + " " + TraceUtil.objectRecursive(er,"er"));
               suggestText.htmlText = "";
            }
         }
      }
      
      private function hideSuggestions() : void
      {
         this.suggestText.visible = false;
         this.suggestText.htmlText = "";
         this.suggestText.height = 20;
         this.cmdSuggest = new Array();
         this.hpos = -1;
      }
      
      public function eval(str:String) : void
      {
         var c:Array = null;
         var i:int = 0;
         var r:int = 0;
         if(str.indexOf(";") > 1)
         {
            c = str.split(";");
            for(i = 0; i < c.length; i++)
            {
               if(c[i].indexOf("x") == 0)
               {
                  c[i] = Number(c[i].slice(1,c[i].length));
                  for(r = 1; r < c[i]; r++)
                  {
                     this.interpretString(c[i - 1]);
                  }
               }
               else if(c[i] != "")
               {
                  this.interpretString(c[i]);
               }
            }
         }
         else
         {
            this.interpretString(str);
         }
      }
      
      private function interpretString(str:String) : void
      {
         var ar:Array = null;
         str = this.stringReplaceAll(str,";");
         str = this.stringReplaceButExclude(str," ",["\""],"",[false]);
         if(str.indexOf("=") > 0)
         {
            ar = str.split("=");
            ar = this.checkShorthandCalculations(ar);
            ar[1] = this.stringToVarWithCalculation(ar[1]);
            this.changeVar(ar[0],ar[1]);
         }
         else if(str.indexOf("trace:") == 0)
         {
            this.setTrace(str);
         }
         else if(str.indexOf("stoptrace:") == 0)
         {
            this.stopTrace(str);
         }
         else
         {
            switch(str)
            {
               case "clear":
                  this.historyText.text = "";
                  break;
               case "help":
                  this.echo(this.HELP,"#0099CC");
                  break;
               case "author":
                  this.echo(this.AUTHOR,"#0099CC");
                  break;
               default:
                  this.getVar(str);
            }
         }
      }
      
      private function getVar(varname:String) : void
      {
         var value:* = undefined;
         var rstring:String = varname + " returned ";
         try
         {
            value = this.stringToVarWithCalculation(varname);
            if(value == undefined)
            {
               return;
            }
            rstring += value;
            this.echo(rstring);
         }
         catch(er:Error)
         {
            error(er.message);
         }
      }
      
      private function changeVar(varname:String, vset:*) : void
      {
         var str:String = null;
         var v:Array = null;
         var index:int = 0;
         try
         {
            try
            {
               if(vset is String)
               {
                  vset = this.stringToArray(vset);
               }
            }
            catch(er:Error)
            {
            }
            if(vset == "true")
            {
               vset = true;
            }
            else if(vset == "false")
            {
               vset = false;
            }
            if(!isNaN(vset))
            {
               vset = Number(vset);
            }
            str = this.stringReplaceButExclude(varname,".",["[","]","(",")"],"`",[false,false,false,false]);
            v = str.split("`");
            if(!this.assignVar(varname,vset,v,API))
            {
               throw new Error();
            }
         }
         catch(er:Error)
         {
            index = tempVarNames.indexOf(v[0]);
            if(index == -1 && stringToVar(varname) != varname)
            {
               error("Invalid type");
            }
            else if(createVarsThatDontExist && v.length == 1)
            {
               tempVarNames.push(v[0]);
               tempVars.push(vset);
               warn("Temporary variable called \"" + v[0] + "\" created with the value " + vset);
            }
            else
            {
               error(er.message);
            }
         }
      }
      
      private function assignVar(varname:String, vset:*, v:Array, ob:*, skipFirstIndex:Boolean = false) : Boolean
      {
         var tempAry:Array = null;
         var i:int = 0;
         var cl:* = undefined;
         var index:int = 0;
         try
         {
            for(i = skipFirstIndex ? 1 : 0; i < v.length - 1; i++)
            {
               if(v[i].indexOf("[") > -1)
               {
                  tempAry = this.stringToArrayItem(v[i]);
                  switch(tempAry.length)
                  {
                     case 4:
                        ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]];
                        break;
                     case 3:
                        ob = ob[tempAry[0]][tempAry[1]][tempAry[2]];
                        break;
                     default:
                        ob = ob[tempAry[0]][tempAry[1]];
                  }
               }
               else
               {
                  ob = ob[v[i]];
               }
            }
            if(v[v.length - 1].indexOf("[") == -1)
            {
               ob[v[v.length - 1]] = vset;
               this.echo(varname + " is now: " + ob[v[v.length - 1]]);
            }
            else
            {
               tempAry = this.stringToArrayItem(v[v.length - 1]);
               switch(tempAry.length)
               {
                  case 4:
                     ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]] = vset;
                     break;
                  case 3:
                     ob[tempAry[0]][tempAry[1]][tempAry[2]] = vset;
                     break;
                  default:
                     ob[tempAry[0]][tempAry[1]] = vset;
               }
            }
            return true;
         }
         catch(e:Error)
         {
            cl = v[0];
            i = 0;
            while(i < v.length)
            {
               try
               {
                  ob = getDefinitionByName(cl) as Class;
                  break;
               }
               catch(e:Error)
               {
                  cl = cl + "." + v[i + 1];
               }
               i++;
            }
            if(ob is Class)
            {
               i++;
               while(i < v.length)
               {
                  ob[v[v.length - 1]] = vset;
                  echo(varname + " is now " + ob[v[v.length - 1]]);
                  i++;
               }
               return v.length > 1;
            }
            index = tempVarNames.indexOf(v[0].indexOf("[") == -1 ? v[0] : v[0].substring(0,v[0].indexOf("[")));
            if(index != -1)
            {
               if(v.length > 1 || v[0].indexOf("[") != -1)
               {
                  ob = tempVars[index];
                  i = v[0].indexOf("[") != -1 ? 0 : 1;
                  while(i < v.length)
                  {
                     if(v[i].indexOf("[") != -1)
                     {
                        tempAry = stringToArrayItem(v[i]);
                        if(i == 0)
                        {
                           tempAry.shift();
                        }
                        switch(tempAry.length)
                        {
                           case 4:
                              ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]] = vset;
                              break;
                           case 3:
                              ob[tempAry[0]][tempAry[1]][tempAry[2]] = vset;
                              break;
                           case 2:
                              ob[tempAry[0]][tempAry[1]] = vset;
                              break;
                           default:
                              ob[tempAry[0]] = vset;
                        }
                     }
                     else
                     {
                        ob[v[i]] = vset;
                        echo(varname + " is now " + ob[v[i]]);
                     }
                     i++;
                  }
               }
               else
               {
                  tempVars[index] = vset;
                  echo(varname + " is now " + tempVars[index]);
               }
               return true;
            }
            return false;
         }
      }
      
      private function stringToVar(str:String, base:* = null, leaveOutLast:Boolean = false) : *
      {
         var ob:* = undefined;
         var lo:int = 0;
         var splitString:String = null;
         var v:Array = null;
         var i:int = 0;
         var tempAry:Array = null;
         var cl:* = undefined;
         var index:int = 0;
         if(base == null)
         {
            base = API;
         }
         ob = str;
         lo = 0;
         if(leaveOutLast)
         {
            lo = 1;
         }
         if(str.indexOf("\"") == -1 && isNaN(Number(str)))
         {
            splitString = this.stringReplaceButExclude(str,".",["[","]","(",")"],"`",[false,false,false,false]);
            v = splitString.split("`");
            try
            {
               ob = base;
               for(i = 0; i < v.length - lo; i++)
               {
                  if(v[i].indexOf("[") != -1)
                  {
                     tempAry = this.stringToArrayItem(v[i]);
                     switch(tempAry.length)
                     {
                        case 4:
                           ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]];
                           break;
                        case 3:
                           ob = ob[tempAry[0]][tempAry[1]][tempAry[2]];
                           break;
                        default:
                           ob = ob[tempAry[0]][tempAry[1]];
                     }
                  }
                  else
                  {
                     ob = ob[v[i]];
                  }
               }
               if(ob == undefined)
               {
                  throw new Error();
               }
            }
            catch(e:Error)
            {
               cl = v[0];
               i = 0;
               while(i < v.length)
               {
                  try
                  {
                     ob = getDefinitionByName(cl) as Class;
                     break;
                  }
                  catch(e:Error)
                  {
                     cl = cl + "." + v[i + 1];
                  }
                  i++;
               }
               if(ob is Class)
               {
                  i++;
                  while(i < v.length - lo)
                  {
                     if(v[i].indexOf("[") != -1)
                     {
                        tempAry = stringToArrayItem(v[i]);
                        switch(tempAry.length)
                        {
                           case 4:
                              ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]];
                              break;
                           case 3:
                              ob = ob[tempAry[0]][tempAry[1]][tempAry[2]];
                              break;
                           default:
                              ob = ob[tempAry[0]][tempAry[1]];
                        }
                     }
                     else
                     {
                        ob = ob[v[i]];
                     }
                     i++;
                  }
               }
               else
               {
                  index = tempVarNames.indexOf(v[0].indexOf("[") == -1 ? v[0] : v[0].substring(0,v[0].indexOf("[")));
                  if(index != -1)
                  {
                     ob = tempVars[index];
                     i = v[0].indexOf("[") != -1 ? 0 : 1;
                     while(i < v.length)
                     {
                        if(v[i].indexOf("[") != -1)
                        {
                           tempAry = stringToArrayItem(v[i]);
                           if(i == 0)
                           {
                              tempAry.shift();
                           }
                           switch(tempAry.length)
                           {
                              case 4:
                                 ob = ob[tempAry[0]][tempAry[1]][tempAry[2]][tempAry[3]];
                                 break;
                              case 3:
                                 ob = ob[tempAry[0]][tempAry[1]][tempAry[2]];
                                 break;
                              case 2:
                                 ob = ob[tempAry[0]][tempAry[1]];
                                 break;
                              default:
                                 ob = ob[tempAry[0]];
                           }
                        }
                        else
                        {
                           ob = ob[v[i]];
                        }
                        i++;
                     }
                  }
                  else
                  {
                     ob = str;
                  }
               }
            }
         }
         return ob;
      }
      
      private function stringToFunc(str:String, base:* = null, leaveOutLast:Boolean = false) : *
      {
         var pars:Array = null;
         var member:String = str.substring(str.indexOf(")") + 2);
         str = str.substring(0,str.indexOf(")"));
         var fn:String = str.substring(0,str.indexOf("("));
         var p:String = str.substring(str.indexOf("(") + 1);
         if(p == "")
         {
            pars = new Array();
         }
         else
         {
            pars = this.stringToPars(p);
         }
         if(member == "")
         {
            return this.stringToVar(fn,base,leaveOutLast).apply(null,pars);
         }
         return this.stringToVarWithCalculation(member,this.stringToVar(fn).apply(null,pars),leaveOutLast);
      }
      
      private function stringToNewInstance(str:String, allowError:Boolean = true) : *
      {
         var pars:Array = null;
         var obj:* = undefined;
         str = this.stringReplaceFirst(str,"new","");
         str = this.stringReplaceAll(str,")");
         var cl:* = str;
         var p:String = "";
         if(str.indexOf("(") != -1)
         {
            cl = str.substring(0,str.indexOf("("));
            p = str.substring(str.indexOf("(") + 1);
         }
         if(p == "")
         {
            pars = new Array();
         }
         else
         {
            pars = this.stringToPars(p);
         }
         cl = this.stringToVar(cl);
         try
         {
            switch(pars.length)
            {
               case 1:
                  obj = new cl(pars[0]);
                  break;
               case 2:
                  obj = new cl(pars[0],pars[1]);
                  break;
               case 3:
                  obj = new cl(pars[0],pars[1],pars[2]);
                  break;
               case 4:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3]);
                  break;
               case 5:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4]);
                  break;
               case 6:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5]);
                  break;
               case 7:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6]);
                  break;
               case 8:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7]);
                  break;
               case 9:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7],pars[8]);
                  break;
               case 10:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7],pars[8],pars[9]);
                  break;
               case 11:
                  obj = new cl(pars[0],pars[1],pars[2],pars[3],pars[4],pars[5],pars[6],pars[7],pars[8],pars[9],pars[10]);
                  break;
               default:
                  obj = new cl();
            }
         }
         catch(e:Error)
         {
            if(!allowError)
            {
               error(e.message);
            }
         }
         return obj;
      }
      
      private function stringToPars(str:String) : Array
      {
         str = this.stringReplaceFirst(str,"[","|");
         str = this.stringReplaceFirst(str,"]","|");
         str = this.stringReplaceButExclude(str,",",["|","(",")"],"`",[true,false,false]);
         var pars:Array = str.split("`");
         for(var i:int = 0; i < pars.length; i++)
         {
            try
            {
               pars[i] = this.stringToVarWithCalculation(pars[i]);
               if(pars[i].indexOf(",") > -1)
               {
                  pars[i] = this.stringToArray(pars[i],false);
               }
            }
            catch(er:Error)
            {
            }
         }
         return pars;
      }
      
      private function stringToArray(str:String, needSquareBrackets:Boolean = true) : *
      {
         var res:Array = null;
         var i:int = 0;
         if(str.indexOf("[") == 0 && str.lastIndexOf("]") == str.length - 1 || !needSquareBrackets)
         {
            if(needSquareBrackets)
            {
               str = str.substr(1,str.length - 2);
            }
            res = str.split(",");
            for(i = 0; i < res.length; i++)
            {
               try
               {
                  res[i] = this.stringToVarWithCalculation(res[i]);
               }
               catch(er:Error)
               {
               }
            }
         }
         else
         {
            res = this.stringToVarWithCalculation(res);
         }
         return res;
      }
      
      private function stringToArrayItem(str:String) : *
      {
         var i:uint = 0;
         var res:* = str;
         if(str.indexOf("[") > -1 && str.lastIndexOf("]") == str.length - 1)
         {
            str = this.stringReplaceAll(str,"]");
            res = str.split("[");
            for(i = 1; i < res.length; i++)
            {
               res[i] = this.stringToVarWithCalculation(res[i]);
            }
         }
         return res;
      }
      
      private function stringToVarWithCalculation(str:*, base:* = null, leaveOutLast:Boolean = false) : *
      {
         if(str == "this")
         {
            return API;
         }
         if(str == "true")
         {
            return true;
         }
         if(str == "false")
         {
            return false;
         }
         str = this.stringReplaceAll(str,"\"");
         try
         {
            if(str.indexOf("new") == 0)
            {
               str = this.stringToNewInstance(str,leaveOutLast);
            }
            else if(str.indexOf("(") > 0)
            {
               str = this.stringToFunc(str,base,leaveOutLast);
            }
            else
            {
               str = this.stringToVar(str,base,leaveOutLast);
            }
         }
         catch(er:Error)
         {
         }
         return str;
      }
      
      private function checkShorthandCalculations(ar:Array) : Array
      {
         if(ar[0].indexOf("+") == ar[0].length - 1 || ar[0].indexOf("-") == ar[0].length - 1 || ar[0].indexOf("/") == ar[0].length - 1 || ar[0].indexOf("*") == ar[0].length - 1 || ar[0].indexOf("%") == ar[0].length - 1)
         {
            ar[1] = ar[0] + ar[1];
            ar[0] = ar[0].substr(0,ar[0].length - 1);
         }
         return ar;
      }
      
      private function containsOperators(str:String, before:String = "", after:String = "") : Boolean
      {
         var index:int = 0;
         var operators:Array = new Array("+","-","/","*","%");
         for(var i:int = 0; i < operators.length; i++)
         {
            index = str.indexOf(operators[i]);
            if(index != -1 && (before == "" || index < str.indexOf(before) || str.indexOf(before) == -1) && (after == "" || index > str.indexOf(after)))
            {
               return true;
            }
         }
         return false;
      }
      
      private function printHistory() : void
      {
         var args:Array = null;
         var colour:String = null;
         var str:String = null;
         var i:uint = 0;
         this.historyText.htmlText = "";
         if(!this.opened)
         {
            return;
         }
         for(var index:int = 0; index < this.echo_arguments.length; index++)
         {
            if(this.echo_arguments[index].dirty == true)
            {
               args = this.echo_arguments[index].arguments;
               if(args[args.length - 1] is String && args[args.length - 1].charAt(0) == "#")
               {
                  colour = String(args[args.length - 1]);
                  args.pop();
               }
               else
               {
                  colour = "#FFFFFF";
               }
               str = "";
               for(i = 0; i < args.length; i++)
               {
                  str += args[i];
                  if(i < args.length - 1)
                  {
                     str += " ";
                  }
               }
               str = str.replace(/\n/g,"<br>");
               this.lines.push("<font face=\"" + DEFAULT_FONT + "\" color=\"" + colour + "\">" + str + "<br /></font>");
               if(this.lines.length > this.MAXIMUM_LINES)
               {
                  this.lines.shift();
               }
               this.echo_arguments[index].dirty = false;
            }
            this.historyText.htmlText += this.lines[index];
         }
         this.historyText.scrollV = this.historyText.maxScrollV;
      }
      
      public function echo(... args) : void
      {
         this.echo_arguments.push({
            "dirty":true,
            "arguments":args
         });
         if(this.echo_arguments.length > this.MAXIMUM_LINES)
         {
            this.echo_arguments.shift();
         }
         this.printHistory();
      }
      
      public function error(... args) : void
      {
         args.push("#FF0000");
         this.echo.apply(null,args);
      }
      
      public function warn(... args) : void
      {
         args.push("#FFA500");
         this.echo.apply(null,args);
      }
      
      public function debug(... args) : void
      {
         args.push("#FFFF00");
         this.echo.apply(null,args);
      }
      
      public function info(... args) : void
      {
         args.push("#00CCFF");
         this.echo.apply(null,args);
      }
      
      public function log(level:int, message:String) : void
      {
         if(level < 1 || level > 4)
         {
            return;
         }
         var type:String = String(levels[level]);
         this[type](message);
      }
      
      private function stringReplaceFirst(str:String, r:String, rw:String = "") : String
      {
         if(EnvUtil.isMobile())
         {
            return TextUtils.stringReplaceFirst(str,r,rw);
         }
         return str.replace(r,rw);
      }
      
      private function stringReplaceAll(str:String, r:String, rw:String = "") : String
      {
         if(EnvUtil.isMobile())
         {
            return TextUtils.stringReplace(str,r,rw);
         }
         do
         {
            str = str.replace(r,rw);
         }
         while(str.indexOf(r) > -1);
         
         return str;
      }
      
      private function stringReplaceButExclude(str:String, r:String, exclude:Array, rw:String, removeExls:Array) : String
      {
         var inExl:Boolean = false;
         var i:int = 0;
         var temp:String = "";
         if(this.stringContains(str,exclude))
         {
            inExl = false;
            for(i = 0; i < str.length; i++)
            {
               if(this.charIsAnyOf(str.charAt(i),exclude))
               {
                  inExl = !inExl;
                  if(!removeExls[exclude.indexOf(str.charAt(i))])
                  {
                     temp += str.charAt(i);
                  }
               }
               else if(str.charAt(i) == r && !inExl)
               {
                  temp += rw;
               }
               else
               {
                  temp += str.charAt(i);
               }
            }
         }
         else
         {
            temp = this.stringReplaceAll(str,r,rw);
         }
         return temp;
      }
      
      private function stringContains(str:String, what:Array) : Boolean
      {
         for(var i:int = 0; i < what.length; i++)
         {
            if(str.indexOf(what[i]) > -1)
            {
               return true;
            }
         }
         return false;
      }
      
      private function charIsAnyOf(char:String, what:Array) : Boolean
      {
         for(var i:int = 0; i < what.length; i++)
         {
            if(char == what[i])
            {
               return true;
            }
         }
         return false;
      }
      
      private function fillArrayWithIndexsOf(ar:Array, str:String, ar2:Array, startIndex:int = -1) : Array
      {
         if(ar == null)
         {
            ar = new Array();
         }
         if(startIndex == -1)
         {
            startIndex = str.length - 1;
         }
         for(var i:int = 0; i < ar2.length; i++)
         {
            ar[i] = str.lastIndexOf(ar2[i],startIndex);
         }
         return ar;
      }
      
      private function characterCount(str:String, char:String) : int
      {
         var count:int = 0;
         for(var i:int = 0; i < str.length; i++)
         {
            if(str.charAt(i) == char)
            {
               count++;
            }
         }
         return count;
      }
      
      private function startSlideAnimation(open:Boolean) : void
      {
         parent.stage.addEventListener(Event.ENTER_FRAME,this.slide);
         this.slideAnimation_animating = true;
         if(open)
         {
            this.slideAnimation_target = 0;
         }
         else
         {
            this.container.visible = true;
            this.slideAnimation_target = -(this.historyText.height + this.inputText.height);
         }
      }
      
      private function stopSlideAnimation() : void
      {
         this.container.y = this.slideAnimation_target;
         parent.stage.removeEventListener(Event.ENTER_FRAME,this.slide);
         this.slideAnimation_animating = false;
      }
      
      private function slide(e:Event) : void
      {
         if(this.container.y <= this.slideAnimation_target)
         {
            this.container.y += this.slideAnimation_speed;
            if(this.container.y >= this.slideAnimation_target)
            {
               this.stopSlideAnimation();
            }
         }
         else if(this.container.y >= this.slideAnimation_target)
         {
            this.container.y -= this.slideAnimation_speed;
            if(this.container.y <= this.slideAnimation_target)
            {
               this.stopSlideAnimation();
               this.container.visible = false;
            }
         }
      }
      
      private function toggleFullscreen() : void
      {
         if(this.consoleHeight != parent.stage.stageHeight)
         {
            this.consoleHeight = parent.stage.stageHeight;
         }
         else
         {
            this.consoleHeight = this.consoleHeight_default;
         }
         if(this.slideAnimation)
         {
            parent.stage.addEventListener(Event.ENTER_FRAME,this.fullscreenSlide);
            this.slideAnimation_animating = true;
            this.slideAnimation_target = this.consoleHeight - 20;
            this.suggestText.visible = false;
         }
         else
         {
            this.historyText.height = this.consoleHeight - 20;
            this.inputText.y = this.historyText.height;
         }
      }
      
      private function stopFullscreenSlideAnimation() : void
      {
         this.historyText.height = this.consoleHeight - 20;
         this.inputText.y = this.historyText.height;
         this.suggestText.y = this.inputText.y + this.inputText.height;
         this.historyText.scrollV = this.historyText.maxScrollV;
         parent.stage.removeEventListener(Event.ENTER_FRAME,this.fullscreenSlide);
         this.slideAnimation_animating = false;
      }
      
      private function fullscreenSlide(e:Event) : void
      {
         if(this.historyText.height <= this.slideAnimation_target)
         {
            this.historyText.height += this.slideAnimation_speed;
            this.inputText.y = this.historyText.height;
            if(this.historyText.height >= this.slideAnimation_target)
            {
               this.stopFullscreenSlideAnimation();
            }
         }
         else if(this.historyText.height >= this.slideAnimation_target)
         {
            this.historyText.height -= this.slideAnimation_speed;
            this.inputText.y = this.historyText.height;
            this.historyText.scrollV = this.historyText.maxScrollV;
            if(this.historyText.height <= this.slideAnimation_target)
            {
               this.stopFullscreenSlideAnimation();
            }
         }
      }
      
      public function setTrace(str:String) : void
      {
         var originalLength:int = int(this.traceVars.length);
         str = this.stringReplaceFirst(str,"trace:","");
         if(str == "fps")
         {
            addEventListener(Event.ENTER_FRAME,this.tick);
         }
         var v:Array = str.split(",");
         for(var n:int = 0; n < v.length; n++)
         {
            if(this.traceVars.indexOf(v[n]) == -1)
            {
               this.traceVars.push(v[n]);
            }
         }
         if(originalLength == 0 && this.traceVars.length != 0)
         {
            this.tracer.addEventListener(Event.ENTER_FRAME,this.traceUpdate);
         }
      }
      
      public function stopTrace(str:String) : void
      {
         var v:Array = null;
         var n:int = 0;
         var i:int = 0;
         str = this.stringReplaceFirst(str,"stoptrace:","");
         removeEventListener(Event.ENTER_FRAME,this.tick);
         if(str == "all")
         {
            this.traceVars = new Array();
         }
         else
         {
            v = str.split(",");
            for(n = 0; n < v.length; n++)
            {
               for(i = 0; i < this.traceVars.length; i++)
               {
                  if(this.traceVars[i] == v[n])
                  {
                     this.traceVars.splice(i,1);
                  }
               }
            }
         }
         if(this.traceVars.length == 0)
         {
            this.tracer.removeEventListener(Event.ENTER_FRAME,this.traceUpdate);
            this.tracer.visible = false;
            this.tracerNames.visible = false;
         }
      }
      
      private function traceUpdate(e:Event) : void
      {
         var na:String = null;
         var i:uint = 0;
         var completeOutput:String = null;
         var output:String = null;
         if(this.tracerActualTrace)
         {
            if(this.tracerOneCiclePerLine)
            {
               completeOutput = "";
            }
            for(i = 0; i < this.traceVars.length; i++)
            {
               if(this.traceVars[i] != "fps" || this.tracerActualTraceFPS)
               {
                  output = this.tracerActualTraceLayout;
                  na = String(this.traceVars[i]);
                  output = this.stringReplaceFirst(output,"name",na);
                  if(na == "fps")
                  {
                     output = this.stringReplaceFirst(output,"value",this.fps);
                  }
                  else
                  {
                     output = this.stringReplaceFirst(output,"value",this.stringToVarWithCalculation(this.traceVars[i]));
                  }
                  if(!this.tracerOneCiclePerLine)
                  {
                     trace(output);
                  }
                  else
                  {
                     completeOutput += output + this.tracerOneCiclePerLine_seperator;
                  }
               }
            }
            if(this.tracerOneCiclePerLine)
            {
               trace(completeOutput);
            }
         }
         if(this.tracerView)
         {
            this.tracer.visible = true;
            this.tracerNames.visible = true;
            this.tracer.text = "";
            this.tracerNames.text = "";
            for(i = 0; i < this.traceVars.length; i++)
            {
               na = String(this.traceVars[i]);
               this.tracerNames.appendText(na + "\n");
               if(na == "fps")
               {
                  this.tracer.appendText(this.fps + "\n");
               }
               else
               {
                  this.tracer.appendText(this.stringToVarWithCalculation(this.traceVars[i]) + "\n");
               }
            }
            this.tracerNames.x = this.tracerAlignX - this.tracerNames.width;
            this.tracer.x = this.tracerNames.x - this.tracer.width - 10;
            if(this.tracerAlignY < this.historyText.height + this.inputText.height)
            {
               this.tracer.y = this.container.y + this.inputText.y + this.inputText.height + this.tracerAlignY;
               this.tracerNames.y = this.container.y + this.inputText.y + this.inputText.height + this.tracerAlignY;
            }
            else
            {
               this.tracer.y = this.tracerAlignY;
               this.tracerNames.y = this.tracerAlignY;
            }
         }
         else
         {
            this.tracer.visible = false;
            this.tracerNames.visible = false;
         }
      }
      
      private function tick(e:Event) : void
      {
         var f:Number = NaN;
         ++this.ticks;
         var now:uint = uint(getTimer());
         var delta:uint = uint(now - this.last);
         if(delta >= 1000)
         {
            f = this.ticks / delta * 1000;
            this.fps = f.toFixed(1);
            this.ticks = 0;
            this.last = now;
         }
      }
      
      private function getKeyboardDict() : Dictionary
      {
         var keyDescription:XML = describeType(Keyboard);
         var keyNames:XMLList = keyDescription..constant.@name;
         var keyboardDict:Dictionary = new Dictionary();
         var len:int = keyNames.length();
         for(var i:int = 0; i < len; i++)
         {
            keyboardDict[Keyboard[keyNames[i]]] = keyNames[i];
         }
         return keyboardDict;
      }
   }
}
