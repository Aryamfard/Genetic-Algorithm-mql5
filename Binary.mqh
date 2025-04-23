//+------------------------------------------------------------------+
//|                                                       Binary.mqh |
//|                               Copyright 2020, Arya Mohamadifard. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Arya Mohamadifard."
#property link      "https://www.mql5.com"
#property version   "1.00"

struct BInt
{
    uchar num[];
};

struct BDouble
{
    uchar num[];
    char p10;
};


  class Binary
  {
      protected:
          int Flnum(double number);

      private:

      public:
          Binary();
          ~Binary();
          void Decimal2Binary(int number,BInt &BRI);
          void Decimal2Binary(double number,BDouble &BRD,short Accuracy=-1);
          int Convert2Decimal(BInt &BRI);
          double Convert2Decimal(BDouble &BRD);
          string PrintBinary(BInt &BRI);
          string PrintBinary(BDouble &BRD);
          uchar DigitNum(BInt &BRI);
          uchar DigitNum(BDouble &BRD);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Binary::Binary()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Binary::~Binary()
  {
  }
//+------------------------------------------------------------------+ Start +----------------------------------------------------------------
//...........................+------------------------------------------------------------------+
//...........................|                         Decimal to bunary converter              |
//...........................+------------------------------------------------------------------+
void Binary::Decimal2Binary(int number,BInt &BRI)
{
    if(number <= 127 && number >= -127) ArrayResize(BRI.num,8);
    else if(number <= 32767 && number >= -32767) ArrayResize(BRI.num,16);
    else if(number <= 2147483647 && number >= -2147483647) ArrayResize(BRI.num,32);
    else return;
    
    uchar len = (uchar)ArraySize(BRI.num);
    
    if(number < 0)
    {
        number = MathAbs(number);
        BRI.num[len-1] = 1;
    }
    else BRI.num[len-1] = 0;
    
    for(int ii=0;ii<=len-2;ii++)
    {
        if(number<1)
        {
            BRI.num[ii] = 0;
            continue;
        }
        BRI.num[ii] = (uchar)(number%2);
        number = number/2;
    }
}
void Binary::Decimal2Binary(double number,BDouble &BRD,short Accuracy=-1)
{   
    long nb=0;
    
    if(Accuracy >= 0 && Accuracy < 12)
    {
        BRD.p10 = (char)Accuracy;
        nb = (long)(MathAbs(number)*MathPow(10,BRD.p10));
    }
    else 
    {
        BRD.p10 = (char)Flnum(number);
        nb = (long)(MathAbs(number)*MathPow(10,BRD.p10));
    }
    
    BRD.p10 *= -1;
    
    if(nb <= 127) ArrayResize(BRD.num,8);
    else if(nb <= 32767) ArrayResize(BRD.num,16);
    else if(nb <= 2147483647) ArrayResize(BRD.num,32);
    else if(nb <=  9223372036854775807) ArrayResize(BRD.num,64);
    else return;
    
    uchar len = (uchar)ArraySize(BRD.num);
    
    if(number<0) BRD.num[len-1] = 1;
    else BRD.num[len-1] = 0;
    
    for(int ii=0;ii<=len-2;ii++)
    {
        if(nb<1)
        {
            BRD.num[ii] = 0;
            continue;
        }
        BRD.num[ii] = (uchar)(nb%2);
        nb = nb/2;
    }
}
//...........................+------------------------------------------------------------------+
//...........................|                         Get binary digit numbers                 |
//...........................+------------------------------------------------------------------+
uchar Binary::DigitNum(BInt &BRI)
{
    char len = (char)ArraySize(BRI.num);
    
    char ii;
    
    for(ii=len-2 ; ii>=0 ; ii--)
    {
        if(BRI.num[ii] != 0) break;
    }
    
    if(ii<0) return(1);
    else return((uchar)(ii+1));
}
uchar Binary::DigitNum(BDouble &BRD)
{
    char len = (char)ArraySize(BRD.num);
    
    char ii;
    
    for(ii=len-2 ; ii>=0 ; ii--)
    {
        if(BRD.num[ii] != 0) break;
    }
    
    if(ii<0) return(1);
    else return((uchar)(ii+1));
}
//...........................+------------------------------------------------------------------+
//...........................|                         Print binaries                           |
//...........................+------------------------------------------------------------------+
string Binary::PrintBinary(BInt &BRI)
{
    string outp="";
    
    uchar len = (uchar)ArraySize(BRI.num);
    
    if(BRI.num[len-1] == 1) outp+="-";
    
    uchar ii=DigitNum(BRI);
    
    do
    {
        outp += IntegerToString(BRI.num[ii-1]);
        ii--;
    }while(ii>0);
    
    return(outp);
}
string Binary::PrintBinary(BDouble &BRD)
{
    string outp="";
    
    uchar len = (uchar)ArraySize(BRD.num);
    
    if(BRD.num[len-1] == 1) outp+="-";
    
    uchar ii=DigitNum(BRD);
    
    do
    {
        outp += IntegerToString(BRD.num[ii-1]);
        ii--;
    }while(ii>0);
    
    return(outp);
}
//...........................+------------------------------------------------------------------+
//...........................|                         Convert binary to decimal                |
//...........................+------------------------------------------------------------------+
int Binary::Convert2Decimal(BInt &BRI)
{
    int resu = 0;
    
    for(int ii=DigitNum(BRI)-1;ii>=0;ii--)
    {
        resu += (int)(BRI.num[ii]*MathPow(2,ii));
    }
    
    if(BRI.num[ArraySize(BRI.num)-1] == 1) return(-resu);
    else return(resu);
}
double Binary::Convert2Decimal(BDouble &BRD)
{
    double resu = 0;
    
    for(int ii=DigitNum(BRD)-1;ii>=0;ii--)
    {
        resu += (double)(BRD.num[ii]*MathPow(2,ii));
    }
    
    if(BRD.num[ArraySize(BRD.num)-1] == 1) resu = -resu * MathPow(10,(double)BRD.p10);
    else resu *= MathPow(10,(double)BRD.p10);
    
    return(resu);
}
//...........................+------------------------------------------------------------------+
//...........................|                         Get double digit numbers                 |
//...........................+------------------------------------------------------------------+
int Binary::Flnum(double number)
{
    int dig=0;
    while(NormalizeDouble(number,dig) != NormalizeDouble(number,17)) dig++;
    
    return(dig);
}