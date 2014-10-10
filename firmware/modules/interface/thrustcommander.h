#ifndef THRUST_COMMANDER_H_
#define THRUST_COMMANDER_H_
#include <stdint.h>
#include <stdbool.h>

#define THRUSTCOMMANDER_WDT_TIMEOUT_SHUTDOWN   M2T(500)

void thrustCommanderInit(void);
bool thrustCommanderTest(void);
void thrustCommanderWatchdog(void);
uint32_t thrustCommanderGetInactivityTime(void);
void thrustCommanderGetThrust(uint16_t* thrust1, uint16_t* thrust2, uint16_t* thrust3, uint16_t* thrust4);

#endif /* THRUST_COMMANDER_H_ */
