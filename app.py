import os
import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import img_to_array, load_img
from flask import Flask, request, render_template, url_for, jsonify
from werkzeug.utils import secure_filename
from flask_cors import CORS  

# Initialize Flask app
app = Flask(__name__, static_folder='Static', template_folder='templates')
CORS(app) 
app.config['UPLOAD_FOLDER'] = os.path.join('Static', 'uploads')

# Load model
model = load_model("Upload/model.h5")

# Class labels
labels = {
    0: 'Brown rust',
    1: 'Healthy',
    2: 'Loose Smut',
    3: 'Septorial',
    4: 'Yellow rust'
}

# -------------------- ROUTES --------------------

# Home route for website
@app.route('/')
def index():
    return render_template('index.html')

# Web form prediction route
@app.route('/predict', methods=['POST'])
def predict_web():
    if 'image' not in request.files or request.files['image'].filename == '':
        return render_template('index.html', label=None)

    image = request.files['image']
    filename = secure_filename(image.filename)
    image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    image.save(image_path)

    # Preprocess
    img = load_img(image_path, target_size=(224, 224))
    img = img_to_array(img)
    img = np.expand_dims(img, axis=0) / 255.0

    # Predict
    prediction = model.predict(img)
    label = labels[np.argmax(prediction)]

    image_url = url_for('static', filename='uploads/' + filename)
    return render_template('index.html', label=label, image_url=image_url)

# API prediction route (for Flutter)
@app.route('/predict-api', methods=['POST'])
def predict_api():
    if 'file' not in request.files or request.files['file'].filename == '':
        return jsonify({'error': 'No image uploaded'}), 400

    image = request.files['file']
    filename = secure_filename(image.filename)
    image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    image.save(image_path)

    # Preprocess
    img = load_img(image_path, target_size=(224, 224))
    img = img_to_array(img)
    img = np.expand_dims(img, axis=0) / 255.0

    # Predict
    prediction = model.predict(img)
    confidence = float(round(np.max(prediction) * 100, 2))
    label = labels[np.argmax(prediction)]

    # Return JSON
    return jsonify({
        'prediction': label,
        'confidence': confidence
    })

# -------------------- MAIN --------------------

if __name__ == '__main__':
    # Ensure it's accessible from mobile devices on LAN
    app.run(host='0.0.0.0', port=5000, debug=True)
