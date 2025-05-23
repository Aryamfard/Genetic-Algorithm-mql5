//+------------------------------------------------------------------+
//|                                                           GA.mqh |
//|                               Copyright 2020, Arya Mohamadifard. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Arya Mohamadifard."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define RandMax 32768;

#include <AryaLib\Binary.mqh>

class GA
{
    protected:
    
        struct Realdata
        {
            double ddata[];
        };
        struct Intdata
        {
            int idata[];
        };
        
        double score[];
        
        ushort SelectNum;
        ushort Population;
        ushort Stop;
        ushort inps;
        short Decimal;
        
        double Minimummsd[];
        double Maximummsd[];
        
        int Minimummsi[];
        int Maximummsi[];
        
        //Main function & fittness function -----------------------------------------****-------------------------------------
        virtual bool MainFunction(double &inp[],double &ans[]) 
        {
            ArrayResize(ans,1);
            //ans[0] = sin(inp[0]);
            ans[0] = MathPow((inp[0]-1),2);
            return(true);
        };
        virtual bool MainFunction(int &inp[],double &ans[]) 
        {
            ArrayResize(ans,1);
            ans[0] = MathPow(inp[0]-5,2) + MathPow(inp[1]-5,2) + 1;
            return(true);
        };
        
        virtual double FittnessFunction(double &data[])
        {
            return(data[0]);
        };
        
        virtual bool Initialcondition(double &data[]) {return(true);};
        virtual bool Initialcondition(int &data[]) {return(true);};
        //select functions ---------------------------------------------------****---------------------------------------------
        void Selection(Realdata &people[]);
        void Selection(Intdata &people[]);
        
        void Editscore(double &sdata[]);
        void FPSelection(double &Scores[],int &Picks[]);    //Fitness proportionate selection
        
        //Generate scores
        virtual void ScoreGenerator(Intdata &people[], double &scores[])
        {
            ArrayResize(scores,Population);
            
            for(int i=0;i<Population;i++)
            {
                double res[];
                if(MainFunction(people[i].idata,res))
                {
                    scores[i] = FittnessFunction(res);
                    //Print(DoubleToString(scores[i])+"------------");
                }
                else 
                {
                    scores[i] = 9e100;
                    //Print("Mainfun error :(");
                }
            }
        };
        virtual void ScoreGenerator(Realdata &people[], double &scores[])
        {
            ArrayResize(scores,Population);
    
            for(int i=0;i<Population;i++)
            {
                double res[];
                if(MainFunction(people[i].ddata,res)) scores[i] = FittnessFunction(res);
                else
                {
                    scores[i] = 9e100;
                    Print("Mainfun error :(");
                }
                //Print(score[i]);
            }
        };
        
        //production main functions---------------------------------------------------****----------------------------------------
        void Reproduce(Intdata &people[]);
        void Reproduce(Realdata &people[]);
        
        //Basic procuction
        void Crossoveri(int &Childs[],int Parrent1,int Parrent2,bool MultiPoint=false);
        void Crossoverd(double &Childs[],double Parrent1,double Parrent2,short Accuracy=-1,bool MultiPoint=false);
        void Mutationi(int &Childs[],int Parrent1,int Parrent2);
        void Mutationd(double &Childs[],double Parrent1,double Parrent2,short Accuracy=-1);
        
        //production data
        void CrossReal(Realdata &p1,Realdata &p2,Realdata &child1,Realdata &child2,short Accuracy = -1,bool Mpoint = false);
        void CrossInt(Intdata &p1,Intdata &p2,Intdata &Child1,Intdata &Child2,bool MultiPoint=false);
        void MutatReal(Realdata &p1,Realdata &p2,Realdata &Child1,Realdata &Child2,short Accuracy = -1);
        void MutatInt(Intdata &p1,Intdata &p2,Intdata &Child1,Intdata &Child2);
        //first [] is number second [] is data from left [][]
        
        
        //other functions ---------------------------------------------------****---------------------------------------------
        bool Arraycontains(int &data[],int value);
        void RandomMaker(Realdata &ranarr[],int startfrom,double &Maxes[],double &Mins[]);
        void RandomMaker(Intdata &ranarr[],int startfrom,int &Maxes[],int &Mins[]);
        void Swap(uchar &data1[],uchar &data2[],int index);
        bool Change(bool bb);
        double RandomRanged(double min,double max);
        int RandomRangei(int min,int max);
        void ArrSwap(Realdata &arr[],int index1,int index2);
        void ArrSwap(Intdata &arr[],int index1,int index2);
        void Makezero(Realdata &arr[],int startfrom=0);
        void Makezero(Intdata &arr[],int startfrom=0);
        bool Equality(Intdata &data1, Intdata &data2);
        bool Equality(Realdata &data1, Realdata &data2);
        void GA::Mout(Realdata &people[],int cc);
        void GA::Mout(Intdata &people[],int cc);
        
        
        
