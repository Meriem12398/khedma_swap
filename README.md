# Khedma Swap 🎓

Khedma Swap est une application mobile développée avec **Flutter** dans le cadre d’un mini-projet de Développement Système Informatique.

L’application permet à un étudiant de :

- Créer un compte (inscription)
- Se connecter avec email et mot de passe
- Voir ses informations sur un écran d’accueil

> L’idée générale : une plateforme pour l’échange de services/compétences entre étudiants (cours, aide, révision, langues, design, etc.).

---

## ✨ Fonctionnalités actuelles

- **Authentification locale avec Stepper**
  - Écran d’authentification avec Stepper (Connexion / Inscription)
  - Inscription : saisie du nom, email, mot de passe
  - Connexion : vérification de l’email + mot de passe saisis lors de l’inscription
- **Écran d’accueil**
  - Affichage des informations de l’utilisateur connecté (nom, email, username)

---

## 🧠 Objectifs pédagogiques

Ce projet permet de pratiquer :

- Flutter (widgets de base : `Scaffold`, `AppBar`, `TextField`, `ElevatedButton`, `Stepper`, …)
- Gestion d’état simple avec `StatefulWidget` et `setState`
- Organisation du code :
  - `lib/main.dart` → point d’entrée
  - `lib/models/user.dart` → modèle utilisateur
  - `lib/screens/auth_stepper_screen.dart` → écran d’authentification
  - `lib/screens/home_screen.dart` → écran d’accueil

---

## 🚀 Installation & exécution

1. Cloner le projet :

   ```bash
   git clone https://github.com/<ton-compte-github>/khedma_swap.git
   cd khedma_swap
2. Installer les dépendances:
   flutter pub get
3. Lancer l’application sur un émulateur ou un appareil :
   flutter run
