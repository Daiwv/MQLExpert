//+------------------------------------------------------------------+
//|                                                    KrishaLib.mqh |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property strict

const int      SLIPPAGE = 3;

int OpenBuyOrder(double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double stop_loss = 0;
   double take_profit = 0;
   string comment = "Buy market order " + Symbol() + " at " + string(Ask) + " for " + string(lot_size);

   if (stop_loss_pts > 0)
   {
      stop_loss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
      comment = comment + " with SL at " + string(stop_loss);
   }
   
   if (take_profit_pts > 0)
   {
      take_profit=NormalizeDouble(Bid+minstoplevel*Point,Digits);
      comment = comment + " with TP at " + string(take_profit);
   }

   int res = OrderSend(Symbol(),OP_BUY,lot_size,Ask,SLIPPAGE,stop_loss,take_profit,comment,magic_number,0,Blue);

   Print(comment);
   return res;
}

int OpenSellOrder(double lot_size, int magic_number, int stop_loss_pts, int take_profit_pts)
{
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double stop_loss = 0;
   double take_profit = 0;
   string comment = "Sell market order " + Symbol() + " at " + string(Bid) + "for " + string(lot_size);

   if (stop_loss_pts > 0)
   {
      stop_loss = NormalizeDouble(Ask+minstoplevel*Point,Digits);
      comment = comment + " with SL at " + string(stop_loss);
   }
   
   if (take_profit_pts > 0)
   {
      take_profit = NormalizeDouble(Ask-minstoplevel*Point,Digits);
      comment = comment + " with TP at " + string(take_profit);
   }

   int res = OrderSend(Symbol(),OP_SELL,lot_size,Bid,SLIPPAGE,stop_loss,take_profit,comment,magic_number,0,Blue);

   Print(comment);
   return res;
}
