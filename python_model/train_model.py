"""
Script d'entraînement du modèle de prédiction de sécheresse
pour AgriAlert BF

Ce script crée un modèle simple de Machine Learning qui prédit
le risque de sécheresse basé sur des données météorologiques.

Le modèle sera ensuite converti en TensorFlow Lite pour être
embarqué dans l'application mobile Flutter.

Auteur: Équipe AgriAlert BF
Date: 2026
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
import json

def generate_synthetic_data(n_samples=1000):
    """
    Génère des données synthétiques pour l'entraînement
    
    Dans une version de production, ces données seraient remplacées
    par des données réelles historiques du Burkina Faso
    """
    np.random.seed(42)
    
    # Features: précipitations cumulées (mm), température moyenne (°C), humidité (%)
    precipitation_7days = np.random.uniform(0, 150, n_samples)
    temperature_avg = np.random.uniform(20, 45, n_samples)
    humidity_avg = np.random.uniform(10, 80, n_samples)
    
    # Calcul du risque de sécheresse (target)
    # Formule simplifiée basée sur les conditions sahéliennes
    risk_score = np.zeros(n_samples)
    
    for i in range(n_samples):
        # Facteur précipitation (plus important: 50%)
        if precipitation_7days[i] < 20:
            precip_factor = 0.9
        elif precipitation_7days[i] < 50:
            precip_factor = 0.5
        elif precipitation_7days[i] < 100:
            precip_factor = 0.2
        else:
            precip_factor = 0.0
        
        # Facteur température (30%)
        if temperature_avg[i] > 40:
            temp_factor = 0.9
        elif temperature_avg[i] > 35:
            temp_factor = 0.6
        elif temperature_avg[i] > 30:
            temp_factor = 0.3
        else:
            temp_factor = 0.0
        
        # Facteur humidité (20%)
        if humidity_avg[i] < 25:
            humid_factor = 0.9
        elif humidity_avg[i] < 40:
            humid_factor = 0.6
        elif humidity_avg[i] < 60:
            humid_factor = 0.3
        else:
            humid_factor = 0.0
        
        # Score final
        risk_score[i] = (
            precip_factor * 0.50 +
            temp_factor * 0.30 +
            humid_factor * 0.20
        )
        
        # Ajouter du bruit réaliste
        risk_score[i] += np.random.normal(0, 0.05)
        risk_score[i] = np.clip(risk_score[i], 0, 1)
    
    # Créer le DataFrame
    data = pd.DataFrame({
        'precipitation_7days': precipitation_7days,
        'temperature_avg': temperature_avg,
        'humidity_avg': humidity_avg,
        'drought_risk': risk_score
    })
    
    return data

def train_model(data):
    """
    Entraîne un modèle Random Forest pour la prédiction
    """
    # Séparer features et target
    X = data[['precipitation_7days', 'temperature_avg', 'humidity_avg']]
    y = data['drought_risk']
    
    # Split train/test
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Normalisation
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Entraînement du modèle
    model = RandomForestRegressor(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    
    model.fit(X_train_scaled, y_train)
    
    # Évaluation
    train_score = model.score(X_train_scaled, y_train)
    test_score = model.score(X_test_scaled, y_test)
    
    print(f"Score d'entraînement: {train_score:.4f}")
    print(f"Score de test: {test_score:.4f}")
    
    # Sauvegarder les paramètres de normalisation
    scaler_params = {
        'mean': scaler.mean_.tolist(),
        'scale': scaler.scale_.tolist()
    }
    
    with open('scaler_params.json', 'w') as f:
        json.dump(scaler_params, f)
    
    return model, scaler

def convert_to_tflite(model, scaler, X_sample):
    """
    Convertit le modèle en TensorFlow Lite pour Flutter
    """
    # Créer un modèle TensorFlow simple qui reproduit le Random Forest
    # Pour simplifier, on utilise un réseau de neurones dense
    
    # Créer des données d'entraînement pour le réseau de neurones
    X_train = np.random.uniform(
        [0, 20, 10],  # min values
        [150, 45, 80],  # max values
        (1000, 3)
    )
    X_train_scaled = scaler.transform(X_train)
    y_train = model.predict(X_train_scaled)
    
    # Créer le modèle TensorFlow
    tf_model = tf.keras.Sequential([
        tf.keras.layers.Dense(32, activation='relu', input_shape=(3,)),
        tf.keras.layers.Dense(16, activation='relu'),
        tf.keras.layers.Dense(8, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid')
    ])
    
    tf_model.compile(
        optimizer='adam',
        loss='mse',
        metrics=['mae']
    )
    
    # Entraîner le modèle TensorFlow
    tf_model.fit(
        X_train_scaled,
        y_train,
        epochs=50,
        batch_size=32,
        verbose=0
    )
    
    # Convertir en TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(tf_model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    # Sauvegarder
    with open('drought_model.tflite', 'wb') as f:
        f.write(tflite_model)
    
    print("Modèle TFLite sauvegardé: drought_model.tflite")
    print(f"Taille du modèle: {len(tflite_model) / 1024:.2f} KB")
    
    return tflite_model

def main():
    """
    Fonction principale d'entraînement
    """
    print("=" * 60)
    print("AGRIALERT BF - Entraînement du Modèle de Prédiction")
    print("=" * 60)
    print()
    
    # Générer les données
    print("1. Génération des données synthétiques...")
    data = generate_synthetic_data(n_samples=2000)
    print(f"   {len(data)} échantillons générés")
    print()
    
    # Entraîner le modèle
    print("2. Entraînement du modèle Random Forest...")
    model, scaler = train_model(data)
    print()
    
    # Convertir en TFLite
    print("3. Conversion en TensorFlow Lite...")
    X_sample = data[['precipitation_7days', 'temperature_avg', 'humidity_avg']].values
    convert_to_tflite(model, scaler, X_sample)
    print()
    
    # Test du modèle
    print("4. Test du modèle...")
    test_cases = [
        ([5, 42, 15], "Risque ÉLEVÉ"),
        ([50, 32, 45], "Risque MODÉRÉ"),
        ([120, 28, 65], "Risque FAIBLE"),
    ]
    
    for features, expected in test_cases:
        features_scaled = scaler.transform([features])
        prediction = model.predict(features_scaled)[0]
        print(f"   Précip: {features[0]}mm, Temp: {features[1]}°C, Humid: {features[2]}%")
        print(f"   → Score: {prediction:.2f} ({expected})")
    
    print()
    print("=" * 60)
    print("Entraînement terminé avec succès!")
    print("Fichiers générés:")
    print("  - drought_model.tflite (modèle pour Flutter)")
    print("  - scaler_params.json (paramètres de normalisation)")
    print("=" * 60)

if __name__ == "__main__":
    main()
