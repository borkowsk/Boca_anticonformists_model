//Model in extended version - with noise and bias and possible use of strengh
//rearranged for doing automatic repetitions and 1D parameters space walks 
//////////////////////////////////////////////////////////////////////////////////////////

//The main objects used in program
////////////////////////////////////////////////////////
TheModel   MyModel;//All model data and dynamics. Also control parameters are n file Model.pde
Clustering ClStat; //Cluster finding "device"
PrintWriter output;//For writing statistics into disk drive

//REPETITIONS OF THE MODEL 
//(Control varialbles for most nested virtual loop)
////////////////////////////////////////////////////////
int NumberOfRepetitions=100; //How many shoud be done at all
int CurrentRepetition=0;   //On which repetition we currently work 

// 1D parameter walk:
//////////////////////////////////////////////////////
//constants for defining axis of walk (ParameterWalk)
final int WALK_NO=0;
final int WALK_RatioA=1;
final int WALK_RatioB=2;
final int WALK_Noise=3;

//Parameter "virtual loop" control variables
float ParameterStart=0.01;
float ParameterStep=0.01;
float ParameterEnd= 0.45;//A bit more, because of floating point precision. "double" may help, but not always!

int   ParameterWalk=WALK_RatioA;//Parameter walk selector
float ParameterVal=ParameterStart;//and setting the starting value

//For flow and speed control of the program
/////////////////////////////////////////////////////
int M=50;          //How often we draw visualization and calculate statistics. Cant be grater than "STOPAfter" defined in model.pde!
int Frames=100;     //How many frames per sec. we would like(!) to call.
boolean Running=true; //Start simulation immediatelly after program begin to run

//... and for visualization
int S=10;       //cell width & height
int StatusHeigh=15; //For status line below cells
boolean UseLogDraw=false; //On/off of logarithic visualisation
boolean DumpScreens=false;//On/off of frame dumping

//... and for controling program from keyboard
boolean ready=true;//help for do one step at a time

//Statistics counters/variables
/////////////////////////////////////////////////////
int  StartingOnes=0;
int  Ones=0;
int  Zeros=0;
int  ConfOnes=0;
int  NConfOnes=0;
int  ConfZeros=0;
int  NConfZeros=0;
int  Conformist=0;
int  Nonconformist=0;

float Stress=0;
float ConfStress=0;
float NConStress=0;

float Dynamics=0;//How many changes?
float ConfDynamics=0;
float NConDynamics=0;

void setup() //Window and model initialization
{
  println("SETUP...");
  noLoop(); //setup may take a longof time
  //noSmooth(); //For fastest visualization
  //println(param(0)+" "+param(1)+" "+param(2));//"param()" does not work :-(
  
  textSize(StatusHeigh);
  println("required size=",N*S,N*S+StatusHeigh+StatusHeigh/2);
  //size(N*S,N*S+StatusHeigh+StatusHeigh/2);//DOES NOT WORK!
  //size(WinWidth,WinHeigh);//DOES NOT WORK ALSO!?!?!?!?!
  size(1050,1010);
  
  
  if(ParameterStep!=0)//Changing control parameter, using  ParameterVal and ParameterWalk selector 
  {
      println("First assigment of control parameter value: "+ParameterVal);
      AssignParameterValWalk();
  }
  
  MyModel = new TheModel();
  ClStat  = new Clustering(MyModel.A);
  
  String LogName="Ind_"+CtrlParValuesStr("-")+".log";
  output = createWriter(LogName); // Create a new file in the sketch directory
  
  MyModel.DoModelInitialisation();
  
  loop();
  frameRate(Frames); //maximize speed
  println("SETUP FINISHED");
}

void exit() //it is called whenever a window is closed. 
{
  noLoop();        //For to be sure...
  delay(100);      // it is possible to close window when draw() is still working!
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  println("Thank You");
  super.exit(); //What library superclass have to do at exit
} 

