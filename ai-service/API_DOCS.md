# DermaMind API Documentation

## Base URL

https://derma-mind-api-production.up.railway.app

---

## Endpoints

| Endpoint | Method | الوظيفة |
|----------|--------|---------|
| / | GET | Health check |
| /predict | POST | تشخيص أساسي بالموديل |
| /analyze | POST | تشخيص ذكي بـ Gemini + بيانات المريض |
| /diagnose/start | POST | بدء التشخيص التفاعلي + توليد أسئلة ذكية |
| /diagnose/complete | POST | إتمام التشخيص بناءً على إجابات المريض |
| /chat | POST | المساعد الطبي الذكي |

### 1. GET / — Health Check

تأكد إن الـ API شغال.

**Response:**

```json
{
  "message": "DermaMind API شغال!",
  "model": "EfficientNet-B3",
  "accuracy": "79%",
  "classes": [...]
}
```

---

### 2. POST /predict — تشخيص أساسي

تشخيص صورة جلدية بدون بيانات المريض.

**Request:**

```
Content-Type: multipart/form-data
- image: File (JPG/PNG)
```

**Response:**

```json
{
  "diagnosis": "Acne",
  "name_ar": "حب الشباب",
  "confidence": 87.3,
  "severity": "low" | "medium" | "high",
  "advice": "...",
  "top3": [
    {"class": "Acne", "name_ar": "...", "confidence": 87.3},
    ...
  ],
  "disclaimer": "..."
}
```

---

### 3. POST /analyze — تشخيص ذكي متقدم ⭐

تشخيص متقدم مع Gemini AI وبيانات المريض.

**Request:**

```
Content-Type: multipart/form-data
- image: File (JPG/PNG) — مطلوب
- skin_type: string — نوع البشرة
- medical_history: string — أمراض سابقة (اختياري)
```

**Response — High Confidence (>= 90%):**

```json
{
  "mode": "high_confidence",
  "diagnosis": "Acne",
  "name_ar": "حب الشباب",
  "confidence": 95.2,
  "severity": "low",
  "personalized_insight": "...",
  "care_recommendations": "...",
  "disclaimer": "..."
}
```

**Response — Low Confidence (< 90%):**

```json
{
  "mode": "low_confidence",
  "top3": [
    {
      "disease": "Acne",
      "name_ar": "حب الشباب",
      "likelihood": "عالية",
      "personalized_insight": "...",
      "care_recommendations": "..."
    },
    ...
  ],
  "disclaimer": "..."
}
```

---

### 4. POST /chat — المساعد الطبي AI

ChatBot طبي متخصص في أمراض الجلد.

**Request:**

```
Content-Type: application/json
```

```json
{
  "message": "سؤال المستخدم",
  "history": [],
  "diagnosis_context": "Acne - حب الشباب - confidence: 87%"
}
```

**ملاحظة:** ابعت `diagnosis_context` في أول رسالة بس، بعدها `null`.

**Response:**

```json
{
  "response": "رد المساعد الطبي...",
  "role": "assistant"
}
```

---


### 5. POST /diagnose/start — بدء التشخيص الذكي التفاعلي

الخطوة الأولى في نظام التشخيص التفاعلي.
يحلل الصورة بالموديل ويولد أسئلة تشخيصية مخصصة بالذكاء الاصطناعي.

**Request:**
Content-Type: multipart/form-data
- image: File (JPG/PNG) — مطلوب
- lang: string — "ar" أو "en" (default: "ar")
- medical_history: string — أمراض سابقة (اختياري)