    public:
        GA();
       ~GA();
        void GAsetting(ushort nvar,ushort CNum=10,ushort Pop=100,ushort End=150,short Acc=-1);
        virtual void Solve(double &MaxR[],double &MinR[],double &ans[],ushort StopSame=50);
        virtual void Solve(int &MaxR[],int &MinR[],int &ans[],ushort StopSame=50);
        void InitData(double &idata[]);
        void InitData(int &idata[]);
        double GetScore(int index)
        {
            return(score[index]);
        };
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GA::GA()
{
    inps = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
GA::~GA()
{
    
}
//+------------------------------------------------------------------+ <<Setting>>
void GA::GAsetting(ushort nvar,ushort CNum=10,ushort Pop=100,ushort End=150,short Acc=-1)
{
    if(CNum * 4 > Pop || CNum%2 != 0 || CNum < 2 || Pop < 10 || End < 5)
    {
        CNum=10;
        Pop=100;
        End=150;
        Print("Un balance settings :(");
    }
    
    inps = nvar;
    SelectNum = CNum;
    Population = Pop;
    Stop = End;
    Decimal = Acc;
}
//...........................+------------------------------------------------------------------+
//...........................|         Swap - Change - Arraycontain - Randoms - Others          |
//...........................+------------------------------------------------------------------+
//change bool value
bool GA::Change(bool bb)
{
    if(bb) return(false);
    else return(true);
}

//Find somthing in an array
bool GA::Arraycontains(int &data[],int value)
{
    bool res=false;
    for(int ii=ArraySize(data)-1;ii>=0;ii--)
        if(data[ii] == value)
        {
            res = true;
            break;
        }
    
    return(res);
}
//Swap data
void GA::Swap(uchar &data1[],uchar &data2[],int index)
{
    uchar satl;
    
    satl = data1[index];
    data1[index] = data2[index];
    data2[index] = satl;
}
//make ramdom    { min <=R< max }
double GA::RandomRanged(double min,double max)
{
    // min <= r < max
    double r = rand()/(double)RandMax;
    return(min + (r*(max-min)));
}

int GA::RandomRangei(int min,int max)
{
    double r = rand()/(double)RandMax;
    return((int)(min + (r*(max-min))));
}

//Swap data array indexes
void GA::ArrSwap(Intdata &arr[],int index1,int index2)
{
    Intdata satl;
    
    ArrayResize(satl.idata,inps);
    
    for(int i=0;i<inps;i++)
    {
        satl.idata[i] = arr[index1].idata[i];
    }
    for(int i=0;i<inps;i++)
    {
        arr[index1].idata[i] = arr[index2].idata[i];
    }
    for(int i=0;i<inps;i++)
    {
        arr[index2].idata[i] = satl.idata[i];
    }
}
void GA::ArrSwap(Realdata &arr[],int index1,int index2)
{
    Realdata satl;
    
    ArrayResize(satl.ddata,inps);
    
    for(int i=0;i<inps;i++)
    {
        satl.ddata[i] = arr[index1].ddata[i];
    }
    for(int i=0;i<inps;i++)
    {
        arr[index1].ddata[i] = arr[index2].ddata[i];
    }
    for(int i=0;i<inps;i++)
    {
        arr[index2].ddata[i] = satl.ddata[i];
    }
}
//Make zero data
void GA::Makezero(Intdata &arr[],int startfrom = 0)
{
    for(int i=startfrom;i<Population;i++)
    {
        for(int j=0;j<inps;j++)
        {
            arr[i].idata[j] = 0;
        }
    }
}
void GA::Makezero(Realdata &arr[],int startfrom = 0)
{
    for(int i=startfrom;i<Population;i++)
    {
        for(int j=0;j<inps;j++)
        {
            arr[i].ddata[j] = 0;
        }
    }
}
//Edit scores
void GA::Editscore(double &sdata[])
{
    if(sdata[ArrayMinimum(sdata)] < 0)
    {
        double Adihes = MathAbs(sdata[ArrayMinimum(sdata)]) + 1;
        
        for(ushort i=0;i<Population;i++) sdata[i] += Adihes;
    }
}
//int data Equality
bool GA::Equality(Intdata &data1,Intdata &data2)
{
    for(int i=0;i<inps;i++)
    {
        if(data1.idata[i] != data2.idata[i])
        {
            return(false);
        }
    }
    return(true);
}
bool GA::Equality(Realdata &data1,Realdata &data2)
{
    for(int i=0;i<inps;i++)
    {
        if(data1.ddata[i] != data2.ddata[i])
        {
            return(false);
        }
    }
    return(true);
}

//...........................+------------------------------------------------------------------+
//...........................|                  Crossover operators for d&i                     |
//...........................+------------------------------------------------------------------+
void GA::Crossoveri(int &Childs[],int Parrent1,int Parrent2,bool MultiPoint=false)
{
    Binary bin;
    BInt p1,p2;
    bin.Decimal2Binary(Parrent1,p1);
    bin.Decimal2Binary(Parrent2,p2);
    //Print("Befor crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2));
    
    ArrayResize(Childs,2);
    short len = (short)MathMin((double)bin.DigitNum(p1),(double)bin.DigitNum(p2));
    
    if(MultiPoint)
    {
        short lp = (len/8)+1;
        int points[];
        
        ArrayResize(points,lp);
        ZeroMemory(points);
        
        //string Prt = " ";
        for(short jj=0;jj<lp;jj++)
        {
            int rp = RandomRangei(0,len-1);
            
            if(Arraycontains(points,rp) && rp != 0)
            {
                 jj--;
                 continue;
            }
            else points[jj] = rp;
            
            //Prt += IntegerToString(points[jj]) + " - ";
        }
        
        bool ds = true;
        ArraySort(points);
        
        for(short jj=0;jj<=len-1;jj++)
        {
            if(ds) Swap(p1.num,p2.num,jj);
            if(Arraycontains(points,jj))
            {
                ds = Change(ds);
            }
        }
        
        //Print("After crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2)+" | "+Prt+" | "+IntegerToString(len));
        Childs[0] = bin.Convert2Decimal(p1);
        Childs[1] = bin.Convert2Decimal(p2);
    }
    else
    {
        int cpo = RandomRangei(0,len-1); 
        for(int jj=0;jj<=cpo;jj++)
            Swap(p1.num,p2.num,jj);
        
        //("After crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2)+" | cpo = "+IntegerToString(cpo));
        Childs[0] = bin.Convert2Decimal(p1);
        Childs[1] = bin.Convert2Decimal(p2);
    }
}

void GA::Crossoverd(double &Childs[],double Parrent1,double Parrent2,short Accuracy=-1,bool MultiPoint=false)
{
    Binary bin;
    BDouble p1,p2;
    bin.Decimal2Binary(Parrent1,p1,Accuracy);
    bin.Decimal2Binary(Parrent2,p2,Accuracy);
    //Print("Befor crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2));
    
    ArrayResize(Childs,2);
    short len = (short)MathMin((double)bin.DigitNum(p1),(double)bin.DigitNum(p2));
    
    if(MultiPoint)
    {
        short lp = (len/8)+1;
        int points[];
        
        ArrayResize(points,lp);
        ZeroMemory(points);
        
        //string Prt = " ";
        for(short jj=0;jj<lp;jj++)
        {
            int rp = RandomRangei(0,len-1);
            
            if(Arraycontains(points,rp) && rp != 0)
            {
                 jj--;
                 continue;
            }
            else points[jj] = rp; 
            
            //Prt += IntegerToString(points[jj]) + " - ";
        }
        
        bool ds = true;
        ArraySort(points);
        
        for(short jj=0;jj<=len-1;jj++)
        {
            if(ds) Swap(p1.num,p2.num,jj);
            if(Arraycontains(points,jj))
            {
                ds = Change(ds);
            }
        }
        
        //Print("After crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2)+" | "+Prt+" | "+IntegerToString(len));
        Childs[0] = bin.Convert2Decimal(p1);
        Childs[1] = bin.Convert2Decimal(p2);
    }
    else
    {
        int cpo = RandomRangei(0,len-1);
            
        for(int jj=0;jj<=cpo;jj++)
            Swap(p1.num,p2.num,jj);
        
        //Print("After crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2)+" | cpo = "+IntegerToString(cpo));
        Childs[0] = bin.Convert2Decimal(p1);
        Childs[1] = bin.Convert2Decimal(p2);
    }
}

void GA::CrossReal(Realdata &p1,Realdata &p2,Realdata &child1,Realdata &child2,short Accuracy = -1,bool Mpoint = false)
{
    double baby[];
    
    if(inps == 1)
    {
        Crossoverd(baby,p1.ddata[0],p2.ddata[0],Accuracy,Mpoint);
        
        if(baby[0] > Maximummsd[0]) baby[0] = Maximummsd[0];
        if(baby[1] > Maximummsd[0]) baby[1] = Maximummsd[0];
        if(baby[0] < Minimummsd[0]) baby[0] = Minimummsd[0];
        if(baby[1] < Minimummsd[0]) baby[1] = Minimummsd[0];
        
        child1.ddata[0] = baby[0];
        child2.ddata[0] = baby[1];
    }
    else 
    {
        for(int k=0;k<inps;k++)
        {
            if(RandomRangei(0,2)!=0)
            {
                Crossoverd(baby,p1.ddata[k],p2.ddata[k],Accuracy,Mpoint);
                
                if(baby[0] > Maximummsd[k]) baby[0] = Maximummsd[k];
                if(baby[1] > Maximummsd[k]) baby[1] = Maximummsd[k];
                if(baby[0] < Minimummsd[k]) baby[0] = Minimummsd[k];
                if(baby[1] < Minimummsd[k]) baby[1] = Minimummsd[k];
                
                child1.ddata[k] = baby[0];
                child2.ddata[k] = baby[1];
            }
            else 
            {
                child1.ddata[k] = p1.ddata[k];
                child2.ddata[k] = p2.ddata[k];
            }
        }  
    }
}

void GA::CrossInt(Intdata &p1,Intdata &p2,Intdata &Child1,Intdata &Child2,bool MultiPoint=false)
{
    int baby[];
    
    if(inps == 1)
    {
        Crossoveri(baby,p1.idata[0],p2.idata[0],MultiPoint);
        
        if(baby[0] >= Maximummsi[0]) baby[0] = Maximummsi[0]-1;
        if(baby[1] >= Maximummsi[0]) baby[1] = Maximummsi[0]-1;
        if(baby[0] < Minimummsi[0]) baby[0] = Minimummsi[0];
        if(baby[1] < Minimummsi[0]) baby[1] = Minimummsi[0];
        
        Child1.idata[0] = baby[0];
        Child2.idata[0] = baby[1];
    }
    else 
    {
        for(int k=0;k<inps;k++)
        {
            if(RandomRangei(0,2)!=0)
            {
                Crossoveri(baby,p1.idata[k],p2.idata[k],MultiPoint);
                
                if(baby[0] >= Maximummsi[k]) baby[0] = Maximummsi[k]-1;
                if(baby[1] >= Maximummsi[k]) baby[1] = Maximummsi[k]-1;
                if(baby[0] < Minimummsi[k]) baby[0] = Minimummsi[k];
                if(baby[1] < Minimummsi[k]) baby[1] = Minimummsi[k];
                
                Child1.idata[k] = baby[0];
                Child2.idata[k] = baby[1];
            }
            else 
            {
                Child1.idata[k] = p1.idata[k];
                Child2.idata[k] = p2.idata[k];
            }
        }  
    }
}
//...........................+------------------------------------------------------------------+
//...........................|                    Mutation operators for i&d                    |
//...........................+------------------------------------------------------------------+
void GA::Mutationi(int &Childs[],int Parrent1,int Parrent2)
{
    Binary bin;
    BInt p1,p2;
    bin.Decimal2Binary(Parrent1,p1);
    bin.Decimal2Binary(Parrent2,p2);
    
    //Print("Befor mutate : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2));
    
    ArrayResize(Childs,2);
    
    short len = (short)MathMin((double)bin.DigitNum(p1),(double)bin.DigitNum(p2));
    int rp1 = 0,rp2 = 0;

    if((short)MathMax((double)bin.DigitNum(p1),(double)bin.DigitNum(p2)) < 
    (short)MathMin((double)ArraySize(p1.num),(double)ArraySize(p2.num)) - 1)
    {
        rp1 = RandomRangei(len/2,len+1);
        rp2 = RandomRangei(len/2,len+1);
    }
    else
    {
        rp1 = RandomRangei(len/2,len);
        rp2 = RandomRangei(len/2,len);
    }
    
    if(p1.num[rp1] == 0) p1.num[rp1] = 1;
    else p1.num[rp1] = 0;
    
    if(p2.num[rp2] == 0) p2.num[rp2] = 1;
    else p2.num[rp2] = 0;
    
    //Print("After crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2)+" | rp1 = "+rp1+" | rp2 = "+rp2+" | len = "+IntegerToString(len));
    
    Childs[0] = bin.Convert2Decimal(p1);
    Childs[1] = bin.Convert2Decimal(p2);
}

void GA::Mutationd(double &Childs[],double Parrent1,double Parrent2,short Accuracy=-1)
{
    Binary bin;
    BDouble p1,p2;
    bin.Decimal2Binary(Parrent1,p1,Accuracy);
    bin.Decimal2Binary(Parrent2,p2,Accuracy);
    
    //Print("Befor mutate : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2));
    
    ArrayResize(Childs,2);
    
    short len = (short)MathMin((double)bin.DigitNum(p1),(double)bin.DigitNum(p2));
    int rp1 = 0,rp2 = 0;
    
    if((short)MathMax((double)bin.DigitNum(p1),(double)bin.DigitNum(p2)) < 
    (short)MathMin((double)ArraySize(p1.num),(double)ArraySize(p2.num)) - 1)
    {
        rp1 = RandomRangei(len/2,len+1);
        rp2 = RandomRangei(len/2,len+1);
    }
    else
    {
        rp1 = RandomRangei(len/2,len);
        rp2 = RandomRangei(len/2,len);
    }
    
    if(p1.num[rp1] == 0) p1.num[rp1] = 1;
    else p1.num[rp1] = 0;
    
    if(p2.num[rp2] == 0) p2.num[rp2] = 1;
    else p2.num[rp2] = 0;
    
    //Print("After crossover : p1 = "+bin.PrintBinary(p1)+" | p2 = "+bin.PrintBinary(p2)+" | rp1 = "+rp1+" | rp2 = "+rp2+" | len = "+IntegerToString(len));
    
    Childs[0] = bin.Convert2Decimal(p1);
    Childs[1] = bin.Convert2Decimal(p2); 
}

void GA::MutatReal(Realdata &p1,Realdata &p2,Realdata &Child1,Realdata &Child2,short Accuracy = -1)
{
    double baby[];
    
    if(inps == 1)
    {
        Mutationd(baby,p1.ddata[0],p2.ddata[0],Accuracy);
        
        if(baby[0] > Maximummsd[0]) baby[0] = Maximummsd[0];
        if(baby[1] > Maximummsd[0]) baby[1] = Maximummsd[0];
        if(baby[0] < Minimummsd[0]) baby[0] = Minimummsd[0];
        if(baby[1] < Minimummsd[0]) baby[1] = Minimummsd[0];
        
        Child1.ddata[0] = baby[0];
        Child2.ddata[0] = baby[1];
    }
    else 
    {
        for(int k=0;k<inps;k++)
        {
            if(RandomRangei(0,2)!=0)
            {
                Mutationd(baby,p1.ddata[k],p2.ddata[k],Accuracy);
                
                if(baby[0] > Maximummsd[k]) baby[0] = Maximummsd[k];
                if(baby[1] > Maximummsd[k]) baby[1] = Maximummsd[k];
                if(baby[0] < Minimummsd[k]) baby[0] = Minimummsd[k];
                if(baby[1] < Minimummsd[k]) baby[1] = Minimummsd[k];
                
                Child1.ddata[k] = baby[0];
                Child2.ddata[k] = baby[1];
            }
            else 
            {
                Child1.ddata[k] = p1.ddata[k];
                Child2.ddata[k] = p2.ddata[k];
            }
        }  
    }
}

void GA::MutatInt(Intdata &p1,Intdata &p2,Intdata &Child1,Intdata &Child2)
{
    int baby[];
    
    if(inps == 1)
    {
        Mutationi(baby,p1.idata[0],p2.idata[0]);
        
        if(baby[0] >= Maximummsi[0]) baby[0] = Maximummsi[0]-1;
        if(baby[1] >= Maximummsi[0]) baby[1] = Maximummsi[0]-1;
        if(baby[0] < Minimummsi[0]) baby[0] = Minimummsi[0];
        if(baby[1] < Minimummsi[0]) baby[1] = Minimummsi[0];
        
        Child1.idata[0] = baby[0];
        Child2.idata[0] = baby[1];
    }
    else 
    {
        for(int k=0;k<inps;k++)
        {
            if(RandomRangei(0,2)!=0)
            {
                Mutationi(baby,p1.idata[k],p2.idata[k]);
                
                if(baby[0] >= Maximummsi[k]) baby[0] = Maximummsi[k]-1;
                if(baby[1] >= Maximummsi[k]) baby[1] = Maximummsi[k]-1;
                if(baby[0] < Minimummsi[k]) baby[0] = Minimummsi[k];
                if(baby[1] < Minimummsi[k]) baby[1] = Minimummsi[k];
                
                Child1.idata[k] = baby[0];
                Child2.idata[k] = baby[1];
            }
            else 
            {
                Child1.idata[k] = p1.idata[k];
                Child2.idata[k] = p2.idata[k];
            }
        }  
    }
}
//...........................+------------------------------------------------------------------+
//...........................|                              select                              |
//...........................+------------------------------------------------------------------+
void GA::Selection(Realdata &people[])
{
    ArrayRemove(score,0);
    
    ScoreGenerator(people,score);
    Editscore(score);
    //Print("Score pass");
    
    double t;
    int max;
    for(int i=Population;i>0;i--)
    {
        max = 0;
        for(int j=0;j<i;j++)
        {
            if(score[j]>score[max]) max=j;
            
            t = score[max];
            score[max] = score[i-1];
            score[i-1] = t;
            
            ArrSwap(people,max,i-1);
        }
    }
    //Print("Sort pass");
    //Mout(people,20);
    
    double sumtot=0;
    for(int i=0;i<Population;i++) sumtot += score[i];
    double newscore[];
    ArrayResize(newscore,Population);
    for(int i=0;i<Population;i++)
    {
        newscore[i] = (score[Population - 1 - i]/sumtot);
        //Print(newscore[i]);
    }
    //Print("PBT pass");
    //ArrayRemove(score,0);
    
    int selected[];
    ArrayResize(selected,SelectNum);
    FPSelection(newscore,selected);  
    ArraySort(selected);
    //Print("FPS pass");
    
    for(int i=0;i<SelectNum;i++)
    {
        ArrSwap(people,i,selected[i]);
    }
}
void GA::Selection(Intdata &people[])
{
    ArrayRemove(score,0);
    
    ScoreGenerator(people,score);
    Editscore(score);
    //Print("Score pass");
    
    double t;
    int max;
    for(int i=Population;i>0;i--)
    {
        max = 0;
        for(int j=0;j<i;j++)
        {
            if(score[j]>score[max]) max=j;
            
            t = score[max];
            score[max] = score[i-1];
            score[i-1] = t;
            
            ArrSwap(people,max,i-1);
        }
    }
    //Print("Sort pass");
    //Mout(people,20);
    
    double sumtot=0;
    for(int i=0;i<Population;i++) sumtot += score[i];
    double newscore[];
    ArrayResize(newscore,Population);
    for(int i=0;i<Population;i++)
    {
        newscore[i] = (score[Population - 1 - i]/sumtot);
        //Print(newscore[i]);
    }
    //Print("PBT pass");
    //ArrayRemove(score,0);
    
    int selected[];
    ArrayResize(selected,SelectNum);
    FPSelection(newscore,selected);  
    ArraySort(selected);
    //Print("FPS pass");
    
    for(int i=0;i<SelectNum;i++)
    {
        ArrSwap(people,i,selected[i]);
    }
}

//...........................+------------------------------------------------------------------+
//...........................|                            Reproduce                             |
//...........................+------------------------------------------------------------------+
void GA::Reproduce(Realdata &people[])
{
    //be ham rikhtan
    int j = 0;
    for(int i = 0;i<SelectNum;i++)
    {
        j = RandomRangei(i,SelectNum);
        
        ArrSwap(people,i,j);
    }
    
    double ch[];
    
    for(int i = SelectNum;i<(SelectNum*2);i+=2)
    {
        j = RandomRangei(0,4);
        
        if(j<2)
        {
            CrossReal(people[i-SelectNum],people[i-SelectNum+1],people[i],people[i+1],Decimal);
        }
        else
        {
            CrossReal(people[i-SelectNum],people[i-SelectNum+1],people[i],people[i+1],Decimal,true);
        }
    }
    
    //Mout(people,20);
    
    for(int i = (SelectNum*2);i<(SelectNum*3);i+=2)
    {
        MutatReal(people[i-(SelectNum*2)],people[i-(SelectNum*2)+1],people[i],people[i+1],Decimal);
    }
}

void GA::Reproduce(Intdata &people[])
{
    //be ham rikhtan
    int j = 0;
    for(int i = 0;i<SelectNum;i++)
    {
        j = RandomRangei(i,SelectNum);
        
        ArrSwap(people,i,j);
    }
    
    double ch[];
    
    for(int i = SelectNum;i<(SelectNum*2);i+=2)
    {
        j = RandomRangei(0,4);
        
        if(j<2)
        {
            CrossInt(people[i-SelectNum],people[i-SelectNum+1],people[i],people[i+1],Decimal);
        }
        else
        {
            CrossInt(people[i-SelectNum],people[i-SelectNum+1],people[i],people[i+1],true);
        }
    }
    
    //Mout(people,20);
    
    for(int i = (SelectNum*2);i<(SelectNum*3);i+=2)
    {
        MutatInt(people[i-(SelectNum*2)],people[i-(SelectNum*2)+1],people[i],people[i+1]);
    }
}
//...........................+------------------------------------------------------------------+
//...........................|                               solve                              |
//...........................+------------------------------------------------------------------+
void GA::Solve(int &MaxR[],int &MinR[],int &ans[],ushort StopSame=50)
{
    if(inps == 0)
    {
        Print("Genetic Algorithm : Please Enter settings !!! :( ");
        return;
    }
    
    Intdata people[],last;
    ushort sameans = 0;
    
    ArrayResize(people,Population);
    ArrayResize(last.idata,inps);
    
    ArrayResize(Minimummsi,inps);
    ArrayResize(Maximummsi,inps);
    ZeroMemory(Minimummsi);
    ZeroMemory(Maximummsi);
    
    for(int i=0;i<inps;i++)
    {
        last.idata[i] = 0;
        Maximummsi[i] = MaxR[i];
        Minimummsi[i] = MinR[i];
    }
    
    for(int i=0;i<Population;i++)
    {
        ArrayResize(people[i].idata,inps);
    }
    
    RandomMaker(people,0,MaxR,MinR);
    //Mout(people,Population);
    
    for(int counter=0;counter<Stop;counter++)
    {
        //Print("Step " + IntegerToString(counter+1) + " Initated");
        Comment("Gen " , IntegerToString(counter+1) , " Initated");
        Selection(people);
        //Mout(people,16);
        
        if(Equality(people[0],last))
        {
            sameans++;
            if(sameans >= StopSame)
            {
                Print("Stop same");
                break;
            }
        }
        else
        {
            for(int i=0;i<inps;i++) last.idata[i] = people[0].idata[i];
            sameans = 0;
        }
        Makezero(people,SelectNum);
        
        //Mout(people,6);
        
        Reproduce(people);

        //Mout(people,50);
        
        RandomMaker(people,SelectNum * 3,MaxR,MinR);
        
        //Mout(people,24);
    }
    
    Selection(people);
    ArrayResize(ans,inps);
    for(int i=0;i<inps;i++)
    {
        ans[i] = people[0].idata[i];
    }
}

void GA::Solve(double &MaxR[],double &MinR[],double &ans[],ushort StopSame=50)
{
    if(inps == 0)
    {
        Print("Genetic Algorithm : Please Enter settings !!! :( ");
        return;
    }
    
    Realdata people[],last;
    ushort sameans=0;
    
    ArrayResize(people,Population);
    ArrayResize(last.ddata,inps);
    
    ArrayResize(Minimummsd,inps);
    ArrayResize(Maximummsd,inps);
    ZeroMemory(Minimummsd);
    ZeroMemory(Maximummsd);
    
    for(int i=0;i<inps;i++)
    {
        last.ddata[i] = 0;
        Maximummsd[i] = MaxR[i];
        Minimummsd[i] = MinR[i];
    }
    
    for(int i=0;i<Population;i++)
    {
        ArrayResize(people[i].ddata,inps);
    }
    
    //Print(ArraySize(people) + " // " + ArraySize(people[1].ddata));
    
    RandomMaker(people,0,MaxR,MinR);
    //Mout(people,24);
    
    for(int counter=0;counter<Stop;counter++)
    {
        //Comment("Gen " , IntegerToString(counter+1) , " Initated");
        //Print("Step " + IntegerToString(counter));
        Selection(people);
        
        if(Equality(people[0],last))
        {
            sameans++;
            if(sameans >= StopSame) break;
        }
        else
        {
            for(int i=0;i<inps;i++) last.ddata[i] = people[0].ddata[i];
            sameans = 0;
        }
        
        Makezero(people,SelectNum);
        
        //Mout(people,6);
        
        Reproduce(people);
        
        //Mout(people,24);
        
        RandomMaker(people,SelectNum * 3,MaxR,MinR);
        
        //Mout(people,24);
    }
    
    Selection(people);
    ArrayResize(ans,inps);
    for(int i=0;i<inps;i++)
    {
        ans[i] = people[0].ddata[i];
    }
}
//...........................+------------------------------------------------------------------+
//...........................|                          Random generator                        |
//...........................+------------------------------------------------------------------+
void GA::RandomMaker(Intdata &randarr[],int startfrom,int &Maxes[],int &Mins[])
{
    for(int i=startfrom;i<Population;i++)
    {
        do{
            for(int j=0;j<inps;j++)
            {
                randarr[i].idata[j] = RandomRangei(Mins[j],Maxes[j]);
            }
        }while(Initialcondition(randarr[i].idata) == false);
    }
}

void GA::RandomMaker(Realdata &randarr[],int startfrom,double &Maxes[],double &Mins[])
{   
    for(int i=startfrom;i<Population;i++)
    {
        do {
            for(int j=0;j<inps;j++)
            {
                randarr[i].ddata[j] = RandomRanged(Mins[j],Maxes[j]);
            }
        }while(Initialcondition(randarr[i].ddata) == false);
    }
}
//...........................+------------------------------------------------------------------+
//...........................|               Fitness proportionate selection                    |
//...........................+------------------------------------------------------------------+
void GA::FPSelection(double &Scores[],int &Picks[])
{
    double rndNumber,sumall=1.0;
    double offset;
    int n = 0;
    
    ArrayResize(Picks,SelectNum);

    do
    {
        rndNumber = RandomRanged(0.0,sumall);
        offset = 0.0;
        for (int i = 0; i < Population; i++) 
        {
            offset += Scores[i];
            if (rndNumber < offset) 
            {
                Picks[n] = i;
                sumall -= Scores[i];
                Scores[i] = 0;
                n++;
                break;
            }
        }
    }while(n<SelectNum);
}
//...........................+------------------------------------------------------------------+
//...........................|                             Printing                             |
//...........................+------------------------------------------------------------------+
void GA::Mout(Realdata &people[],int cc)
{
    string p = "";
    for(int i=0;i<cc;i++)
    {
        for(int j=0 ;j<inps;j++)
        {
            p += DoubleToString(people[i].ddata[j]) + " // ";
        }
        if(i==SelectNum) Print("------------ *** ------------");
        Print(p);
        p = "";
    }
    
    Print("##################################################");
}
void GA::Mout(Intdata &people[],int cc)
{
    string p = "";
    for(int i=0;i<cc;i++)
    {
        for(int j=0 ;j<inps;j++)
        {
            p += IntegerToString(people[i].idata[j]) + " // ";
        }
        p += DoubleToString(score[i]);
        if(i==SelectNum) Print("------------ *** ------------");
        Print(p /*+ Initialcondition(people[i].idata)*/);
        p = "";
    }
    
    Print("##################################################");
}