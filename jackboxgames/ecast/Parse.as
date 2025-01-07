package jackboxgames.ecast
{
   import jackboxgames.ecast.messages.*;
   import jackboxgames.ecast.messages.audience.*;
   import jackboxgames.ecast.messages.client.*;
   import jackboxgames.ecast.messages.room.*;
   import jackboxgames.logger.*;
   import jackboxgames.nativeoverride.*;
   
   public class Parse
   {
      public function Parse()
      {
         super();
      }
      
      private static function _parseResult(typeName:String, result:Object) : *
      {
         switch(typeName)
         {
            case "ok":
               return new OK();
            case "echo":
               return new Echo(result.message);
            case "error":
               return new CallError(result.msg,result.code);
            case "string":
               return result;
            case "text":
               return new TextElement(result.key,result.val,result.version);
            case "text/echo":
               return new TextEcho(result.message);
            case "json":
               return new JSONElement(result.key,result.val,result.version);
            case "json/echo":
               return new JSONEcho(result.message);
            case "object":
               return new ObjectElement(result.key,result.val,result.version);
            case "object/echo":
               return new ObjectEcho(result.message);
            case "client/connected":
               return new ClientConnected(result.id,result.userId,result.name,result.role,result.reconnect);
            case "client/disconnected":
               return new ClientDisconnected(result.id,result.userId,result.role);
            case "client/kicked":
               return new ClientKicked(result.id);
            case "client/send":
               return new ClientSend(result.to,result.from,result.body);
            case "client/welcome":
               return new ClientWelcome(result.id,result.entity,result.secret);
            case "room/exit":
               return new RoomExit(result.cause);
            case "room/lock":
               return new RoomLock();
            case "room/get-audience":
               return new GetAudienceReply(result.connections);
            case "audience/count-group":
               return new CountGroup(result.key,result.choices);
            case "audience/text-ring":
               return new TextRing(result.key,result.elements);
            case "audience/g-counter":
               return new GrowOnlyCounter(result.key,result.count);
            case "audience/pn-counter":
               return new PositiveNegativeCounter(result.key,result.count);
            case "artifact":
               return new SendArtifactReply(result.rootId,result.categoryId,result.artifactId);
            default:
               Logger.error("Failed to parse result of type " + typeName + ": " + result);
               return result;
         }
      }
      
      public static function parseResponseMessage(e:String) : *
      {
         var data:Object = JSON.deserialize(e);
         if(data == null)
         {
            return null;
         }
         var typeName:String = Boolean(data.opcode) ? data.opcode : data.type;
         if(Boolean(data.re))
         {
            return new Reply(data.pc,data.re,typeName,_parseResult(typeName,data.result));
         }
         return new Notification(data.pc,typeName,_parseResult(typeName,data.result));
      }
   }
}

