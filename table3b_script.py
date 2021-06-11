import pandas as pd 
import os
import optparse
import sys

def create_table(options):
    cwd = os.getcwd()
    folder = options.folder
    output = options.output
    
    files = os.listdir(cwd + '/' + folder)
    csv_files = list(filter(lambda f: f.endswith('.csv'), files))

    tools_results = {}
    for filename in csv_files:
        tool = filename.split('-')
        df = pd.read_csv(folder + '/' + filename, index_col=None, header=0)

        tools_results[tool[0]] = [len(df.index)]
    
    df = pd.DataFrame(tools_results)

    df.to_csv("results/" + output + ".csv", index=False)        

def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option("--folder", type="string", dest="folder", default="")
    optParser.add_option("--output", type="string", dest="output", default="table3b")

    options, _ = optParser.parse_args()
    return options
                  
# this is the main entry point of this script
if __name__ == "__main__":
    options = get_options()
    if options.folder == "":
        print("Requires a binary to do results for")
        sys.exit()

    create_table(options)