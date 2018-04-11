class Clustering
{
  //Parametry sterujące wizualizacją badań klastrów
  boolean UseMoore=false;
  boolean VisualClust=false;
  boolean VisualBorders=false;
  boolean VisualDiameters=false;
  
  //Zmienne zbierajace dane statystyczne i określające ich nazwy w pliku wyjściowym
  //Za KLASTER uznawana jest grupa co najmniej 2 komórek w tym samym kolorze!
  String  NofClustersHead="NofClusters"; //Liczba KLASTRÓW
  int     NofClusters=0;
  String  MnClustersSizeHead="MnClustersSize";//Powierzchnia klastrów
  double  MnClustersSize=0; //średnia może być z ważną częścią ułamkową
  String  MaxClustersSizeHead="MaxClustersSize";
  int     MaxClustersSize=0;
  String  MinClustersSizeHead="MinClustersSize";
  int     MinClustersSize=111111111;//Dziwna liczba żeby było podejrzane jak zostanie
  String  MnClustersDiamHead="MnClustersDiam";//Średnica klastrów
  double  MnClustersDiam=0;
  String  MaxClustersDiamHead="MaxClustersDiam";
  float   MaxClustersDiam=0;
  String  MinClustersDiamHead="MinClustersDiam";
  float   MinClustersDiam=111111111;//Dziwna liczba żeby było podejrzane jak zostanie
  String  MnClustersBRatHead="MnClustersBRat";//Udział brzegu w całości powierzchi klastra
  double  MnClustersBRat=0;
  String  MaxClustersBRatHead="MaxClustersBRat";
  float   MaxClustersBRat=0;
  String  MinClustersBRatHead="MinClustersBRat";
  float   MinClustersBRat=111111111;//Dziwna liczba żeby było podejrzane jak zostanie;
  
  String  HeaderStr(String T/*Separator*/)
  //Generator nagłówka danych klastrowych
  {
    return NofClustersHead+T
    +MnClustersSizeHead+T
    +MaxClustersSizeHead+T
    +MinClustersSizeHead+T
    +MnClustersDiamHead+T
    +MaxClustersDiamHead+T
    +MinClustersDiamHead+T
    +MnClustersBRatHead+T
    +MaxClustersBRatHead+T
    +MinClustersBRatHead;
  }
  
  String  StatsStr(String T/*Separator*/)
  //Generator nagłówka danych klastrowych
  {
    return NofClusters+T
    +MnClustersSize+T
    +MaxClustersSize+T
    +MinClustersSize+T
    +MnClustersDiam+T
    +MaxClustersDiam+T
    +MinClustersDiam+T
    +MnClustersBRat+T
    +MaxClustersBRat+T
    +MinClustersBRat;
  }
    
  //Zmienne służące rejestracji itd
  int[][] K; 
  int[][] Bak;
  int N,M;
  
  int LastClusterSize=0; //Ile komórek w ostatnio zbadanym klastrze
  int LastClBorderReg=0; //Ile komórek obrzeża w ostatnio zbadanym klastrze
  
  int RegX[];
  int RegY[];
  
  Clustering(int[][] P)
  {
    Bak=P;              //Zapamiętaj gdzie jest tablica źródłowa //<>//
    N=P.length;
    M=P[0].length;
    K = new int[N][M];  //Stwórz miejsce na kopie
    RegX = new int[M*N]; //I miejsce na współrzedne punktów. Trochę duże
    RegY = new int[M*N]; 
    println("Clustering calculator for "+N+"x"+M+" is ready.");
  }

  void ResetRegistry()
  {
    LastClusterSize=0;
    LastClBorderReg=0;
  }
   
  boolean Allien(int ix, int iy,int col)
  {
      return Bak[ix][iy]!=col;
      //return true;
  }
    
  void RegistryCell(int x, int y,int col,boolean eight)
  {      
    boolean border=false;
    LastClusterSize++;
    
    if(Allien((x-1+N)%N,   y ,col)
    || Allien( x  ,(y-1+M)%M ,col)
    || Allien( x  ,(y+1)%M   ,col)
    || Allien((x+1)%N,     y ,col) )
    border=true;
    
    if(!border && eight)
    if(Allien((x-1+N)%N,(y-1+M)%M,col)
    || Allien((x-1+N)%N,(y+1)%M  ,col)
    || Allien((x+1)%N,(y-1+M)%M  ,col)
    || Allien((x+1)%N,(y+1)%M   ,col) )
    border=true;
    
    if(border)
    {
      RegX[LastClBorderReg]=x;
      RegY[LastClBorderReg]=y;
      LastClBorderReg++;
    }
  }
  
  void Seed8(int i,int j,int oldcol,int newcol)
  {
    if(K[i][j]!=oldcol) return; //Warunek stopu
    K[i][j]=newcol;
    RegistryCell(i,j,oldcol,true);
    
    Seed8((i-1+N)%N,(j-1+M)%M,oldcol,newcol);
    Seed8((i-1+N)%N,   j    ,oldcol,newcol);
    Seed8((i-1+N)%N,(j+1)%M,oldcol,newcol);
  
    Seed8( i  ,(j-1+M)%M ,oldcol,newcol);
    Seed8( i  ,(j+1)%M   ,oldcol,newcol);
    
    Seed8((i+1)%N,(j-1+M)%M,oldcol,newcol);
    Seed8((i+1)%N,     j  ,oldcol,newcol);
    Seed8((i+1)%N,(j+1)%M,oldcol,newcol);
  }
  
  void Seed4(int i,int j,int oldcol,int newcol)
  {
    if(K[i][j]!=oldcol) return; //Warunek stopu
    K[i][j]=newcol;
    RegistryCell(i,j,oldcol,false);
    
    Seed4((i-1+N)%N,   j  ,oldcol,newcol);
    Seed4( i  , (j-1+M)%M ,oldcol,newcol);
    Seed4( i  , (j+1)%M   ,oldcol,newcol);
    Seed4((i+1)%N,     j  ,oldcol,newcol);
  }
  
  void LastClDrawBorder()
  {
    if(LastClBorderReg<=1) return;
    fill(128,128,0,100);
    stroke(0,0);
    //println(LastClBorderReg);
    for(int i=0;i<LastClBorderReg;i++)
    {
      rect(RegX[i]*S,RegY[i]*S,S,S);
    }
    stroke(0,255);
  }
  
  float LastClDiameter()
  {
    boolean ThrTorus=false;
    float max=0;//Maksymalna "średnica"
    int imax=-1;//od którego
    int jmax=-1;//do którego agenta
   // sprytna podwójna pętla: 
   // for(int i=0;i<LastClBorderReg-1;i++)
   // for(int j=i+1;j<LastClBorderReg;j++)
   // mniej sprytna podwójna pętla
    for(int i=0;i<LastClBorderReg;i++)
     for(int j=0;j<LastClBorderReg;j++)
     if(i!=j)
    {
      boolean LocalThrTorus=false;
      float X,Y;
      if(RegX[i]>RegX[j])
        X=RegX[i]-RegX[j];
      else
        X=RegX[j]-RegX[i];
        
      if(RegY[i]>RegY[j])  
        Y=RegY[i]-RegY[j];
      else
        Y=RegY[j]-RegY[i];
      
      //Uwzględnienie torusa w liczeniu odległości
      if(X>float(N)/2.0) 
          {X=N-X;LocalThrTorus=true;}
      if(Y>float(M)/2.0) 
          {Y=M-Y;LocalThrTorus=true;}//println("!"+M+" Y:"+Y);
      float pom=X*X+Y*Y;
      if(pom>0)
      {
        pom=sqrt(pom);
        if(pom>max)
        {
            max=pom;
            imax=i;
            jmax=j; 
            ThrTorus=LocalThrTorus;
        }
      } 
    }
    
    if(VisualDiameters && imax!=-1 && jmax!=-1 )
    {
      if(ThrTorus)
       { stroke(0,255,255);fill(0,255,255);}
      else
       { stroke(0,0,0); fill(0,0,0);}
      //println("D:"+max+" X:"+X+" Y:"+Y+" T:"+ThrTorus);
      line(RegX[imax]*S+S/2,RegY[imax]*S+S/2,RegX[jmax]*S+S/2,RegY[jmax]*S+S/2);
      text("d="+max,int(RegX[imax]*S+RegX[jmax]*S)/2,int(RegY[imax]*S+RegY[jmax]*S)/2);
    }
    
    fill(0,0,0); 
    stroke(0,0,0);
    return max;
  }
  
  void Calculate()
  //Oblicza statystyki i wizualizuje w razie potrzeby klastry, ich brzegi i średnice 
  { 
    //Liczba KLASTRÓW
    NofClusters=0;
    //Powierzchnia klastrów
    MnClustersSize=0;
    MaxClustersSize=0;
    MinClustersSize=99999999;//Dziwna liczbażeby było podejrzane jak zostanie
    //Średnica klastrów
    MnClustersDiam=0;
    MaxClustersDiam=0;
    MinClustersDiam=99999999;//Dziwna liczbażeby było podejrzane jak zostanie
    //Udział brzegu w całości powierzchi klastra
    MnClustersBRat=0;
    MaxClustersBRat=0;
    MinClustersBRat=99999999;//Dziwna liczbażeby było podejrzane jak zostanie
    
    //Kopiowanie
    for(int i=0;i<K.length;i++)
      for(int j=0;j<K[i].length;j++)
         K[i][j]=Bak[i][j];
         
    //Szukanie klastrów, liczenie statystyk i automatycznie wypełnianie mapy klastrów     
    int Kolor=1;
    for(int i=0;i<K.length;i++)
      for(int j=0;j<K[i].length;j++)   
      if(K[i][j]>=0) //Jak jeszcze nie jest wypełniony
      {
         ResetRegistry();
         Kolor=(Kolor+1235711)%0xFFFFFF;
         if(UseMoore) //Wypełnia ujemną wersją wybranego koloru 
           Seed8(i,j,K[i][j],-Kolor);
         else
           Seed4(i,j,K[i][j],-Kolor);
         if(VisualBorders) LastClDrawBorder();
         if(LastClusterSize<=1) //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                 continue; //Klastry jednoelelementowe nas nie interesują!
                           //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         float Diam=LastClDiameter();
         //Liczba KLASTRÓW
         NofClusters++;
         //Powierzchnia klastrów
         MnClustersSize+=LastClusterSize;
         if(MaxClustersSize<LastClusterSize) MaxClustersSize=LastClusterSize;
         if(MinClustersSize>LastClusterSize) MinClustersSize=LastClusterSize;
         //Średnica klastrów
         MnClustersDiam+=Diam;
         if(MaxClustersDiam<Diam) MaxClustersDiam=Diam;
         if(MinClustersDiam>Diam) MinClustersDiam=Diam;
         //Udział brzegu w całości powierzchi klastra
         float Ratio=float(LastClBorderReg)/float(LastClusterSize);
         MnClustersBRat+=Ratio;
         if(MaxClustersBRat<Ratio) MaxClustersBRat=Ratio;
         if(MinClustersBRat>Ratio) MinClustersBRat=Ratio;
      }
    
    //Uśrednianie dotychczasowych sum     
    MnClustersSize/=NofClusters;
    MnClustersDiam/=NofClusters;
    MnClustersBRat/=NofClusters;
    
    //Wizualizacja
    if(VisualClust)
     for(int i=0;i<K.length;i++)
      for(int j=0;j<K[i].length;j++)
      {
         int pom=-K[i][j];
         fill(pom & 0x000000FF, (pom & 0x0000FF00)>>8, (pom & 0x00FF0000)>>16,128);
         rect(i*S,j*S,S,S);
      }
  }
}

//***********************************************************************
// 2013 (c) Wojciech Tomasz Borkowski  http://borkowski.iss.uw.edu.pl
//***********************************************************************
