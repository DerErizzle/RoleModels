package jackboxgames.userinteraction
{
   import jackboxgames.blobcast.model.BlobCastPlayer;
   
   public interface IInteractionBehavior
   {
       
      
      function setup(param1:Array) : void;
      
      function generateBlob(param1:BlobCastPlayer) : Object;
      
      function handleMessage(param1:BlobCastPlayer, param2:Object) : String;
      
      function playerIsDoneInteracting(param1:BlobCastPlayer) : Boolean;
      
      function cleanUp(param1:Boolean) : void;
   }
}
