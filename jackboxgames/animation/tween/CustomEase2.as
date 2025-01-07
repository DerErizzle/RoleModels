package jackboxgames.animation.tween
{
   import com.greensock.easing.*;
   import jackboxgames.utils.*;
   
   public class CustomEase2 extends Ease
   {
      private var _id:String;
      
      private var _data:String;
      
      private var _segment:Array;
      
      private var _l:Number;
      
      private var _lookup:Array;
      
      public function CustomEase2(id:String, data:String, config:Object)
      {
         super();
         this._id = id;
         this._setData(data,config);
      }
      
      private function _setData(data:String, config:Object) : Boolean
      {
         var a1:Object = null;
         var a2:Object = null;
         var i:Number = NaN;
         var inc:Number = NaN;
         var j:Number = NaN;
         var point:Object = null;
         var prevPoint:Object = null;
         var p:Number = NaN;
         var a1y:Number = NaN;
         config = JBGUtil.or(config,{});
         data = JBGUtil.or(data,"0,0,1,1");
         var numExp:RegExp = /[-+=\.]*\d+[\.e\-\+]*\d*[e\-\+]*\d*/gi;
         var needsParsingExp:RegExp = /[cLlsSaAhHvVtTqQ]/g;
         var values:Array = data.match(numExp);
         var closest:Number = 1;
         var points:Array = [];
         var precision:Number = JBGUtil.or(config.precision,1);
         var fast:Boolean = precision <= 1;
         this._data = data;
         this._lookup = [];
         if(Boolean(needsParsingExp.test(data)) || data.indexOf("M") >= 0 && data.indexOf("C") < 0)
         {
            values = this._stringToRawPath(data)[0];
         }
         this._l = values.length;
         if(this._l === 4)
         {
            values.unshift(0,0);
            values.push(1,1);
            this._l = 8;
         }
         else if(Boolean((this._l - 2) % 6))
         {
            return false;
         }
         if(Number(values[0]) !== 0 || Number(values[this._l - 2]) !== 1)
         {
            this._normalize(values,config.height,config.originY);
         }
         this._segment = values;
         for(i = 2; i < this._l; i += 6)
         {
            a1 = {
               "x":Number(values[i - 2]),
               "y":Number(values[i - 1])
            };
            a2 = {
               "x":Number(values[i + 4]),
               "y":Number(values[i + 5])
            };
            points.push(a1,a2);
            this._bezierToPoints(a1.x,a1.y,Number(values[i]),Number(values[i + 1]),Number(values[i + 2]),Number(values[i + 3]),a2.x,a2.y,1 / (precision * 200000),points,points.length - 1);
         }
         this._l = points.length;
         for(i = 0; i < this._l; i++)
         {
            point = points[i];
            prevPoint = JBGUtil.or(points[i - 1],point);
            if((point.x > prevPoint.x || prevPoint.y !== point.y && prevPoint.x === point.x || point === prevPoint) && point.x <= 1)
            {
               prevPoint.cx = point.x - prevPoint.x;
               prevPoint.cy = point.y - prevPoint.y;
               prevPoint.n = point;
               prevPoint.nx = point.x;
               if(fast && i > 1 && Math.abs(prevPoint.cy / prevPoint.cx - points[i - 2].cy / points[i - 2].cx) > 2)
               {
                  fast = false;
               }
               if(prevPoint.cx < closest)
               {
                  if(!prevPoint.cx)
                  {
                     prevPoint.cx = 0.001;
                     if(i === this._l - 1)
                     {
                        prevPoint.x -= 0.001;
                        closest = Math.min(closest,0.001);
                        fast = false;
                     }
                  }
                  else
                  {
                     closest = Number(prevPoint.cx);
                  }
               }
            }
            else
            {
               points.splice(i--,1);
               --this._l;
            }
         }
         this._l = 1 / closest + 1 | 0;
         inc = 1 / this._l;
         j = 0;
         point = points[0];
         if(fast)
         {
            for(i = 0; i < this._l; i++)
            {
               p = i * inc;
               if(point.nx < p)
               {
                  point = points[++j];
               }
               a1y = point.y + (p - point.x) / point.cx * point.cy;
               this._lookup[i] = {
                  "x":p,
                  "cx":inc,
                  "y":a1y,
                  "cy":0,
                  "nx":9
               };
               if(Boolean(i))
               {
                  this._lookup[i - 1].cy = a1y - this._lookup[i - 1].y;
               }
            }
            this._lookup[this._l - 1].cy = points[points.length - 1].y - a1y;
         }
         else
         {
            for(i = 0; i < this._l; i++)
            {
               if(point.nx < i * inc)
               {
                  point = points[++j];
               }
               this._lookup[i] = point;
            }
            if(j < points.length - 1)
            {
               this._lookup[i - 1] = points[points.length - 2];
            }
         }
         return true;
      }
      
      override public function getRatio(p:Number) : Number
      {
         var point:Object = JBGUtil.or(this._lookup[p * this._l | 0],this._lookup[this._l - 1]);
         if(point.nx < p)
         {
            point = point.n;
         }
         return point.y + (p - point.x) / point.cx * point.cy;
      }
      
      private function _normalize(values:Array, height:Number, originY:Number) : void
      {
         var i:Number = NaN;
         if(!originY && originY !== 0)
         {
            originY = Math.max(Number(values[values.length - 1]),Number(values[1]));
         }
         var tx:Number = Number(values[0]) * -1;
         var ty:Number = -originY;
         var l:Number = values.length;
         var sx:Number = 1 / (Number(values[l - 2]) + tx);
         var sy:Number = Number(-height || (Math.abs(Number(values[l - 1]) - Number(values[1])) < 0.01 * (Number(values[l - 2]) - Number(values[0])) ? this._findMinimum(values) + ty : Number(values[l - 1]) + ty));
         if(Boolean(sy))
         {
            sy = 1 / sy;
         }
         else
         {
            sy = -sx;
         }
         for(i = 0; i < l; i += 2)
         {
            values[i] = (Number(values[i]) + tx) * sx;
            values[i + 1] = (Number(values[i + 1]) + ty) * sy;
         }
      }
      
      private function _findMinimum(values:Array) : Number
      {
         var i:Number = NaN;
         var l:Number = values.length;
         var min:Number = Number.MAX_VALUE;
         for(i = 1; i < l; i += 6)
         {
            min = Number(values[i]);
            Number(values[i]) < min && (min);
         }
         return min;
      }
      
      private function _bezierToPoints(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number, threshold:Number, points:Array, index:Number) : Array
      {
         var length:Number = NaN;
         var x12:Number = (x1 + x2) / 2;
         var y12:Number = (y1 + y2) / 2;
         var x23:Number = (x2 + x3) / 2;
         var y23:Number = (y2 + y3) / 2;
         var x34:Number = (x3 + x4) / 2;
         var y34:Number = (y3 + y4) / 2;
         var x123:Number = (x12 + x23) / 2;
         var y123:Number = (y12 + y23) / 2;
         var x234:Number = (x23 + x34) / 2;
         var y234:Number = (y23 + y34) / 2;
         var x1234:Number = (x123 + x234) / 2;
         var y1234:Number = (y123 + y234) / 2;
         var dx:Number = x4 - x1;
         var dy:Number = y4 - y1;
         var d2:Number = Math.abs((x2 - x4) * dy - (y2 - y4) * dx);
         var d3:Number = Math.abs((x3 - x4) * dy - (y3 - y4) * dx);
         if(!points)
         {
            points = [{
               "x":x1,
               "y":y1
            },{
               "x":x4,
               "y":y4
            }];
            index = 1;
         }
         points.splice(JBGUtil.or(index,points.length - 1),0,{
            "x":x1234,
            "y":y1234
         });
         if((d2 + d3) * (d2 + d3) > threshold * (dx * dx + dy * dy))
         {
            length = points.length;
            this._bezierToPoints(x1,y1,x12,y12,x123,y123,x1234,y1234,threshold,points,index);
            this._bezierToPoints(x1234,y1234,x234,y234,x34,y34,x4,y4,threshold,points,index + 1 + (points.length - length));
         }
         return points;
      }
      
      private function _stringToRawPath(d:String) : Array
      {
         var i:Number = NaN;
         var j:Number = NaN;
         var x:Number = NaN;
         var y:Number = NaN;
         var command:String = null;
         var isRelative:Boolean = false;
         var segment:Array = null;
         var startX:Number = NaN;
         var startY:Number = NaN;
         var difX:Number = NaN;
         var difY:Number = NaN;
         var beziers:Array = null;
         var prevCommand:String = null;
         var flag1:* = undefined;
         var flag2:* = undefined;
         var svgPathExp:RegExp = /[achlmqstvz]|(-?\d*\.?\d*(?:e[\-+]?\d+)?)[0-9]/ig;
         var scientific:RegExp = /[\+\-]?\d*\.?\d+e[\+\-]?\d+/ig;
         var a:Array = (d + "").replace(scientific,function(m:String, ... args):String
         {
            var n:* = Number(m);
            return n < 0.0001 && n > -0.0001 ? "0" : String(n);
         }).match(svgPathExp);
         a = JBGUtil.or(a,[]);
         var path:Array = [];
         var relativeX:Number = 0;
         var relativeY:Number = 0;
         var twoThirds:Number = 2 / 3;
         var elements:Number = a.length;
         var points:Number = 0;
         var errorMessage:String = "ERROR: malformed path: " + d;
         var line:Function = function(sx:Number, sy:Number, ex:Number, ey:Number):void
         {
            difX = (ex - sx) / 3;
            difY = (ey - sy) / 3;
            segment.push(sx + difX,sy + difY,ex - difX,ey - difY,ex,ey);
         };
         if(!d || !isNaN(a[0]) || isNaN(a[1]))
         {
            return path;
         }
         for(i = 0; i < elements; i++)
         {
            prevCommand = command;
            if(isNaN(a[i]))
            {
               command = a[i].toUpperCase();
               isRelative = command !== a[i];
            }
            else
            {
               i--;
            }
            x = Number(a[i + 1]);
            y = Number(a[i + 2]);
            if(isRelative)
            {
               x += relativeX;
               y += relativeY;
            }
            if(!i)
            {
               startX = x;
               startY = y;
            }
            if(command === "M")
            {
               if(Boolean(segment))
               {
                  if(segment.length < 8)
                  {
                     path.length -= 1;
                  }
                  else
                  {
                     points += segment.length;
                  }
               }
               relativeX = startX = x;
               relativeY = startY = y;
               segment = [x,y];
               path.push(segment);
               i += 2;
               command = "L";
            }
            else if(command === "C")
            {
               if(!segment)
               {
                  segment = [0,0];
               }
               if(!isRelative)
               {
                  relativeX = relativeY = 0;
               }
               segment.push(x,y,relativeX + a[i + 3] * 1,relativeY + a[i + 4] * 1,relativeX = relativeX + a[i + 5] * 1,relativeY = relativeY + a[i + 6] * 1);
               i += 6;
            }
            else if(command === "S")
            {
               difX = relativeX;
               difY = relativeY;
               if(prevCommand === "C" || prevCommand === "S")
               {
                  difX += relativeX - segment[segment.length - 4];
                  difY += relativeY - segment[segment.length - 3];
               }
               if(!isRelative)
               {
                  relativeX = relativeY = 0;
               }
               segment.push(difX,difY,x,y,relativeX = relativeX + a[i + 3] * 1,relativeY = relativeY + a[i + 4] * 1);
               i += 4;
            }
            else if(command === "Q")
            {
               difX = relativeX + (x - relativeX) * twoThirds;
               difY = relativeY + (y - relativeY) * twoThirds;
               if(!isRelative)
               {
                  relativeX = relativeY = 0;
               }
               relativeX += a[i + 3] * 1;
               relativeY += a[i + 4] * 1;
               segment.push(difX,difY,relativeX + (x - relativeX) * twoThirds,relativeY + (y - relativeY) * twoThirds,relativeX,relativeY);
               i += 4;
            }
            else if(command === "T")
            {
               difX = relativeX - segment[segment.length - 4];
               difY = relativeY - segment[segment.length - 3];
               segment.push(relativeX + difX,relativeY + difY,x + (relativeX + difX * 1.5 - x) * twoThirds,y + (relativeY + difY * 1.5 - y) * twoThirds,relativeX = x,relativeY = y);
               i += 2;
            }
            else if(command === "H")
            {
               line(relativeX,relativeY,relativeX = x,relativeY);
               i += 1;
            }
            else if(command === "V")
            {
               line(relativeX,relativeY,relativeX,relativeY = x + (isRelative ? relativeY - relativeX : 0));
               i += 1;
            }
            else if(command === "L" || command === "Z")
            {
               if(command === "Z")
               {
                  x = startX;
                  y = startY;
                  segment.closed = true;
               }
               if(command === "L" || Math.abs(relativeX - x) > 0.5 || Math.abs(relativeY - y) > 0.5)
               {
                  line(relativeX,relativeY,x,y);
                  if(command === "L")
                  {
                     i += 2;
                  }
               }
               relativeX = x;
               relativeY = y;
            }
            else if(command === "A")
            {
               flag1 = a[i + 4];
               flag2 = a[i + 5];
               difX = Number(a[i + 6]);
               difY = Number(a[i + 7]);
               j = 7;
               if(flag1.length > 1)
               {
                  if(flag1.length < 3)
                  {
                     difY = difX;
                     difX = flag2;
                     j--;
                  }
                  else
                  {
                     difY = flag2;
                     difX = Number(flag1.substr(2));
                     j -= 2;
                  }
                  flag2 = flag1.charAt(1);
                  flag1 = flag1.charAt(0);
               }
               beziers = this._arcToSegment(relativeX,relativeY,Number(a[i + 1]),Number(a[i + 2]),Number(a[i + 3]),Number(flag1),Number(flag2),(isRelative ? relativeX : 0) + difX * 1,(isRelative ? relativeY : 0) + difY * 1);
               i += j;
               if(Boolean(beziers))
               {
                  for(j = 0; j < beziers.length; j++)
                  {
                     segment.push(beziers[j]);
                  }
               }
               relativeX = Number(segment[segment.length - 2]);
               relativeY = Number(segment[segment.length - 1]);
            }
         }
         i = segment.length;
         if(i < 6)
         {
            path.pop();
            i = 0;
         }
         else if(segment[0] === segment[i - 2] && segment[1] === segment[i - 1])
         {
            segment.closed = true;
         }
         path.totalPoints = points + i;
         return path;
      }
      
      private function _arcToSegment(lastX:Number, lastY:Number, rx:Number, ry:Number, angle:Number, largeArcFlag:Number, sweepFlag:Number, x:Number, y:Number) : Array
      {
         var i:Number = NaN;
         if(lastX === x && lastY === y)
         {
            return undefined;
         }
         rx = Math.abs(rx);
         ry = Math.abs(ry);
         var angleRad:Number = angle % 360 * Math.PI / 180;
         var cosAngle:Number = Math.cos(angleRad);
         var sinAngle:Number = Math.sin(angleRad);
         var PI:Number = Math.PI;
         var TWOPI:Number = PI * 2;
         var dx2:Number = (lastX - x) / 2;
         var dy2:Number = (lastY - y) / 2;
         var x1:Number = cosAngle * dx2 + sinAngle * dy2;
         var y1:Number = -sinAngle * dx2 + cosAngle * dy2;
         var x1_sq:Number = x1 * x1;
         var y1_sq:Number = y1 * y1;
         var radiiCheck:Number = x1_sq / (rx * rx) + y1_sq / (ry * ry);
         if(radiiCheck > 1)
         {
            rx = Math.sqrt(radiiCheck) * rx;
            ry = Math.sqrt(radiiCheck) * ry;
         }
         var rx_sq:Number = rx * rx;
         var ry_sq:Number = ry * ry;
         var sq:Number = (rx_sq * ry_sq - rx_sq * y1_sq - ry_sq * x1_sq) / (rx_sq * y1_sq + ry_sq * x1_sq);
         if(sq < 0)
         {
            sq = 0;
         }
         var coef:Number = (largeArcFlag === sweepFlag ? -1 : 1) * Math.sqrt(sq);
         var cx1:Number = coef * (rx * y1 / ry);
         var cy1:Number = coef * -(ry * x1 / rx);
         var sx2:Number = (lastX + x) / 2;
         var sy2:Number = (lastY + y) / 2;
         var cx:Number = sx2 + (cosAngle * cx1 - sinAngle * cy1);
         var cy:Number = sy2 + (sinAngle * cx1 + cosAngle * cy1);
         var ux:Number = (x1 - cx1) / rx;
         var uy:Number = (y1 - cy1) / ry;
         var vx:Number = (-x1 - cx1) / rx;
         var vy:Number = (-y1 - cy1) / ry;
         var temp:Number = ux * ux + uy * uy;
         var angleStart:Number = (uy < 0 ? -1 : 1) * Math.acos(ux / Math.sqrt(temp));
         var angleExtent:Number = (ux * vy - uy * vx < 0 ? -1 : 1) * Math.acos((ux * vx + uy * vy) / Math.sqrt(temp * (vx * vx + vy * vy)));
         angleExtent = PI;
         isNaN(angleExtent) && (angleExtent);
         if(!sweepFlag && angleExtent > 0)
         {
            angleExtent -= TWOPI;
         }
         else if(Boolean(sweepFlag) && angleExtent < 0)
         {
            angleExtent += TWOPI;
         }
         angleStart %= TWOPI;
         angleExtent %= TWOPI;
         var segments:Number = Math.ceil(Math.abs(angleExtent) / (TWOPI / 4));
         var rawPath:Array = [];
         var angleIncrement:Number = angleExtent / segments;
         var controlLength:Number = 4 / 3 * Math.sin(angleIncrement / 2) / (1 + Math.cos(angleIncrement / 2));
         var ma:Number = cosAngle * rx;
         var mb:Number = sinAngle * rx;
         var mc:Number = sinAngle * -ry;
         var md:Number = cosAngle * ry;
         for(i = 0; i < segments; i++)
         {
            angle = angleStart + i * angleIncrement;
            x1 = Math.cos(angle);
            y1 = Math.sin(angle);
            ux = Math.cos(angle = angle + angleIncrement);
            uy = Math.sin(angle);
            rawPath.push(x1 - controlLength * y1,y1 + controlLength * x1,ux + controlLength * uy,uy - controlLength * ux,ux,uy);
         }
         for(i = 0; i < rawPath.length; i += 2)
         {
            x1 = Number(rawPath[i]);
            y1 = Number(rawPath[i + 1]);
            rawPath[i] = x1 * ma + y1 * mc + cx;
            rawPath[i + 1] = x1 * mb + y1 * md + cy;
         }
         rawPath[i - 2] = x;
         rawPath[i - 1] = y;
         return rawPath;
      }
   }
}

