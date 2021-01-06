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

print("\n[[[ CHECKING AND PREPROCESSING NEW IMAGES ]]]\n")
# Convert the images down from the original scraped sizes
# datasets.preprocess_images(pic_raw_path, pic_processed_path)

df = pd.read_csv(training_csv_path)

if os.path.isfile(sat21_path) :
    print('\n Loading saved np images')
    images = np.load(sat21_path)
else :
    images = []
    for row in df.iterrows():
        # resize all images in ./images to 224x224 for vgg, then
        # save in ./images224
        #imgPath = os.path.sep.join([inputPath, "images", imgName])
        imageName = row[1]['fname']
        #print("\n ", imageName)
        imagePath = os.path.expanduser(row[1]['fpath'])
        image = cv2.imread(imagePath)
        image = cv2.resize(image, (224, 224))
        image = image/255.0
        cv2.imwrite(os.path.sep.join([pic_processed_path, imageName]), image)
        images.append(image)
    np.save(sat21_path, images)
    print("\n image conversion to 224 complete")

split = train_test_split(df, images, test_size=0.20, random_state=5)

print('Split complete')
(train_df, test_df, train_imgs, test_imgs) = split
trainY = np.array(train_df['width']).reshape(-1,1)
testY = np.array(test_df['width']).reshape(-1,1)

cs= MinMaxScaler()
trainY = cs.fit_transform(trainY)
testY = cs.transform(testY)

if os.path.exists(model_path):
    print("\n   ", model_path, "FOUND, LOADING SAVED WEIGHTS \n")
    model = load_model(model_path)
else:
    vgg = VGG16(include_top=False, input_shape=(224, 244, 3), pooling='avg')
    for layer in vgg.layers:
        layer.trainable = False
        # Check the trainable status of the individual layers
        # for layer in vgg.layers:
        # print(layer, layer.trainable)
    flat1 = Flatten()(vgg.output)
    feat1 = Dense(48, activation="relu")(flat1)
    drop1 = Dropout(0.4)(feat1)
    output = Dense(1, activation="linear")(drop1)
    model = Model(inputs=vgg.inputs, outputs=output)
    model.summary()
    #opt = Adam(lr=1e-3, decay=1e-6, clipnorm=1.0, clipvalue=0.5)
    opt = Adam(lr=1e-3, decay=1e-6)
    model.compile(loss="mse", optimizer=opt)

    checkpoint_cb = ModelCheckpoint(model_path, save_best_only=True)
    history = model.fit(train_imgs, trainY, epochs=500, batch_size=16, validation_data=(test_imgs, testY), callbacks=[checkpoint_cb])

    print('model calibration done')

predictions_output_path = os.path.dirname('/home/ebjohnson5/Documents/Github/bike_lanes/predictions/')
trainPreds = model.predict(train_imgs)
train_save_location = os.path.sep.join([predictions_output_path, 'training_predictions.csv'])
pd_dataset_train = pd.DataFrame({'locationid': train_df['location_id'],
                           'actual_width': train_df['width'],
                          'predicted_width': cs.inverse_transform(trainPreds).reshape(-1)})
pd_dataset_train.to_csv(train_save_location, index=False)

testPreds = model.predict(test_imgs)
test_save_location = os.path.sep.join([predictions_output_path, 'testing_predictions.csv'])
pd_dataset_test = pd.DataFrame({'locationid': test_df['location_id'],
                           'actual_width': test_df['width'],
                          'predicted_width': cs.inverse_transform(testPreds).reshape(-1)})
pd_dataset_test.to_csv(test_save_location, index=False)

# Check out how model predicts on University BLVD
university_blvd_raw_path = os.path.dirname("/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/raw/university_blvd_snapshots/")
university_blvd_np_path = "/home/ebjohnson5/Dropbox/pkg.data/bike_lanes/data/clean/university_blvd_snapshots.npy"
onlyfiles: List[str] = [f for f in os.listdir(university_blvd_raw_path) if os.path.isfile(os.path.join(university_blvd_raw_path, f))]
if os.path.isfile(university_blvd_np_path):
    university_blvd_images = np.load(university_blvd_np_path)
else:

    university_blvd_images = []
    for file in onlyfiles:
        file_path = university_blvd_raw_path + '/' + file
        image = cv2.imread(file_path)
        image = cv2.resize(image, (224, 224))
        image = image / 255.0
        university_blvd_images.append(image)
    np.save(university_blvd_np_path, university_blvd_images)
    university_blvd_images = np.load(university_blvd_np_path)

university_blvd_predictions = model.predict(university_blvd_images)
university_blvd_save_location = os.path.sep.join([predictions_output_path, 'university_blvd_predictions.csv'])
pd_university_blvd_predictions = pd.DataFrame({'fname': onlyfiles,
                                               'predicted_width': cs.inverse_transform(university_blvd_predictions).reshape(-1)})
pd_university_blvd_predictions.to_csv(university_blvd_save_location, index=False)

