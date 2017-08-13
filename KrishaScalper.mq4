//+------------------------------------------------------------------+
//|                                                KrishaScalper.mq4 |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <KrishaLib.mqh>
#include <KrishaObject.mqh>

const string   EA_NAME = "KrishaScalper v0.1";
const int      MAGIC_NUMBER = 20160811;
const int      CANDLE_BODY_RATIO = 55;

extern double  init_lot_size = 0.01;
extern int     slow_ma = 20;
extern int     fast_ma = 10;
extern double  std_deviation = 2.5;
extern double  partial_profit_percentage = 0.7;
extern int     max_loss_pts = 100;
extern int     max_profit_before_trail_pts = 200;

int            bars_onchart;
Price          *closed_price;
double         current_fast_ma;
double         current_sar;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Initialize ", EA_NAME);
   
   if (ValidateInput()) {
      return(INIT_SUCCEEDED);
   }
   else {
      Print("1 or more input parameter is wrong!");
      return(INIT_FAILED);
   }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Destroying ", EA_NAME);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(bars_onchart!=iBars(NULL,0))
     {
         bars_onchart=iBars(NULL,0);
         TradeLogic();
     }
   else
     {
         return;
     }
  }

//+------------------------------------------------------------------+
//| Custom function for any input validation                         |
//+------------------------------------------------------------------+
bool ValidateInput()
{
   if (fast_ma > slow_ma)
   {
      Print("Fast MA must be lower then Slow MA");
      return false;
   }
   if (fast_ma < 0 || slow_ma < 0)
   {
      Print("Fast MA or Slow MA must be a positive number");
      return false;
   }
   if (partial_profit_percentage > 1 || partial_profit_percentage < 0) 
   {
      Print("Partial lot percentage must be postive and less then or equal to 1");
      return false;
   }
   if (max_loss_pts < 0 || max_profit_before_trail_pts < 0)
   {
      Print("Max loss/profit before trail points must be a positive integer");
      return false;
   }
   if (init_lot_size < 0)
   {
      Print("Initial lot size must be a postive double");
      return false;
   }

   return true;
}

void TradeLogic()
{      
   double open = NormalizeDouble(iOpen(NULL, 0, 1),5);
   double high = NormalizeDouble(iHigh(NULL, 0, 1),5);
   double low = NormalizeDouble(iLow(NULL, 0, 1),5);
   double close = NormalizeDouble(iClose(NULL, 0, 1),5);

   closed_price = new Price(open, high, low, close);   

   current_fast_ma = NormalizeDouble(iMA(NULL, 0, 50, 0, MODE_SMA, PRICE_CLOSE, 0), 5);
   current_sar = NormalizeDouble(iSAR(NULL, 0, 0.02, 0.2, 0), 5);
   
   Print("Fast MA: ",current_fast_ma,", SAR: ", current_sar);

   OpenBuyOrder(init_lot_size, MAGIC_NUMBER, 50, 50);
   OpenSellOrder(init_lot_size, MAGIC_NUMBER, 50, 50);
}