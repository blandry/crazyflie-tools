from estimation import StateEstimator

state_estimator = StateEstimator(listen_to_vicon=False,publish_to_lcm=True,use_rpydot=False,use_ukf=True)
state_estimator.add_imu_reading([1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 5.0])
print state_estimator.get_xhat()
state_estimator.add_input([10.0,10.0,10.0,10.0])
print state_estimator.get_xhat()
