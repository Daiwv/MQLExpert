//+------------------------------------------------------------------+
//|                                                KrishaScalper.mq4 |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <OrderLib.mqh>
#include <PriceClass.mqh>

const string      EA_NAME = "KrishaScalper v0.1";
const int         MAGIC_NUMBER = 20160811;

sinput string     TradeManagement;
input bool        UseMoneyManagement = false;
input double      FixedStaticLotSize = 0.01;
input int         MaxTradeSpreadPts = 10;
input int         MaxLossPts = 100;
input int         TrailStopActivatePts = 200;
input int         TrailStep = 10;

sinput string     TradingHour;
input tradeHour   AllowTradeFrom = HOUR_0;
input tradeHour   AllowTradeUntil = HOUR_0;

sinput string     BrokerInformation;
input bool        IsECNBroker = true;

sinput string     IndicatorSettings;
input double      MinPiercePenetration=51.0;
input double      MinBodySize=60.0;
input double      MaxPinbarSize=25.0;

int               buyOrderTicket = 0;
int               sellOrderTicket = 0;
int               bars_onchart;
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

         if (OrdersTotal() == 0)
         {
            CheckOpenOrder();
            TradeLogic();
         }
     }
   else
     {
         if (OrdersTotal() > 0)
         {
            bool orderSelected = false;

            if (buyOrderTicket > 0)
            {
               orderSelected = OrderSelect(buyOrderTicket, SELECT_BY_TICKET);
            }
            if (sellOrderTicket > 0)
            {
               orderSelected = OrderSelect(sellOrderTicket, SELECT_BY_TICKET);
            }
         }

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
         sellOrderTicket = OpenOrder(Sell, IsECNBroker, FixedStaticLotSize, MAGIC_NUMBER, MaxLossPts, 0);
      }
      else if (down != EMPTY_VALUE)
      {
         buyOrderTicket = OpenOrder(Buy, IsECNBroker, FixedStaticLotSize, MAGIC_NUMBER, MaxLossPts, 0); 
      }
   }
}

void CheckOpenOrder()
{
   if (OrdersTotal() == 0)
   {
      if (buyOrderTicket > 0)
      {
         buyOrderTicket = 0;
      }
      if (sellOrderTicket > 0)
      {
         sellOrderTicket = 0;
      }
   }
}