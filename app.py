# Imports
from fastapi import FastAPI, HTTPException, File, UploadFile, Response
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import base64
from groq import Groq
import os
from dotenv import load_dotenv
import uvicorn
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from datetime import datetime
import tempfile

# Custom utility imports
from utils.stutter_score import process_audio_and_calculate_stuttering
from utils.text_to_audio import text_to_speech_audio

print("🚀 Initializing Speech Therapy AI Server...")

# Load environment variables and initialize FastAPI app
load_dotenv()
app = FastAPI()

# Global variables
score = 101
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
MONGODB_URI = os.getenv("MONGODB_URI")

print("🔑 API keys and environment variables loaded.")

# MongoDB initialization
try:
    client = MongoClient(MONGODB_URI, server_api=ServerApi('1'))
    db = client.speech_therapy
    chats_collection = db.chats
    print("📊 Successfully connected to MongoDB!")
except Exception as e:
    print(f"❌ MongoDB connection error: {e}")
    raise HTTPException(status_code=500, detail="Failed to connect to MongoDB")

# Models
class GroqResponse(BaseModel):
    response: str

# Database functions
def store_chat_mongodb(fb_text: str, response: str, score: float):
    chat_document = {
        "timestamp": datetime.utcnow(),
        "fb_text": fb_text,
        "score": score,
        "response": response
    }
    result = chats_collection.insert_one(chat_document)
    print(f"💾 Chat stored in MongoDB with ID: {result.inserted_id}")
    return result

def get_chat_history_mongodb():
    chats = list(chats_collection.find({}, {'_id': 0}).sort('timestamp', -1))
    print(f"📜 Retrieved {len(chats)} recent chat(s) from history.")
    print(chats[:2])
    return chats[:2]

# Chat function
def chat_groq(GROQ_API_KEY, temp_file_path):
    global score
    print("🤖 Initiating chat with Groq AI...")
    client = Groq(api_key=GROQ_API_KEY)

    chat_history = get_chat_history_mongodb()
    print("💬 Chat History loaded.")

    print("🎙️ Processing audio file...")
    whisper_text, fb_text, timestamp, stuttering_score = process_audio_and_calculate_stuttering(temp_file_path)
    stuttering_score = round(stuttering_score, 0)

    print(f"""
    📊 Speech Analysis Results:
    Whisper Transcription: {whisper_text}
    Facebook Transcription: {fb_text}
    Timestamp: {timestamp}
    Stuttering Score: {stuttering_score}
    """)
    prompt = f"""
    You are an AI speech therapist helping a user improve their speech in a natural, supportive conversation.

    ### **Session Context**
    {chat_history}

    ### **Speech Data**
    - Processed speech: {whisper_text}
    - Speech with timestamps: {timestamp}
    - Fluency level (0-100, where 100 indicates more difficulty speaking): {stuttering_score}

    ### **Your Role**
    Engage in a **fluid, back-and-forth conversation** like a real speech therapist. Focus on **small, achievable improvements** with **gentle, positive guidance**. 

    ### **Guidance for Your Response**
    - Keep responses **natural, short, and engaging**—no robotic phrasing.
    - Respond in a **conversational tone** (e.g., "Hey Alex, let's try this…").
    - Offer **one practical exercise** per response, and the exercise should be about **one** specific word.
    - Be **encouraging**, avoiding technical terms like "stuttering score" or "transcription."
    - **No over-explaining.** Keep it to **2 sentences max** unless giving an example.
    - **No repeating previous exercises**—build on past attempts naturally.
    - **Avoid formal intros and conclusions.** Continue like an ongoing chat.

    If it's the user's first session, start with **gentle encouragement and a simple warm-up exercise.**
    """




    system_message = """You are an AI-powered speech therapist specializing in 
    helping people who stutter. Analyze the provided transcriptions, offer personalized constructive 
    feedback, and suggest exercises to help the user improve their speech through practice."""

    print("📝 Generating AI response...")
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "system",
                "content": system_message
            },
            {
                "role": "user", 
                "content": prompt
            }
        ],
        model="llama-3.3-70b-versatile",
        temperature=0.5,
        max_completion_tokens=1024
    )
    response_content = chat_completion.choices[0].message.content
    print("✅ AI response generated successfully.")
    print(f"🤖 AI Response: {response_content}")

    if score > 100:
        score = stuttering_score
    else:
        score = score * 0.8 + stuttering_score * 0.2 

    store_chat_mongodb(fb_text, response_content, score)
    print(f"📈 Updated overall score: {score}")

    return response_content

