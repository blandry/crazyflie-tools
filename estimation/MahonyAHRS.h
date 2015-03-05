//=====================================================================================================
// MahonyAHRS.h
//=====================================================================================================
//
// Madgwick's implementation of Mayhony's AHRS algorithm.
// See: http://www.x-io.co.uk/node/8#open_source_ahrs_and_imu_algorithms
//
// Date			Author			Notes
// 29/09/2011	SOH Madgwick    Initial release
// 02/10/2011	SOH Madgwick	Optimised for reduced CPU load
// 02/22/2015	Benoit Landry	Simplified for crazyflie experiment, plus python api
//
//=====================================================================================================
#ifndef MahonyAHRS_h
#define MahonyAHRS_h

extern volatile float twoKp;			// 2 * proportional gain (Kp)
extern volatile float twoKi;			// 2 * integral gain (Ki)

void MahonyAHRSupdateIMU(float gx, float gy, float gz, float ax, float ay, float az, float dt,
	float q0, float q1, float q2, float q3, float integralFBx, float integralFBy, float integralFBz,
	float* ret);

#endif
