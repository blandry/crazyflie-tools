from estimation import StateEstimator
from estimation.models import Crazyflie2Model

state_estimator = StateEstimator(listen_to_vicon=False,publish_to_lcm=True,use_rpydot=False,use_ukf=True)
state_estimator.add_imu_reading([1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 5.0])
#print state_estimator.get_xhat()
state_estimator.add_input([10.0,10.0,10.0,10.0])
#print state_estimator.get_xhat()

cf = Crazyflie2Model()
x = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
u = [1.0, 1.5, .5, 4.0, 0, 1.0]
dt = 1
nx = cf.fx(x,u,dt)
print nx