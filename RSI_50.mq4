//+------------------------------------------------------------------+
//|                                                       RSI_50.mq4 |
//|                                                             Bozz |
//|                                                bozzlab.github.io |
//+------------------------------------------------------------------+
#property copyright "Bozz"
#property link      "bozzlab.github.io"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//GUI 
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>

input ENUM_TIMEFRAMES RSI_TIME  = 0;
input int RSIPeriod = 14;
input ENUM_APPLIED_PRICE PRICE = PRICE_CLOSE;
input int SLIPPAGE          = 3;
input int MAGIC_NUMBER      = 1234;
input double LOTS           = 0.01;
double StartBalance;
double RSI1st, RSI2nd;
double ATR;
double AskPrice, BidPrice;
int LastBar = 0;
int Ticket;

CPanel Panel;
CLabel Header,BuyLotPanel,SellLotPanel,ProfitPanel,ATRPanel;

void OnTick()
{
    GetRSI();
    GetATR();
    BuyCondition();
    CountBuy();
    SellCondition();
    CountSell();
}

void BuyCondition()
{
    if(RSI1st > 50 && RSI2nd < 50 && CountBuy()==0)
    {
      OrderBuy();
    }
}
        
void SellCondition()
{
    if(RSI1st < 50 && RSI2nd > 50 && CountSell()==0)
    {
      OrderSell();
    }  
}

void GetRSI()
{
    RSI1st = iRSI(Symbol(), RSI_TIME, RSIPeriod, PRICE, 1);
    RSI2nd = iRSI(Symbol(), RSI_TIME, RSIPeriod, PRICE, 2);
}

void OrderBuy()
{
    Ticket = OrderSend(Symbol(), OP_BUY, LOTS, Ask, SLIPPAGE, 0, Ask+ATR/4, "Buy", MAGIC_NUMBER, 0, clrGreen);
}

void GetATR()
{
    ATR = iATR(Symbol(), 0, 12, 0);
}

void OrderSell()
{
    Ticket = OrderSend(Symbol(), OP_SELL, LOTS, Bid, SLIPPAGE, 0, Bid-(ATR/4), "Sell", MAGIC_NUMBER, 0, clrRed);
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

int OnInit()
{
   return(INIT_SUCCEEDED);
}
