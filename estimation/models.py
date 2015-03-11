
import numpy as np
from transforms import body2world, angularvel2rpydot

class DoubleIntegrator():

    # (acc in Gs in body frame)
    # states: x y z dx dy dz accxbias accybias acczbias
    # inputs: roll pitch yaw accx accy accz
    # measurements: x y z dx dy dz accxbias accybias acczbias

    def hx(self, x):
        """ transform state into measurement space """
        return x

    def fx(self, state, control_input, dt):
        """ computes the next x[k+1] from x[k], u[k], dt """
        
        [x,y,z,dx,dy,dz,axbias,aybias,azbias] = state
        [roll,pitch,yaw,ax,ay,az] = control_input

        new_x = x + dx*dt
        new_y = y + dy*dt
        new_z = z + dz*dt

        g = 9.81
        [axw,ayw,azw] = body2world([roll,pitch,yaw],[ax+axbias,ay+aybias,az+azbias])
        new_dx = dx + g*axw*dt
        new_dy = dy + g*ayw*dt
        new_dz = dz + g*(azw-1.0)*dt

        return np.array([new_x, new_y, new_z, new_dx, new_dy, new_dz, axbias, aybias, azbias])