# API endpoints
@app.post("/ask", response_model=GroqResponse)
async def ask_groq(file: UploadFile = File(...)):
    print('📁 Received audio file.')
    if not GROQ_API_KEY:
        raise HTTPException(status_code=500, detail="GROQ API key not configured")
    
    try:
        with tempfile.NamedTemporaryFile(delete=False) as temp_file:
            temp_file.write(await file.read())
            temp_file_path = temp_file.name
        print("💾 Temporary file created for processing.")
    except Exception as e:
        print(f"❌ Error creating temporary file: {e}")
        raise HTTPException(status_code=500, detail=str(e))

    response = chat_groq(GROQ_API_KEY, temp_file_path)
    os.unlink(temp_file_path)
    print("🗑️ Temporary file deleted.")

    print("🔊 Generating audio response...")
    audio_stream = text_to_speech_audio(response)
    audio_base64 = base64.b64encode(audio_stream.getvalue()).decode('utf-8')
    print("✅ Audio response generated successfully.")

    print('📤 Sending response to client.')
    return JSONResponse(content={"text": response, "progress": 100 - score, "audio": audio_base64})

@app.get("/chat-history")
async def get_chat_history():
    try:
        chats = list(chats_collection.find({}, {'_id': 0}).sort('timestamp', -1))
        print(f"📜 Retrieved {len(chats)} chats from history.")
        return {"chats": chats}
    except Exception as e:
        print(f"❌ Error retrieving chat history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

count = 0
score = 10
# API endpoints
@app.post("/butterask", response_model=GroqResponse)
async def ask_groq(file: UploadFile = File(...)):
    global count
    global score
    print('📁 Received audio file.')
    
    

    therapist_dialogue = [
        "Hey Alex, Let’s start with some easy breathing. Take a deep breath in… and let it out slowly. Good. Now, let’s try saying “Monday,” but we’ll stretch the first sound gently—like ‘Mooonday.’ Give it a try",
        "Nice! Did that feel a little smoother?",
        "Great! Now, let’s try it again, but even softer this time—no rush, just let the sound flow.",
        "That was really smooth! This technique—stretching the first sound—can help words feel easier. Want to try with another word? Maybe “morning”?",
        "Awesome! You’re doing great, Alex. The more we practice, the easier it’ll feel. Want to try one more?",
        "Nailed it! See? You’re getting the hang of it. 😊"
    ]
    response = therapist_dialogue[count]
    count  += 1
    print("🗑️ Temporary file deleted.")

    score = score + 20

    print("🔊 Generating audio response...")
    audio_stream = text_to_speech_audio(response)
    audio_base64 = base64.b64encode(audio_stream.getvalue()).decode('utf-8')
    print("✅ Audio response generated successfully.")

    print('📤 Sending response to client.')
    return JSONResponse(content={"text": response, "progress": score, "audio": audio_base64})


# Main execution
if __name__ == "__main__":
    try:
        client.admin.command('ping')
        print("✅ MongoDB connection verified!")
    except Exception as e:
        print(f"❌ MongoDB connection error: {e}")
    
    print("🚀 Starting the Speech Therapy AI server...")
    uvicorn.run(app, host="0.0.0.0", port=8080)
