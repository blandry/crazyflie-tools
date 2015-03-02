def rotx(theta):
    c = cos(theta)
    s = sin(theta)
    M = np.matrix([[1,0,0],[0,c,-s],[0,s,c]])
    return M

def roty(theta):
    c = cos(-theta)
    s = sin(-theta)
    M = np.matrix([[c,0,-s],[0,1,0],[s,0,c]])
    return M

def rotz(theta):
    c = cos(theta)
    s = sin(theta)
    M = np.matrix([[c,-s,0],[s,c,0],[0,0,1]])
    return M

def rpy2rotmat(rpy):
    R = np.dot(rotz(rpy[2]),np.dot(roty(rpy[1]),rotx(rpy[0])))
    return R

def body2world(xyz, rpy):
    R = rpy2rotmat(rpy)
    xyz_world = np.dot(np.linalg.inv(R),np.array(xyz).transpose())
    return (np.array(xyz_world)[0]).tolist()