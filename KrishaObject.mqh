//+------------------------------------------------------------------+
//|                                                 KrishaObject.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

class Price
{
   public:
      double open;
      double high;
      double low;
      double close;

      Price(double aopen, double ahigh, double alow, double aclose)
      {
         open = aopen;
         high = ahigh;
         low = alow;
         close = aclose;
      }
      void Price() {}
      Price(const Price &price) { }
      Price operator=(const Price &price) { return this; }
      ~Price(void) { }

      double GetBodyWickRatio()
      {
         double high_low = MathAbs(high - low);
         double body = NormalizeDouble(MathAbs(open - close), 5);

         return (body/high_low) * 100;
      }

      double GetUpperWick()
      {
         if (open > close)
         {
            return NormalizeDouble(MathAbs(high - close), 5);
         }
         else
         {
            return NormalizeDouble(MathAbs(high - open), 5);
         }
      }

      double GetLowerWick()
      {
         if (open > close)
         {
            return NormalizeDouble(MathAbs(low - open), 5);
         }
         else
         {
            return NormalizeDouble(MathAbs(low - close), 5);
         }
      }

      bool IsBearCandle()
      {
         return open > close;
      }

      bool IsBullCandle()
      {
         return close > open;
      }      
};