class Clustering
{
  boolean UseMoore=false;
  boolean VisualClust=false;
  boolean VisualBorders=false;
  boolean VisualDimens=false;
  
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
    println("Clustering 'device' for "+N+"x"+M+" is ready.");
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
    float max=0;
    for(int i=0;i<LastClBorderReg-1;i++)
    for(int j=i+1;j<LastClBorderReg;j++)
    {
      float X=float(RegX[i])-RegX[j];
      float Y=float(RegY[i])-RegY[j];
      float pom=X*X+Y*Y;
      if(pom>0)
      {
        pom=sqrt(pom);
        if(pom>max)
        {
            max=pom;
            if(VisualDimens)
              line(RegX[i]*S,RegY[i]*S,RegX[j]*S,RegY[j]*S);
        }
      } 
    }
    return max;
  }
  
  void Calculate()
  { //Kopiowanie
    for(int i=0;i<K.length;i++)
      for(int j=0;j<K[i].length;j++)
         K[i][j]=Bak[i][j];
         
    //Wypełnianie     
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
         float Diam=LastClDiameter();
      }
         
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
