import sys
import os
import pandas as pd
import optparse
import matplotlib.pyplot as plt
import numpy as np
import glob
import ntpath
import math
import re
def path_leaf(path):
    head, tail = ntpath.split(path)
    return tail or ntpath.basename(head)

def string_until_digit(test_str):
    res = re.findall('([a-zA-Z -]*)\d*.*', test_str)
  
    return str(res[0])

def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option('-f','--folder', type="string", help='Folder containing .csv files', dest = 'folder', default = "")
    optParser.add_option('-o','--output', type="string", help='Output .csv file', dest = 'output', default = "")


    options, args = optParser.parse_args()
    return options                  

# this is the main entry point of this script
if __name__ == "__main__":
    options = get_options() 
    all_files = [options.folder + '/A+B-unfolding-results.csv', options.folder + '/ITS-unfolding-results.csv',options.folder + '/MCC-unfolding-results.csv',options.folder + '/Spike-unfolding-results.csv']
    size_df_list = []

    for filename in all_files:
        df = pd.read_csv(filename, index_col=None, header=0)
        df_time = pd.DataFrame()
        tool = path_leaf(filename).split('-')[0]
        df_size = pd.DataFrame()
        df_size['name'] = df['name']
        df_size[tool+'size'] = df['places'] + df['transitions']
        df_size.set_index('name', inplace=True)

        size_df_list.append(df_size)

    size_frame = size_df_list[0].copy()
    for df in size_df_list[1:]:
        size_frame = size_frame.join(df, how='outer')


    netnames = []
    for index, row in size_frame.iterrows():
        netnames.append(string_until_digit(index))
        
    listofDfs = []
    for name in set(netnames):
        dataFrameOut = size_frame[size_frame.index.str.match(name)]
        #We only keep the rows where only we are constant
        if len(np.unique(dataFrameOut['A+Bsize']))==1 and len(np.unique(dataFrameOut['ITSsize']))!=1:
            listofDfs.append(dataFrameOut)
    df = pd.concat(listofDfs)
    df.sort_index().to_csv(options.output)



    

    