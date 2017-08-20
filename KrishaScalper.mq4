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
const int      DIGIT = int(MarketInfo(Symbol(), MODE_DIGITS));

extern double  init_lot_size = 0.01;
extern int     max_loss_pts = 100;
extern int     max_spread_pts = 10;

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

   return true;
}

void TradeLogic()
{
   int spread = int(NormalizeDouble(MathPow(10, DIGIT) * MathAbs(Ask - Bid), 0));
   double up = iCustom(NULL, 0, "PIERCE", 51, 60, 25, 0, 1);
   double down = iCustom(NULL, 0, "PIERCE", 51, 60, 25, 1, 1);
   string print = "Spread " + string(spread);
   
   if (up != EMPTY_VALUE)
   {
      print += " Up " + string(up);
   }
   else if (down != EMPTY_VALUE)
   {
      print += " Down " + string(down);
   }
   
   if (print != "")
   {
      Print(print);
   }
   
}