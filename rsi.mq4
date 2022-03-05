int input PERIOD = 14;
int input HIGH = 70;
int input LOW = 30;
int input MAXBARS = 185;

double input SL = 100;

double input LOTSIZE = 0.1;

int BarsCount = 0;

int shortT = 0;
int longT = 0; 
 
int sbars = 0;
int lbars = 0; 

bool hasTraded = false;

int tradeDay;

int start()
{

  datetime x = TimeCurrent();
  int day = TimeDayOfYear(TimeCurrent());
  
  if (day != tradeDay) 
  {
    if (TimeHour(TimeCurrent()) > 21)
    {
      if (!hasTraded) 
      {
        double MA = iMA(Symbol(), 0, 200, 0, MODE_EMA, PRICE_CLOSE, 0);
        if (PRICE_CLOSE < MA)
        {
          OrderSend(Symbol(), OP_SELL, LOTSIZE/10, Bid, 2, Ask+3, Ask-3);
          hasTraded = True;
        }
        else 
        {
          OrderSend(Symbol(), OP_BUY, LOTSIZE/10, Ask, 2, Bid-3, Bid+3);
          hasTraded = True;
        }
      }
    }
  }
  
  tradeDay = day;

  if (Bars>BarsCount)
  
  {
    //your code to be executed only once per bar goes here. You can enclose your entire Expert Advisor within here...
   
    if (shortT != 0)
    {
      sbars = sbars + 1;
    }
    
    if (longT != 0)
    {
      lbars = lbars + 1;
    }
   
    
    double RSI1 = iRSI(Symbol(), 0, PERIOD, PRICE_CLOSE, 0);
    double RSI2 = iRSI(Symbol(), 0, PERIOD, PRICE_CLOSE, 1);
    
    bool crossover = (RSI1 > LOW) & (RSI2 < LOW);
    bool crossunder = (RSI1 < HIGH) & (RSI2 > HIGH);
    
    if (crossover)
    {
      longT = OrderSend(Symbol(), OP_BUY, LOTSIZE, Ask, 2, Bid-SL, Bid+Bid);
      hasTraded = True;
      if (shortT != 0) 
      {
         OrderClose(shortT, LOTSIZE, Bid, 2);
         shortT = 0;
         sbars = 0;
      }
    }
    
    else if (crossunder)
    {
      shortT = OrderSend(Symbol(), OP_SELL, LOTSIZE, Bid, 2, Ask+SL, Ask-Ask);
      hasTraded = True;
      if (longT != 0) 
      {
         OrderClose(longT, LOTSIZE, Ask, 2);
         longT = 0;
         lbars = 0;
      }
    }
    
    if (lbars >= MAXBARS)
    {
      OrderClose(longT, LOTSIZE, Ask, 2);
      longT = 0;
      lbars = 0;
    }
    
    else if (sbars >= MAXBARS) 
    {
      OrderClose(shortT, LOTSIZE, Bid, 2);
      shortT = 0;
      sbars = 0;
    }
 
    
    BarsCount = Bars;
  }
  
  return(0);
}