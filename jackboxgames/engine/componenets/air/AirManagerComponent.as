package jackboxgames.engine.componenets.air
{
   import flash.display.*;
   import flash.events.*;
   import flash.external.*;
   import flash.system.ApplicationDomain;
   import jackboxgames.audio.*;
   import jackboxgames.engine.*;
   import jackboxgames.engine.componenets.*;
   import jackboxgames.events.*;
   import jackboxgames.flash.*;
   import jackboxgames.loader.*;
   import jackboxgames.nativeoverride.*;
   import jackboxgames.pause.*;
   import jackboxgames.talkshow.core.*;
   import jackboxgames.timer.*;
   import jackboxgames.userinput.*;
   import jackboxgames.utils.*;
   import jackboxgames.video.*;
   
   public class AirManagerComponent extends PausableEventDispatcher implements IComponent
   {
      private var _managerSwf:MovieClip;
      
      public function AirManagerComponent()
      {
         super();
      }
      
      public function get priority() : uint
      {
         return 2;
      }
      
      public function init(doneFn:Function) : void
      {
         var child:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         var m:MediaLoader = new MediaLoader(JBGLoader.instance.getUrl("Manager.swf"),child);
         m.load(function(result:Object):void
         {
            _managerSwf = result.data;
            StageRef.addChildAt(_managerSwf,StageRef.numChildren);
            JBGUtil.eventOnce(_managerSwf,Event.COMPLETE,doneFn);
         });
      }
      
      public function dispose() : void
      {
      }
      
      public function startGame(doneFn:Function) : void
      {
         doneFn();
      }
      
      public function disposeGame() : void
      {
      }
   }
}

