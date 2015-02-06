#include <stdio.h>
#include <math.h>

static float rpyX[3];
static float rpyN[3];
static float omegaX[3];
static float omegaN[3];

static float IMURotMatrix[3][3] = {{0.7071, -0.7071, 0},
                                   {0.7071,  0.7071, 0},
                                   {0,       0,      1}};

static void rotateGyro(float* omega, float* rotomega)
{
  // IMURotMatrix*omega
  int i;
  int j;
  for (i=0;i<3;i++)
  {
    rotomega[i] = 0;
    for (j=0;j<3;j++)
    {
      rotomega[i] += IMURotMatrix[i][j]*omega[j];
    }
  }
}

static void rotateRPY(float* rpy, float* rotrpy)
{

  float rotmat[3][3]; 
  rotmat[0][0] = cos(rpy[2])*cos(rpy[1]);
  rotmat[0][1] = cos(rpy[2])*sin(rpy[1])*sin(rpy[0])-sin(rpy[2])*cos(rpy[0]);
  rotmat[0][2] = cos(rpy[2])*sin(rpy[1])*cos(rpy[0])+sin(rpy[2])*sin(rpy[0]);
  rotmat[1][0] = sin(rpy[2])*cos(rpy[1]);
  rotmat[1][1] = sin(rpy[2])*sin(rpy[1])*sin(rpy[0])+cos(rpy[2])*cos(rpy[0]);
  rotmat[1][2] = sin(rpy[2])*sin(rpy[1])*cos(rpy[0])-cos(rpy[2])*sin(rpy[0]);
  rotmat[2][0] = -sin(rpy[1]);
  rotmat[2][1] = cos(rpy[1])*sin(rpy[0]);
  rotmat[2][2] = cos(rpy[1])*cos(rpy[0]);

  // rotmat*IMURotMatrix
  float rotmatR[3][3];
  int i;
  int j;
  int k;
  for (i=0;i<3;i++)
  {
    for (j=0;j<3;j++)
    {
      rotmatR[i][j] = 0;
      for (k=0;k<3;k++)
      {
        rotmatR[i][j] += rotmat[i][k]*IMURotMatrix[k][j];
      }
    }
  }

  // rotmat2rpy
  rotrpy[0] = atan2(rotmatR[2][1],rotmatR[2][2]);
  rotrpy[1] = atan2(-rotmatR[2][0],sqrt(pow(rotmatR[2][1],2) + pow(rotmatR[2][2],2)));
  rotrpy[2] = atan2(rotmatR[1][0],rotmatR[0][0]);
}

int array_eq(float const *x, float const *y, int n, float eps)
{
    int i;
    for (i=0; i<n; i++)
        if (fabs(x[i] - y[i]) > eps)
            return 0;
    return 1;
}

int test1(void)
{

  float rpys[5][3] = {
    {-0.9426,   -1.9063,   -1.5640},
    {0.7291,   -0.1678,   -0.9321},
    {2.0787,    0.5357,    0.3124},
    {2.6213,   -1.3456,    1.6160},
    {1.5942,   -0.7512,    0.4261}
  };
  float omegas[5][3] = {
    {-84.8291,  -89.2100,    6.1595},
    {55.8334,   86.8021,  -74.0188},
    {13.7647,   -6.1219,  -97.6196},
    {-32.5755,  -67.5635,   58.8569},
    {-37.7570,    5.7066,  -66.8703}
  };
  float rotrpys[5][3];
  float rotomegas[5][3];
  float crotrpys[5][3] = {
    {-1.954478153761925,  -1.027571868934493,  -0.630103580058686},
    {0.440214467557604,  -0.621863318529118,  -0.226089611057829},
    {2.009120029973903,  -0.171189617196501,  -0.044104238120300},
    {-1.877985854666314,  -0.875318184331965,  -0.247290835422163},
    {2.036290551651717,  -1.532682829893402,  -0.023124096893764},
  };
  float crotomegas[5][3] = {
    {3.0977343900000,  -123.0630476100000,   6.1595000000000},
    {-21.8979677700000,   100.8575620500000,  -74.0188000000000},
    {14.0618148600000,   5.4042238800000,  -97.6196000000000},
    {24.7400148000000,  -070.8082869000000,   58.8569000000000},
    {-30.7331115600000,  -022.6628378400000,  -66.8703000000000},
  };

  int i;
  int errorcount = 0;
  for (i=0;i<5;i++)
  {
    rotateRPY(rpys[i],rotrpys[i]);
    rotateGyro(omegas[i],rotomegas[i]);
    if (array_eq(rotrpys[i],crotrpys[i],3,1E-5)==0)
    {
      errorcount += 1;
      printf("Expected: \t%f %f %f\nGot: \t\t%f %f %f\n\n",crotrpys[i][0],crotrpys[i][1],crotrpys[i][2],rotrpys[i][0],rotrpys[i][1],rotrpys[i][2]);
    }
    if (array_eq(rotomegas[i],crotomegas[i],3,1E-5)==0)
    {
      errorcount += 1;
      printf("Expected: \t%f %f %f\nGot: \t\t%f %f %f\n\n",crotomegas[i][0],crotomegas[i][1],crotomegas[i][2],rotomegas[i][0],rotomegas[i][1],rotomegas[i][2]);
    }
  }

  return errorcount;
}

int main()
{
  int pass = 0;
  pass += test1(); 
  printf("Tests failed: %i\n",pass);
  if (pass>0)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}