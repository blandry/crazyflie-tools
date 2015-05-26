from ddapp.drakevisualizer import DrakeVisualizerApp
from ddapp import objectmodel as om
from ddapp import vtkNumpy as vnp
from ddapp import lcmUtils
from ddapp import filterUtils 
from ddapp import transformUtils
from ddapp.debugVis import DebugData
from ddapp import visualization as vis
from ddapp import applogic
import numpy as np
from crazyflie_t import polytopes_t
from vicon_t import vicon_pos_t
import drake as lcmdrake


def drawPolytope(msg):
    _id = msg.id;
    if msg.remove:
        om.removeFromObjectModel(om.findObjectByName('IRIS polytopes'))
        return
    if msg.highlighted:
        color = [.8,.2,.2]
    else:
        color = [.8,.8,.8]
    name = 'polytope {:d}'.format(_id)
    obj = om.findObjectByName(name)
    if obj:
        om.removeFromObjectModel(obj)
    V = np.array(msg.V)
    polyData = vnp.numpyToPolyData(V.T.copy())
    vol_mesh = filterUtils.computeDelaunay3D(polyData)
    debug = DebugData()
    debug.addPolyData(vol_mesh)
    vis.showPolyData(debug.getPolyData(), name, color=color, alpha=0.4, parent='IRIS polytopes')

def updateCamera(msg):
    T = transformUtils.frameFromPositionAndRPY(msg.q[:3],np.degrees(msg.q[3:]))
    axes = transformUtils.getAxesFromTransform(T)
   
    #vis.updateFrame(T, 'vicon camera')
    #return

    camera = app.view.camera()
    camera.SetPosition(T.GetPosition())
    camera.SetFocalPoint(np.array(T.GetPosition())+axes[0])
    camera.SetViewUp(axes[2])
    camera.SetViewAngle(122.6)
    app.view.render()

def setupStrings():
    d = DebugData()
    poles = [[-.36,.5,1.5],[-.36,-.5,1.5],[0,.5,1.5],[0,-.5,1.5],[.36,.5,1.5],[.36,-.5,1.5]]
    for pole in poles:
        d.addCylinder(pole, [0,0,1], 3, radius=0.021)
    vis.updatePolyData(d.getPolyData(), 'poles')

    d = DebugData()
    strings = [
        [-.36, .5, .09, 0, -.5, 1.77],
        [-.36, .5, .74, -.36, -.5, .95],
        [-.36, .5, 1.12, -.36, -.5, 1.68],
        [-.36, .5, 1.33, .36, -.5, 2.29],
        [-.36, .5, 1.6, .36, -.5, 1.62],
        [-.36, .5, 1.74, .36, -.5, 1.93],
        [-.36, .5, 2.15, -.36, -.5, 1.46],
        [0, .5, .765, 0, -.5, .795],
        [0, .5, 1.15, .36, -.5, 1.15],
        [0, .5, 1.28, -.36, -.5, .11],
        [0, .5, 1.42, 0, -.5, 1.42],
        [0, .5, 1.78, .36, -.5, .12],
        [0, .5, 2.05, -.36, -.5, 1.835],
        [.36, .5, .8, -.36, -.5, 1.11],
        [.36, .5, 1.16, -.36, -.5, 1.47],
        [.36, .5, 1.61, .36, -.5, 1.19],
        [.36, .5, 2.0, .36, -.5, 2.1],
        [-.36, .3, 0, -.36, .3, 2.01],
        [0, -.34, 0, 0, -.34, 1.42],
        [.36, 0, 0, .36, 0, 2.05],
    ]
    for string in strings:
        p1 = string[:3]
        p2 = string[3:]
        d.addLine(p1,p2,radius=.001,color=[255,0,0])
    vis.updatePolyData(d.getPolyData(), 'strings')


class QuadCamera():
    def __init__(self):
        self.last_pos = None
        self.cam_pos = None
        self.fpoint = None
        self.last_fpoint = None
        self.dir = None

    def onRobotDraw(self, msg):

        # alpha = .5
        # pos = np.array(msg.position[1])

        # if self.last_pos==None:
        #     #self.cam_pos = np.array([-1.5, -.1, 1.25]) 
        #     self.cam_pos = pos
        #     self.fpoint = pos + np.array([.5, 0, 0])
        # else:
        #     v = pos-self.last_pos
        #     if np.linalg.norm(v)>0.005:
        #         self.dir = v/np.linalg.norm(v)
        #         #self.cam_pos = alpha*(pos - v*.05) + (1-alpha)*self.cam_pos
        #         self.cam_pos = pos - .25*self.dir
        #         self.fpoint = alpha*(pos + .5*self.dir) + (1-alpha)*self.last_fpoint
        #     else:
        #         self.fpoint = pos

        # self.last_pos = pos
        # self.last_fpoint = self.fpoint

        # self.fpoint = pos

        # camera = app.view.camera()
        # camera.SetFocalPoint(self.fpoint.tolist())
        # #camera.SetPosition(self.cam_pos.tolist())
        # camera.SetViewAngle(100)
        # camera.SetViewUp([0,0,1])

        pos = np.array(msg.position[1])
        camera = app.view.camera()

        #camera.SetPosition([-.,.5,1.5])
        camera.SetFocalPoint((.9*np.array(camera.GetFocalPoint())+.1*pos).tolist())
        #camera.SetViewAngle(100)
        camera.SetViewUp([0,0,1])

        app.view.render()


if __name__=='__main__':
    # use global so the variable is available in the python console
    global app

    app = DrakeVisualizerApp()
    lcmUtils.addSubscriber('DRAW_POLYTOPE', polytopes_t, drawPolytope)
    
    # to have the camera follow the camera log
    #lcmUtils.addSubscriber('sbach_camera', vicon_pos_t, updateCamera)
    
    # to have the camera follow the robot
    quad_cam = QuadCamera()
    lcmUtils.addSubscriber('DRAKE_VIEWER_DRAW', lcmdrake.lcmt_viewer_draw, quad_cam.onRobotDraw)

    # to plot the strings obstacles course
    setupStrings()

    applogic.setBackgroundColor([0.3, 0.3, 0.35], [0.95,0.95,1])
    
    app.mainWindow.show()
    app.start()