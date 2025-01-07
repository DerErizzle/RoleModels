package jackboxgames.entityinteraction.commonbehaviors
{
   import jackboxgames.model.JBGPlayer;
   import jackboxgames.utils.PerPlayerContainer;
   
   public class MakeSingleChoiceCompiler implements IChooseCompiler
   {
      private var _choices:PerPlayerContainer;
      
      public function MakeSingleChoiceCompiler()
      {
         super();
      }
      
      public function setupChooseCompiler(players:Array) : void
      {
         this._choices = new PerPlayerContainer();
      }
      
      public function canAdd(p:JBGPlayer, index:int) : Boolean
      {
         return !this._choices.hasDataForPlayer(p);
      }
      
      public function add(p:JBGPlayer, index:int) : void
      {
         this._choices.setDataForPlayer(p,index);
      }
      
      public function playerIsDone(p:JBGPlayer) : Boolean
      {
         return this._choices.hasDataForPlayer(p);
      }
      
      public function get payload() : *
      {
         return this._choices;
      }
   }
}

