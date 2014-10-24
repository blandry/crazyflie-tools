#define DEBUG_MODULE "SUPERVISOR"

#include "FreeRTOS.h"
#include "task.h"

#include "supervisor.h"
#include "stabilizer.h"
#include "commander.h"
#include "offboardctrl.h"
#include "system.h"
#include "crtp.h"
#include "debug.h"

struct SupervisorCrtpCommand
{
  uint16_t mode; // 0 = stabilizer, 1 = offboardctrl
} __attribute__((packed));

#define MODE_UPDATE_FREQ 500

static struct SupervisorCrtpCommand* modeCmd;
static uint16_t mode;
static bool isInit;
static xTaskHandle stabilizerTaskHandle;
static xTaskHandle offboardCtrlTaskHandle;

static void supervisorCrtpCB(CRTPPacket* pk);
static void supervisorTask(void* param);

void supervisorInit(void)
{
  if(isInit)
    return;

  mode = 0;
  crtpInit();
  offboardCtrlInit();
  commanderInit();
  stabilizerInit();
  crtpRegisterPortCB(CRTP_PORT_SUPERVISOR, supervisorCrtpCB);
  xTaskCreate(supervisorTask, (const signed char * const)"SUPERVISOR",
              2*configMINIMAL_STACK_SIZE, NULL, /*Piority*/2, NULL);
  isInit = TRUE;
}

bool supervisorTest(void)
{
  bool pass = isInit;
  pass &= crtpTest();
  pass &= offboardCtrlTest();
  pass &= commanderTest();
  pass &= stabilizerTest();
  return isInit;
}

static void supervisorCrtpCB(CRTPPacket* pk)
{
  *modeCmd = *((struct SupervisorCrtpCommand*)pk->data);
}

static void supervisorTask(void* param)
{
  vTaskSetApplicationTaskTag(0, (void*)TASK_SUPERVISOR_ID_NBR);
  systemWaitStart();
  uint32_t lastWakeTime = xTaskGetTickCount();
  while(1)
  {
    vTaskDelayUntil(&lastWakeTime, F2T(MODE_UPDATE_FREQ));

    //if (mode==0&&modeCmd->mode==1)
    if (1)
    {

      // stop stabilizer
      if (stabilizerTaskHandle)
      {
        vTaskSuspend(stabilizerTaskHandle);
      }

      // start offboard
      if (!offboardCtrlTaskHandle)
      {
        xTaskCreate(offboardCtrlTask, (const signed char * const)"OFFBOARDCTRL",
                    2*configMINIMAL_STACK_SIZE, NULL, /*Piority*/2, &offboardCtrlTaskHandle);
      }
      else
      {
        vTaskResume(offboardCtrlTaskHandle);
      }

      mode=1;

    }
    //else if (mode==1&&modeCmd->mode==0)
    else
    {

      // stop offboard
      if (offboardCtrlTaskHandle)
      {
        vTaskSuspend(offboardCtrlTaskHandle);
      }

      // start stabilizer
      if (!stabilizerTaskHandle)
      {
        xTaskCreate(stabilizerTask, (const signed char * const)"STABILIZER",
                    2*configMINIMAL_STACK_SIZE, NULL, /*Piority*/2, &stabilizerTaskHandle);
      }
      else
      {
        vTaskResume(stabilizerTaskHandle);
      }

      mode=0;
    }
  }
}
