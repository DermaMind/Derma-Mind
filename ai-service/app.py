import torch
import torch.nn as nn
from torchvision import transforms
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
import io
import os
import json
import re
import time
from dotenv import load_dotenv
from google import genai
from google.genai import types
from chatbot import get_response

# نحمّل .env بـ path صريح عشان Flask debug reloader مبيغيرش الـ CWD
_ENV_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
load_dotenv(dotenv_path=_ENV_PATH, override=True)
# نحفظ الـ key في module-level variable وقت التحميل
_GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

app = Flask(__name__)
CORS(app)

# ── تحميل الموديل ──────────────────────────────────────────
from huggingface_hub import hf_hub_download
import timm

MODEL_PATH = hf_hub_download(
    repo_id="omdaa/derma-mind-model",
    filename="best_efficientnet_b3_phase2.pth"
)

checkpoint  = torch.load(MODEL_PATH, map_location="cpu", weights_only=False)
CLASS_NAMES = checkpoint.get("class_names", [
    'Acne', 'Actinic_Keratosis', 'Benign_tumors', 'Bullous',
    'DrugEruption', 'Lichen', 'Moles', 'Psoriasis',
    'Rosacea', 'Seborrh_Keratoses', 'SkinCancer', 'Tinea',
    'Vasculitis', 'Vitiligo', 'Warts'
])
NUM_CLASSES = len(CLASS_NAMES)

model = timm.create_model(
    "efficientnet_b3",
    pretrained=False,
    num_classes=0,
    global_pool="avg"
)
model.classifier = nn.Sequential(
    nn.Dropout(p=0.4),
    nn.Linear(1536, 512),
    nn.SiLU(inplace=True),
    nn.Dropout(p=0.3),
    nn.Linear(512, NUM_CLASSES)
)
model.load_state_dict(checkpoint["model_state_dict"])
model.eval()

print(f"✅ الموديل اتحمل — {NUM_CLASSES} classes")
print(f"Classes: {CLASS_NAMES}")

# ── Preprocessing ───────────────────────────────────────────
transform = transforms.Compose([
    transforms.Resize((300, 300)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225]),
])

# ── معلومات الأمراض ─────────────────────────────────────────
DISEASE_INFO = {
    "Acne": {
        "name_ar": "حب الشباب",
        "severity": "low",
        "advice":   "نظف بشرتك بانتظام وتجنب العوامل المحفزة."
    },
    "Actinic_Keratosis": {
        "name_ar": "التقران السفعي",
        "severity": "medium",
        "advice":   "يُنصح بمراجعة طبيب جلدية قريباً."
    },
    "Benign_tumors": {
        "name_ar": "أورام حميدة",
        "severity": "low",
        "advice":   "راقبها وراجع الطبيب لو تغير شكلها."
    },
    "Bullous": {
        "name_ar": "الأمراض الفقاعية",
        "severity": "high",
        "advice":   "يُنصح بمراجعة طبيب جلدية فوراً."
    },
    "DrugEruption": {
        "name_ar": "طفح دوائي",
        "severity": "medium",
        "advice":   "أوقف الدواء المسبب واستشر طبيبك فوراً."
    },
    "Lichen": {
        "name_ar": "الحزاز",
        "severity": "medium",
        "advice":   "يُنصح بمراجعة طبيب جلدية."
    },
    "Moles": {
        "name_ar": "الشامات",
        "severity": "low",
        "advice":   "راقب أي تغير في الحجم أو اللون وراجع الطبيب."
    },
    "Psoriasis": {
        "name_ar": "الصدفية",
        "severity": "medium",
        "advice":   "استشر طبيب جلدية للحصول على العلاج المناسب."
    },
    "Rosacea": {
        "name_ar": "الوردية",
        "severity": "low",
        "advice":   "تجنب المحفزات واستشر طبيب جلدية."
    },
    "Seborrh_Keratoses": {
        "name_ar": "الكيراتوز الدهني",
        "severity": "low",
        "advice":   "حالة حميدة — استشر طبيباً للتأكيد."
    },
    "SkinCancer": {
        "name_ar": "سرطان الجلد",
        "severity": "high",
        "advice":   "⚠️ يُنصح بمراجعة طبيب جلدية فوراً."
    },
    "Tinea": {
        "name_ar": "السعفة (فطريات الجلد)",
        "severity": "low",
        "advice":   "استخدم مضادات الفطريات الموضعية واستشر الصيدلاني."
    },
    "Vasculitis": {
        "name_ar": "التهاب الأوعية الدموية",
        "severity": "high",
        "advice":   "يُنصح بمراجعة طبيب فوراً."
    },
    "Vitiligo": {
        "name_ar": "البهاق",
        "severity": "low",
        "advice":   "استشر طبيب جلدية لخيارات العلاج المتاحة."
    },
    "Warts": {
        "name_ar": "الثآليل",
        "severity": "low",
        "advice":   "يمكن علاجها بطرق متعددة — استشر طبيب جلدية."
    },
}

