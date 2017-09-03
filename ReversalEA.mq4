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

const string      EA_NAME = "KrishaScalper v0.1";
const int         MAGIC_NUMBER = 20160811;

sinput string     TradeManagement;
input bool        UseMoneyManagement = false;
input double      FixedStaticLotSize = 0.1;
input double      PartialClosePercent = 60.0;
input int         MaxTradeSpreadPts = 10;
input int         MaxLossPts = 100;
input int         TrailStep = 10;

sinput string     TradingHour;
input tradeHour   AllowTradeFrom = HOUR_0;
input tradeHour   AllowTradeUntil = HOUR_0;

sinput string     BrokerInformation;
input bool        IsECNBroker = true;

sinput string     IndicatorSettings;
input double      MinPiercePenetration=50.0;
input double      MinBodySize=60.0;
input double      MaxPinbarSize=25.0;
input int         ATRPeriod=14;

int               buyOrderTicket = 0;
int               sellOrderTicket = 0;
int               buyOrderStopLossPts = 0;
int               sellOrderStopLossPts = 0;
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

         if (GetTotalOrderCount(Symbol(), MAGIC_NUMBER) == 0)
         {
            CheckOpenOrder();
            TradeLogic();
         }
     }
   else
     {
         if (GetTotalOrderCount(Symbol(), MAGIC_NUMBER) > 0)
         {
            OpenOrderLogic();       
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

void OpenOrderLogic()
{
   bool orderSelected = false;
   int ticket = 0;

   if (buyOrderTicket > 0)
   {
      ticket = buyOrderTicket;
   }

   if (sellOrderTicket > 0)
   {
      ticket = sellOrderTicket;
   }

   if (ticket > 0)
   {
      orderSelected = OrderSelect(ticket, SELECT_BY_TICKET);

      if (orderSelected)
      {
         /**
         * Move stop loss to open price if profit already hits stop loss pts
         * If stop loss has already been moved, trail stop by X-step
         */
         if (OrderType() == OP_BUY)
         {
            int currentDistance = GetDistanceInPoints(Bid, OrderOpenPrice());

            if (OrderStopLoss() < OrderOpenPrice())
            {
               if (currentDistance > sellOrderStopLossPts)
               {
                  ModifyOrder(buyOrderTicket, OrderOpenPrice(), 0);
                  int result = PartialCloseOrder(buyOrderTicket, Bid, FixedStaticLotSize, PartialClosePercent);

                  if (result != CERR_PARTIAL_CLOSE_FAILED)
                  {
                     buyOrderTicket = result;
                  }
               }
            }
            else
            {
               if (GetDistanceInPoints(Bid, OrderStopLoss()) > (MaxLossPts + TrailStep))
               {
                  ModifyOrder(buyOrderTicket, NormalizeDouble(OrderStopLoss() + (TrailStep * Point), DIGIT), 0);
               }
            }  
         }
         else if (OrderType() == OP_SELL)
         {
            int currentDistance = GetDistanceInPoints(OrderOpenPrice(), Ask);

            if (OrderStopLoss() > OrderOpenPrice())
            {
               if (currentDistance > sellOrderStopLossPts)
               {
                  ModifyOrder(sellOrderTicket, OrderOpenPrice(), 0);
                  int result = PartialCloseOrder(sellOrderTicket, Ask, FixedStaticLotSize, PartialClosePercent);

                  if (result != CERR_PARTIAL_CLOSE_FAILED)
                  {
                     sellOrderTicket = result;
                  }
               }
            }
            else
            {
               if (GetDistanceInPoints(OrderStopLoss(), Ask) > (MaxLossPts + TrailStep))
               {
                  ModifyOrder(sellOrderTicket, NormalizeDouble(OrderStopLoss() - (TrailStep * Point), DIGIT), 0);
               }
            }        
         }
      }
      else
      {
         Print("Order cannot be selected from OpenOrderLogic with error ", GetLastError());
      }
   }
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
      /**
       * Stop loss is being calculated from previous high/low + X-period ATR
       * - if calculated SL is smaller then max loss pts, use calculated SL
       * - if calculated SL is greater then max loss pts, use max loss pts
       */
      if (up != EMPTY_VALUE)
      {
         double highest = High[1] > High[2] ? High[1] : High[2];
         int tempStopLossPts = GetDistanceInPoints(highest + iATR(NULL, 0, ATRPeriod, 0), Bid, true);
         sellOrderStopLossPts = tempStopLossPts < MaxLossPts ? tempStopLossPts : MaxLossPts;

         sellOrderTicket = OpenOrder(Sell, IsECNBroker, FixedStaticLotSize, MAGIC_NUMBER, sellOrderStopLossPts, 0);
      }
      else if (down != EMPTY_VALUE)
      {
         double lowest = Low[1] < Low[2] ? Low[1] : Low[2];
         int tempStopLossPts = GetDistanceInPoints(Ask, lowest - iATR(NULL, 0, ATRPeriod, 0), true);
         buyOrderStopLossPts = tempStopLossPts < MaxLossPts ? tempStopLossPts : MaxLossPts;

         buyOrderTicket = OpenOrder(Buy, IsECNBroker, FixedStaticLotSize, MAGIC_NUMBER, buyOrderStopLossPts, 0); 
      }
   }
}

void CheckOpenOrder()
{
   if (GetTotalOrderCount(Symbol(), MAGIC_NUMBER) == 0)
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