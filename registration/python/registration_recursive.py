# -*- coding: utf-8 -*-
"""
Created on Tue Jan 18 16:59:12 2022

@author: pmuza
"""

#%% Import settings and packages
from __future__ import division
import os, sys, time

#Set your working directory here
dname = " " #PATH TO WORKING DIRECTORY 
os.chdir(dname)


#%% Import registration_main script and execute registration
start = time.time()

sys.path.insert(1," ") PATH TO PYTHON REGISTRATION FOLDER
import registration_script


list_of_subfolders = [f.path for f in os.scandir(os.getcwd()) if f.is_dir()]
for folder in list_of_subfolders:
        os.chdir(folder)
        registration_IN.main()

print("It took: {} seconds to process these folders".format(time.time() - start))


