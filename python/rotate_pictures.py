import cv2
import locale
import pickle
import random
import os
from os import listdir
import sys
import numpy as np

pic_raw_path = os.path.dirname("/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/raw/training_data/")

onlyfiles = [f for f in os.listdir(pic_raw_path) if os.path.isfile(os.path.join(pic_raw_path, f))]

file_paths = []
for file in onlyfiles:
    file_path = pic_raw_path + '/' + file
    image = cv2.imread(file_path)
    file_clean = file.replace(".png", "")

    img_rot_90 = cv2.rotate(image, cv2.ROTATE_90_CLOCKWISE)
    file_path_rot_90 = pic_raw_path + '/' + file_clean + '-rotate_90.png'
    cv2.imwrite(file_path_rot_90, img_rot_90)

    img_rot_180 = cv2.rotate(image, cv2.ROTATE_180)
    file_path_rot_180 = pic_raw_path + '/' + file_clean + '-rotate_180.png'
    cv2.imwrite(file_path_rot_180, img_rot_180)

    img_rot_270 = cv2.rotate(image, cv2.ROTATE_90_COUNTERCLOCKWISE)
    file_path_rot_270 = pic_raw_path + '/' + file_clean + '-rotate_270.png'
    cv2.imwrite(file_path_rot_270, img_rot_270)
