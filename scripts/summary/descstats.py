''' Write out descriptive statistics using a pre-made template '''

#%% preamble
import numpy as np 
import pandas as pd 
from os import chdir
from os.path import dirname, realpath

try:
    path = dirname(dirname(dirname(realpath(__file__))))
except NameError:
    path = '/Users/usenk/Desktop/Master Thesis/thesis_revised'
    
chdir(path)

data = pd.read_stata('./output/data/thesisdata.dta')

#%%
# add variables identifying Panel A and Panel B
panelA_vars = ['dlrdeposits_hhs_w', 'election', 'inflation_cpi_lag', 'lrgdppc_usd_lag', 
               'dlrgdp_lcu_lag', 'unempl_ilo_lag', 'capitaltoassets_lag', 'depositstogdp_lag', 
               'liqratio_lag', 'hf_prights_lag', 'ti_cpi_lag', 'lowpolcon', 'dlrdeposits_hhs_w_lag']
data.loc[:, 'panelA'] = 0
data.loc[np.all(pd.notnull(data[panelA_vars]), axis=1), 'panelA'] = 1

panelB_vars = ['dlrloans_w', 'election', 'inflation_cpi_lag', 'lrgdppc_usd_lag',
               'dlrgdp_lcu_lag', 'unempl_ilo_lag', 'capitaltoassets_lag', 
               'liqratio_lag', 'credittodeposits_lag', 'bankconcentr_lag', 
               'hf_prights_lag', 'ti_cpi_lag', 'lowpolcon', 'dlrloans_w_lag']
data.loc[:, 'panelB'] = 0
data.loc[np.all(pd.notnull(data[panelB_vars]), axis=1), 'panelB'] = 1


# add vars
data.eval('intercb1_high = election - intercb1', inplace=True)
data.loc[pd.isnull(data['lowpolcon']), 'intercb1_high'] = np.nan

data.eval('interdi_no = election - interdi', inplace=True)
data.loc[pd.isnull(data['depinsurance_lag']), 'interdi_no'] = np.nan

#%%
# descr stats
# first part of the table
election_vars = ['election', 'intercb1', 'intercb1_high', 'clelec', 
                 'sureelec', 'interdi_no', 'interdi', 'interright', 
                 'intercent', 'interleft']

election_stats = pd.DataFrame({'Panel A': data.loc[data['panelA'] == 1, election_vars].sum(),
                               'Panel B': data.loc[data['panelB'] == 1, election_vars].sum()})
election_statslist = election_stats.values.tolist()
election_values_list = []
for x in election_statslist:
    election_values_list.extend(x)
    
election_values_list = ['{' + str(int(x)) + '}' for x in election_values_list]

table_first_part = '''\\textbf{{Elections:}} & & & & & & & & & & \\\\
Total N. of elections     &         \\multicolumn{{5}}{{c|}}{} & \\multicolumn{{5}}{{c}}{} \\\\
\\hspace{{2mm}} \\textit{{of which}}  & & & & & & & & & & \\\\
with weak C\\&B           &          \\multicolumn{{5}}{{c|}}{} & \\multicolumn{{5}}{{c}}{} \\\\
with high C\\&B           &          \\multicolumn{{5}}{{c|}}{} &   \\multicolumn{{5}}{{c}}{} \\\\
close elections     &          \\multicolumn{{5}}{{c|}}{} &   \\multicolumn{{5}}{{c}}{} \\\\
certain elections   &          \\multicolumn{{5}}{{c|}}{} &     \\multicolumn{{5}}{{c}}{} \\\\
with no explicit dep. insurance&          \\multicolumn{{5}}{{c|}}{} & \\multicolumn{{5}}{{c}}{} \\\\
with explicit dep. insurance&          \\multicolumn{{5}}{{c|}}{} &    \\multicolumn{{5}}{{c}}{} \\\\
with right-wing incumbent&          \\multicolumn{{5}}{{c|}}{} &        \\multicolumn{{5}}{{c}}{} \\\\
with centrist incumbent  &          \\multicolumn{{5}}{{c|}}{} &       \\multicolumn{{5}}{{c}}{} \\\\
with left-wing incumbent &          \\multicolumn{{5}}{{c|}}{} &       \\multicolumn{{5}}{{c}}{} \\\\
'''.format(*election_values_list)

#%%
# second part of the table
other_vars_1 = ['dlrdeposits_hhs_w', 'inflation_cpi_lag', 'lrgdppc_usd_lag', 
              'dlrgdp_lcu_lag', 'unempl_ilo_lag', 'capitaltoassets_lag',
              'depositstogdp_lag', 'liqratio_lag', 'credittodeposits_lag',
              'bankconcentr_lag', 'hf_prights_lag', 'ti_cpi_lag']

other_vars_2 = ['dlrloans_w', 'inflation_cpi_lag', 'lrgdppc_usd_lag', 
              'dlrgdp_lcu_lag', 'unempl_ilo_lag', 'capitaltoassets_lag',
              'depositstogdp_lag', 'liqratio_lag', 'credittodeposits_lag',
              'bankconcentr_lag', 'hf_prights_lag', 'ti_cpi_lag']

other_stats = data.loc[data['panelA'] == 1, other_vars_1].describe().loc[
    ['mean', '50%', 'min', 'max', 'std'], :].T
other_stats.columns = [('Panel A', x) for x in other_stats]

