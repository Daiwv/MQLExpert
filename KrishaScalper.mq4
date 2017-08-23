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

const string      EA_NAME = "KrishaScalper v0.1";
const int         MAGIC_NUMBER = 20160811;
const int         DIGIT = int(MarketInfo(Symbol(), MODE_DIGITS));

extern double     InitLotSize = 0.01;
extern int        MaxLossPts = 100;
extern int        MaxTradeSpreadPts = 10;
input tradeHour   AllowTradeFrom = HOUR_0;
input tradeHour   AllowTradeUntil = HOUR_0;
input bool        IsECNBroker = true;
input double      MinPiercePenetration=51.0;
input double      MinBodySize=60.0;
input double      MaxPinbarSize=25.0;

int               bars_onchart;
Price             *closed_price;
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
   double up = iCustom(NULL, 0, "PIERCE", MinPiercePenetration, MinBodySize, MaxPinbarSize, 0, 1);
   double down = iCustom(NULL, 0, "PIERCE", MinPiercePenetration, MinBodySize, MaxPinbarSize, 1, 1);
   bool canOpenOrder = false;

   if (AllowTradeFrom == HOUR_0 && AllowTradeUntil == HOUR_0) // Can open trade anytime
   {
      canOpenOrder = true;
   }
   else // Limited to specific time only
   {
      int hour = Hour();
      
      if (hour >= AllowTradeFrom && hour < AllowTradeUntil)
      {
         canOpenOrder = true;
      }
   }
   
   if (canOpenOrder)
   {
      if (up != EMPTY_VALUE)
      {
         OpenOrder(Sell, IsECNBroker, InitLotSize, MAGIC_NUMBER, MaxLossPts, MaxLossPts);
      }
      else if (down != EMPTY_VALUE)
      {
         OpenOrder(Buy, IsECNBroker, InitLotSize, MAGIC_NUMBER, MaxLossPts, MaxLossPts); 
      }
   }
}
