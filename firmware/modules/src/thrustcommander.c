#define DEBUG_MODULE "THRUSTCOMMANDER"

#include "stm32f10x_conf.h"

#include "FreeRTOS.h"
#include "task.h"

#include "thrustcommander.h"
#include "crtp.h"
#include "configblock.h"
#include "param.h"
#include "debug.h"

#define MIN_THRUST  10000
#define MAX_THRUST  60000

struct ThrustCrtpValues
{
  uint16_t thrust1;
  uint16_t thrust2;
  uint16_t thrust3;
  uint16_t thrust4;
} __attribute__((packed));

static struct ThrustCrtpValues targetVal[2];
static bool isInit;
static int side=0;
static uint32_t lastUpdate;
static bool isInactive;

static void thrustCommanderCrtpCB(CRTPPacket* pk);
static void thrustCommanderWatchdogReset(void);

void thrustCommanderInit(void)
{
  if(isInit)
    return;

  crtpInit();
  crtpRegisterPortCB(CRTP_PORT_COMMANDER, thrustCommanderCrtpCB);

  lastUpdate = xTaskGetTickCount();
  isInactive = TRUE;
  isInit = TRUE;
}

bool thrustCommanderTest(void)
{
  crtpTest();
  return isInit;
}

static void thrustCommanderCrtpCB(CRTPPacket* pk)
{
  //DEBUG_PRINT("THRUST PACKET RECEIVED\n");
  targetVal[!side] = *((struct ThrustCrtpValues*)pk->data);
  side = !side;
  thrustCommanderWatchdogReset();
}

void thrustCommanderWatchdog(void)
{
  int usedSide = side;
  uint32_t ticktimeSinceUpdate;

  ticktimeSinceUpdate = xTaskGetTickCount() - lastUpdate;

  if (ticktimeSinceUpdate > THRUSTCOMMANDER_WDT_TIMEOUT_SHUTDOWN)
  {
    targetVal[usedSide].thrust1 = 0;
    targetVal[usedSide].thrust2 = 0;
    targetVal[usedSide].thrust3 = 0;
    targetVal[usedSide].thrust4 = 0;
    isInactive = TRUE;
  }
  else
  {
    isInactive = FALSE;
  }
}

static void thrustCommanderWatchdogReset(void)
{
  lastUpdate = xTaskGetTickCount();
}

uint32_t thrustCommanderGetInactivityTime(void)
{
  return xTaskGetTickCount() - lastUpdate;
}

void thrustCommanderGetThrust(uint16_t* thrust1, uint16_t* thrust2, uint16_t* thrust3, uint16_t* thrust4)
{
  int usedSide = side;

  uint16_t rawThrust1 = targetVal[usedSide].thrust1;
  if (rawThrust1 > MIN_THRUST) {
    *thrust1 = rawThrust1;
  }
  else
  {
    *thrust1 = 0;
  }
  if (rawThrust1 > MAX_THRUST)
  {
    *thrust1 = MAX_THRUST;
  }

  uint16_t rawThrust2 = targetVal[usedSide].thrust2;
  if (rawThrust2 > MIN_THRUST)
  {
    *thrust2 = rawThrust2;
  }
  else
  {
    *thrust2 = 0;
  }
  if (rawThrust2 > MAX_THRUST)
  {
    *thrust2 = MAX_THRUST;
  }

  uint16_t rawThrust3 = targetVal[usedSide].thrust3;
  if (rawThrust3 > MIN_THRUST)
  {
    *thrust3 = rawThrust3;
  }
  else
  {
    *thrust3 = 0;
  }
  if (rawThrust3 > MAX_THRUST)
  {
    *thrust3 = MAX_THRUST;
  }

  uint16_t rawThrust4 = targetVal[usedSide].thrust4;
  if (rawThrust4 > MIN_THRUST)
  {
    *thrust4 = rawThrust4;
  }
  else
  {
    *thrust4 = 0;
  }
  if (rawThrust4 > MAX_THRUST)
  {
    *thrust4 = MAX_THRUST;
  }

  thrustCommanderWatchdog();
}