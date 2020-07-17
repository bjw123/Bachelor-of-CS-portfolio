#Implementation of the classic Connect4 using an ANN. Reference used is "Artificial Inteligence: A Guide to Intelligent Systems"

import numpy as np
import json
#TODO: Clean up code.
#TODO: Add error plotting.


class NeuralNetwork:
    """
    The current set up is 4 layers including two hidden layers each having 24 neurons. The set up is optimised
        so as to not touch any function by changing the amount of hidden layers and or neurons. 
        The only variables that should be touched are
        totalLayers
        layList
        weiList
        treList
    """
    features = 42
    OUT = 1
    row = 6
    neurons = 24
    neurons2 = 24
    neurons3 = 24
    neurons4 = 24
    Epoch = 0
    MaxEpoch = 50
    iteration = 0
    learnRate = .1
    momentum = 0.95
    
    def __init__(self, option, data = []):
        if (option['mode'] == 'train'):
            self.Games_Num = len(data)

            self.X = np.zeros((2,option['input'])) #Input
            self.Yd = np.zeros((2, option['output']))#Desired output
            self.Y_InOutErr = np.zeros((3, NeuralNetwork.OUT))#Output neurons

            self.totalLayers= option['Layers'] #Number of layers
            self.h1_InOutErr = np.zeros((3, NeuralNetwork.neurons))#hidden layer neurons
            self.h2_InOutErr = np.zeros((3, NeuralNetwork.neurons2))#2nd hidden layer
            self.h3_InOutErr = np.zeros((3, NeuralNetwork.neurons3))#rd hidden Layer
            self.h4_InOutErr = np.zeros((3, NeuralNetwork.neurons4))#4th Hidden layer
            self.err_out = np.zeros(option['output'])#error between output and desired output
            
            #Weights and Thresholds Configuration
            self.W_ih =  np.random.normal(0.0, 1.0/NeuralNetwork.features, (NeuralNetwork.neurons, NeuralNetwork.features)) #Weights between input and hidden layer.
            self.W_hh =  np.random.normal(0.0, 1.0/NeuralNetwork.features, (NeuralNetwork.neurons2, NeuralNetwork.neurons)) #Weights between input and hidden layer.
            self.W_hh2 =  np.random.normal(0.0, 1.0/NeuralNetwork.features, (NeuralNetwork.neurons3, NeuralNetwork.neurons2)) #Weights between input and hidden layer.
            self.W_hh3 =  np.random.normal(0.0, 1.0/NeuralNetwork.features, (NeuralNetwork.neurons4, NeuralNetwork.neurons3)) #Weights between input and hidden layer.
            self.W_ho = np.random.normal(0.0, 1.0/NeuralNetwork.features, (NeuralNetwork.OUT, NeuralNetwork.neurons2))
            #

            self.layList = [self.X, self.h1_InOutErr, self.h2_InOutErr, self.h3_InOutErr, self.h4_InOutErr, self.Y_InOutErr]
            self.weiList = [self.W_ih, self.W_hh, self.W_hh2, self.W_hh3, self.W_ho]
            self.errList = np.zeros(self.Games_Num)
            self.sse = np.zeros(NeuralNetwork.MaxEpoch)
            self.prev_weightcorr = [self.W_ih, self.W_hh, self.W_hh2, self.W_hh3, self.W_ho]

        elif(option['mode'] == 'play'):
            self.totalLayers = option['Layers']
            self.X = np.zeros((2, option['input']))
            self.Y_InOut = np.zeros((2, NeuralNetwork.OUT))

            self.h1_InOut = np.zeros((2, NeuralNetwork.neurons))#hidden layer neurons
            self.h2_InOut = np.zeros((2, NeuralNetwork.neurons2))#2nd hidden layer
            self.h3_InOut = np.zeros((2, NeuralNetwork.neurons3))#rd hidden Layer
            self.h4_InOut = np.zeros((2, NeuralNetwork.neurons4))#4th Hidden layer

            self.W_ih = np.asarray(option['weights'][0])
            self.W_hh = np.asarray(option['weights'][1])
            self.W_hh2 = np.asarray(option['weights'][2])
            self.W_hh3 = np.asarray(option['weights'][3])
            self.W_ho = np.asarray(option['weights'][4])

            self.layList = [self.X, self.h1_InOut, self.h2_InOut, self.h3_InOut, self.h4_InOut, self.Y_InOut]
            self.weiList = [self.W_ih, self.W_hh, self.W_hh2, self.W_hh3, self.W_ho]


    def SSE(self):
        self.sse[NeuralNetwork.Epoch] = np.sum(self.errList**2)
        self.errList = np.zeros(self.Games_Num)
        print(NeuralNetwork.Epoch, self.sse[NeuralNetwork.Epoch])

    def update(self, cmd, container):
        if (cmd == "outputs"):
            for i in range(self.totalLayers):
                self.layList[i][1] = container[i]
        if (cmd == "weights"):
            for i in range(self.totalLayers-1):
                j = len(container)-1
                self.weiList[i] = container[j-i]#Weights in container are in reverse 
        del container
        return

    def NeuronsActivation(self, data = [], container=[], lidx=0, widx=0):
        #ref: TB p177 eq:6.96
        if (lidx == 0):
            container = []
            container.append(data[:len(data)])#remember to reput len(data)-1 when training
            self.layList[lidx][0] = container[0]
            self.layList[lidx][1] = container[0]
            #self.Yd[0] = data[len(data)-1]
            self.NeuronsActivation(container =container, lidx =lidx+1, widx =widx)
           
        elif (lidx <=self.totalLayers-1):
            inp, weights = self.layList[lidx], self.weiList[widx]

            #Calculation of the input to each neuron first
            inp[0] = np.sum(np.multiply(weights, container[lidx-1]), axis=1)
            self.layList[lidx][0] = inp[0]

            #Activation function is tanh which is a rescaling of the Sigmoid over -1 to 1.
            inp[1] = np.tanh(inp[0])

            container.append(inp[1])
            self.NeuronsActivation(container =container, lidx =lidx+1, widx =widx+1)
        return container

    def outErr(self, cmd=None):
        self.errList[NeuralNetwork.iteration] = np.subtract(self.Yd[0], self.layList[self.totalLayers-1][1])
        return self.errList[NeuralNetwork.iteration]
        
    def backPropagation(self, err, container=[], lidx= None, widx=None, tidx=None):
        """ Recursive Function. Returns list containing new weights for next iteration, for all weights.
            Only needed to be called once per iteration.
            Should call self.update() next to actually update the
            #ref p177
        """
        #ref p177
        #Output Layer Error Gradient calculation
        if (lidx is None):
            container = []
            lidx, widx= self.totalLayers-1, self.totalLayers-2
            errGradient = np.zeros(np.shape(self.layList[lidx][2])[0])
            errGradient = np.subtract(1, np.multiply(self.layList[lidx][1], self.layList[lidx][1]))*err
        #Middle layer Error Gradient Calculation
        elif (lidx >=0):
            errGradient = np.multiply(np.subtract(1, np.multiply(self.layList[lidx][1], self.layList[lidx][1])), err)

        #Rest is similar for all layers
        inpNeurT = self.layList[lidx-1][1]
        errGradient = np.reshape(errGradient, (np.shape(errGradient)[0], 1))
        weightCorr = np.add(NeuralNetwork.momentum*self.prev_weightcorr[widx], np.multiply(NeuralNetwork.learnRate, np.multiply(inpNeurT, errGradient)))
        self.prev_weightcorr[widx] = weightCorr
        weights = np.add(self.weiList[widx], weightCorr)

        container.append(weights)

        if (widx > 0):
            weightsT = np.transpose(self.weiList[widx])
            err = np.sum(np.multiply(self.layList[lidx][2], weightsT), axis=1)
            if (lidx > 0):
                self.layList[lidx][2] = np.reshape(errGradient, np.shape(errGradient)[0])
            self.backPropagation(err, container, lidx-1, widx-1)

        return container
        
    def saveState(self, options):
        weights =[]
        for i in range(self.totalLayers-1):
            weights.append(np.ndarray.tolist(self.weiList[i]))
        options['weights'] = weights
        
        options["SSE"] = np.ndarray.tolist(self.sse)
        with open('options.json', 'w') as file:
            json.dump(options, file, indent=4)
        return

    def LearningRule(self):
        err1, err2 = self.sse[NeuralNetwork.Epoch], self.sse[NeuralNetwork.Epoch-1]
        if (err1 > err2*1.04) :
            NeuralNetwork.learnRate = NeuralNetwork.learnRate * 0.7
            print("decrease")
        elif (err1 <= err2):
            NeuralNetwork.learnRate *= 1.05
            print("increase")
        print(NeuralNetwork.learnRate)

