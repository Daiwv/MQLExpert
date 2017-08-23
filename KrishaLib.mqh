//+------------------------------------------------------------------+
//|                                                    KrishaLib.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

const int      SLIPPAGE = 3;
enum tradeMode
{
   Buy,
   Sell
};

int _OpenBuyOrderECN(double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   double stop_loss = 0;
   double take_profit = 0;
   string comment = "Buy market order " + Symbol() + " at " + string(Ask) + " for " + string(lot_size) + " with spread " + string(GetSpread());

   int res = OrderSend(Symbol(),OP_BUY,lot_size,Ask,SLIPPAGE,0,0,comment,magic_number,0,Blue);

   if (res <= 0)
   {
      Print("OrderSend Error: ", string(GetLastError()));
   }
   else
   {
      if (stop_loss_pts > 0)
      {
         stop_loss = _GetStopLoss(Buy, stop_loss_pts);
         comment = comment + " with SL at " + string(stop_loss);
      }

      if (take_profit_pts > 0)
      {
         take_profit = _GetTakeProfit(Buy, take_profit_pts);
         comment = comment + " with TP at " + string(take_profit);
      }

      if (_ModifyOrder(res, stop_loss, take_profit))
      {
         Print(comment);
      }
   }

   return res;
}

int _OpenSellOrderECN(double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   double stop_loss = 0;
   double take_profit = 0;
   string comment = "Sell market order " + Symbol() + " at " + string(Bid) + " for " + string(lot_size) + " with spread " + string(GetSpread());

   int res = OrderSend(Symbol(),OP_SELL,lot_size,Bid,SLIPPAGE,0,0,comment,magic_number,0,Red);

   if (res <= 0)
   {
      Print("OrderSend Error: ", string(GetLastError()));
   }
   else
   {
      if (stop_loss_pts > 0)
      {
         stop_loss = _GetStopLoss(Sell, stop_loss_pts);
         comment = comment + " with SL at " + string(stop_loss);
      }

      if (take_profit_pts > 0)
      {
         take_profit = _GetTakeProfit(Sell, take_profit_pts);
         comment = comment + " with TP at " + string(take_profit);
      }

      if (_ModifyOrder(res, stop_loss, take_profit))
      {
         Print(comment);
      }
   }   

   return res;
}

int OpenOrder(tradeMode mode, bool is_ecn, double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   if (is_ecn)
   {
      int response;

      if (mode == Buy)
      {
         response = _OpenBuyOrderECN(lot_size, magic_number, stop_loss_pts, take_profit_pts);
      }
      else {
         response = _OpenSellOrderECN(lot_size, magic_number, stop_loss_pts, take_profit_pts);
      }

      return response;
   }
   else {
      return -1;
   }
}

bool _ModifyOrder(int ticket, double stop_loss, double take_profit)
{
   bool modRes = OrderModify(ticket, 0, stop_loss, take_profit, 0);

   if (!modRes)
   {
      Print("OrderModify Error: ", string(GetLastError()), " SL ", stop_loss, " TP ", take_profit);
   }

   return modRes;
}

double _GetStopLoss(tradeMode mode, int stop_loss_pts)
{
   if (mode == Sell)
   {
      return NormalizeDouble(Ask + stop_loss_pts * Point, Digits);
   }
   else
   {
      return NormalizeDouble(Bid - stop_loss_pts * Point, Digits);
   }

}

double _GetTakeProfit(tradeMode mode, int take_profit_pts)
{
   if (mode == Sell)
   {
      return NormalizeDouble(Ask - take_profit_pts * Point, Digits);
   }
   else
   {
      return NormalizeDouble(Bid + take_profit_pts * Point, Digits);
   }
}

int GetSpread()
{
   return int(NormalizeDouble(MathPow(10, int(MarketInfo(Symbol(), MODE_DIGITS))) * MathAbs(Ask - Bid), 0));
}