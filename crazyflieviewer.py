from ddapp.drakevisualizer import DrakeVisualizerApp
from ddapp import objectmodel as om
from ddapp import vtkNumpy as vnp
from ddapp import lcmUtils
from ddapp import filterUtils
from ddapp.debugVis import DebugData
from ddapp import visualization as vis
import numpy as np
from crazyflie_t import polytopes_t

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

if __name__=='__main__':
    # use global so the variable is available in the python console
    global app

    app = DrakeVisualizerApp()
    lcmUtils.addSubscriber('DRAW_POLYTOPE', polytopes_t, drawPolytope)
    app.setupGlobals(globals())

    #app.view.setBackgroundColor([.3,.3,.3],[.6,.6,.6])

    app.mainWindow.show()
    app.start()