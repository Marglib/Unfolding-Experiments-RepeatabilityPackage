import pandas as pd
import optparse
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
    labels = []

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

    size_df = pd.DataFrame()
    #Rules: Number/NaN = inf, NaN/Number = 0, NaN/NaN = NaN
    size_df['A+B/ITS'] = size_frame['A+Bsize'].divide(size_frame['ITSsize'], fill_value=0)
    size_df['A+B/MCC'] = size_frame['A+Bsize'].divide(size_frame['MCCsize'], fill_value=0)
    size_df['A+B/Spike'] = size_frame['A+Bsize'].divide(size_frame['Spikesize'], fill_value=0)
    
    i = 0
    netname = ""
    rows= []
    indices_to_keep = []
    for index, row in size_df.iterrows():
        #print(netname)
        if i == 0:
            netname =string_until_digit(index)
            i += 1
            rows.append(row)
        elif index.startswith(netname):
            rows.append(row)
            i+=1
        else:
            if i % 2 != 0:
                indices_to_keep.append(rows[math.floor(i / 2)])
            else:
                new_row = (rows[int((i / 2))-1] + rows[int((i / 2))]) / 2
                new_row.name= rows[int((i / 2))-1].name + rows[int((i / 2))].name
                indices_to_keep.append(new_row)
            rows = []
            netname =string_until_digit(index)
            rows.append(row)
            i = 1
            if index == size_df.index[-1]:
                indices_to_keep.append(row)
    median_size_df = pd.DataFrame(indices_to_keep)
    median_size_df.sort_values(by=['A+B/ITS'], ascending=True).to_csv(options.output)
    