void AssignParameterValWalk()
//Changing control parameter, using  ParameterVal and ParameterWalk selector 
{
    switch(ParameterWalk){
            case WALK_RatioA: RatioA=(float)ParameterVal; break;
            case WALK_RatioB: RatioB=(float)ParameterVal; break; //Now we have to force conversion
            case WALK_Noise:  Noise=(float)ParameterVal; break;
            default: break;}
}

void draw() //Running - visualization, statistics and model dynamics
{
  if(StepCounter%M==0 || !Running ) //Do it every M-th step 
  {
    background(128); //Clear the window
    if(UseLogDraw)
        MyModel.DoDrawSizeLog();
    else
        MyModel.DoDrawFill();
    DoStatistics();
    if(DumpScreens) 
        saveFrame("frame-######.png");

  }
  
  if(keyPressed)
  {
    if(ready)
    {
     switch(key){
     case '8': ClStat.UseMoore=true; break;
     case '4': ClStat.UseMoore=false; break;  
     case 'B':            
     case 'b': ClStat.VisualBorders=!ClStat.VisualBorders;break;
     case 'C':            
     case 'c': ClStat.VisualClust=! ClStat.VisualClust; break;
     case 'D':
     case 'd': ClStat.VisualDiameters=!ClStat.VisualDiameters; break;
     case 'S':
     case 's': Running=false; break;
     case 'R': 
     case 'r': Running=true; break;
     }
     ready=false;
    } 
  }
  else ready=true;
 
  if(Running) 
    MyModel.DoMonteCarloStep();
  
  //Very unusual method to loop model thru parameter space
  //We have to make it on that way because there is intrinsic draw loop hardcoded into Processing program! 
  if(Running && STOPAfter<StepCounter) //What to do when particular simulation run stoped?  
  {

    if(ParameterVal >= ParameterEnd
    && CurrentRepetition >= NumberOfRepetitions ) //When are no repetitions and parameter steps left, then stop
    {
        println("No more work to do");
        Running=false;
    }
    else
    {
        println("Step limit achived!"); 
        //DoStatistics();
        CurrentRepetition++;//Next repetition or next parameter value?
        if(CurrentRepetition < NumberOfRepetitions)
        {
          println("Reinitialisation of the model for repetition #"+CurrentRepetition);
          MyModel.DoModelInitialisation();
        }
        else
        {
          ParameterVal+=ParameterStep;//We have to use "double". "Float" type is not enought precise for parameters value manipulation! 
          if(ParameterVal>ParameterEnd)
          {
            println("Parameter walk is finished!");
            Running=false;
          }
          else
          {
            println("New value for control parameter: "+ParameterVal);
            AssignParameterValWalk(); //Changing control parameter, using  ParameterVal and ParameterWalk selector 
            CurrentRepetition=0; //Reset repetition counter
            println("Reinitialisation of the model for repetition #"+CurrentRepetition);
            MyModel.DoModelInitialisation();
          }
        }
    }
  }
}


void Count()
{
  Ones=0;
  Zeros=0;
  Stress=0;
  ConfOnes=0;
  NConfOnes=0;
  ConfZeros=0;
  NConfZeros=0;
  ConfStress=0;
  NConStress=0;
  
  for(int i=0;i<N;i++)
   for(int j=0;j<N;j++)
   {
    if(MyModel.A[i][j]==1)
    {
      if(MyModel.B[i][j])
          NConfOnes++;
      else
          ConfOnes++;
      Ones++;
    }
    else
    {
      if(MyModel.B[i][j])
          NConfZeros++;
      else
          ConfZeros++;
      Zeros++;
    }
    
     int LStress=0;
     for(int m=i-1;m<=i+1;m++)
      for(int n=j-1;n<=j+1;n++)
      {
        int p=(m+N)%N;
        int r=(n+N)%N;
        if(MyModel.A[p][r]!=MyModel.A[i][j])
           LStress++;
      }  
      
      Stress+=LStress/8.0;  
      
      if(MyModel.B[i][j])
          NConStress+=LStress/8.0;
          else
          ConfStress+=LStress/8.0;
   }
   
   Stress/=(N*N);
   NConStress/=Nonconformist;
   ConfStress/=Conformist;
}

