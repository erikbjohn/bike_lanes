from typing import List

from tensorflow.keras.models import Model, load_model, Sequential
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.layers import Dense, Dropout, concatenate, Input, Reshape, Flatten, GlobalAveragePooling2D
from tensorflow.keras.applications import VGG16
# from tensorflow.keras.applications import imagenet_utils
# from tensorflow.keras.preprocessing.image import img_to_array, load_img
from tensorflow.keras.callbacks import ModelCheckpoint
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
import numpy as np
import pandas as pd
import cv2
import locale
import pickle
import random
import os
import sys
import getpass

print("\n Running Training \n")


# Flags
preprocess_images = 1

# fetch directory of this script
#data_path = os.path.dirname("/home/ebjohnson5/Dropbox/pkg.data/lincoln/clean/")
pic_raw_path = os.path.dirname("/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/raw/training_data")
pic_processed_path = os.path.dirname("/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/clean/images224/")
tensor_model_path = os.path.dirname('/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/models/')
training_csv_path = '/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/clean/df_training.csv'
sat21_path = '/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/clean/sat21.npy'
university_blvd_path = '/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/clean/university_blvd.npy'
model_path = '/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/models/first_model.h5'