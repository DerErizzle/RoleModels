package jackboxgames.utils
{
   public final class JSON
   {
       
      
      public function JSON()
      {
         super();
      }
      
      public static function deserialize(source:String) : *
      {
         var at:Number = NaN;
         var ch:String = null;
         var _isDigit:Function = null;
         var _isHexDigit:Function = null;
         var _white:Function = null;
         var _string:Function = null;
         var _next:Function = null;
         var _array:Function = null;
         var _object:Function = null;
         var _number:Function = null;
         var _word:Function = null;
         var _value:Function = null;
         var _error:Function = null;
         source = new String(source);
         at = 0;
         ch = " ";
         _isDigit = function(c:String):*
         {
            return "0" <= c && c <= "9";
         };
         _isHexDigit = function(c:String):*
         {
            return _isDigit(c) || "A" <= c && c <= "F" || "a" <= c && c <= "f";
         };
         _error = function(m:String):void
         {
            throw new Error(m,at - 1);
         };
         _next = function():*
         {
            ch = source.charAt(at);
            at += 1;
            return ch;
         };
         _white = function():void
         {
            while(Boolean(ch))
            {
               if(ch <= " ")
               {
                  _next();
               }
               else
               {
                  if(ch != "/")
                  {
                     break;
                  }
                  switch(_next())
                  {
                     case "/":
                        while(_next() && ch != "\n" && ch != "\r")
                        {
                        }
                        break;
                     case "*":
                        for(_next(); true; )
                        {
                           if(Boolean(ch))
                           {
                              if(ch == "*")
                              {
                                 if(_next() == "/")
                                 {
                                    _next();
                                    break;
                                 }
                              }
                              else
                              {
                                 _next();
                              }
                           }
                           else
                           {
                              _error("Unterminated Comment");
                           }
                        }
                        break;
                     default:
                        _error("Syntax Error");
                  }
               }
            }
         };
         _string = function():*
         {
            var t:* = undefined;
            var u:* = undefined;
            var i:* = "";
            var s:* = "";
            var outer:Boolean = false;
            if(ch == "\"")
            {
               while(Boolean(_next()))
               {
                  if(ch == "\"")
                  {
                     _next();
                     return s;
                  }
                  if(ch == "\\")
                  {
                     switch(_next())
                     {
                        case "b":
                           s += "\b";
                           break;
                        case "f":
                           s += "\f";
                           break;
                        case "n":
                           s += "\n";
                           break;
                        case "r":
                           s += "\r";
                           break;
                        case "t":
                           s += "\t";
                           break;
                        case "u":
                           u = 0;
                           for(i = 0; i < 4; i += 1)
                           {
                              t = parseInt(_next(),16);
                              if(!isFinite(t))
                              {
                                 outer = true;
                                 break;
                              }
                              u = u * 16 + t;
                           }
                           if(outer)
                           {
                              outer = false;
                              break;
                           }
                           s += String.fromCharCode(u);
                           break;
                        default:
                           s += ch;
                     }
                  }
                  else
                  {
                     s += ch;
                  }
               }
            }
            _error("Bad String");
            return null;
         };
         _array = function():*
         {
            var a:Array = [];
            if(ch == "[")
            {
               _next();
               _white();
               if(ch == "]")
               {
                  _next();
                  return a;
               }
               while(Boolean(ch))
               {
                  a.push(_value());
                  _white();
                  if(ch == "]")
                  {
                     _next();
                     return a;
                  }
                  if(ch != ",")
                  {
                     break;
                  }
                  _next();
                  _white();
               }
            }
            _error("Bad Array");
            return null;
         };
         _object = function():*
         {
            var k:* = {};
            var o:* = {};
            if(ch == "{")
            {
               _next();
               _white();
               if(ch == "}")
               {
                  _next();
                  return o;
               }
               while(Boolean(ch))
               {
                  k = _string();
                  _white();
                  if(ch != ":")
                  {
                     break;
                  }
                  _next();
                  o[k] = _value();
                  _white();
                  if(ch == "}")
                  {
                     _next();
                     return o;
                  }
                  if(ch != ",")
                  {
                     break;
                  }
                  _next();
                  _white();
               }
            }
            _error("Bad Object");
         };
         _number = function():*
         {
            var v:* = undefined;
            var n:* = "";
            var hex:String = "";
            var sign:String = "";
            if(ch == "-")
            {
               n = "-";
               sign = n;
               _next();
            }
            if(ch == "0")
            {
               _next();
               if(ch == "x" || ch == "X")
               {
                  _next();
                  while(Boolean(_isHexDigit(ch)))
                  {
                     hex += ch;
                     _next();
                  }
                  if(hex != "")
                  {
                     return Number(sign + "0x" + hex);
                  }
                  _error("mal formed Hexadecimal");
               }
               else
               {
                  n += "0";
               }
            }
            while(Boolean(_isDigit(ch)))
            {
               n += ch;
               _next();
            }
            if(ch == ".")
            {
               n += ".";
               while(_next() && ch >= "0" && ch <= "9")
               {
                  n += ch;
               }
            }
            v = 1 * n;
            if(!isFinite(v))
            {
               _error("Bad Number");
               return NaN;
            }
            return v;
         };
         _word = function():*
         {
            switch(ch)
            {
               case "t":
                  if(_next() == "r" && _next() == "u" && _next() == "e")
                  {
                     _next();
                     return true;
                  }
                  break;
               case "f":
                  if(_next() == "a" && _next() == "l" && _next() == "s" && _next() == "e")
                  {
                     _next();
                     return false;
                  }
                  break;
               case "n":
                  if(_next() == "u" && _next() == "l" && _next() == "l")
                  {
                     _next();
                     return null;
                  }
                  break;
            }
            _error("Syntax Error");
            return null;
         };
         _value = function():*
         {
            _white();
            switch(ch)
            {
               case "{":
                  return _object();
               case "[":
                  return _array();
               case "\"":
                  return _string();
               case "-":
                  return _number();
               default:
                  return ch >= "0" && ch <= "9" ? _number() : _word();
            }
         };
         return _value();
      }
      
      public static function serialize(o:*) : String
      {
         var c:String = null;
         var i:Number = NaN;
         var l:Number = NaN;
         var v:* = undefined;
         var prop:String = null;
         var code:Number = NaN;
         var s:String = "";
         switch(typeof o)
         {
            case "object":
               if(o)
               {
                  if(o is Array)
                  {
                     l = Number(o.length);
                     for(i = 0; i < l; i++)
                     {
                        v = serialize(o[i]);
                        if(Boolean(s))
                        {
                           s += ",";
                        }
                        s += v;
                     }
                     return "[" + s + "]";
                  }
                  if(typeof o.toString != "undefined")
                  {
                     for(prop in o)
                     {
                        v = o[prop];
                        if(typeof v != "undefined" && typeof v != "function")
                        {
                           v = serialize(v);
                           if(Boolean(s))
                           {
                              s += ",";
                           }
                           s += serialize(prop) + ":" + v;
                        }
                     }
                     return "{" + s + "}";
                  }
               }
               return "null";
            case "number":
               return isFinite(o) ? String(o) : "null";
            case "string":
               l = Number(o.length);
               s = "\"";
               for(i = 0; i < l; i += 1)
               {
                  c = String(o.charAt(i));
                  if(c >= " ")
                  {
                     if(c == "\\" || c == "\"")
                     {
                        s += "\\";
                     }
                     s += c;
                     continue;
                  }
                  switch(c)
                  {
                     case "\b":
                        s += "\\b";
                        break;
                     case "\f":
                        s += "\\f";
                        break;
                     case "\n":
                        s += "\\n";
                        break;
                     case "\r":
                        s += "\\r";
                        break;
                     case "\t":
                        s += "\\t";
                        break;
                     default:
                        code = c.charCodeAt();
                        s += "\\u00" + Math.floor(code / 16).toString(16) + (code % 16).toString(16);
                        break;
                  }
               }
               return s + "\"";
            case "boolean":
               return String(o);
            default:
               return "null";
         }
      }
   }
}
