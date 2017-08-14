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

extern int     acceptable_candle_body_ratio = 55;
extern double  init_lot_size = 0.01;
extern int     moving_average = 50;
extern double  partial_profit_percentage = 0.7;
extern int     max_loss_pts = 100;
extern int     max_profit_before_trail_pts = 200;

int            bars_onchart;
Price          *closed_price;
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
   if (moving_average < 0)
   {
      Print("Moving average must be a positive inter");
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
   if (acceptable_candle_body_ratio < 0 || acceptable_candle_body_ratio > 100)
   {
      Print("Candle's body ratio must be within range of 0 to 100");
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
   double ma = NormalizeDouble(iMA(NULL, 0, moving_average, 0, MODE_SMA, PRICE_CLOSE, 0), 5);

   closed_price = new Price(open, high, low, close);

   if (closed_price.GetBodyWickRatio() >= acceptable_candle_body_ratio)
   {
      if (closed_price.open > ma && closed_price.close < ma)
      {
         OpenSellOrder(init_lot_size, MAGIC_NUMBER, max_loss_pts, max_profit_before_trail_pts);
      }
      else if (closed_price.open < ma && closed_price.close > ma)
      {
         OpenBuyOrder(init_lot_size, MAGIC_NUMBER, max_loss_pts, max_profit_before_trail_pts);
      }
   }
}