void DoStatistics() //Calculate and print statistics,  into text file & maybe also to console
{ 
  if(ParameterVal==ParameterStart 
  && CurrentRepetition==0 
  && StepCounter==0 
  && Running)// Write the headers to the file only once
     output.println("StepCounter\t Dynamics\t ConfDynamics\t NConDynamics\t  Zeros\t  Ones\t ConfZeros\t NConfZeros\t ConfOnes\t NConfOnes\t RealRatioA\t RealRatioB\t Stress\t ConfStress\t NConStress\t frameRate"+"\t "
                   +ClStat.HeaderStr("\t ")+"\t "+CtrlParHeaderStr("\t ")); 

  Count(); //Calculate the after step statistics 
  
  ClStat.Calculate(); //Calculate quite complicate clusters statistics
  //ConfZeros,NConfZeros,ConfOnes,NConfOnes
  String  Stats=StepCounter+"\t "+Dynamics+"\t "+ConfDynamics+"\t "+NConDynamics+"\t "+Zeros+"\t "+Ones+"\t "+ConfZeros+"\t "+NConfZeros+"\t "+ConfOnes+"\t "+NConfOnes+"\t"+((double)(StartingOnes)/((double)(N*N)))+"\t"+((double)(Nonconformist)/((double)(N*N)))+"\t "+Stress+"\t "+ConfStress+"\t "+NConStress+"\t "+frameRate+"\t "
                  +ClStat.StatsStr("\t ")+"\t "+CtrlParValuesStr("\t ");
  fill(0,0,0);            //Color of text (!) on the window
  if(!DumpScreens) 
      text(Stats, 1,S*(N+1)+1);//Print the statistics on the window
  else
      text("Step:"+StepCounter+" Opinions: "+Zeros+" : "+Ones, 1,S*(N+1)+1);
      
  if(Running)
  {
  //  println(Stats);        // Write the statistics to the console
    output.println(Stats); // Write the statistics to the file
  }
}

String CtrlParHeaderStr(String Sep)
{
  String Pom="RatioA"+Sep//=0.5; //How many "reds" in the array
  +"RatioB"+Sep//=0.99; //How many individualist in the array
  +"Noise"+Sep//=1.5; //some noise as a ratio of -MaxStrengh..MaxStrengh
  +"MaxStrengh"+Sep//=1000;//have not to be 0 or negative!
  +"Distribution"+Sep//=0;//-5;//-6;//1 and -1 means flat, 0 means no difference, negative are Pareto, positive is Gaussian
  +"Bias"+Sep
  +"N" + Sep              //=50;       //array side
  +"Repetition" + Sep
  +"from"
  ;
  if(ParameterStep!=0)
    Pom+=Sep+"Walk1D";
  return Pom;
}

String CtrlParValuesStr(String Sep)
{
  String Pom=RatioA+Sep//=0.5; //How many "reds" in the array
  +RatioB+Sep//=0.99; //How many individualist in the array
  +Noise+Sep//=1.5; //some noise as a ratio of -MaxStrengh..MaxStrengh
  +MaxStrengh+Sep//=1000;//have not to be 0 or negative!
  +Distribution+Sep//=0;//-5;//-6;//1 and -1 means flat, 0 means no difference, negative are Pareto, positive is Gaussian
  +Bias+Sep
  +N+Sep//=50;       //array side
  +CurrentRepetition+Sep
  +NumberOfRepetitions
  ;
  if(ParameterStep!=0)
    Pom+=Sep+ParameterStart+"++"+ParameterStep+"="+ParameterEnd+"("+ParameterWalk+")";
  return Pom;
}

//***********************************************************************
// 2013 (c) Wojciech Tomasz Borkowski  http://borkowski.iss.uw.edu.pl
//***********************************************************************