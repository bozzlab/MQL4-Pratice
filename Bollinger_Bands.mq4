//+------------------------------------------------------------------+
//|                                                           BB.mq4 |
//|                                                             Bozz |
//|                                                bozzlab.github.io |
//+------------------------------------------------------------------+
#property copyright "Bozz"
#property link      "bozzlab.github.io"
#property version   "1.00"
#property strict

input ENUM_TIMEFRAMES BBTime  = 0;
input int BBPeriod = 14;
input double BBdeviation = 2;
input ENUM_APPLIED_PRICE BBPrice = PRICE_CLOSE;
input int BBBandShift = 0;
input int BBModeUp = MODE_UPPER;
input int BBModeLow = MODE_LOWER; // line index
input int BBShift = 0; 
input double LOTS = 0.01;
input int SLIPPAGE = 3;
input int MAGIC_BUY = 1111;
input int MAGIC_SELL = 0000;

double BBUp, BBLow;
int Ticket;
bool Action;

void OnTick()
{
  GetBB();
  BuySellCondition();
}

void GetBB()
{
   BBUp = iBands(Symbol(), BBTime, BBPeriod, BBdeviation, BBBandShift, BBPrice, BBModeUp, 0);
   BBLow = iBands(Symbol(), BBTime, BBPeriod, BBdeviation, BBBandShift, BBPrice, BBModeLow, 0);
}

void BuySellCondition()
{
    if(Open[1] <= BBLow && Close[1] >= BBLow && CountBuy() == 0)
    {
        OpenBuy();
        CloseSell();
    }
    else if(Close[1] <= BBUp && Open[1] >= BBUp && CountSell() == 0)
    {
        CloseBuy();
        OpenSell();   
    }  
}

void OpenBuy()
{
   Ticket = OrderSend(Symbol(), OP_BUY, LOTS, Ask, SLIPPAGE, 0,0, "Buy", MAGIC_BUY, 0, clrGreen);
}

void OpenSell()
{
   Ticket = OrderSend(Symbol(), OP_SELL, LOTS, Bid, SLIPPAGE, 0, 0, "Sell", MAGIC_SELL, 0, clrRed);
}

bool CloseBuy()
{
    for(int i = OrdersTotal() - 1; i >=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS))
        {
            if(OrderType() == OP_BUY)
            {
                Action = OrderClose(OrderTicket(), OrderLots(), Bid,SLIPPAGE, clrRed);
            }
        }
    }
    return Action;
}

bool CloseSell()
{
    for(int i = OrdersTotal() - 1; i >=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS))
        {
            if(OrderType() == OP_SELL)
            {
                Action = OrderClose(OrderTicket(), OrderLots(), Ask,SLIPPAGE, clrRed);
            }
        }
    }
    return Action;
}

int CountBuy()
{
    int count=0;
    for(int i=OrdersTotal()-1;i>=0;i--){
        if(OrderSelect(i,SELECT_BY_POS))
            {
            if(OrderType()==OP_BUY)
                {
                count++;
                }
            }
        }
    return count;
}

int CountSell()
{
    int count=0;
    for(int i=OrdersTotal()-1;i>=0;i--){
        if(OrderSelect(i,SELECT_BY_POS))
            {
            if(OrderType()==OP_SELL)
                {
                count++;
                }
            }
        }
    return count;
}
