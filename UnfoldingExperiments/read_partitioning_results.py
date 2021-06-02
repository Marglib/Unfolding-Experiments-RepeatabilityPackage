import pandas as pd 
import os
import numpy as np
import os
import optparse
import sys

def total_unfolding_time(row):
    return row['pureunfoldingtime'] + row['colorfixedpoint'] + row['partitioning-time']

def read_partitioning_df(options):
    folder = options.binary
    filelist = os.listdir(folder)

    part_list = [pd.read_table(folder + "/" + file, header=None, delimiter=",", names=['name','Bplaces','Btransitions','Barcs','places','transitions','arcs','pureunfoldingtime','colorfixedpoint','partitioning-time']) for file in filelist]

    part_df = pd.DataFrame(columns=['name','Bplaces','Btransitions','Barcs','places','transitions','arcs','pureunfoldingtime','colorfixedpoint','partitioning-time'])

    i = 0
    for df in part_list:
        if i % 100 == 0:
            print("Reading files: " + str(i))
        part_df = part_df.append(df)
        i += 1

    part_df[['Bplaces','Btransitions','Barcs','places','transitions','arcs','pureunfoldingtime','colorfixedpoint','partitioning-time']] = part_df[['Bplaces','Btransitions','Barcs','places','transitions','arcs','pureunfoldingtime','colorfixedpoint','partitioning-time']].apply(pd.to_numeric)

    part_df['name'] = part_df['name'].map(lambda x: x.strip()[14:-11])
    part_df = part_df.groupby('name').mean()
    part_df['unfoldingtime'] = part_df.apply(lambda row: total_unfolding_time(row), axis=1)


    part_df.to_csv("partitioning-unfolding-results.csv")
    return part_df


def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option("--binary", type="string", dest="binary", default="")

    options, _ = optParser.parse_args()
    return options
                  
# this is the main entry point of this script
if __name__ == "__main__":
    options = get_options()
    if options.binary == "":
        print("Requires a binary to do results for")
        sys.exit()

    read_partitioning_df(options)