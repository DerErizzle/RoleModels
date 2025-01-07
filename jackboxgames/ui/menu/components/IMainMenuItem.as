package jackboxgames.ui.menu.components
{
   import flash.display.MovieClip;
   import jackboxgames.text.ExtendableTextField;
   import jackboxgames.utils.MovieClipShower;
   
   public interface IMainMenuItem
   {
      function get mc() : MovieClip;
      
      function get shower() : MovieClipShower;
      
      function get title() : ExtendableTextField;
      
      function get description() : ExtendableTextField;
      
      function get action() : String;
      
      function dispose() : void;
      
      function reset() : void;
      
      function setup(param1:Object, param2:String = null) : void;
      
      function show(param1:Function) : void;
      
      function dismiss(param1:Boolean, param2:Function) : void;
      
      function highlight(param1:Function) : void;
      
      function unhighlight(param1:Function) : void;
      
      function select(param1:Function) : void;
   }
}

