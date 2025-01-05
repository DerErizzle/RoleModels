package jackboxgames.userinteraction
{
   import jackboxgames.blobcast.model.BlobCastPlayer;
   
   public interface IInteractionSubBehavior
   {
       
      
      function setup(param1:Array) : void;
      
      function alterBlob(param1:BlobCastPlayer, param2:Object) : void;
      
      function handleMessage(param1:BlobCastPlayer, param2:Object) : void;
      
      function cleanUp(param1:Boolean) : void;
   }
}
