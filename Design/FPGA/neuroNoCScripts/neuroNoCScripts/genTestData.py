import sys
from matplotlib import pyplot as plt

outputPath = ""

try:
    import cPickle as pickle
except:
    import pickle
import gzip
import numpy as np

dataWidth = 10					#specify the number of bits in test data
IntSize = 2 #Number of bits of integer portion including sign bit
testDataNum = 5000

#Do not modify below this line####################################################################

def DtoB(num,dataWidth,fracBits):						#funtion for converting into two's complement format
	if num >= 0:
		num = num * (2**fracBits)
		d = int(num)
	else:
		num = -num
		num = num * (2**fracBits)		#number of fractional bits
		num = int(num)
		if num == 0:
			d = 0
		else:
			d = 2**dataWidth - num
	return d


def load_data():
	f = gzip.open('mnist.pkl.gz', 'rb') 		#change this location to the resiprositry where MNIST dataset sits
	try:
		training_data, validation_data, test_data = pickle.load(f,encoding='latin1')
	except:
		training_data, validation_data, test_data = pickle.load(f)
	f.close()
	return (training_data, validation_data, test_data)

def genTestData(dataWidth,IntSize,testDataNum):
	#dataHeaderFile = open(headerFilePath+"dataValues.h","w")
	#dataHeaderFile.write("int dataValues[]={")
	tr_d, va_d, te_d = load_data()
	test_inputs = [np.reshape(x, (1, 784)) for x in te_d[0]]
	x = len(test_inputs[0][0])
	d=dataWidth-IntSize
	count = 0
	fileName = 'validation_data.txt'
	f = open(outputPath+fileName,'w')
	#k = open('testData.txt','w')
	testData = np.reshape(te_d[0][testDataNum], (28, 28))
	plt.imshow(testData)
	#plt.show()
	plt.savefig('testData.png')
	for i in range(0,x):
		#k.write(str(test_inputs[testDataNum][0][i])+',')
		dInDec = DtoB(test_inputs[testDataNum][0][i],dataWidth,d)
		myData = bin(dInDec)[2:]
		#dataHeaderFile.write(str(dInDec)+',')
		f.write(myData+'\n')
		count += 1
	#k.close()
	f.close()
	#dataHeaderFile.write('0};\n')
	#dataHeaderFile.write('int result='+str(te_d[1][testDataNum])+';\n')
	#dataHeaderFile.close()
		
		
def genAllTestData(dataWidth,IntSize):
	tr_d, va_d, te_d = load_data()
	test_inputs = [np.reshape(x, (1, 784)) for x in te_d[0]]
	x = len(test_inputs[0][0])
	d=dataWidth-IntSize
	for i in range(len(test_inputs)):
		if i < 10:
			ext = "000"+str(i)
		elif i < 100:
			ext = "00"+str(i)
		elif i < 1000:
			ext = "0"+str(i)
		else:
			ext = str(i)
		fileName = 'validation_data_'+ext+'.txt'
		f = open(outputPath+fileName,'w')
		for j in range(0,x):
			dInDec = DtoB(test_inputs[i][0][j],dataWidth,d)
			myData = bin(dInDec)[2:]
			f.write(myData+'\n')
		f.write(bin(DtoB((te_d[1][i]),dataWidth,0))[2:])
		f.close()



if __name__ == "__main__":
	genTestData(dataWidth,IntSize,testDataNum)
	#genAllTestData(dataWidth,IntSize)