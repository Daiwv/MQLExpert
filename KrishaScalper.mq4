//+------------------------------------------------------------------+
//|                                                KrishaScalper.mq4 |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

const string   EA_NAME = "KrishaScalper v0.1";
const int      MAGIC_NUMBER = 20160811;
const int      CANDLE_BODY_RATIO = 60;

extern double  init_lot_size = 0.01;
extern int     slow_ma = 20;
extern int     fast_ma = 10;
extern double  partial_profit_percentage = 0.7;
extern int     max_loss_pts = 100;
extern int     max_profit_before_trail_pts = 200;

int            bars_onchart;
double         v_fast_ma;
double         v_slow_ma;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Initialize ", EA_NAME);
   
   if (validate_input()) {
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
   close_all_order();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(bars_onchart!=iBars(NULL,0))
     {
         bars_onchart=iBars(NULL,0);
         trade_logic();
     }
   else
     {
         return;
     }
  }

//+------------------------------------------------------------------+
//| Custom function for any input validation                         |
//+------------------------------------------------------------------+
bool validate_input()
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

void trade_logic()
   {      
      double open = NormalizeDouble(iOpen(NULL, 0, 1),5);
      double high = NormalizeDouble(iHigh(NULL, 0, 1),5);
      double low = NormalizeDouble(iLow(NULL, 0, 1),5);
      double close = NormalizeDouble(iClose(NULL, 0, 1),5);
      double high_low = MathAbs(high - low);
      double body = NormalizeDouble(MathAbs(open - close), 5);
      double body_ratio = (body/high_low) * 100;
      double upperwick;
      double lowerwick;

      if (open > close)
         {
            upperwick = NormalizeDouble(MathAbs(high - close), 5);
            lowerwick = NormalizeDouble(MathAbs(low - open), 5);
         }
      else
         {
            upperwick = NormalizeDouble(MathAbs(high - open), 5);
            lowerwick = NormalizeDouble(MathAbs(low - close), 5);
         }

      /* Only trade when candle is greater then wick */
      if (body_ratio >= CANDLE_BODY_RATIO)
         {
            // Check distance between previous candle close to fast MA
            //    If it is greater then X (to be defined), then don't jump to trade
            //    Otherwise, jump to trade if open to close cross MA
            Print("Trade logic here");
         }
      else
         {
            Print("Too much rejection");
         }
      //v_fast_ma = NormalizeDouble(iMA(NULL, 0, fast_ma, 0, MODE_EMA, PRICE_CLOSE, 0), 5);
      //v_slow_ma = NormalizeDouble(iMA(NULL, 0, slow_ma, 0, MODE_EMA, PRICE_CLOSE, 0), 5);

      /*if(Volume[0]>1) return;

      if(Open[1] > fast_ma && Close[1] < fast_ma)
        {
         res=OrderSend(Symbol(),OP_SELL,init_lot_size,Bid,3,0,0,"",MAGIC_NUMBER,0,Red);
         return;
        }
      if(Open[1] < fast_ma && Close[1] > fast_ma)
        {
         res=OrderSend(Symbol(),OP_BUY,init_lot_size,Ask,3,0,0,"",MAGIC_NUMBER,0,Blue);
         return;
        }*/
  }
   
void close_all_order()
   {
   
   }