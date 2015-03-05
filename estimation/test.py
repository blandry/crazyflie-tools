
import transforms

if __name__=='__main__':
	rpy = [1.0, 2.0, 3.0]
	gyro = [1.5, 1.0, 1.5]
	rpydot = transforms.angularvel2rpydot(rpy, transforms.body2world(rpy, gyro))
	rpydotexpected = [-2.109520760384187, -0.721904171343705, -3.969571070914463]
	for i in range(3):
		assert (rpydotexpected[i]-rpydot[i])<1E-6