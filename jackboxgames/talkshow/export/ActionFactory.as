package jackboxgames.talkshow.export
{
   import jackboxgames.talkshow.actions.Action;
   import jackboxgames.talkshow.actions.ActionPackageRef;
   import jackboxgames.talkshow.actions.Parameter;
   import jackboxgames.talkshow.api.ActionPackageType;
   import jackboxgames.talkshow.utils.ExportDictionary;
   
   internal class ActionFactory
   {
      
      private static const DELIMITER_PACKAGES:String = "^";
      
      private static const DELIMITER_PACKAGE_DATA:String = "|";
      
      private static const DELIMITER_ACTIONS:String = "^";
      
      private static const DELIMITER_ACTION_DATA:String = "|";
       
      
      public function ActionFactory()
      {
         super();
      }
      
      public static function buildActions(export:Export, packageData:String, actionData:String, dict:ExportDictionary) : void
      {
         var data:Array = null;
         var pkg:ActionPackageRef = null;
         var pkgid:int = 0;
         var packageString:String = null;
         var actions:Array = null;
         var actionString:String = null;
         var id:int = 0;
         var name:String = null;
         var pkgId:int = 0;
         var action:Action = null;
         var packages:Array = packageData.split(DELIMITER_PACKAGES);
         var type:String = "";
         var parent:int = -1;
         for each(packageString in packages)
         {
            data = packageString.split(DELIMITER_PACKAGE_DATA);
            type = data[2] as String;
            parent = int(data[3]);
            pkgid = int(data[0]);
            if(type != ActionPackageType.TYPE_INTERNAL)
            {
               if(export.getActionPackage(pkgid) == null)
               {
                  if(type == ActionPackageType.TYPE_SWF)
                  {
                     pkg = new ActionPackageRef(type,pkgid,dict.lookup(data[1]),export);
                  }
                  else
                  {
                     pkg = new ActionPackageRef(type,pkgid,dict.lookup(data[1]));
                  }
                  export.addActionPackage(pkg,parent);
               }
            }
         }
         actions = actionData.split(DELIMITER_ACTIONS);
         for each(actionString in actions)
         {
            data = actionString.split(DELIMITER_ACTION_DATA);
            id = data.shift();
            name = dict.lookup(data.shift());
            pkgId = data.shift();
            pkg = export.getActionPackage(pkgId) as ActionPackageRef;
            action = new Action(id,name,pkg);
            pkg.addAction(action);
            while(data.length > 0)
            {
               action.addParameter(new Parameter(dict.lookup(data.shift()),data.shift()));
            }
            export.addAction(action);
         }
      }
   }
}
