#property copyright "Bozz"
#property link      "bozzlab.github.io"
#property version   "1.00"
#property strict
#import "StandardLibs.ex4"
void Buy(double lots, int magics);
void Sell(double lots, int magics);
int CounterOrder(int order_type, int magics);
double ProfitMyMagics(int magics);
void CloseAllOrder(int order_type, int magics);
void CloseAllProfit(int magics);
#import
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>

CPanel P1;
CLabel L1,L2,L3,L4,L5,L6,L7,L8,L9,L10;
CButton B1,B2,B3,B4,B5,B6;
CEdit E1,E2,E3;

input double Lots = 0;
input int SL = 0;
input int TP = 0;
input int MAGIC_NUMBER = 1234;

input ENUM_MA_METHOD MA_METHOD          = MODE_SMA;
input ENUM_APPLIED_PRICE PRICE          = PRICE_CLOSE;
input int MA_PERIOD         = 20;
input int SHIFT             = 1; 
double Ema;

int OnInit()
{
   Panel();
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   OnTimer();
}

void OnTimer()
{
   Update();
}

int ticket;
input int slippage = 5;

void Update()
{
   L3.Text(DoubleToString(Open[1],5));
   L3.Color(clrGreen);
      
   L5.Text(DoubleToString(Close[1],5));
   L5.Color(clrRed);
      
   double ima = GetMA(); 
   L7.Text(DoubleToString(ima,5));
   L7.Color(clrBlue);
}

double GetMA()
{
    Ema = iMA(Symbol(), 0, MA_PERIOD, 0, MA_METHOD, PRICE, SHIFT);
    return Ema;
}

void Panel()
{
   P1.Create(0, "P1", 0, 18, 18, 400, 400);
   P1.ColorBackground(clrWhiteSmoke);
   
   L1.Create(0, "L1", 0, 0, 0, 100, 50);
   L1.Text("Tracking Price");
   L1.Shift(130,40);
   L1.Color(clrBlack);
   L1.FontSize(14);
   
   L2.Create(0, "L2", 0, 0, 0, 100, 50);
   L2.Text("Open");
   L2.Shift(100,80);
   L2.Color(clrBlack);
   L2.FontSize(12);
   
   L3.Create(0, "L3", 0, 0, 0, 100, 50);
   L3.Text("0");
   L3.Shift(240,80);
   L3.Color(clrBlack);
   L3.FontSize(12);
   
   L4.Create(0, "L4", 0, 0, 0, 100, 50);
   L4.Text("Close");
   L4.Shift(100,120);
   L4.Color(clrBlack);
   L4.FontSize(12);
   
   L5.Create(0, "L5", 0, 0, 0, 100, 50);
   L5.Text("0");
   L5.Shift(240,120);
   L5.Color(clrBlack);
   L5.FontSize(12);
   
   L6.Create(0, "L6", 0, 0, 0, 100, 50);
   L6.Text("EMA");
   L6.Shift(100,160);
   L6.Color(clrBlack);
   L6.FontSize(12);
   
   L7.Create(0, "L7", 0, 0, 0, 100, 50);
   L7.Text("0");
   L7.Shift(240,160);
   L7.Color(clrBlack);
   L7.FontSize(12);
}
