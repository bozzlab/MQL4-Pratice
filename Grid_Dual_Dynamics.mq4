//+------------------------------------------------------------------+
//|                                                 Grid_lastone.mq4 |
//|                                                             Bozz |
//|                                                bozzlab.github.io |
//+------------------------------------------------------------------+
#property copyright "Bozz"
#property link      "bozzlab.github.io"
#property version   "1.00"
#property strict

input double GridStart = 1.10000 , GridEnd = 1.35000;
input double LOTS = 0.01; 
input int SLIPPAGE = 3;
input int MAGIC_NUMBER = 1111;
input int Step = 5;
double GridDistance = 100;
double Ticket;
int OnInit()
{
    BuyCondition();
    SellCondition();
    return(INIT_SUCCEEDED);
}

void OnTick()
{
    if(CountOrder(OP_BUYLIMIT) != 0 || CountOrder(OP_BUY) != 0)
    {
    BuyCondition();
    }
    if(CountOrder(OP_SELLLIMIT) != 0 || CountOrder(OP_SELL) != 0)
    {
    SellCondition();
    }
}

void BuyCondition()
{   
    int n = 0;
    for(double currentGrid = GridEnd; currentGrid >= GridStart; currentGrid -= GridDistance*Point)
    {           
        if(Ask > currentGrid) 
        {
            if( n < Step)
            {   
                if(!AdjustOrder(currentGrid,OP_BUYLIMIT,OP_BUY))
                {
                    Ticket = OrderSend(Symbol(), OP_BUYLIMIT, LOTS, NormalizeDouble(currentGrid,Digits), SLIPPAGE, 0, currentGrid+GridDistance*Point, "Buy", 0, 0, clrGreen);      
                }                               
                n++;
            }
        }
    }
}

void SellCondition()
{   
    int n = 0;
    for(double currentGrid = GridStart; currentGrid <= GridEnd; currentGrid += GridDistance*Point)
    {           
        if(Bid < currentGrid) 
        {
            if( n < Step)
            {   
                if(!AdjustOrder(currentGrid,OP_SELLLIMIT,OP_SELL))
                {
                    Ticket = OrderSend(Symbol(), OP_SELLLIMIT, LOTS, NormalizeDouble(currentGrid,Digits), SLIPPAGE, 0, currentGrid-GridDistance*Point, "Sell", 0, 0, clrRed);      
                }                               
                n++;
            }
        }
    }
}

#define checkprice(a,b) (fabs(a-b) < 0.000000001)

bool AdjustOrder(double grid,int typelimit,int typeorder)
{
    for(int i = OrdersTotal(); i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES))
        {
            if((OrderType() == typelimit || OrderType() == typeorder) && checkprice(OrderOpenPrice(),grid))
            {
                return True;   
            }
        }             
    }
    return False;
}

int CountOrder(int type) 
{
    int count = 0;
    for(int i = OrdersTotal() - 1; i >=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS))
        {
            if(OrderType() == type)
            {
                  count++;
            }
        }
    }
    return count;
}

// EURUSD