other_stats_tmp = data.loc[data['panelB'] == 1, other_vars_2].describe().loc[
    ['mean', '50%', 'min', 'max', 'std'], :].T
other_stats_tmp.columns = [('Panel B', x) for x in other_stats]
other_stats = pd.concat([other_stats, other_stats_tmp], axis=1, sort=False)

order_list = other_stats.index.values.tolist()
order_list = ['dlrdeposits_hhs_w', 'dlrloans_w'] + order_list[1:-1]


other_stats = other_stats.reindex(order_list)
other_stats_list = []
for i, row in other_stats.iterrows():
    tmp_list = [round(x, 2) for x in row.tolist()]
    tmp_list = [int(x) if x % 1 == 0 else x for x in tmp_list]
    tmp_list = [str(x) if pd.notnull(x) else ' ' for x in tmp_list]
    other_stats_list.append(' & '.join(tmp_list))

# add count
count = [data.loc[data['panelA'] == 1, other_vars_1].describe().loc['count'].iloc[0],
        data.loc[data['panelB'] == 1, other_vars_2].describe().loc['count'].iloc[0]]
count = ['{' + str(int(x)) + '}' for x in count]

other_stats_list = other_stats_list + count

table_second_part = '''\\hline
                    &        Mean &   Median&   Min&    Max&      SD&        Mean&  Median&      Min&     Max&   SD\\\\
\\hline
\\textbf{{Dependent variables:}} & & & & & & & & & & \\\\
$\\text{{Real HH deposit growth}}_{{it}}$ &        {} \\\\
$\\text{{Real loan growth}}_{{it}}$ &         {} \\\\
 & & & & & & & & & & \\\\
\\textbf{{Macroeconomic variables:}} & & & & & & & & & & \\\\
$\\text{{Inflation CPI}}_{{it-1}}$   &       {} \\\\
$\\log(\\text{{Real GDP per capita}}_{{it-1}})$ &     {} \\\\
$\\text{{Real GDP growth}}_{{it-1}}$ &        {} \\\\
$\\text{{Unemployment}}_{{it-1}}$    &        {} \\\\
 & & & & & & & & & & \\\\
\\textbf{{Banking system variables:}} & & & & & & & & & & \\\\
$\\text{{Capital ratio}}_{{it-1}}$   &      {} \\\\
$\\text{{Deposits to GDP}}_{{it-1}}$ &      {} \\\\
$\\text{{Liquidity ratio}}_{{it-1}}$  &     {} \\\\
$\\text{{Credit to deposits}}_{{it-1}}$&      {} \\\\
$\\text{{Bank concentration}}_{{it-1}}$   &    {} \\\\
 & & & & & & & & & & \\\\
\\textbf{{Institutional variables:}} & & & & & & & & & & \\\\
$\\text{{Property rights}}_{{it-1}}$ &      {} \\\\
$\\text{{Corruption perception}}_{{it-1}}$ &    {} \\\\
\\hline
Observations        &         \\multicolumn{{5}}{{c|}}{} &        \\multicolumn{{5}}{{c}}{}  \\\\
\\hline
'''.format(*other_stats_list)

#%%
# add preamble and footnote

preamble = '''{
\\def\\sym#1{\\ifmmode^{#1}\\else\\(^{#1}\\)\\fi}
\\renewcommand*{\\arraystretch}{0.8}
\\begin{longtable}{l*{2}{|ccccc}}
\\caption{Descriptive Statistics\\label{descrstat1}}\\\\
\\hline
					& \\multicolumn{5}{c|}{Sample A} & \\multicolumn{5}{c}{Sample B} \\\\
\\hline
\\endfirsthead
\\multicolumn{11}{r}{\\textit{Table~\\ref{descrstat1} continued}} \\\\
\\hline
					& \\multicolumn{5}{c|}{Sample A} & \\multicolumn{5}{c}{Sample B} \\\\
\\hline
                    &        Mean &   Median&   Min&    Max&      SD&        Mean&  Median&      Min&     Max&   SD\\\\
\\hline
\\endhead
\\hline
\\endfoot\\endlastfoot
'''

footnote = '''\\multicolumn{11}{m{22cm}}{\\setstretch{1}\\footnotesize This table reports summary statistics, i.e., mean, median, standard deviation, minimum and maximum, for macroeconomic, banking and institutional regressors, as well as for the dependent variables. In addition, the table shows how executive elections are distributed across types relevant for the analysis. Sample A comprises observations which are usable in the baseline regression -- Equation~\\eqref{model1} -- when $\\text{Real HH deposit growth}_{it}$ is the dependent variable, and Sample B -- when $\\text{Real loan growth}_{it}$ is the dependent variable. Dependent variables, banking-system variables and macroeconomic variables, apart from $\\log(\\text{Real GDP per capita}_{it-1})$, are measured in percent. $\\log(\\text{Real GDP per capita}_{it-1})$ is measured in log-units, while $\\text{Property rights}_{it-1}$ is an index that ranges from 0 (worst) to 100 (best) and $\\text{Corruption perception}_{it-1}$ -- an index that ranges from 0 (most corrupt) to 100 (least corrupt). $\\text{Liquidity ratio}_{it-1}$ stands for liquid assets to deposits and short-term funding.}
\\end{longtable}

}'''


output = preamble + table_first_part + table_second_part + footnote

# write out
with open('./output/tables/descrstats.tex', 'w') as f:
    f.write(output)