**Response:**
```json
{
  "model_result": {
    "top3": [
      {"disease": "Acne", "name_ar": "حب الشباب", "confidence": 67.5},
      {"disease": "Rosacea", "name_ar": "الوردية", "confidence": 20.1},
      {"disease": "DrugEruption", "name_ar": "طفح دوائي", "confidence": 12.4}
    ],
    "raw_scores": {
      "Acne": 67.5,
      "Rosacea": 20.1,
      "DrugEruption": 12.4
    }
  },
  "questions": [
    {
      "id": 1,
      "question": "كم مدة ظهور الأعراض؟",
      "options": ["أقل من أسبوع", "من أسبوع لشهر", "أكثر من شهر", "أكثر من 6 أشهر"]
    },
    {
      "id": 2,
      "question": "أين تظهر الآفات بشكل أساسي؟",
      "options": ["الوجه", "الظهر والصدر", "الأطراف", "منتشرة في الجسم"]
    }
  ]
}
```

**ملاحظات:**
- عدد الأسئلة من 3 لـ 7 بيحددها Gemini تلقائياً حسب مدى التقارب بين الأمراض
- لو مرض واحد dominant جداً → 3 أسئلة كافية
- لو الأمراض متقاربة → 5-7 أسئلة
- احتفظ بـ model_result وابعته كامل في /diagnose/complete

---

### 6. POST /diagnose/complete — إتمام التشخيص النهائي

الخطوة الثانية والأخيرة في نظام التشخيص التفاعلي.
يأخذ إجابات المريض وبياناته ويرجع تقييم نهائي مخصص.

**Request:**
Content-Type: application/json
```json
{
  "model_result": {
    "top3": [
      {"disease": "Acne", "name_ar": "حب الشباب", "confidence": 67.5},
      {"disease": "Rosacea", "name_ar": "الوردية", "confidence": 20.1},
      {"disease": "DrugEruption", "name_ar": "طفح دوائي", "confidence": 12.4}
    ],
    "raw_scores": {
      "Acne": 67.5,
      "Rosacea": 20.1,
      "DrugEruption": 12.4
    }
  },
  "answers": [
    {
      "question_id": 1,
      "question": "كم مدة ظهور الأعراض؟",
      "answer": "من أسبوع لشهر"
    },
    {
      "question_id": 2,
      "question": "أين تظهر الآفات بشكل أساسي؟",
      "answer": "الوجه"
    }
  ],
  "skin_type": "DSPW",
  "medical_history": "حساسية من البنسلين",
  "lang": "ar"
}
```

**ملاحظات على الـ Request:**
- model_result: نفس الـ object اللي رجع من /diagnose/start كامل بدون تعديل
- answers: array بإجابات اليوزر على كل الأسئلة
- skin_type: Baumann Skin Type (مثال: DSPW, ORNT, DSNT)
- lang: نفس اللغة المستخدمة في /diagnose/start

**Response:**
```json
{
  "disease": "Acne",
  "name_localized": "حب الشباب",
  "confidence_level": "عالية",
  "personalized_insight": "بشرتك من نوع DSPW تجعلها أكثر عرضة لحب الشباب بسبب الإفراز الدهني الزائد مع الحساسية...",
  "care_recommendations": "استخدم غسول لطيف خالٍ من الزيوت مرتين يومياً، وتجنب المستحضرات الدهنية...",
  "disclaimer": "هذا النظام أداة مساعدة فقط وليس تشخيصاً طبياً نهائياً."
}
```

**قيم confidence_level:**
- "عالية" / "High" — الموديل والأسئلة يؤكدان التشخيص
- "متوسطة" / "Moderate" — احتمال معقول لكن يحتاج تأكيد طبي
- "منخفضة" / "Low" — غير محدد، يُنصح بزيارة طبيب

---

## Error Responses

| Status | المعنى                         |
| ------ | ------------------------------ |
| 400    | مفيش صورة أو نوع ملف غير مدعوم |
| 500    | خطأ داخلي في السيرفر           |

---

## Notes

- الـ API يدعم CORS لجميع الـ origins
- الـ ChatBot يرد بنفس لغة المستخدم (عربي/إنجليزي)
- الـ history يُحفظ على الـ Client مش على الـ Server
- الموديل: EfficientNet-B3 | الدقة: 79.22% | 15 class
