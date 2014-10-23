#define DEBUG_MODULE "SUPERVISOR"

#include "FreeRTOS.h"
#include "task.h"

#include "supervisor.h"
#include "crtp.h"
#include "debug.h"

struct SupervisorCrtpCommand
{
  uint16_t mode; // 0 = stabilizer, 1 = offboardctrl
} __attribute__((packed));

static struct SupervisorCrtpCommand* modeCmd;
static bool isInit;

static void SupervisorCrtpCB(CRTPPacket* pk);

void supervisorInit(void)
{
  if(isInit)
    return;

  crtpInit();
  crtpRegisterPortCB(CRTP_PORT_SUPERVISOR, SupervisorCrtpCB);

  xTaskCreate(supervisorTask, (const signed char * const)"SUPERVISOR",
              2*configMINIMAL_STACK_SIZE, NULL, /*Piority*/2, NULL);

  isInit = TRUE;
}

bool supervisorTest(void)
{
  crtpTest();
  return isInit;
}

static void SupervisorCrtpCB(CRTPPacket* pk)
{
  modeCmd = *((struct SupervisorCrtpMode*)pk->data);
}

// supervisor task here
// checks that the current mode is the one in modeCmd
// stop/starts stabilizerTask and offboardCtrlTask
