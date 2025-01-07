package jackboxgames.flash
{
   import flash.display.MovieClip;
   
   public class ButtonCalloutHelperComponent extends MovieClip
   {
      [Inspectable(type="String",defaultValue="")]
      public var id:String = "";
      
      [Inspectable(enumeration="SELECT,BACK,UP,DOWN,LEFT,RIGHT,PAUSE,ALT1,ALT2",defaultValue="SELECT")]
      public var userInputKey:String = "SELECT";
      
      public function ButtonCalloutHelperComponent()
      {
         super();
      }
   }
}

