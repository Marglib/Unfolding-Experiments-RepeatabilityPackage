import sys
import os
import pandas as pd
import optparse
import matplotlib.pyplot as plt
import numpy as np
import glob
import ntpath
def path_leaf(path):
    head, tail = ntpath.split(path)
    return tail or ntpath.basename(head)

def make_plot(df, num_cases, best_cases, labels, ylabel, outfile, showGraph, linecolors, linestyles, ymax=0):
    #Remove unnamed
    df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
    #df = df.fillna(1000)
    cut_df = pd.DataFrame()
    for col in df.columns:
        cut_df[col] = df.sort_values(by=[col], ascending=best_cases, na_position='last')[col][0:num_cases].tolist()
    columns = []
    for col in cut_df:
        columns.append(col)
    cut_df.sort_values(by=columns, inplace=True, ascending=True)
    cut_df = cut_df.reset_index(drop=True)
    x = 0
    if not best_cases:
        x = len(df.index) - num_cases + 1
    cut_df.index = cut_df.index + x
    i = 0
    #labels = ['Method A (unfolded 198 nets)', 'Method B (unfolded 203 nets)', 'Method A+B (unfolded 208 nets)', 'MCC']
    #linestyles = ['-', '--', ':', '-.', '-', ':', '--', '-.']
    #linecolors = ['c', 'b', 'r', 'k', 'g','m', 'lime']
    for col in cut_df:       
        #plt.plot(cut_df[col][np.isfinite(cut_df[col])], linestyle=linestyles[i], color=linecolors[i])
        plt.plot(cut_df[col], linestyle=linestyles[i], color=linecolors[i])
        i += 1

    #plot styling
    plt.grid(True)
    plt.xlabel("Models")
    plt.ylabel(ylabel)
    plt.legend(labels)
    plt.yscale("log")
    x_values = []
    new_x = x
    while new_x < x + len(cut_df.index):
        x_values.append(new_x)
        new_x += 20
    x_values.append(x+ len(cut_df.index)-1)
    if ymax == 0:
        ymax = cut_df.max().max()
    plt.xticks(x_values, visible=True)
    x1,x2,y1,y2 = plt.axis()  
    plt.axis((x,x + len(cut_df.index)-1,y1,ymax))
    #plt.axis((x,x + len(cut_df.index)-1,y1,10))
    #plt.axhline(y=1, color='k', linestyle='-')
    if outfile:
        plt.savefig(outfile,bbox_inches='tight')
    if showGraph:
        plt.show()

def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option('-f','--folder', type="string", help='Folder containing .csv files', dest = 'folder', default = "")
    optParser.add_option("-s", action="store_true", dest="doSize", help="make size ratio graph")
    optParser.add_option("-t", action="store_true", dest="doTime", help="make time graph")
    optParser.add_option("-w", action="store_false", dest="worstCases", help="display worst cases", default=True)
    optParser.add_option('-n', type="int", help='Number of cases to display, default=81', dest = 'numCases', default = 81)
    optParser.add_option('-o','--outSizePNG', type="string", help='Where to put the PNG for size, default=\'\'', dest = 'sizeOut', default = "")
    optParser.add_option('-p','--outTimePNG', type="string", help='Where to put the PNG for time, default=\'\'', dest = 'timeOut', default = "")
    optParser.add_option('-d','--noshow', action="store_false", dest="show", help="display chosen graph", default=True)



    options, args = optParser.parse_args()
    return options                  
# this is the main entry point of this script
if __name__ == "__main__":
    options = get_options() 
    all_files = glob.glob(options.folder + "/*.csv")
    time_df_list = []
    size_df_list = []
    labels = []

    for filename in all_files:
        df = pd.read_csv(filename, index_col=None, header=0)
        df_time = pd.DataFrame()
        tool = path_leaf(filename).split('-')[0]
        labels.append(tool)
        df_time['name'] = df['name']
        df_time[tool + 'time'] = df['unfoldingtime']
        df_time.set_index('name', inplace=True)
        time_df_list.append(df_time)
        df_size = pd.DataFrame()
        df_size['name'] = df['name']
        df_size[tool+'size'] = df['places'] + df['transitions']
        df_size.set_index('name', inplace=True)

        size_df_list.append(df_size)

        

    if options.doTime:
        time_frame = time_df_list[0].copy()
        for df in time_df_list[1:]:
            time_frame = time_frame.join(df, how='outer')
        time_frame.fillna(1000, inplace=True)
        make_plot(time_frame, options.numCases, options.worstCases, labels, 'Time(s)', options.timeOut, options.show, ['c', 'b', 'r', 'k', 'g','m', 'lime'],['-', '--', ':', '-.', '-', ':', '--', '-.'])
    

    if options.doSize:
        size_frame = size_df_list[0].copy()
        for df in size_df_list[1:]:
            size_frame = size_frame.join(df, how='outer')

        size_frame.to_csv('test.csv')
        #size_frame[size_frame['itssize'] < size_frame['partitioningsize']].to_csv("itssizebetter.csv")
        size_df = pd.DataFrame()
        #Rules: Number/NaN = inf, NaN/Number = 0, NaN/NaN = NaN
        #size_df['ITS/MCC'] = size_frame['ITSsize'].divide(size_frame['MCCsize'], fill_value=0)
        size_df['A+B/ITS'] = size_frame['A+Bsize'].divide(size_frame['ITSsize'], fill_value=0)
        size_df['A+B/MCC'] = size_frame['A+Bsize'].divide(size_frame['MCCsize'], fill_value=0)
        size_df['A+B/Spike'] = size_frame['A+Bsize'].divide(size_frame['Spikesize'], fill_value=0)

        #size_df = size_df[((size_df.T < 0.9) | (size_df.T > 1.1)).any()]
        """
        size_df['MCC/A+B'] = size_frame['MCCsize'].divide(size_frame['A+Bsize'], fill_value=0)
        size_df['ITS/A+B'] = size_frame['ITSsize'].divide(size_frame['A+Bsize'], fill_value=0)
        size_df['Spike/A+B'] = size_frame['Spikesize'].divide(size_frame['A+Bsize'], fill_value=0)
        size_df['MCC/ITS'] = size_frame['MCCsize'].divide(size_frame['ITSsize'], fill_value=0)
        """
        #NaN/Number = 0 --> 1000
        size_df[size_df == 0] = 1000
        #Number/NaN = inf --> 0
        size_df.fillna(1,inplace=True)
        size_df.replace([np.inf, -np.inf], 0, inplace=True)
        size_df = size_df[(size_df.T != 1).any()]
        #size_df = size_df[(size_df['A+B/ITS'] <= 0.7) & (size_df['A+B/MCC'] <= 0.7) & (size_df['A+B/Spike'] <= 0.7)]
        #size_df.to_csv('test.csv')

        make_plot(size_df, options.numCases, options.worstCases, size_df.columns, 'Size ratio', options.sizeOut,options.show, ['b', 'r', 'k', 'g','m', 'lime'],['--', ':', '-.', '-', ':', '--', '-.'], ymax=10)
    
    


    

    