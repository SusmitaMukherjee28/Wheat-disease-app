import os
from tensorflow.keras.preprocessing.image import ImageDataGenerator

dataset_path = 'Dataset'  # Make sure this folder exists in your project

# Show the absolute path to verify it's correct
print("Absolute dataset path:", os.path.abspath(dataset_path))

# Image settings
img_size = (224, 224)
batch_size = 16

# ImageDataGenerator with validation split
datagen = ImageDataGenerator(rescale=1./255, validation_split=0.2)

# Load training set
train_generator = datagen.flow_from_directory(
    dataset_path,
    target_size=img_size,
    batch_size=batch_size,
    class_mode='categorical',
    subset='training',
    shuffle=True
)

# Load validation set
val_generator = datagen.flow_from_directory(
    dataset_path,
    target_size=img_size,
    batch_size=batch_size,
    class_mode='categorical',
    subset='validation',
    shuffle=False
)

# Print class indices and sample counts
print("Train classes:", train_generator.class_indices)
print("Train samples:", train_generator.samples)
print("Validation samples:", val_generator.samples)