package jackboxgames.configuration
{
   import jackboxgames.nativeoverride.*;
   
   public class CommandLineSource implements IConfigSource
   {
      private var _commandLineArguments:Object;
      
      public function CommandLineSource()
      {
         super();
      }
      
      public function load(earlyLookupFn:Function, doneFn:Function) : void
      {
         this._commandLineArguments = Platform.instance.commandLineArguments;
         doneFn();
      }
      
      public function hasValueForKey(key:String) : Boolean
      {
         return Boolean(this._commandLineArguments) ? Boolean(this._commandLineArguments.hasOwnProperty(key)) : false;
      }
      
      public function getValueForKey(key:String) : *
      {
         return Boolean(this._commandLineArguments) ? this._commandLineArguments[key] : undefined;
      }
   }
}