# ── Endpoints ───────────────────────────────────────────────
@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "DermaMind API شغال!",
        "model":   "EfficientNet-B3",
        "classes": CLASS_NAMES,
        "accuracy": "79%"
    })

@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "مفيش صورة في الـ request"}), 400

    file = request.files["image"]

    if file.filename == "":
        return jsonify({"error": "الملف فاضل"}), 400

    allowed = {"jpg", "jpeg", "png"}
    ext     = file.filename.rsplit(".", 1)[-1].lower()
    if ext not in allowed:
        return jsonify({"error": "نوع الملف مش مدعوم — jpg/png بس"}), 400

    try:
        img_bytes = file.read()
        image     = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        tensor    = transform(image).unsqueeze(0)

        with torch.no_grad():
            output          = model(tensor)
            probs           = torch.softmax(output, dim=1)[0]
            top3_probs, top3_idxs = torch.topk(probs, 3)

        top_idx   = top3_idxs[0].item()
        top_class = CLASS_NAMES[top_idx]
        top_prob  = round(top3_probs[0].item() * 100, 1)
        info      = DISEASE_INFO.get(top_class, {})

        top3 = [
            {
                "class":      CLASS_NAMES[top3_idxs[i].item()],
                "name_ar":    DISEASE_INFO.get(CLASS_NAMES[top3_idxs[i].item()], {}).get("name_ar", ""),
                "confidence": round(top3_probs[i].item() * 100, 1)
            }
            for i in range(3)
        ]

        return jsonify({
            "diagnosis":  top_class,
            "name_ar":    info.get("name_ar", ""),
            "confidence": top_prob,
            "severity":   info.get("severity", ""),
            "advice":     info.get("advice", ""),
            "top3":       top3,
            "disclaimer": "هذا النظام أداة مساعدة فقط وليس تشخيصاً طبياً نهائياً."
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ── Gemini Settings ──────────────────────────────────────────
GEMINI_MODEL = "gemini-2.5-flash"
DISCLAIMER   = "هذا النظام أداة مساعدة فقط وليس تشخيصاً طبياً نهائياً."

# ── Prompt Templates ─────────────────────────────────────────
HIGH_CONF_PROMPT = """
أنت طبيب جلدية خبير. المريض لديه:
- التشخيص: {disease_name}
- نوع البشرة: {skin_type}
- التاريخ الطبي: {medical_history}

اكتب بالعربية:
1. personalized_insight: رؤية مخصصة (3 جمل) تربط المرض بنوع بشرة المريض وتاريخه الطبي
2. care_recommendations: 3 توصيات علاجية أولية مناسبة لنوع بشرته تحديداً

أرجع JSON فقط بهذا الشكل:
{{"personalized_insight": "...", "care_recommendations": "..."}}
"""

LOW_CONF_PROMPT = """
أنت طبيب جلدية خبير. المريض لديه صورة جلدية غير محددة بوضوح.
- الاحتمالات: {disease1} ({conf1}%), {disease2} ({conf2}%), {disease3} ({conf3}%)
- نوع البشرة: {skin_type}
- التاريخ الطبي: {medical_history}

اكتب بالعربية لكل مرض:
- likelihood: "عالية" أو "متوسطة" أو "منخفضة" بناءً على نوع البشرة والتاريخ الطبي
- personalized_insight: جملتين مخصصتين
- care_recommendations: توصيتين أوليتين

أرجع JSON فقط بهذا الشكل:
{{"results": [
  {{"disease": "...", "likelihood": "...", "personalized_insight": "...", "care_recommendations": "..."}},
  {{"disease": "...", "likelihood": "...", "personalized_insight": "...", "care_recommendations": "..."}},
  {{"disease": "...", "likelihood": "...", "personalized_insight": "...", "care_recommendations": "..."}}
]}}
"""

def _parse_gemini_json(text):
    """يستخرج JSON من رد Gemini حتى لو جاء ملفوف في markdown code block."""
    text = text.strip()
    # شيل ```json ... ``` أو ``` ... ``` لو موجودين
    match = re.search(r"```(?:json)?\s*([\s\S]+?)\s*```", text)
    if match:
        text = match.group(1)
    return json.loads(text)


def _call_gemini(prompt):
    """
    يبعت prompt لـ Gemini ويرجع JSON مُحلَّل، أو None لو فشل.

    ملاحظة مهمة: gemini-2.5-flash نموذج Thinking بيستهلك tokens في التفكير،
    لذا نعطّل الـ thinking_budget=0 عشان كل الـ tokens تتوجه للـ JSON response.
    """
    try:
        api_key = _GEMINI_API_KEY or os.getenv("GEMINI_API_KEY")
        if not api_key:
            print("[Gemini] GEMINI_API_KEY غير موجودة")
            return None
        client   = genai.Client(api_key=api_key)
        response = client.models.generate_content(
            model=GEMINI_MODEL,
            config=types.GenerateContentConfig(
                max_output_tokens=2048,
                temperature=0.4,
                # تعطيل Thinking عشان الـ response ما يكونش فارغ
                thinking_config=types.ThinkingConfig(thinking_budget=0),
            ),
            contents=prompt,
        )
        raw_text = response.text or ""
        if not raw_text.strip():
            print("[Gemini] response.text فارغ — thinking model exhausted tokens")
            return None
        return _parse_gemini_json(raw_text)
    except Exception as e:
        print(f"[Gemini Error] {type(e).__name__}: {str(e)[:200]}")
        return None


def _call_gemini_with_retry(prompt, max_retries=3):
    """
    يحاول استدعاء Gemini حتى max_retries مرات قبل الاستسلام.
    ينتظر ثانية بين كل محاولة.
    """
    for attempt in range(max_retries):
        result = _call_gemini(prompt)
        if result is not None:
            return result
        if attempt < max_retries - 1:
            time.sleep(1)
    return None


# ── POST /analyze ─────────────────────────────────────────────
@app.route("/analyze", methods=["POST"])
def analyze():
    """
    Endpoint متقدم يجمع بين الموديل وGemini.

    Fields (multipart/form-data):
    - image          : الصورة (مطلوب)
    - skin_type      : نوع البشرة (اختياري)
    - medical_history: التاريخ الطبي (اختياري)
    """
    # ── 1. التحقق من الصورة ───────────────────────────────────
    if "image" not in request.files:
        return jsonify({"error": "مفيش صورة في الـ request"}), 400

    file = request.files["image"]
    if file.filename == "":
        return jsonify({"error": "الملف فاضل"}), 400

    ext = file.filename.rsplit(".", 1)[-1].lower()
    if ext not in {"jpg", "jpeg", "png"}:
        return jsonify({"error": "نوع الملف مش مدعوم — jpg/png بس"}), 400

    # ── 2. قراءة البيانات الإضافية ────────────────────────────
    skin_type      = request.form.get("skin_type", "غير محدد").strip() or "غير محدد"
    medical_history = request.form.get("medical_history", "لا يوجد").strip() or "لا يوجد"

    # ── 3. تحليل الصورة بالموديل ──────────────────────────────
    try:
        img_bytes = file.read()
        image     = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        tensor    = transform(image).unsqueeze(0)

        with torch.no_grad():
            output               = model(tensor)
            probs                = torch.softmax(output, dim=1)[0]
            top3_probs, top3_idx = torch.topk(probs, 3)

        top3 = [
            {
                "disease":    CLASS_NAMES[top3_idx[i].item()],
                "confidence": round(top3_probs[i].item() * 100, 1),
            }
            for i in range(3)
        ]

    except Exception as e:
        return jsonify({"error": f"خطأ في تحليل الصورة: {str(e)}"}), 500

    # ── 4. High Confidence (>= 90%) ───────────────────────────
    if top3[0]["confidence"] >= 90.0:
        disease   = top3[0]["disease"]
        info      = DISEASE_INFO.get(disease, {})
        name_ar   = info.get("name_ar", disease)
        severity  = info.get("severity", "")
        conf      = top3[0]["confidence"]

        prompt   = HIGH_CONF_PROMPT.format(
            disease_name    = f"{disease} ({name_ar})",
            skin_type       = skin_type,
            medical_history = medical_history,
        )
        gemini_data = _call_gemini(prompt)

        result = {
            "mode":       "high_confidence",
            "diagnosis":  disease,
            "name_ar":    name_ar,
            "confidence": conf,
            "severity":   severity,
            "disclaimer": DISCLAIMER,
        }

        if gemini_data:
            result["personalized_insight"]  = gemini_data.get("personalized_insight", "")
            result["care_recommendations"]  = gemini_data.get("care_recommendations", "")
        else:
            result["personalized_insight"]  = ""
            result["care_recommendations"]  = info.get("advice", "")
            result["gemini_note"]           = "تعذّر الاتصال بـ Gemini — تم استخدام النصيحة الافتراضية"

        return jsonify(result)

    # ── 5. Low Confidence (< 90%) ─────────────────────────────
    else:
        d1, c1 = top3[0]["disease"], top3[0]["confidence"]
        d2, c2 = top3[1]["disease"], top3[1]["confidence"]
        d3, c3 = top3[2]["disease"], top3[2]["confidence"]

        prompt = LOW_CONF_PROMPT.format(
            disease1 = f"{d1} ({DISEASE_INFO.get(d1, {}).get('name_ar', d1)})",
            conf1    = c1,
            disease2 = f"{d2} ({DISEASE_INFO.get(d2, {}).get('name_ar', d2)})",
            conf2    = c2,
            disease3 = f"{d3} ({DISEASE_INFO.get(d3, {}).get('name_ar', d3)})",
            conf3    = c3,
            skin_type       = skin_type,
            medical_history = medical_history,
        )
        gemini_data = _call_gemini(prompt)

        # بناء top3 من Gemini أو fallback لو فشل
        if gemini_data and "results" in gemini_data:
            top3_result = []
            for i, item in enumerate(gemini_data["results"][:3]):
                disease  = top3[i]["disease"]
                info     = DISEASE_INFO.get(disease, {})
                top3_result.append({
                    "disease":              disease,
                    "name_ar":              info.get("name_ar", disease),
                    "confidence":           top3[i]["confidence"],
                    "likelihood":           item.get("likelihood", ""),
                    "personalized_insight": item.get("personalized_insight", ""),
                    "care_recommendations": item.get("care_recommendations", ""),
                })
        else:
            # Fallback بدون Gemini
            top3_result = [
                {
                    "disease":              top3[i]["disease"],
                    "name_ar":              DISEASE_INFO.get(top3[i]["disease"], {}).get("name_ar", top3[i]["disease"]),
                    "confidence":           top3[i]["confidence"],
                    "likelihood":           "",
                    "personalized_insight": "",
                    "care_recommendations": DISEASE_INFO.get(top3[i]["disease"], {}).get("advice", ""),
                }
                for i in range(3)
            ]

        result = {
            "mode":       "low_confidence",
            "top3":       top3_result,
            "disclaimer": DISCLAIMER,
        }

        if not gemini_data:
            result["gemini_note"] = "تعذّر الاتصال بـ Gemini — تم استخدام البيانات الافتراضية"

        return jsonify(result)


# ── POST /diagnose/start ──────────────────────────────────────
@app.route("/diagnose/start", methods=["POST"])
def diagnose_start():
    """
    الخطوة الأولى من التشخيص التفاعلي:
    ① تحليل الصورة بالموديل
    ② توليد أسئلة تشخيصية ديناميكية بـ Gemini

    Fields (multipart/form-data):
    - image          : الصورة (مطلوب)
    - lang           : "ar" أو "en" (default: "ar")
    - medical_history: أمراض سابقة (اختياري)
    """
    # ── التحقق من الصورة ──────────────────────────────────────
    if "image" not in request.files:
        return jsonify({"error": "مفيش صورة في الـ request"}), 400

    file = request.files["image"]
    if file.filename == "":
        return jsonify({"error": "الملف فاضل"}), 400

    ext = file.filename.rsplit(".", 1)[-1].lower()
    if ext not in {"jpg", "jpeg", "png"}:
        return jsonify({"error": "نوع الملف مش مدعوم — jpg/png بس"}), 400

    # ── قراءة الـ parameters ──────────────────────────────────
    lang            = request.form.get("lang", "ar").strip().lower()
    if lang not in ("ar", "en"):
        lang = "ar"
    medical_history = request.form.get("medical_history", "None").strip() or "None"

    # ── تحليل الصورة بالموديل ─────────────────────────────────
    try:
        img_bytes = file.read()
        image     = Image.open(io.BytesIO(img_bytes)).convert("RGB")
        tensor    = transform(image).unsqueeze(0)

        with torch.no_grad():
            output               = model(tensor)
            probs                = torch.softmax(output, dim=1)[0]
            top3_probs, top3_idx = torch.topk(probs, 3)

        # top 3 مع الترجمة العربية
        top3 = [
            {
                "disease":    CLASS_NAMES[top3_idx[i].item()],
                "name_ar":    DISEASE_INFO.get(CLASS_NAMES[top3_idx[i].item()], {}).get("name_ar", ""),
                "confidence": round(top3_probs[i].item() * 100, 1),
            }
            for i in range(3)
        ]

        # كل الـ scores للـ model_result
        raw_scores = {
            CLASS_NAMES[j]: round(probs[j].item() * 100, 1)
            for j in range(len(CLASS_NAMES))
        }

    except Exception as e:
        return jsonify({"error": f"خطأ في تحليل الصورة: {str(e)}"}), 500

    # ── بناء Gemini Prompt لتوليد الأسئلة ─────────────────────
    d1, c1 = top3[0]["disease"], top3[0]["confidence"]
    d2, c2 = top3[1]["disease"], top3[1]["confidence"]
    d3, c3 = top3[2]["disease"], top3[2]["confidence"]

    questions_prompt = f"""You are an expert dermatologist AI assistant.

An AI model analyzed a skin image and returned these top 3 results:
1. {d1} - {c1}%
2. {d2} - {c2}%
3. {d3} - {c3}%

Patient medical history: {medical_history}
Response language: {lang}

Your task:
Generate diagnostic questions to help differentiate between these conditions.
- If one disease is very dominant (>70%), generate 3 questions minimum
- If diseases are close in probability, generate up to 7 questions
- Each question must have 3-4 multiple choice options
- Questions should target symptoms, duration, location, triggers that differentiate these specific diseases
- Response language must be {lang} (ar=Arabic, en=English)

Return ONLY this JSON (no markdown, no explanation):
{{
  "questions": [
    {{
      "id": 1,
      "question": "...",
      "options": ["option1", "option2", "option3"]
    }}
  ]
}}"""

    # ── استدعاء Gemini مع retry ───────────────────────────────
    gemini_data = _call_gemini_with_retry(questions_prompt, max_retries=3)

    if gemini_data is None or "questions" not in gemini_data:
        return jsonify({"error": "التشخيص غير متاح حالياً، حاول مرة أخرى"}), 503

    return jsonify({
        "model_result": {
            "top3":       top3,
            "raw_scores": raw_scores,
        },
        "questions": gemini_data["questions"],
    })


# ── POST /diagnose/complete ───────────────────────────────────
@app.route("/diagnose/complete", methods=["POST"])
def diagnose_complete():
    """
    الخطوة الثانية من التشخيص التفاعلي:
    يأخذ نتيجة الموديل + إجابات المريض ويرجع Final Assessment بـ Gemini.

    Body (application/json):
    - model_result   : نفس اللي رجع من /diagnose/start
    - answers        : قائمة إجابات المريض
    - skin_type      : نوع البشرة (Baumann)
    - medical_history: أمراض سابقة (اختياري)
    - lang           : "ar" أو "en" (default: "ar")
    """
    # ── قراءة الـ JSON body ───────────────────────────────────
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"error": "الـ request body فاضل أو مش JSON"}), 400

    model_result    = data.get("model_result", {})
    answers         = data.get("answers", [])
    skin_type       = data.get("skin_type", "غير محدد") or "غير محدد"
    medical_history = data.get("medical_history", "None") or "None"
    lang            = data.get("lang", "ar").strip().lower()
    if lang not in ("ar", "en"):
        lang = "ar"

    # ── التحقق من البيانات المطلوبة ───────────────────────────
    top3 = model_result.get("top3", [])
    if not top3:
        return jsonify({"error": "model_result.top3 مطلوب"}), 400
    if not answers:
        return jsonify({"error": "answers مطلوبة"}), 400

    # ── تنسيق معلومات الموديل ─────────────────────────────────
    model_lines = "\n".join(
        f"{item.get('disease', '?')}: {item.get('confidence', 0)}%"
        for item in top3
    )

    # ── تنسيق الأسئلة والإجابات ───────────────────────────────
    qa_lines = "\n".join(
        f"Q{a.get('question_id', i+1)}: {a.get('question', '')}\n"
        f"   Answer: {a.get('answer', '')}"
        for i, a in enumerate(answers)
    )

    # ── بناء Gemini Prompt للتقييم النهائي ────────────────────
    complete_prompt = f"""You are an expert dermatologist AI assistant.

AI Model Analysis:
{model_lines}

Patient Profile:
- Skin Type (Baumann): {skin_type}
- Medical History: {medical_history}

Patient Answers to Diagnostic Questions:
{qa_lines}

Based on the AI model results AND the patient's answers and profile,
provide a final dermatological assessment.

Response language: {lang} (ar=Arabic, en=English)

Return ONLY this JSON (no markdown):
{{
  "disease": "disease_class_name_in_english",
  "name_localized": "disease name in response language",
  "confidence_level": "high/medium/low in response language",
  "personalized_insight": "3 sentences connecting the diagnosis to patient skin type and history",
  "care_recommendations": "3 specific initial care steps suitable for patient skin type",
  "disclaimer": "standard medical disclaimer in response language"
}}"""

    # ── استدعاء Gemini مع retry ───────────────────────────────
    gemini_data = _call_gemini_with_retry(complete_prompt, max_retries=3)

    if gemini_data is None:
        return jsonify({"error": "التشخيص غير متاح حالياً، حاول مرة أخرى"}), 503

    # ── إضافة name_ar من DISEASE_INFO لو موجود ───────────────
    disease_key = gemini_data.get("disease", "")
    if disease_key in DISEASE_INFO and "name_ar" not in gemini_data:
        gemini_data["name_ar"] = DISEASE_INFO[disease_key]["name_ar"]

    return jsonify(gemini_data)


# ── POST /chat ────────────────────────────────────────────────
@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    if not data or "message" not in data:
        return jsonify({"error": "مفيش message في الـ request"}), 400

    message           = data.get("message", "")
    history           = data.get("history", [])
    diagnosis_context = data.get("diagnosis_context", None)

    response_text = get_response(
        history=history,
        message=message,
        diagnosis_context=diagnosis_context
    )

    return jsonify({"response": response_text, "role": "assistant"})


if __name__ == "__main__":
    import os
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)