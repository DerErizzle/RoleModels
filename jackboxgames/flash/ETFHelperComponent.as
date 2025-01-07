package jackboxgames.flash
{
   import flash.display.MovieClip;
   
   public class ETFHelperComponent extends MovieClip
   {
      [Inspectable(type="String",defaultValue="")]
      public var id:String = "";
      
      [Inspectable(type="String",defaultValue="")]
      public var textKey:String = "";
      
      [Inspectable(type="Boolean",defaultValue="true")]
      public var resize:Boolean = true;
      
      [Inspectable(type="Number",defaultValue="4")]
      public var minSize:int = 4;
      
      [Inspectable(type="Number",defaultValue="128")]
      public var maxSize:int = 128;
      
      [Inspectable(type="Boolean",defaultValue="true")]
      public var balance:Boolean = true;
      
      [Inspectable(enumeration="top,center,bottom",defaultValue="center")]
      public var balanceType:String = "center";
      
      [Inspectable(enumeration="normal,upper,lower",defaultValue="normal")]
      public var letterCase:String = "normal";
      
      [Inspectable(type="Boolean",defaultValue="false")]
      public var supportsEmoji:Boolean = false;
      
      public function ETFHelperComponent()
      {
         super();
      }
   }
}

