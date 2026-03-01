# Guide d'installation et de déploiement - AgriAlert BF

## Table des matières

1. [Configuration de l'environnement de développement](#configuration-environnement)
2. [Installation du projet](#installation-projet)
3. [Entraînement du modèle d'IA](#entrainement-modele)
4. [Configuration des APIs](#configuration-apis)
5. [Compilation et génération de l'APK](#compilation-apk)
6. [Tests et validation](#tests-validation)
7. [Dépôt pour PRESCI](#depot-presci)
8. [Résolution de problèmes](#resolution-problemes)

---

## 1. Configuration de l'environnement de développement

### Installation de Flutter

#### Windows

1. Télécharger Flutter SDK depuis https://flutter.dev/docs/get-started/install/windows
2. Extraire le fichier ZIP dans C:\src\flutter
3. Ajouter C:\src\flutter\bin au PATH système
4. Ouvrir une nouvelle invite de commande et exécuter:

```cmd
flutter doctor
```

#### Linux/macOS

```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

### Installation d'Android Studio

1. Télécharger Android Studio depuis https://developer.android.com/studio
2. Installer le SDK Android (niveau API 21 minimum)
3. Installer les plugins Flutter et Dart
4. Configurer un émulateur Android ou connecter un appareil physique

### Installation de VS Code (alternatif à Android Studio)

1. Télécharger VS Code depuis https://code.visualstudio.com/
2. Installer les extensions:
   - Flutter
   - Dart
   - Flutter Widget Snippets

### Installation de Python (pour le modèle d'IA)

```bash
# Ubuntu/Debian
sudo apt install python3 python3-pip

# Windows
# Télécharger depuis https://python.org

# Vérifier l'installation
python3 --version
pip3 --version
```

---

## 2. Installation du projet

### Clonage du repository

```bash
git clone https://github.com/votre-username/agrialert-bf.git
cd agrialert-bf
```

### Installation des dépendances Flutter

```bash
flutter pub get
```

Cette commande installe toutes les dépendances listées dans `pubspec.yaml`:
- google_fonts
- flutter_map
- geolocator
- tflite_flutter
- http
- shared_preferences
- provider
- etc.

### Vérification de l'installation

```bash
flutter doctor -v
```

Assurez-vous qu'il n'y a pas d'erreurs critiques (les avertissements sont acceptables).

---

## 3. Entraînement du modèle d'IA

### Installation des bibliothèques Python

```bash
cd python_model
pip3 install numpy pandas scikit-learn tensorflow
```

### Entraînement du modèle

```bash
python3 train_model.py
```

Le script va:
1. Générer 2000 échantillons de données synthétiques
2. Entraîner un modèle Random Forest
3. Convertir le modèle en TensorFlow Lite
4. Générer deux fichiers:
   - `drought_model.tflite` (modèle pour Flutter)
   - `scaler_params.json` (paramètres de normalisation)

### Copie du modèle dans les assets

```bash
cd ..
mkdir -p assets/models
mkdir -p assets/data
cp python_model/drought_model.tflite assets/models/
cp python_model/scaler_params.json assets/data/
```

---

## 4. Configuration des APIs

### Open-Meteo API

**Aucune configuration requise!** Open-Meteo est une API gratuite sans clé d'authentification.

L'application utilise les endpoints suivants:
- https://api.open-meteo.com/v1/forecast (prévisions)
- https://api.open-meteo.com/v1/forecast (historique)

### Configuration de la géolocalisation

#### Android (android/app/src/main/AndroidManifest.xml)

Ajoutez les permissions suivantes:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS (ios/Runner/Info.plist)

Ajoutez les clés suivantes:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>AgriAlert BF a besoin de votre position pour fournir des prévisions de sécheresse locales</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>AgriAlert BF a besoin de votre position pour fournir des prévisions de sécheresse locales</string>
```

---

## 5. Compilation et génération de l'APK

### Mode développement (debug)

Pour tester sur un émulateur ou un appareil connecté:

```bash
flutter run
```

### Génération de l'APK release

#### APK standard

```bash
flutter build apk --release
```

Le fichier APK se trouve dans:
`build/app/outputs/flutter-apk/app-release.apk`

#### APK optimisé par ABI (recommandé pour production)

```bash
flutter build apk --split-per-abi --release
```

Génère 3 APK optimisés:
- `app-armeabi-v7a-release.apk` (appareils 32-bit)
- `app-arm64-v8a-release.apk` (appareils 64-bit modernes)
- `app-x86_64-release.apk` (émulateurs)

#### Bundle Android (pour Google Play Store)

```bash
flutter build appbundle --release
```

Le fichier AAB se trouve dans:
`build/app/outputs/bundle/release/app-release.aab`

### Signature de l'APK (pour distribution)

1. Créer une clé de signature:

```bash
keytool -genkey -v -keystore ~/agrialert-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias agrialert
```

2. Créer `android/key.properties`:

```properties
storePassword=votre_mot_de_passe
keyPassword=votre_mot_de_passe
keyAlias=agrialert
storeFile=/chemin/vers/agrialert-key.jks
```

3. Modifier `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. Rebuilder l'APK:

```bash
flutter build apk --release
```

---

## 6. Tests et validation

### Tests unitaires

Créer des tests dans `test/`:

```dart
// test/drought_prediction_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:agrialert_bf/services/drought_prediction_service.dart';

void main() {
  test('Score de risque doit être entre 0 et 1', () {
    final service = DroughtPredictionService();
    // Ajouter vos tests ici
  });
}
```

Exécuter les tests:

```bash
flutter test
```

### Tests d'intégration

```bash
flutter drive --target=test_driver/app.dart
```

### Tests manuels

#### Test de géolocalisation

1. Activer/désactiver le GPS
2. Tester en intérieur/extérieur
3. Vérifier la sélection manuelle de région

#### Test offline

1. Activer le mode avion
2. Lancer l'application
3. Vérifier que les données en cache sont affichées
4. Désactiver le mode avion
5. Vérifier la synchronisation

#### Test des prédictions

1. Tester avec différentes régions
2. Vérifier la cohérence des scores de risque
3. Valider les recommandations affichées

---

## 7. Dépôt pour PRESCI

### Préparation du dossier de dépôt

Créer un dossier contenant:

```
PRESCI_AgriAlert_BF/
├── APK/
│   └── agrialert-bf-release.apk
├── Code_Source/
│   └── agrialert_bf/
│       ├── lib/
│       ├── assets/
│       ├── python_model/
│       └── pubspec.yaml
├── Documentation/
│   ├── README.md
│   ├── INSTALL.md
│   └── PRESENTATION.pdf
├── Démonstration/
│   ├── screenshots/
│   └── demo_video.mp4
└── FICHE_PROJET.pdf
```

### Création de la fiche projet

La fiche projet doit inclure:

1. **Titre du projet**: AgriAlert BF - Application d'alerte sécheresse pour le Burkina Faso

2. **Catégorie**: 
   - Niveau: Universitaire
   - Sous-catégorie: Développement d'applications web et mobiles

3. **Résumé** (200 mots max):
   Description concise du projet, du problème résolu, et de la solution apportée.

4. **Innovation**:
   - IA embarquée pour fonctionnement offline
   - Première app dédiée au Burkina Faso
   - Interface bilingue Français/Mooré

5. **Impact social**:
   - Sécurité alimentaire
   - Adaptation au changement climatique
   - Accessibilité aux zones rurales

6. **Technologies utilisées**:
   Flutter, TensorFlow Lite, Open-Meteo API, Python, etc.

7. **Captures d'écran**: 4-6 images de l'application

8. **Membres de l'équipe**:
   Nom, prénom, institution, rôle

### Génération des captures d'écran

```bash
flutter screenshot --out=screenshots/
```

Ou prendre manuellement depuis l'émulateur/appareil.

### Création d'une vidéo de démonstration

1. Enregistrer l'écran avec l'application en action (2-3 minutes)
2. Montrer toutes les fonctionnalités principales
3. Ajouter des annotations expliquant chaque fonctionnalité
4. Exporter en MP4 (max 100 MB)

Outils recommandés:
- Windows: OBS Studio
- macOS: QuickTime Player
- Linux: SimpleScreenRecorder
- Android: AZ Screen Recorder

### Compression de l'APK si nécessaire

Si l'APK dépasse 100 MB:

```bash
# Utiliser ProGuard pour réduire la taille
flutter build apk --release --shrink
```

---

## 8. Résolution de problèmes

### Erreur: "SDK location not found"

**Solution**:
Créer `android/local.properties`:

```properties
sdk.dir=/chemin/vers/Android/Sdk
```

### Erreur: "Gradle build failed"

**Solutions**:
1. Nettoyer le build:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

2. Vérifier la version Java:
```bash
java -version  # Doit être Java 11 ou supérieur
```

### Erreur: "TFLite plugin not found"

**Solution**:
```bash
flutter pub cache repair
flutter pub get
```

### Application se ferme au lancement

**Solutions**:
1. Vérifier les permissions dans AndroidManifest.xml
2. Vérifier les logs:
```bash
flutter logs
```

3. Tester en mode debug:
```bash
flutter run --debug
```

### Problèmes de performance

**Solutions**:
1. Activer ProGuard pour réduire la taille
2. Optimiser les images dans assets/
3. Compiler en mode release (pas debug)

### Géolocalisation ne fonctionne pas

**Solutions**:
1. Vérifier que le GPS est activé sur l'appareil
2. Vérifier les permissions dans les paramètres
3. Tester en extérieur (pas en intérieur)
4. Utiliser la sélection manuelle de région comme fallback

---

## Support et contact

Pour toute question ou problème:

1. Consulter la documentation Flutter: https://flutter.dev/docs
2. Consulter les issues GitHub du projet
3. Contacter l'équipe via les coordonnées du concours PRESCI

---

**Dernière mise à jour**: Février 2026

**Bonne chance pour le concours PRESCI 2026!** 🚀
