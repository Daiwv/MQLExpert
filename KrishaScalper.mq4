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

extern double  InitLotSize = 0.01;
extern int     MaxLossPts = 100;
extern int     MaxTradeSpreadPts = 10;
input int      AllowTradeFrom = NULL;
input int      AllowTradeUntil = NULL;
input bool     IsECNBroker = true;

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
   int spread = GetSpread();
   double up = iCustom(NULL, 0, "PIERCE", 51, 60, 25, 0, 1);
   double down = iCustom(NULL, 0, "PIERCE", 51, 60, 25, 1, 1);
   string print = "";
}