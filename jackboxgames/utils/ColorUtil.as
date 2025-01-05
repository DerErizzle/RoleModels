package jackboxgames.utils
{
   import fl.motion.Color;
   import flash.display.DisplayObject;
   import flash.geom.ColorTransform;
   
   public final class ColorUtil
   {
       
      
      public function ColorUtil()
      {
         super();
      }
      
      public static function tint(d:DisplayObject, c:uint, a:Number) : void
      {
         var t:Color = new Color();
         t.setTint(c,a);
         d.transform.colorTransform = t;
      }
      
      public static function untint(d:DisplayObject) : void
      {
         d.transform.colorTransform = new ColorTransform();
      }
      
      public static function additiveTint(d:DisplayObject, c:uint) : void
      {
         var t:ColorTransform = new ColorTransform(1,1,1,1,Number(c >> 16 & 255),Number(c >> 8 & 255),Number(c & 255));
         d.transform.colorTransform = t;
      }
      
      public static function subtractiveTint(d:DisplayObject, c:uint) : void
      {
         var subC:uint = uint(16777215 - c);
         var t:ColorTransform = new ColorTransform(1,1,1,1,-Number(subC >> 16 & 255),-Number(subC >> 8 & 255),-Number(subC & 255));
         d.transform.colorTransform = t;
      }
      
      public static function tinteroplate(d:DisplayObject, c1:uint, a1:Number, c2:uint, a2:Number, progress:Number) : void
      {
         var t1:Color = new Color();
         t1.setTint(c1,a1);
         var t2:Color = new Color();
         t2.setTint(c2,a2);
         d.transform.colorTransform = Color.interpolateTransform(t1,t2,progress);
      }
      
      public static function rgbToHex(c:uint) : String
      {
         var playerColor:String = c.toString(16).toUpperCase();
         while(playerColor.length < 6)
         {
            playerColor = "0" + playerColor;
         }
         return "#" + playerColor;
      }
   }
}
