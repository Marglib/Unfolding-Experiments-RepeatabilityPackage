import pandas as pd 
import os
import optparse
import sys
import numpy as np
from IPython.display import display 
from tabulate import tabulate 

#---------HELPER FUNCTIONS---------
def size_ratio(row):
    return (row['cfp-Atransitions'] + row['cfp-Aplaces']) / (row['trunk-Atransitions'] + row['trunk-Aplaces'])

def unfolding_ratio(row):
    return (row['cfp-unfoldingtime'] + row['colorfixedpoint'] + row['partitioning-time']) / row['trunk-unfoldingtime']

def mcc_size_ratio(row):
    return (row['cfp-Atransitions'] + row['cfp-Aplaces']) / (row['mcc-Atransitions'] + row['mcc-Aplaces'])

def mcc_unfolding_ratio(row):
    return (row['cfp-unfoldingtime'] + row['colorfixedpoint'] + row['partitioning-time']) / row['mcc-unfoldingtime']

def cfp_size(row):
    return row['cfp-Atransitions'] + row['cfp-Aplaces']

def trunk_size(row):
    return row['trunk-Atransitions'] + row['trunk-Aplaces']

def remove_fast_row(row,threshold):
    return ((row['cfp-unfoldingtime'] + row['colorfixedpoint']) < threshold) and (row['trunk-unfoldingtime'] < threshold)

def remove_fast_row_mcc(row,threshold):
    return ((row['cfp-unfoldingtime'] + row['colorfixedpoint']) < threshold) and (row['mcc-unfoldingtime'] < threshold)

def create_latex_table(df,n):
    middle_count = df.shape[0] / 2
    bot_middle = int(middle_count - (n/2))
    top_middle = int(middle_count + (n/2))
    
    middle = df[bot_middle:top_middle]
    top = df[:n]
    bottom = df[-n:]

    full_df = top.append([middle,bottom])
    
    print(full_df.to_latex(index=False))



pd.set_option('display.max_columns', None)

def create_unfolding_stats(options):
    #---------READING FILES---------
    #list the files
    binary_two = 'results/' + options.binary
    filelist_bin = os.listdir(binary_two)

    #read them into pandas
    cfpstats_df_list = [pd.read_table(binary_two + "/" + file, header=None, delimiter=",", names=['name','cfp-Bplaces','cfp-Btransitions','cfp-Barcs','cfp-Aplaces','cfp-Atransitions','cfp-Aarcs','cfp-unfoldingtime','colorfixedpoint','partitioning-time']) for file in filelist_bin]

    #Trunk stats complete df
    cfpdata = pd.DataFrame(columns=['name','cfp-Bplaces','cfp-Btransitions','cfp-Barcs','cfp-Aplaces','cfp-Atransitions','cfp-Aarcs','cfp-unfoldingtime','colorfixedpoint','partitioning-time'])

    i = 0
    for df in cfpstats_df_list:
        if i % 100 == 0:
            print("Reading files: " + str(i))
        cfpdata = cfpdata.append(df)
        i += 1

    cfpdata['name'] = cfpdata['name'].map(lambda x: x.strip()[14:-11])

    #Preprocessing
    #Read mcc data
    mcc_df = pd.read_csv('results/mcc-unfolding-results.csv', index_col=0)

    #Read trunk data
    trunkstats_df = pd.read_csv('results/trunk226-unfolding-results.csv', index_col=0)

    #Fix bin data
    cfpdata[['cfp-Bplaces','cfp-Btransitions','cfp-Barcs','cfp-Aplaces','cfp-Atransitions','cfp-Aarcs','cfp-unfoldingtime','colorfixedpoint','partitioning-time']] = cfpdata[['cfp-Bplaces','cfp-Btransitions','cfp-Barcs','cfp-Aplaces','cfp-Atransitions','cfp-Aarcs','cfp-unfoldingtime','colorfixedpoint','partitioning-time']].apply(pd.to_numeric)
    cfpdata = cfpdata.groupby('name').mean()
    cfpdata.dropna(inplace=True)

    cfpdata[['cfp-Bplaces','cfp-Btransitions','cfp-Barcs','cfp-Aplaces','cfp-Atransitions','cfp-Aarcs','cfp-unfoldingtime','colorfixedpoint','partitioning-time']] = cfpdata[['cfp-Bplaces','cfp-Btransitions','cfp-Barcs','cfp-Aplaces','cfp-Atransitions','cfp-Aarcs','cfp-unfoldingtime','colorfixedpoint','partitioning-time']].apply(pd.to_numeric)
    cfpdata = cfpdata.groupby('name').mean()
    cfpdata.dropna(inplace=True)

    #----------GATHER STATISTICS---------
    #MCC COMPARISON
    mcc_cfp_comp = cfpdata.join(mcc_df,how='outer',on='name')
    mcc_cfp_comp['size_ratio'] = mcc_cfp_comp.apply(lambda row: mcc_size_ratio(row), axis=1)
    mcc_cfp_comp['unfolding_ratio'] = mcc_cfp_comp.apply(lambda row: mcc_unfolding_ratio(row), axis=1)
    mcc_cfp_comp.sort_values(by=['unfolding_ratio'],inplace=True)
    mcc_cfp_comp = mcc_cfp_comp.set_index('name')

    mcc_cfp_comp.to_csv('output/mcc-' + options.binary + '.csv')

    full_df = cfpdata.join(trunkstats_df, how='outer', on='name')

    #TRUNK COMPARISON
    full_df['size_ratio'] = full_df.apply(lambda row: size_ratio(row), axis=1)
    full_df['unfolding_ratio'] = full_df.apply(lambda row: unfolding_ratio(row), axis=1)
    full_df.sort_values(by=['unfolding_ratio'],inplace=True)
    full_df.drop(['trunk-Btransitions', 'trunk-Bplaces', 'trunk-Barcs'],inplace=True,axis=1)
    full_df.rename(columns={"cfp-Btransitions" : "Btransitions", "cfp-Bplaces" : "Bplaces", "cfp-Barcs" : "Barcs"},inplace=True)

    full_df.to_csv('output/trunk-226-' + options.binary + '.csv')

def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option("--binary", type="string", dest="binary", default="")

    options, args = optParser.parse_args()
    return options
                  
# this is the main entry point of this script
if __name__ == "__main__":
    options = get_options()
    if options.binary == "":
        print("Requires a binary to do results for")
        sys.exit()

    print("im am here: " + os.getcwd())
    create_unfolding_stats(options)
