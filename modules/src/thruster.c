#define DEBUG_MODULE "THRUSTER"

#include "stm32f10x_conf.h"
#include "FreeRTOS.h"
#include "task.h"

#include "math.h"

#include "system.h"
#include "pm.h"
#include "thruster.h"
#include "thrustcommander.h"
#include "motors.h"
#include "log.h"
#include "pid.h"
#include "ledseq.h"
#include "param.h"
#include "ms5611.h"
#include "debug.h"

uint16_t thrust1;
uint16_t thrust2;
uint16_t thrust3;
uint16_t thrust4;

uint32_t motorPowerM4;
uint32_t motorPowerM2;
uint32_t motorPowerM1;
uint32_t motorPowerM3;

#define THRUST_UPDATE_FREQ  500

static bool isInit;

static uint16_t limitThrust(int32_t value);
static void thrusterTask(void* param);
static void setThrust(const uint16_t thrust1val, const uint16_t thrust2val,
                      const uint16_t thrust3val, const uint16_t thrust4val);

void thrusterInit(void)
{
  if(isInit)
    return;

  motorsInit();

  xTaskCreate(thrusterTask, (const signed char * const)"THRUSTER",
              2*configMINIMAL_STACK_SIZE, NULL, /*Piority*/2, NULL);

  isInit = TRUE;
}

bool thrusterTest(void)
{
  bool pass = true;

  pass &= motorsTest();

  return pass;
}

static void thrusterTask(void* param)
{
  //DEBUG_PRINT("TRHUSTER TASK AWAKENED\n");
  uint32_t lastWakeTime;

  vTaskSetApplicationTaskTag(0, (void*)TASK_THRUSTER_ID_NBR);
  systemWaitStart();
  lastWakeTime = xTaskGetTickCount();
  while(1)
  {
    vTaskDelayUntil(&lastWakeTime, F2T(THRUST_UPDATE_FREQ)); // 500Hz
    thrustCommanderGetThrust(&thrust1,&thrust2,&thrust3,&thrust4);
    setThrust(thrust1,thrust2,thrust3,thrust4);
    //DEBUG_PRINT("TRHUST SET %d %d %d %d\n",thrust1,thrust2,thrust3,thrust4);
  }
}

static void setThrust(const uint16_t thrust1val, const uint16_t thrust2val,
                      const uint16_t thrust3val, const uint16_t thrust4val)
{
  motorPowerM1 = limitThrust(thrust1val);
  motorPowerM2 = limitThrust(thrust2val);
  motorPowerM3 = limitThrust(thrust3val);
  motorPowerM4 = limitThrust(thrust4val);
  motorsSetRatio(MOTOR_M1, motorPowerM1);
  motorsSetRatio(MOTOR_M2, motorPowerM2);
  motorsSetRatio(MOTOR_M3, motorPowerM3);
  motorsSetRatio(MOTOR_M4, motorPowerM4);
}

static uint16_t limitThrust(int32_t value)
{
  if(value > UINT16_MAX)
  {
    value = UINT16_MAX;
  }
  else if(value < 0)
  {
    value = 0;
  }

  return (uint16_t)value;
}