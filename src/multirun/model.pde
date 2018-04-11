// Separated Model class which include model synamics and control parameters 
//////////////////////////////////////////////////////////////////////////////////////

int StepCounter=0;  //Current step
int STOPAfter=100; //How many steps in one run?

//Control parameters for the model
float RatioA=0.25; //How many "reds" in the array
float RatioB=0.0; //How many individualist in the array
float Noise=0; //some noise as a ratio of -MaxStrengh..MaxStrengh
float Bias=0;  //Positive BIAS promote "ones", negative promote "zeros" (scaled by MaxStrenght!)

int   N=10;       //array side
float MaxStrengh=100;//have not to be 0 or negative!
int   Distribution=0;//-5;//-6;//1 and -1 means flat, 0 means no difference, negative are Pareto, positive is Gaussian

float log10 (float x) // Calculates the base-10 logarithm of a number
{
  return (log(x) / log(10));
}

class TheModel
{
  //2D "World" of individuals
  int A[][]; // new int[N][N];     //Attitudes  
  float P[][]; // new float[N][N];  //Strengh or "power"
  boolean B[][];// new boolean[N][N]; //Individualism
  
  TheModel()
  {
      A = new int[N][N];     //Attitudes  
      P = new float[N][N];   //Strengh or "power"
      B = new boolean[N][N]; //Individualism
  }
  
float RandomGaussPareto(int Dist)// when Dist is negative, it is Pareto, when positive, it is Gauss
{
  if(Dist>0)
  {
    float s=0;
    for(int i=0;i<Dist;i++)
      s+=random(0,1);
    return s/Dist;  
  }
  else
  {
    float s=1;
    for(int i=Dist;i<0;i++)
       s*=random(0,1);
    return s;
  }
}

//int   Distribution=1;//1 means flat
void DoStrenghInitialisation()
{
  for(int i=0;i<N;i++)
   for(int j=0;j<N;j++)
   {
     if(Distribution!=0)
       P[i][j]=1+RandomGaussPareto(Distribution)*(MaxStrengh-1);//Not below one !!!
       else
       P[i][j]=MaxStrengh;
   }
}

void DoModelInitialisation()
{
  Nonconformist=0;
  Conformist=0;
  
  println("MODEL INITIALISATION... " 
    + RatioA +'\t' //How many "reds" in the array
    + RatioB +'\t' //How many individualist in the array
    + Noise +'\t'//some noise as a ratio of -MaxStrengh..MaxStrengh
    + Bias  +'\t'//Positive BIAS promote "ones", negative promote "zeros" (scaled by MaxStrenght!)
    + N     +'\t'  //array side
    + MaxStrengh +'\t'//have not to be 0 or negative!
    + Distribution//-5;//-6;//1 and -1 means flat, 0 means no difference, negative are Pareto, positive is Gaussian
       );
       
  for(int i=0;i<N;i++)
   for(int j=0;j<N;j++)
    if( random(0,1) < RatioA )
     A[i][j]=1;
    else
     A[i][j]=0;
     
  for(int i=0;i<N;i++)
   for(int j=0;j<N;j++)
    if( random(0,1) < RatioB )
    {
     B[i][j]=true;
     Nonconformist++;
    }
    else
    {
     B[i][j]=false;
     Conformist++;
    } 
    
   DoStrenghInitialisation(); 
   
   StepCounter=0; //Ready to first/next run
   Dynamics=0;//How many changes?
   ConfDynamics=0;
   NConDynamics=0;
   
   println("DONE");
}

void DoMonteCarloStep()
{
   Dynamics=0;//How many changes?
   ConfDynamics=0;
   NConDynamics=0;
   
   for(int a=0;a<N*N;a++) //as many times as number of cells 
   {
     int i=int(random(N));
     int j=int(random(N));
     
     float support=0;
     for(int m=i-1;m<=i+1;m++)
      for(int n=j-1;n<=j+1;n++)
      {
        int p=(m+N)%N;
        int r=(n+N)%N;
        if(A[p][r]==A[i][j])
           support+=P[p][r];
           else
           support-=P[p][r];
      }
      
     support+=Noise*random(-MaxStrengh,MaxStrengh);
     
     if(Bias!=0) //Bias=0;  //Positive BIAS promote "ones", negative promote "zeros"
      if( Bias>0 && A[i][j]==1) //Support for agent which is belonged to "ones" 
       support+=Bias*MaxStrengh;
       else
       if( Bias<0 && A[i][j]==0) //Support for agent which is belonged to "zeros" 
           support+=(-Bias)*MaxStrengh; 
       
     
     if(B[i][j])
     {
      if(support>=0)
      {
      Dynamics++;
      NConDynamics++;
      if(A[i][j]==1) //make switch
       A[i][j]=0;
       else
       A[i][j]=1;
      }
     }
     else
     if(support<0)
      {
      Dynamics++;
      ConfDynamics++;
      if(A[i][j]==1)//switch
       A[i][j]=0;
       else
       A[i][j]=1;
      }    
   }
   
   Dynamics/=(N*N);
   NConDynamics/=Nonconformist;
   ConfDynamics/=Conformist;   
   
   StepCounter++; //Step done
}


void DoDrawFill() //Visualize the cells or agents
{
  for(int i=0;i<N;i++)
  {
   for(int j=0;j<N;j++)
   {
    if(A[i][j]==1)
      fill(255*P[i][j]/MaxStrengh,0,0);
    else
      fill(255*P[i][j]/MaxStrengh);
         
    rect(i*S,j*S,S,S);
    if(RatioB>0)
    {
     if(B[i][j])
       fill(0,255,0);
     else
       fill(0,0,255);
     ellipse(i*S+S/2,j*S+S/2,S/2,S/2);
    }
   }
 }  
}


void DoDrawSizeLog() //Visualize the cells or agents
{
  float Max=log10(MaxStrengh);
  for(int i=0;i<N;i++)
  {
   for(int j=0;j<N;j++)
   {
    if(A[i][j]==1)
      fill(255*P[i][j],0,0);
    else
      fill(255*P[i][j]);
     
    if(B[i][j])
      stroke(0,255,0);
    else
      stroke(0,0,255);  
         
    int SofThis=int(S*(log10(P[i][j])/Max)+1);
    rect(i*S,j*S,SofThis,SofThis);
   }
 }  
}

}
