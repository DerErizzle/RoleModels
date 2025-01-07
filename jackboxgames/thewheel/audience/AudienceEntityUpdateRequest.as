package jackboxgames.thewheel.audience
{
   public class AudienceEntityUpdateRequest
   {
      private var _gameToAudienceKeys:Array;
      
      public function AudienceEntityUpdateRequest()
      {
         super();
         this._gameToAudienceKeys = [];
      }
      
      public function get gameToAudienceKeysToUpdate() : Array
      {
         return this._gameToAudienceKeys;
      }
      
      public function dispose() : void
      {
         this._gameToAudienceKeys = [];
      }
      
      public function withGameToAudienceEntity(key:String) : AudienceEntityUpdateRequest
      {
         this._gameToAudienceKeys.push(key);
         return this;
      }
      
      public function withGameToAudienceMainEntity() : AudienceEntityUpdateRequest
      {
         return this.withGameToAudienceEntity("main");
      }
   }
}

