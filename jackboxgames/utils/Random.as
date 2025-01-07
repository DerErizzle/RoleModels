package jackboxgames.utils
{
   import jackboxgames.nativeoverride.Save;
   
   public class Random
   {
      private static var _instance:Random;
      
      private var _seed:uint;
      
      private var _saveSeed:Boolean;
      
      private var _seedId:String;
      
      public function Random(seedId:String)
      {
         super();
         this._seedId = seedId;
         this.seedRandom(new Date().getTime(),false);
      }
      
      public static function get instance() : Random
      {
         return Boolean(_instance) ? _instance : (_instance = new Random("MASTER"));
      }
      
      public function seedRandom(seed:uint, saveSeed:Boolean = false) : void
      {
         var savedSeed:uint = 0;
         this._saveSeed = saveSeed;
         if(seed == 0)
         {
            seed++;
         }
         this._seed = seed;
         if(this._saveSeed)
         {
            savedSeed = Save.instance.loadObject("SEED_" + this._seedId);
            if(savedSeed != 0 && !isNaN(savedSeed))
            {
               this._seed = savedSeed;
            }
            else
            {
               Save.instance.saveObject("SEED_" + this._seedId,this._seed);
            }
         }
      }
      
      public function nextRandomNumber() : Number
      {
         this._seed = this._seed * 16807 % 2147483647;
         if(this._saveSeed)
         {
            Save.instance.saveObject("SEED_" + this._seedId,this._seed);
         }
         return this._seed / 2147483647;
      }
      
      public function roll(range:Number, offset:Number = 0) : Number
      {
         return Math.floor(range * this.nextRandomNumber()) + offset;
      }
   }
}

