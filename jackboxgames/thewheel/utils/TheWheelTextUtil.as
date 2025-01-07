package jackboxgames.thewheel.utils
{
   import jackboxgames.thewheel.Player;
   import jackboxgames.thewheel.widgets.PlayerWidget;
   import jackboxgames.utils.NumberUtil;
   
   public final class TheWheelTextUtil
   {
      public function TheWheelTextUtil()
      {
         super();
      }
      
      public static function formattedPlayerName(p:Player) : String
      {
         return p.name.val;
      }
      
      public static function formattedPlayerList(players:Array) : String
      {
         return players.map(function(p:Player, ... args):String
         {
            return TheWheelTextUtil.formattedPlayerName(p);
         }).join("<BR>");
      }
      
      public static function formattedScore(score:int) : String
      {
         return NumberUtil.format(score);
      }
      
      public static function formattedPlayerScore(p:Player) : String
      {
         return formattedScore(p.score.val);
      }
      
      public static function formattedScoreChange(change:int) : String
      {
         return NumberUtil.format(change);
      }
      
      public static function formattedPointsSliceAmount(amount:int) : String
      {
         return String(amount);
      }
      
      public static function formattedMultiplier(val:Number) : String
      {
         return "x" + NumberUtil.roundToDecimalPlace(val,2);
      }
      
      public static function formattedPot(pot:int) : String
      {
         return String(pot);
      }
      
      public static function formattedAudienceNum(num:int) : String
      {
         return NumberUtil.format(num);
      }
      
      public static function formattedPlayerResult(num:int, viewMode:String) : String
      {
         switch(viewMode)
         {
            case PlayerWidget.RESULT_VIEW_MODE_STANDARD:
               return String(num);
            case PlayerWidget.RESULT_VIEW_MODE_WIDE:
               return NumberUtil.format(num);
            default:
               return String(num);
         }
      }
   }
}