def makeInt(c):
    for i in range(len(c)):
        line = c[i].split(",")
        c[i] = []
        for j in range(len(line)):
            c[i].append(float(line[j]))
    return c

def main():
    
    with open('.\\options.json', 'r') as file:
        options = json.load(file)
    print("loaded options")
    with open('__DataSet\\Data.txt', 'r') as file:
        content = file.read()
        data = makeInt(content.split())
        print("loaded data")

    ann = NeuralNetwork(options, data)#Step1&2: Initialisation
    while (NeuralNetwork.Epoch < NeuralNetwork.MaxEpoch):
        while(NeuralNetwork.iteration < ann.Games_Num):

            #Activation of weights and thresholds
            outputs = ann.NeuronsActivation(data[NeuralNetwork.iteration])#Returns outputs of each neuron
            ann.update("outputs", outputs)#Assign the outputs to each Layer

            #Weight training
            error = ann.outErr()
            w = ann.backPropagation(error)
            ann.update("weights", w)#Update the weights

            NeuralNetwork.iteration +=1
        
        ann.SSE()
        if (NeuralNetwork.Epoch > 0):
            ann.LearningRule()
        NeuralNetwork.iteration = 0
        NeuralNetwork.Epoch +=1
    ann.saveState(options)

if __name__ == '__main__':
    #Main will not run if NeuralNetwork is imported as a module
    #Can then be used to play by loading a saved state
    main()