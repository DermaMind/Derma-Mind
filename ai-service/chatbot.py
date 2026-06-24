from google import genai
from google.genai import types
from dotenv import load_dotenv
import os
import time

load_dotenv()
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

SYSTEM_PROMPT = """
أنت مساعد طبي متخصص في أمراض الجلد اسمك "دكتور ديرما".
عملك هو:
1. شرح التشخيص اللي عمله نظام DermaMind بطريقة مبسطة
2. الإجابة على أسئلة المستخدم عن حالته الجلدية
3. تقديم نصائح عامة للعناية بالجلد
4. توجيه المستخدم لزيارة طبيب متخصص عند الحاجة

قواعد مهمة:
- رد دايماً بنفس لغة المستخدم (عربي أو إنجليزي)
- لا تعطي تشخيصاً نهائياً — أنت مساعد تمهيدي فقط
- كن ودوداً ومطمئناً
- الردود تكون مختصرة وواضحة (3-4 جمل بحد أقصى)
- لو السؤال خارج نطاق الجلدية، اعتذر بلطف وأعد التركيز
- دايماً أذكر إن النتيجة تمهيدية وتحتاج تأكيد طبي
"""

def get_response(history, message, diagnosis_context=None):
    max_retries = 3
    for attempt in range(max_retries):
        try:
            messages = []

            if diagnosis_context and len(history) == 0:
                messages.append(
                    types.Content(role="user", parts=[types.Part(text=f"تشخيص النظام: {diagnosis_context}")])
                )
                messages.append(
                    types.Content(role="model", parts=[types.Part(text="حسناً، اطلعت على نتيجة التشخيص. كيف يمكنني مساعدتك؟")])
                )

            for msg in history:
                role = "model" if msg["role"] == "assistant" else "user"
                messages.append(
                    types.Content(role=role, parts=[types.Part(text=msg["content"])])
                )

            messages.append(
                types.Content(role="user", parts=[types.Part(text=message)])
            )

            response = client.models.generate_content(
                model="gemini-2.5-flash",
                config=types.GenerateContentConfig(
                    system_instruction=SYSTEM_PROMPT,
                    max_output_tokens=500,
                    temperature=0.7
                ),
                contents=messages
            )

            return response.text

        except Exception as e:
            error_str = str(e)
            if "503" in error_str or "UNAVAILABLE" in error_str:
                if attempt < max_retries - 1:
                    time.sleep(2)
                    continue
                else:
                    return "عذراً، المساعد الطبي مشغول حالياً. حاول مرة أخرى بعد قليل."
            return f"عذراً، حدث خطأ: {error_str}"


if __name__ == "__main__":
    print("اختبار الـ ChatBot...")
    history = []
    response = get_response(
        history,
        "إيه الأكزيما وإزاي أتعامل معاها؟",
        diagnosis_context="Eczema - أكزيما - confidence: 85%"
    )
    print("الرد:", response)