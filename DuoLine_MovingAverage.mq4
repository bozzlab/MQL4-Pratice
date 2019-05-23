//+------------------------------------------------------------------+
//|                                                         1_MA.mq4 |
//|                                                             Bozz |
//|                                                bozzlab.github.io |
//+------------------------------------------------------------------+
#property copyright "Bozz"
#property link      "bozzlab.github.io"
#property version   "1.00"
#property strict

//GUI 
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>

double EmaSlow20,EmaSlow,EmaFast5,EmaFast;
double ATR;
double AskPrice, BidPrice;
int Ticket;
input int MA_PERIOD         = 20;
input int SHIFT             = 1; 
input int MAGIC_NUMBER      = 1234;
input ENUM_MA_METHOD MA_METHOD          = MODE_SMA;
input ENUM_APPLIED_PRICE PRICE          = PRICE_CLOSE;
input int SLIPPAGE          = 3;
input double LOTS           = 0.01;
double StartBalance;
int LastBar = 0;

CPanel Panel;
CLabel Header,BuyLotPanel,SellLotPanel,ProfitPanel,ATRPanel;

void OnTick()
{
    if(LastBar!=Bars)
    {
        GetMA();
        GetATR();
        BuyCondition();
        SellCondition();
        CountLotBuySell(OP_SELL);
        CountLotBuySell(OP_BUY);
        UpdateProfit();
        UpdatePanel();
        LastBar=Bars;
    }
}

void BuyCondition()
{
    if(EmaFast < EmaSlow && EmaFast5 > EmaSlow20)
    {
      OrderBuy();
    }
}
        
void SellCondition()
{
    if(EmaFast > EmaSlow && EmaFast5 < EmaSlow20)
    {
      OrderSell();
    }  
}

void GetMA()
{
   EmaSlow20 = iMA(Symbol(), 0, MA_PERIOD, 0, MA_METHOD, PRICE, SHIFT);
   EmaSlow = iMA(Symbol(), 0, MA_PERIOD, 0, MA_METHOD, PRICE, 2);
   EmaFast5 = iMA(Symbol(), 0, 5, 0, MA_METHOD, PRICE, SHIFT);
   EmaFast = iMA(Symbol(), 0, 5, 0, MA_METHOD, PRICE, 2);
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

double CountLotBuySell(int orderType)
{
    double countLot = 0;
    for(int i = OrdersTotal() - 1; i >=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS))
        {
            if(OrderType() == orderType) 
            {
                countLot += OrderLots();
            }
        }
    }
    return countLot;
}
double UpdateProfit()
{
  return AccountBalance() - StartBalance;
}

//////////////////////////////////////////////////////////// GUI ///////////////////////////////////////////

int OnInit()
{
   Panel();
   EventSetTimer(1);
   StartBalance = AccountBalance();
   return(INIT_SUCCEEDED);
}

void UpdatePanel()
{
   string buyUpdate = StringConcatenate("Buy Lots  : ", DoubleToString(CountLotBuySell("OP_BUY"),2));
   BuyLotPanel.Text(buyUpdate);
   
   string sellUpdate = StringConcatenate("Sell Lots  : ", DoubleToString(CountLotBuySell("OP_SELL"),2));
   SellLotPanel.Text(sellUpdate);
   
   string profitUpdate = StringConcatenate("Profit  : ", DoubleToString(UpdateProfit(),2));   
   ProfitPanel.Text(profitUpdate);
   
   string ATRUpdate = StringConcatenate("ATR  : ", DoubleToString(ATR,8)); 
   ATRPanel.Text(ATRUpdate);
}

void Panel()
{
   Panel.Create(0, "Panel", 0, 18, 18, 400, 250);
   Panel.ColorBackground(clrGray);

   Header.Create(0, "Header", 0, 0, 0, 100, 50);
   Header.Text(" Tracking Monitor");
   Header.Shift(130,40);
   Header.Color(clrBlack);
   Header.FontSize(14);

   BuyLotPanel.Create(0, "BuyLotPanel", 0, 0, 0, 100, 50);
   BuyLotPanel.Shift(100,80);
   BuyLotPanel.Color(clrBlack);
   BuyLotPanel.FontSize(12);

   SellLotPanel.Create(0, "SellLotPanel", 0, 0, 0, 100, 50);
   SellLotPanel.Shift(100,120);
   SellLotPanel.Color(clrBlack);
   SellLotPanel.FontSize(12);

   ProfitPanel.Create(0, "ProfitPanel", 0, 0, 0, 100, 50);
   ProfitPanel.Shift(100,160);
   ProfitPanel.Color(clrBlack);
   ProfitPanel.FontSize(12);
   
   ATRPanel.Create(0, "ATRPanel", 0, 0, 0, 100, 50);
   ATRPanel.Shift(100,200);
   ATRPanel.Color(clrBlack);
   ATRPanel.FontSize(12);  
}
