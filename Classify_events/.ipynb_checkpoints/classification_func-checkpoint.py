import pandas as pd
import numpy as np


def separate_meta_types(df, types_dict):
    '''
    Check whether events in df can be classified using the meta_key and key in the types_dict
    Return classied events as df_combined. Return the remaining unclassified events as df
    '''
    
    df_combined = None
    
    for meta_key, meta_list in types_dict.items():
    
        for key_value, type_name in meta_list:

            df, df_combined = separate_by_event_name(df, df_combined, 
                                                     key=key_value, meta_key=meta_key,
                                                     type_name=type_name)
            
    return df, df_combined



def separate_by_event_name(df_remainer, df_combined=None, key=None, meta_key=None, type_name='end'):
    '''
    Check how many events in the df_remainer have key
    Separate those events, assign them appropriate key and meta_key, add tese events to df_combined
    Return the remaining (unclassified) events and combined clasified events
    '''
    
    if type_name == 'end':
        df_subset = df_remainer[df_remainer.event_name.apply(lambda x: x[-len(key):] == key)]
        df_remainer = df_remainer[df_remainer.event_name.apply(lambda x: x[-len(key):] != key)]
    else:
        df_subset = df_remainer[df_remainer.event_name.apply(lambda x: x[:len(key)] == key)]
        df_remainer = df_remainer[df_remainer.event_name.apply(lambda x: x[:len(key)] != key)]
    
    # do nothing if no events were classified
    events_found = df_subset.shape[0]
#     print(f'Type "{key}". Number of events: {events_found:,.0f} \n')
    if events_found == 0:
        return df_remainer, df_combined
    
    # assign type
    df_subset.loc[:, 'type_name'] = key
    df_subset.loc[:, 'meta_type_name'] = meta_key
    
    # combine dataset
    if df_combined is None:
        df_combined = df_subset
    else:
        df_combined = pd.concat([df_combined, df_subset])
    
    return df_remainer, df_combined



def get_type_pivot(df, columns_name):
    '''
    Creates pivot table with meta_type_name as an index
    '''
    
    df_pivot = pd.pivot_table(data = df,
                              index = "meta_type_name",
                              columns = columns_name,
                              values = "number|event",
                              aggfunc = "count",
                              fill_value = 0)

    if columns_name == "registrationConvocation":
        df_pivot = df_pivot[['Undefined', 'III скликання', 'IV скликання', 
                             'V скликання', 'VI скликання', 'VII скликання', 
                             'VIII скликання', 'IX скликання']]
    
    # Sum by row
    df_pivot.loc[:, 'Total'] = df_pivot.sum(axis=1)
    df_pivot.sort_values('Total', ascending=False, inplace=True)
    df_pivot.loc[:, 'Total, %'] = np.round(df_pivot.Total / df_pivot.Total.sum() * 100, 4)

    # Sum by column
    column_sum = df_pivot.sum()
    column_sum_classified = df_pivot[df_pivot.index != "not classified"].sum()
    column_sum_classified_share = np.round(column_sum_classified / column_sum * 100, 4)
    
    df_pivot.reset_index(inplace=True)
    df_pivot.columns.name = ''
    df_pivot.loc[len(df_pivot), :] = ['Total'] + list(column_sum)
    df_pivot.loc[len(df_pivot), :] = ['Classified, %'] + list(column_sum_classified_share)
    
    return df_pivot