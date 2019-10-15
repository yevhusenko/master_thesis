''' Plot coefficients of basic regressions with standard errors
    clustered on country level '''

#%% PREAMBLE
import numpy as np 
import pandas as pd 
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt 
import matplotlib.gridspec as gridspec
import seaborn as sns
from os import chdir
from os.path import dirname, realpath

sns.set()
sns.set_style('ticks')

try:
    path = dirname(dirname(dirname(realpath(__file__))))
except NameError:
    path = '/Users/usenk/Desktop/Master Thesis/thesis_revised'
    
chdir(path)

mainDF = pd.read_stata('./output/data/thesisdata.dta')
mainDF.dropna(subset=['dlrdeposits_hhs_w'], inplace=True)

mainDF.eval('nonelection = 1 - election', inplace=True)

#%% ESTIMATE MODELS
coefs = {}
conf_ints = {}
def get_estimates(data, name):
    model = smf.ols('dlrdeposits_hhs_w ~ nonelection + election - 1 ', 
                        data=data).fit(cov_type='cluster', 
                                        cov_kwds={'groups': data['ccode']})

    coefs[name] = model.params
    tmp_conf_ints = model.conf_int(alpha=0.05, cols=None).stack().droplevel(level=-1)
    # tmp_conf_ints.drop(columns='level_1', inplace=True)
    # tmp_conf_ints.rename(columns={'level_0': 'election', 0: 'conf_int'}, inplace=True)
    conf_ints[name] = tmp_conf_ints

# full sample
get_estimates(mainDF, 'full')

# divide by political constraints
get_estimates(mainDF.query('lowpolcon == 0'), 'lowpolcon')
get_estimates(mainDF.query('lowpolcon == 1'), 'highpolcon')

# divide by deposit insurance status
get_estimates(mainDF.query('depinsurance_lag == 1'), 'ins')
get_estimates(mainDF.query('depinsurance_lag == 0'), 'noins')

# divide by political platform of the incumbent
get_estimates(mainDF.query('platform1 == 1'), 'right')
get_estimates(mainDF.query('platform2 == 1'), 'center')
get_estimates(mainDF.query('platform3 == 1'), 'left')

# close vs nonclose vs no elections
clelec_model = smf.ols('dlrdeposits_hhs_w ~ clelec + sureelec + nonelection - 1 ', 
            data=mainDF).fit(cov_type='cluster', 
            cov_kwds={'groups': mainDF.dropna(subset=['clelec', 'sureelec'])['ccode']})
                        
clelec_coefs = pd.DataFrame({'parameter': clelec_model.params}).reset_index().rename(columns={'index': 'election'})
clelec_coefs.loc[:, 'election'] = clelec_coefs['election'].replace(
    {'clelec': 0, 'sureelec': 1, 'nonelection': 2})

clelec_ci = clelec_model.conf_int(alpha=0.05, cols=None).stack().droplevel(level=-1)
clelec_ci = clelec_ci.to_frame('conf_int')
clelec_ci = clelec_ci.reset_index().rename(columns={'index': 'election'})
clelec_ci.loc[:, 'election'] = clelec_ci['election'].replace(
    {'clelec': 0, 'sureelec': 1, 'nonelection': 2})

#%% CONSTRUCT DATAFRAMES FOR PLOTTING
coefsDF = pd.DataFrame(coefs).reset_index().rename(columns={'index': 'nonelection'})
conf_ints_DF = pd.DataFrame(conf_ints).reset_index().rename(columns={'index': 'nonelection'})

coefsDF.loc[:, 'nonelection'] = coefsDF['nonelection'].replace({'nonelection': 1, 'election': 0})
conf_ints_DF.loc[:, 'nonelection'] = conf_ints_DF['nonelection'].replace({'nonelection': 1, 'election': 0})


#%% PLOT #1: Full and checks & balances

fig, (ax1, ax2) = plt.subplots(nrows=1, ncols=2, sharey=True, figsize=(8, 5))

ax1.scatter(coefsDF['full'], coefsDF['nonelection'], color='navy', label='Baseline')

ax1.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'full'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'nonelection'], 
         marker='|', color='navy')

ax1.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'full'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'nonelection'],
         marker='|', color='navy')

ax1.set_xticks(range(2, 11, 2))
ax1.set_yticks([0, 1])
ax1.set_yticklabels(['Election years', 'Non-election years'])
ax1.set_ylim(-0.5, 1.5)
ax1.set_title('Panel A')

