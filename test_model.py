import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import load_img, img_to_array

# Load the trained model
model = load_model("Upload/model.h5")

# Define your label map
labels = {0: 'Healthy', 1: 'Powdery', 2: 'Rust'}

# Set your image path (replace this with your test image)
image_path = "Dataset/Test/Rust/rust.1.jpg" 

# === Step 1: Preprocess the image ===
img = load_img(image_path, target_size=(224, 224))  # Resize
img = img_to_array(img)                             # Convert to array
img = img / 255.0                                   # Normalize
img = np.expand_dims(img, axis=0)                   # Add batch dimension

# Predict
pred = model.predict(img)
predicted_label = labels[np.argmax(pred)]

# Output
print("Prediction Output:", pred)
print("Predicted Label:", predicted_label)