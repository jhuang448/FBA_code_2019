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
from matplotlib.pyplot import tight_layout

matDir = '/Users/caspia/Desktop/Github/FBA_code_2019/src/prediction_models/experiments/pitched_instrument_regression/dataPyin/'
os.chdir(matDir)

FeatureList = {'middleAlto Saxophone5_score revDTW_SightReading_': np.arange(32)}
FeatureNum = 32
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
    hfont = {'fontname':'Arial'}
    fig = plt.figure()
    features = StandardScaler().fit_transform(features)
    pca = PCA()
    pca.fit(features)
    v_ratio = pca.explained_variance_ratio_
    y_pos = np.arange(len(v_ratio))
    plt.bar(y_pos+1, v_ratio, align='center', alpha=0.5)
    plt.xlabel('Component Index',fontsize = 15, **hfont)
    plt.ylabel('Explained Variance',fontsize = 15, **hfont)
    plt.show()
    fig.savefig("/Users/caspia/Documents/explained_var_sr.pdf", bbox_inches='tight')
    
    fig = plt.figure(figsize=(18,18))
    mtx = np.cov(features.T)
    mtx[mtx>1] = 1
    mtx = np.abs(mtx)
    im = plt.matshow(mtx)
    plt.yticks([4,9,14,19,24,29], [5,10,15,20,25,30], fontsize = 12,**hfont)
    plt.xticks([4,9,14,19,24,29], [5,10,15,20,25,30], fontsize = 12,**hfont)
    plt.xlabel('Feature Index',fontsize = 15, **hfont)
    plt.ylabel('Feature Index',fontsize = 15, **hfont)
    plt.gca().xaxis.set_label_position('top')
    cbar=plt.colorbar(im,fraction=0.046, pad=0.04)
    cbar.ax.tick_params(labelsize=12) 
    fig = plt.gcf()
    fig.savefig("/Users/caspia/Documents/cov_sr.pdf", bbox_inches='tight')
    fig = plt.figure(figsize=(600,600))
    
    principalComponents = pca.fit_transform(features)
    trans = pca.components_.T
    p = np.abs(pca.components_[0:5, :])
    #p[p<0.25] = 0
    im = plt.matshow(p,cmap='viridis')
    plt.xlabel('Feature Index',fontsize = 18, **hfont)
    plt.gca().xaxis.set_label_position('top')
    plt.yticks([0,1,2,3,4],['1st Comp','2nd Comp','3rd Comp', '4th Comp', '5th Comp'],fontsize=12, **hfont)
    plt.xticks([4,9,14,19,24,29], [5,10,15,20,25,30], fontsize = 12, **hfont)
    cbar=plt.colorbar(im)
    cbar.ax.tick_params(labelsize=12) 
    plt.clim(0, 0.4)
    fig = plt.gcf()
    fig.savefig("/Users/caspia/Documents/compo_sr.pdf", bbox_inches='tight')
    
    plt.show()
    
    
    
    
    # 0: 118:end
    # 1: 124:end
    # 2: 116:end
    st = np.array([118, 124, 116, 130, 131]) # sight-reading
    #st = np.array([117,117,123,128,128]) # technical
    i_group = []
    
    for i in np.arange(0):
        print(i)
        B = np.sort(np.abs(trans[:, i]))
        I = np.argsort(np.abs(trans[:, i]))
        i_group.append(I[st[i]:])
        plt.plot(B, '*')
        #plt.plot([st[i], st[i]], [0, 0.20], '-')
        plt.show()
        #plt.matshow(mtx[st[i]:,st[i]:])
        #plt.colorbar()
        #plt.show()
    
    
    return v_ratio, trans, mtx
    

if __name__ == '__main__':
    features, labels, student_ids = combineAllFeatures()

    v_ratio, trans, mtx = runPCA(features)
        