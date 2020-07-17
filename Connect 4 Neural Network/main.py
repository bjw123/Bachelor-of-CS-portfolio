#!/usr/bin/env python3
import sys
import random
from NeuralNetwork.neural_network import NeuralNetwork
import json
import numpy as np

with open('C:\\Users\\dbari\Documents\\GitHub\\Connect4-py\\options.json', 'r') as file:
        options = json.load(file)

ann = NeuralNetwork(options)

class Settings():
    def __init__(self):
        self.timebank = None 
        self.time_per_move = None
        self.player_names = None 
        self.your_bot = None
        self.your_botid = None
        self.field_width = None
        self.field_height = None

class Field():

    def __init__(self):
        self.position = ['30', '40', '20', '10', '50', '00', '60']
        self.available_cols = 7
        self.field_state = None

    def update_field(self, celltypes, settings):
        #change to contain diff type cell.
        self.field_state = [[] for _ in range(settings.field_height)]
        n_cols = settings.field_width
        tok = ''
        for idx, cell in enumerate(celltypes):
            row_idx = idx // n_cols
            if (cell == '.'):
                tok = '0'
            elif(cell == '0'):
                if (settings.your_botid == 0):
                    tok = '-1'
                else:
                    tok = '1'
            elif(cell == '1'):
                if (settings.your_botid == 1):
                    tok = '-1'
                else:
                    tok = '1' 

            self.field_state[row_idx].append(tok)
        self.fieldI = np.zeros((7,6), dtype=object)
        for col in range(7):
            for row in range(6):
                self.fieldI[col][row] = self.field_state[-row-1][col]



class State():
    def __init__(self):
        self.settings = Settings()
        self.field = Field()
        self.round = 0

def parse_communication(text):
    """ Return the first word of the communication - that's the command """
    return text.strip().split()[0]

def settings(text, state):
    """ Handle communication intended to update game settings """
    tokens = text.strip().split()[1:] # Ignore token 0, it's the string "settings".
    cmd = tokens[0]
    if cmd in ('timebank', 'time_per_move', 'your_botid', 'field_height', 'field_width'):
        # Handle setting integer settings.
        setattr(state.settings, cmd, int(tokens[1]))
    elif cmd in ('your_bot',):
        # Handle setting string settings.
        setattr(state.settings, cmd, tokens[1])
    elif cmd in ('player_names',):
        # Handle setting lists of strings.
        setattr(state.settings, cmd, tokens[1:])
    else:
        raise NotImplementedError('Settings command "{}" not recognized'.format(text))
    

def update(text, state):
    """ Handle communication intended to update the game """
    tokens = text.strip().split()[2:] # Ignore tokens 0 and 1, those are "update" and "game" respectively.
    cmd = tokens[0]
    if cmd in ('round',):
        # Handle setting integer settings.
        setattr(state.settings, 'round', int(tokens[1]))
    if cmd in ('field',):
        # Handle setting the game board.
        celltypes = tokens[1].split(',')
        state.field.update_field(celltypes, state.settings)


def action(text, state):
    """ Handle communication intended to prompt the bot to take an action """
    tokens = text.strip().split()[1:] # Ignore token 0, it's the string "action".
    cmd = tokens[0]
    if cmd in ('move',):
        return make_move(state)
    else:
        raise NotImplementedError('Action command "{}" not recognized'.format(text))

def MovesScore(state):
    #First figure out the playable positions
    field= state.field.fieldI #Transforms array from row containing columns to columns containing rows.
    for i in range(7):
        for pos, sub in enumerate(field[i]):
            if (sub == '0'):
                row = pos
                break
            else:
                row = -1
            
        if (row != -1): #a return of -1 means it did not find an empty space.
            for idx, j in enumerate(state.field.position):
                if j[0] == str(i):
                    break
            state.field.position[idx] = str(i)+str(row)
            idx = 0
        else:
            for idx, j in enumerate(state.field.position):
                if j[0] == str(i):
                    break
            state.field.position.pop(idx)
            idx = 0
    return state.field.position

def make_move(state):

    # TODO: Implement bot logic here
    max_score = 1
    positions = MovesScore(state)
    move = (positions[0][0])
    potential_play = np.reshape(state.field.fieldI, 42)
    potential_play = np.array(potential_play, dtype=int)
    #curr_score = ann.NeuronsActivation(potential_play)[-1]
    for i in range(len(positions)):
        col = int(positions[i][0])
        row = int(positions[i][1])
        potential_play[col*6 + row] = -1
        score = ann.NeuronsActivation(potential_play)[-1]
        if (score < max_score):
            max_score = score
            move = str(col)
        potential_play[col*6 + row] = 0
        state.field.position = ['30', '40', '20', '10', '50', '00', '60']
    return 'place_disc {}'.format(move)

def main():
    command_lookup = { 'settings': settings, 'update': update, 'action': action }
    state = State() 
    
    for input_msg in sys.stdin:
        cmd_type = parse_communication(input_msg)
        command = command_lookup[cmd_type]

        # Call the correct command. 
        res = command(input_msg, state)

        # Assume if the command generates a string as output, that we need 
        # to "respond" by printing it to stdout.
        if isinstance(res, str):
            print(res)
            sys.stdout.flush()



main()
