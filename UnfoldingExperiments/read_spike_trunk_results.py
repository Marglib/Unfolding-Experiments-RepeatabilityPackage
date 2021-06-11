import pandas as pd 
import os
import optparse
import sys

def read_df(options):
    cwd = os.getcwd()
    folder = options.binary
    output = options.output
    filelist = os.listdir(cwd + '/' + folder)
    
    df = pd.DataFrame(columns=['name','places','transitions','arcs','unfoldingtime'])
    lst = [pd.read_table(folder + "/" + file, header=None, delimiter=",", names=['name','places','transitions','arcs','unfoldingtime']) for file in filelist]
    
    for df in lst:
        df = df.append(df)

    df[['places','transitions','arcs','unfoldingtime']] = df[['places','transitions','arcs','unfoldingtime']].apply(pd.to_numeric)

    df = df.groupby('name').mean()
    df.to_csv("../results/" + output + ".csv")
    return df


def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option("--binary", type="string", dest="binary", default="")
    optParser.add_option("--output", type="string", dest="output", default="")

    options, _ = optParser.parse_args()
    return options
                  
# this is the main entry point of this script
if __name__ == "__main__":
    options = get_options()
    if options.binary == "":
        print("Requires a binary to do results for")
        sys.exit()
    if options.output == "":
        print("Requires an output string")
        sys.exit()

    read_df(options)