package jackboxgames.video
{
   import flash.events.IEventDispatcher;
   
   public interface IVideoPlayer extends IEventDispatcher
   {
      function load(param1:String, param2:Boolean = false, param3:Boolean = false) : void;
      
      function play(param1:Boolean = false) : void;
      
      function pause() : Boolean;
      
      function resume() : Boolean;
      
      function stop() : void;
      
      function dispose() : void;
      
      function get length() : int;
      
      function set autoPlay(param1:Boolean) : void;
      
      function get volume() : Number;
      
      function set volume(param1:Number) : void;
   }
}

