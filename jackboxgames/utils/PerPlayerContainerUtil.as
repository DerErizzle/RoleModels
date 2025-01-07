package jackboxgames.utils
{
   import jackboxgames.model.JBGPlayer;
   
   public final class PerPlayerContainerUtil
   {
      public function PerPlayerContainerUtil()
      {
         super();
      }
      
      public static function MAP(players:Array, mapFn:Function) : PerPlayerContainer
      {
         var ppc:PerPlayerContainer = null;
         ppc = new PerPlayerContainer();
         players.forEach(function(p:JBGPlayer, i:int, a:Array):void
         {
            ppc.setDataForPlayer(p,mapFn(p,i,players));
         });
         return ppc;
      }
   }
}

