import pandas as pd
import optparse
import ntpath


def path_leaf(path):
    head, tail = ntpath.split(path)
    return tail or ntpath.basename(head)


def get_options():
    optParser = optparse.OptionParser()
    optParser.add_option('-f','--folder', type="string", help='Folder containing .csv files', dest = 'folder', default = "")
    optParser.add_option('-o','--output', type="string", help='Output .csv file', dest = 'output', default = "")


    options, args = optParser.parse_args()
    return options   

if __name__ == "__main__":
    options = get_options() 
    all_files = [options.folder + '/A+B-unfolding-results.csv', options.folder + '/ITS-unfolding-results.csv',options.folder + '/MCC-unfolding-results.csv',options.folder + '/Spike-unfolding-results.csv']
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

        
    time_frame = time_df_list[0].copy()
    for df in time_df_list[1:]:
        time_frame = time_frame.join(df, how='outer')

    time_frame.to_csv(options.output)