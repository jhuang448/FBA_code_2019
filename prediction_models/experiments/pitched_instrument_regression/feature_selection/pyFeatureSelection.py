#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 26 14:44:47 2019

Features Analysis & Feature Selection

@author: caspia
"""

import os
import scipy.io as sio
import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

matDir = '/Users/caspia/Desktop/Github/FBA_code_2019/src/prediction_models/experiments/pitched_instrument_regression/dataPyin/'
os.chdir(matDir)
'''
FeatureList = {'middleAlto Saxophone5_std_': np.arange(68), \
               'middleAlto Saxophone5_nonscore_': np.arange(24), \
               'middleAlto Saxophone5_score revDTW_noteratio0220_': np.arange(26), \
               'middleAlto Saxophone5_score revDTW_fullset0219_': np.arange(26, 33), \
               'middleAlto Saxophone5_score revDTW_fullset0220_': np.arange(26, 32), \
               'middleAlto Saxophone5_score revDTW_noteratio0220mix_': np.arange(32, 36) \
               }
'''
FeatureList = {'middleAlto Saxophone2_std_': np.arange(68), \
               'middleAlto Saxophone2_nonscore_': np.arange(24), \
               'middleAlto Saxophone2_score revDTW_fullset_': np.arange(43)
               }
FeatureNum = 68+24+22+4+7+6+4
DataSize = {2013: 120, 2014: 149, 2015: 122}

def combineAllFeatures():
    AllFeatures = np.empty(shape = [0, FeatureNum])
    AllLabels = np.empty(shape = [0, 4])
    AllIds = np.empty(shape = [0, 1])
    for year in np.arange(2013, 2016):
        featureYear = np.empty(shape = [DataSize[year], 0])
        for file in FeatureList:
            filename = file + str(year)
            matFile = sio.loadmat(filename)
            featureYear = np.concatenate((featureYear,matFile['features'][:, FeatureList[file]]), axis = 1)
            labelYear = matFile['labels']
            idsYear = matFile['student_ids']
        AllFeatures = np.concatenate((AllFeatures, featureYear), axis = 0)
        AllLabels = np.concatenate((AllLabels, labelYear), axis = 0)
        AllIds = np.concatenate((AllIds, idsYear), axis = 0)
    return AllFeatures, AllLabels, AllIds
            
def runPCA(features):
    features = StandardScaler().fit_transform(features)
    pca = PCA(.95)
    pca.fit(features)
    v_ratio = pca.explained_variance_ratio_
    y_pos = np.arange(len(v_ratio))
    plt.bar(y_pos, v_ratio, align='center', alpha=0.5)
    plt.title('explained_variance_ratio')
    plt.show()
    
    plt.figure(figsize=(200,200))
    mtx = np.cov(features.T)
    plt.matshow(mtx)
    
    principalComponents = pca.fit_transform(features)
    
    return v_ratio, principalComponents
    

if __name__ == '__main__':
    features, labels, student_ids = combineAllFeatures()
    v_ratio, pcaFeatures = runPCA(features)
        