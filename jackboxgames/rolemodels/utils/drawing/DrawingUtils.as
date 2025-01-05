package jackboxgames.rolemodels.utils.drawing
{
   import flash.geom.*;
   import jackboxgames.algorithm.*;
   import jackboxgames.rolemodels.model.*;
   import jackboxgames.utils.*;
   
   public final class DrawingUtils
   {
       
      
      public function DrawingUtils()
      {
         super();
      }
      
      public static function COMPRESS_LINES(lines:Array) : Array
      {
         var newLines:Array = null;
         newLines = [];
         lines.forEach(function(line:Object, i:int, arr:Array):void
         {
            var newLine:Object = ObjectUtil.concat(line);
            newLine.points = COMPRESS_POINTS(line.points);
            newLines.push(newLine);
         });
         return newLines;
      }
      
      public static function COMPRESS_POINTS(points:Array) : String
      {
         return points.map(function(point:Object, i:int, arr:Array):String
         {
            return point.x + "," + point.y;
         }).join("|");
      }
      
      public static function UNCOMPRESS_LINES(lines:Array) : Array
      {
         var newLines:Array = null;
         newLines = [];
         lines.forEach(function(line:Object, i:int, arr:Array):void
         {
            var newLine:Object = ObjectUtil.concat(line);
            newLine.points = UNCOMPRESS_POINTS(line.points);
            newLines.push(newLine);
         });
         return newLines;
      }
      
      public static function UNCOMPRESS_POINTS(points:String) : Array
      {
         return points.split("|").map(function(pair:String, i:int, arr:Array):Object
         {
            var positions:* = pair.split(",");
            return {
               "x":positions[0],
               "y":positions[1]
            };
         });
      }
      
      public static function GET_NUM_POINTS(lines:Array) : Number
      {
         return MapFold.process(lines,function(line:Object, i:int, arr:Array):Number
         {
            return line.points.length;
         },MapFold.FOLD_SUM);
      }
      
      public static function LINES_ARE_VALID(lines:Array) : Boolean
      {
         var i:int = 0;
         var j:int = 0;
         for(i = 0; i < lines.length; i++)
         {
            if(!(lines[i] is Object))
            {
               return false;
            }
            if(!lines[i].hasOwnProperty("points") || !(lines[i].points is Array))
            {
               return false;
            }
            for(j = 0; j < lines[i].points.length; j++)
            {
               if(!lines[i].points[j].hasOwnProperty("x") || isNaN(Number(lines[i].points[j].x)))
               {
                  return false;
               }
               if(!lines[i].points[j].hasOwnProperty("y") || isNaN(Number(lines[i].points[j].y)))
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public static function PREPARE_LINES_USING_ELLIPSE(lines:Array, maxPoints:int, bounds:Ellipse) : Array
      {
         var i:int = 0;
         var j:int = 0;
         var pointCount:int = 0;
         var colorsUsed:Array = [];
         for(i = 0; i < lines.length; i++)
         {
            if(pointCount + lines[i].points.length > maxPoints)
            {
               lines[i].points.splice(0,maxPoints - pointCount);
               if(i + 1 < lines.length)
               {
                  lines[i].splice(i + 1,lines[i].length - (i + 1));
               }
               break;
            }
            pointCount += lines[i].points.length;
         }
         lines = _removePointsOutsideOfEllipse(lines,bounds);
         for(i = 0; i < lines.length; i++)
         {
            if(!ArrayUtil.arrayContainsElement(colorsUsed,lines[i].color))
            {
               colorsUsed.push(lines[i].color);
            }
            if(!lines[i].hasOwnProperty("color") || lines[i].color.length != 7 || isNaN(parseInt(lines[i].color.substring(1),16)))
            {
               lines[i].color = "#000000";
            }
            for(j = 0; j < lines[i].points.length; j++)
            {
               lines[i].points[j].x = int(Math.round(Number(lines[i].points[j].x)));
               lines[i].points[j].y = int(Math.round(Number(lines[i].points[j].y)));
            }
         }
         return lines;
      }
      
      private static function _removePointsOutsideOfEllipse(lines:Array, bounds:Ellipse) : Array
      {
         var splitLines:Array = null;
         splitLines = [];
         lines.forEach(function(line:Object, ... args):void
         {
            var indexOfStartOfNewLine:Number = NaN;
            var indexOfEndOfNewLine:Number = NaN;
            var newLine:Object = null;
            indexOfStartOfNewLine = 0;
            indexOfEndOfNewLine = 0;
            (line.points as Array).forEach(function(point:Object, index:int, ... args):void
            {
               var newLine:Object = null;
               if(bounds.isPointInside(point.x,point.y))
               {
                  indexOfEndOfNewLine = index;
               }
               else
               {
                  if(indexOfStartOfNewLine < indexOfEndOfNewLine)
                  {
                     newLine = ObjectUtil.concat(line);
                     newLine.points = (newLine.points as Array).slice(indexOfStartOfNewLine,indexOfEndOfNewLine + 1);
                     point.x = bounds.findXOnEllipse(point.x,point.y);
                     newLine.points.push(point);
                     splitLines.push(newLine);
                  }
                  indexOfStartOfNewLine = index + 1;
               }
            });
            if(indexOfStartOfNewLine < indexOfEndOfNewLine)
            {
               newLine = ObjectUtil.concat(line);
               newLine.points = (newLine.points as Array).slice(indexOfStartOfNewLine,indexOfEndOfNewLine + 1);
               splitLines.push(newLine);
            }
         });
         return splitLines;
      }
      
      public static function PREPARE_LINES(lines:Array, maxPoints:int, bounds:Rectangle) : void
      {
         var i:int = 0;
         var j:int = 0;
         var pointCount:int = 0;
         var colorsUsed:Array = [];
         for(i = 0; i < lines.length; i++)
         {
            if(pointCount + lines[i].points.length > maxPoints)
            {
               lines[i].points.splice(0,maxPoints - pointCount);
               if(i + 1 < lines.length)
               {
                  lines[i].splice(i + 1,lines[i].length - (i + 1));
               }
               break;
            }
            pointCount += lines[i].points.length;
         }
         for(i = 0; i < lines.length; i++)
         {
            if(!ArrayUtil.arrayContainsElement(colorsUsed,lines[i].color))
            {
               colorsUsed.push(lines[i].color);
            }
            if(!lines[i].hasOwnProperty("color") || lines[i].color.length != 7 || isNaN(parseInt(lines[i].color.substring(1),16)))
            {
               lines[i].color = "#000000";
            }
            for(j = 0; j < lines[i].points.length; j++)
            {
               lines[i].points[j].x = int(Math.round(Number(lines[i].points[j].x)));
               lines[i].points[j].y = int(Math.round(Number(lines[i].points[j].y)));
               lines[i].points[j].x = Math.min(Math.max(bounds.left,lines[i].points[j].x),bounds.right);
               lines[i].points[j].y = Math.min(Math.max(bounds.top,lines[i].points[j].y),bounds.bottom);
            }
         }
      }
   }
}
