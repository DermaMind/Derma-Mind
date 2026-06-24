# DermaMind

AI-Powered Skin Disease Classification and Personalized Skincare Platform

## Overview

DermaMind is a comprehensive healthcare platform that combines artificial intelligence, personalized skincare recommendations, e-commerce services, and conversational AI into a single ecosystem.

The platform was developed as a graduation project to assist users in obtaining preliminary skin-disease assessments, determining their Baumann skin type, receiving personalized skincare recommendations, and accessing nearby pharmacies and dermatology clinics.

DermaMind is designed primarily for users in Egypt and the MENA region, with full support for both Arabic and English languages.

---

## Key Features

### AI-Powered Skin Disease Classification (DermaScan)

- Upload a skin image for analysis.
- Deep learning model based on EfficientNet-B3.
- Classification of 15 different skin diseases.
- Interactive diagnosis workflow powered by Google Gemini 2.5 Flash.
- Personalized follow-up questions for improved diagnostic accuracy.
- Preliminary diagnosis report and recommendations.

### Baumann Skin Type Assessment

- Interactive skin-type questionnaire.
- Classification using the Baumann Skin Type System.
- Personalized skincare recommendations.
- User skin profile generation.

### Dr. Derma AI Assistant

- Conversational AI chatbot.
- Skincare guidance and education.
- Diagnosis-aware responses.
- Medical explanations in simplified language.

### DermaStore

- Product catalog browsing.
- Product recommendations based on diagnosis and skin type.
- Wishlist functionality.
- Shopping cart management.
- Secure online payments using Paymob.

### Location-Based Services

- Nearby pharmacy discovery.
- Nearby dermatology clinic recommendations.
- Interactive map integration.

### User Management

- User registration and authentication.
- Email verification using OTP.
- Password recovery.
- Profile management.
- Scan history tracking.
- Skin test history tracking.

---

## AI Model

The AI diagnosis module utilizes an EfficientNet-B3 architecture with Transfer Learning.

### Dataset

- 15 Skin Disease Classes
- Dermatology image dataset
- Data augmentation techniques applied

### Training Configuration

- Training Split: 70%
- Validation Split: 15%
- Testing Split: 15%

### Performance

| Metric            | Value  |
| ----------------- | ------ |
| Accuracy          | 82.0%  |
| Weighted F1-Score | 0.8217 |
| Test Images       | 1,030  |

### Training Techniques

- Transfer Learning
- Label Smoothing
- Cosine Annealing
- Mixup Augmentation
- Two-Phase Fine-Tuning Strategy

---

## System Architecture

The system follows a service-oriented architecture composed of four major components:

### Web Frontend

- Next.js
- TypeScript
- Responsive UI
- Arabic & English Support

### Backend API

- ASP.NET Core Web API
- Entity Framework Core
- PostgreSQL
- JWT Authentication
- Cloudinary Integration
- Paymob Integration

### Mobile Application

- Flutter
- Cross-platform support
- Android & iOS compatible

### AI Service

- Flask
- PyTorch
- EfficientNet-B3
- Google Gemini 2.5 Flash Integration

---

## Project Structure

```text
DermaMind
│
├── docs
│   ├── Graduation Book
│   ├── Presentation
│   └── Project Assets
│
├── frontend-web
│   └── Next.js Application
│
├── backend-api
│   └── ASP.NET Core Web API
│
├── mobile-app
│   └── Flutter Application
│
├── ai-service
│   └── Flask AI Service
│
├── database
│   ├── PostgreSQL Scripts
│   └── Database Design
│
└── README.md
```

---

## Technologies Used

### Frontend

- Next.js
- TypeScript
- Tailwind CSS

### Mobile

- Flutter
- Dart

### Backend

- ASP.NET Core
- Entity Framework Core
- PostgreSQL
- Cloudinary
- Paymob

### Artificial Intelligence

- Python
- Flask
- PyTorch
- EfficientNet-B3
- Google Gemini 2.5 Flash

### Tools

- Git & GitHub
- Postman
- Swagger
- Power BI
- Figma

---

## Database Design

The database includes the following core entities:

- Users
- Scans
- Diseases
- Products

Additional supporting entities:

- User Preferences
- Product Ingredients
- Disease Ingredients
- Product Ratings
- Scan Symptoms

---

## Supported Functional Modules

- Authentication & Authorization
- Profile Management
- Skin Type Assessment
- AI Disease Diagnosis
- Conversational AI Assistant
- Product Recommendation Engine
- E-Commerce System
- Location Services
- Analytics Dashboard

---

## Future Enhancements

- Multi-disease prediction
- Severity estimation
- Doctor appointment booking
- Expanded dermatology dataset
- Real-time consultation services
- Mobile push notifications

---

## Disclaimer

DermaMind is intended as a preliminary support tool and educational healthcare platform. It is not a replacement for professional medical consultation, diagnosis, or treatment. Users should always seek advice from qualified healthcare professionals for medical concerns.

---

## Team Members

- Esraa Abdelsamie Salem El-Sebaie
- Ahmed Emad El-Din Mohamed Bakr
- Mariam Hamdy Mohamed Hamdy El-Nahas
- Nada Ahmed Gamal El-Din Mohamed
- Nada Reda Ahmed Tantawy
- Hedaya Ismail Abdelkarim Eid Hamdan
- Hend Ragab Sayed Gomaa

---

## Academic Information

Faculty of Computers and Artificial Intelligence

Graduation Project 2025/2026

DermaMind — AI-Powered Dermatology Assistant and Skincare Platform