ax2.scatter(coefsDF['lowpolcon'], coefsDF['nonelection'] - 0.2, color='red', label='Strong C&B')
ax2.scatter(coefsDF['highpolcon'], coefsDF['nonelection'] + 0.2, color='green', label='Weak C&B')

ax2.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'lowpolcon'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'nonelection'] - 0.2, 
         marker='|', color='red')

ax2.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'lowpolcon'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'nonelection'] - 0.2,
         marker='|', color='red')

ax2.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'highpolcon'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'nonelection'] + 0.2, 
         marker='|', color='green')

ax2.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'highpolcon'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'nonelection'] + 0.2,
         marker='|', color='green')

ax2.set_xticks(range(2, 11, 2))
ax2.set_title('Panel B')

fig.legend(ncol=3, loc='lower center', bbox_to_anchor=(0.5, 0))

sns.despine()
fig.tight_layout(rect=[0, 0.1, 1, 1])
# fig.show()
fig.savefig('./output/plots/res1.pdf', dpi=100)


#%% PLOT 2: by insurance status, political affiliation of the incumbent and 
# closeness
fig = plt.figure(figsize=(8, 8))
gs = gridspec.GridSpec(4, 4, figure=fig, wspace=0.5, hspace=0.5)

ax1 = plt.subplot(gs[:2, :2])
ax1.scatter(coefsDF['noins'], coefsDF['nonelection'] + 0.2, color='navy', 
            label='No deposit insurance')
ax1.scatter(coefsDF['ins'], coefsDF['nonelection'] - 0.2, color='red', 
            label='With deposit insurance')

ax1.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'noins'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'nonelection'] + 0.2, 
         marker='|', color='navy')

ax1.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'noins'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'nonelection'] + 0.2,
         marker='|', color='navy')

ax1.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'ins'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 1, 'nonelection'] - 0.2, 
         marker='|', color='red')

ax1.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'ins'], 
         conf_ints_DF.loc[conf_ints_DF['nonelection'] == 0, 'nonelection'] - 0.2,
         marker='|', color='red')

ax1.set_xticks(range(0, 16, 5))
ax1.set_yticks([0, 1])
ax1.set_yticklabels(['Election years', 'Non-election years'])
ax1.set_ylim(-0.5, 1.5)
ax1.set_title('Panel A')

ax2 = plt.subplot(gs[:2, 2:])
ax2.scatter(coefsDF['left'], coefsDF['nonelection'] - 0.25, color='orange', 
            label='Left-wing')
ax2.scatter(coefsDF['center'], coefsDF['nonelection'], color='green', 
            label='Centrist')
ax2.scatter(coefsDF['right'], coefsDF['nonelection'] + 0.25, color='darkgray', 
            label='Right-wing')

for i in [0, 1]: 
    ax2.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == i, 'left'], 
            conf_ints_DF.loc[conf_ints_DF['nonelection'] == i, 'nonelection'] - 0.25, 
            marker='|', color='orange')

    ax2.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == i, 'center'], 
            conf_ints_DF.loc[conf_ints_DF['nonelection'] == i, 'nonelection'], 
            marker='|', color='green')

    ax2.plot(conf_ints_DF.loc[conf_ints_DF['nonelection'] == i, 'right'], 
            conf_ints_DF.loc[conf_ints_DF['nonelection'] == i, 'nonelection'] + 0.25,
            marker='|', color='darkgray')

ax2.set_xticks(range(0, 16, 5))
ax2.set_yticks([0,1])
ax2.set_yticklabels([])
ax2.set_title('Panel B')

ax3 = plt.subplot(gs[2:4, 1:3])
ax3.scatter(clelec_coefs['parameter'], clelec_coefs['election'], color='black',
            label='Full sample')

for i in [0, 1, 2]:
    ax3.plot(clelec_ci.loc[clelec_ci['election'] == i, 'conf_int'], 
            clelec_ci.loc[clelec_ci['election'] == i, 'election'], 
            marker='|', color='black')
    
ax3.set_xticks(range(2, 11, 2))
ax3.set_yticks([0, 1, 2])
ax3.set_yticklabels(['Close-election years', 'Certain-election years', 
                     'Non-election years'])
ax3.set_title('Panel C')

fig.legend(ncol=3, loc='lower center', bbox_to_anchor=(0.5, 0))

sns.despine()
# fig.tight_layout(rect=[0., 0, 1, 1])
# plt.show()
fig.savefig('./output/plots/res2.pdf', dpi=100, bbox_inches='tight')

#%%