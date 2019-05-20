input ENUM_MA_METHOD MA_METHOD          = MODE_SMA;
input ENUM_APPLIED_PRICE PRICE          = PRICE_CLOSE;

input int SLIPPAGE          = 3;
input double LOTS           = 0.01;
input int SL                = 100;
input int TP                = 50;
input int MA_PERIOD         = 20;
input int SHIFT             = 1; 
input int MAGIC_NUMBER      = 1234;

input bool MARTINGALE_ENABLE                = true;
input double MARTINGALE_MULTIPLIER          = 2;
input int MARTINGALE_DISTANCE               = 100;
input int MARTINGALE_MAX_ORDERS             = 4; 
input double MARTINGALE_GOAL_PROFIT         = 10;

double Ema;
double AskPrice, BidPrice;
bool NewOrder = false;
int Ticket;


void GetMA()
{
   Ema = iMA(Symbol(), 0, MA_PERIOD, 0, MA_METHOD, PRICE, SHIFT);
}



void Condition()
{

  if(OrdersTotal() == 0)
     {
        if(Open[1] < Ema && Close[1] > Ema) 
         {
            OrderBuy();
         }
        else if(Open[1] > Ema && Close[1] < Ema)
        {
            OrderSell();
        }  
     }
  else if (OrdersTotal() != 0) 
  {               
      if(CountSell() == 0 && AskPrice - Ask > MARTINGALE_DISTANCE*Point)
      {
            OrderBuy();
      } 
      else if(CountBuy() == 0 && Bid - BidPrice > MARTINGALE_DISTANCE*Point)
      {
            OrderSell();
      }       

   
   }
}



void OrderBuy()
{
   int tp         = 0;
   double new_lot = LOTS;
   if(OrdersTotal() == 0) 
   {
        tp = TP; 
        Ticket = OrderSend(Symbol(), OP_BUY, new_lot, Ask, SLIPPAGE, 0, Ask+tp*Point, "Buy1", MAGIC_NUMBER, 0, clrGreen);
   } 
   else 
   {
        new_lot = NewLots();
        Ticket = OrderSend(Symbol(), OP_BUY, new_lot, Ask, SLIPPAGE, 0, 0, "Buy", MAGIC_NUMBER, 0, clrGreen);
        ModifyTP();
   }
   
   AskPrice = Ask;
}



void OrderSell()
{
   int tp         = 0;
   double new_lot = LOTS;
   if(OrdersTotal() == 0) 
   {
        tp = TP; 
        Ticket = OrderSend(Symbol(), OP_SELL, new_lot, Bid, SLIPPAGE, 0, Bid-tp*Point, "Sell1", MAGIC_NUMBER, 0, clrRed);
   } 
   else 
   {
        new_lot = NewLots();
        Ticket = OrderSend(Symbol(), OP_SELL, new_lot, Bid, SLIPPAGE, 0, 0, "Sell", MAGIC_NUMBER, 0, clrRed);
        ModifyTP();
   }
   
   BidPrice = Bid;
}




void ModifyTP()
{
       //////////////////////// Prepare Modify ///////////////////////////////////
       
       double sumOrderBuy,sumOrderSell     = 0;
       double sumLotsBuy,sumLotsSell       = 0;
       double avgPriceBuy,avgPriceSell     = 0;
       double newTPBuy,newTPSell           = 0;
   
       for(int i = OrdersTotal() - 1; i >= 0; i--)
       {
           if(OrderSelect(i , SELECT_BY_POS))
           {
               if(OrderType() == OP_BUY)
               {
                  sumOrderBuy += OrderOpenPrice() * OrderLots();
                  sumLotsBuy  += OrderLots();
               }
               if(OrderType() == OP_SELL)
               {
                  sumOrderSell += OrderClosePrice() * OrderLots();
                  sumLotsSell  += OrderLots();
               }
           }
       }
       
       //////////////////////// Modify TP Buy ///////////////////////////////////
       
       if(sumLotsBuy != 0)
       {
            avgPriceBuy = NormalizeDouble(sumOrderBuy / sumLotsBuy, Digits);
            newTPBuy = avgPriceBuy + TP * Point;   
       
           for(i = OrdersTotal() - 1; i >=0; i--)
           {
               if(OrderSelect(i, SELECT_BY_POS))
               {
                   if(OrderType() == OP_BUY)
                   {
                      //newTPBuy = avgPriceBuy + TP * Point;
                      Print(newTPBuy);
                      Print(OrderTakeProfit());
                      Print("...");
                      if(newTPBuy != OrderTakeProfit())
                      {
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),newTPBuy, 0, 0);
                        Print(OrderTicket());
                        Print("..");
                      } 
                   }
                }     
             }   
         }
         
         
         //////////////////////// Modify TP Sell ///////////////////////////////////
         
         if(sumLotsSell != 0) 
         {
            avgPriceSell = NormalizeDouble(sumOrderSell / sumLotsSell, Digits);
            newTPSell = avgPriceSell + TP * Point;   
            
            for(i = OrdersTotal() - 1; i >=0; i--)
            {
               if(OrderSelect(i, SELECT_BY_POS))
               {
                   if(OrderType() == OP_SELL)
                   {
                      if(newTPSell != OrderTakeProfit())
                      {
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),newTPSell, 0, 0);
                        Print(OrderTicket());
                        Print("..");
                      }
                   }
                }
             }   
          }
}



double NewLots()
{
   double new_lots = LOTS;
   for(int i = OrdersTotal()-1; i >=0; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         new_lots *= MARTINGALE_MULTIPLIER;
      }
   }
   return new_lots;
}



void OnTick()
{
    GetMA();
    Condition();
    Print(CountBuy());
    Print("=====");
    Print(CountSell());
}



int CountSell()
{
    int count = 0;
    for(int i = OrdersTotal() - 1; i >=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_TICKET))
        {
            if(OrderType() == OP_SELL)
            {
                  count++;
            }
        }
    }
    return count;
}



int CountBuy()
{
    int count = 0;
    for(int i = OrdersTotal() - 1; i >=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_TICKET))
        {
            if(OrderType() == OP_BUY)
            {
                  count++;
            }
        }
    }
    return count;
}
