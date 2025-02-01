from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from groq import Groq
import os
from dotenv import load_dotenv
import uvicorn

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI()

# Get API key from environment variable
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

# Define request model
class PromptRequest(BaseModel):
    prompt: str
    system_message: str = "You are a helpful assistant trying to help a person who stutters. I will pass you with the text of htie person speaking and you be a nice speech therapist and help."

# Define response model
class GroqResponse(BaseModel):
    response: str

@app.post("/ask", response_model=GroqResponse)
async def ask_groq(request: PromptRequest):
    if not GROQ_API_KEY:
        raise HTTPException(status_code=500, detail="GROQ API key not configured")
    
    try:
        client = Groq(api_key=GROQ_API_KEY)
        
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": request.system_message
                },
                {
                    "role": "user", 
                    "content": request.prompt
                }
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.5,
            max_completion_tokens=1024
        )
        
        return {"response": chat_completion.choices[0].message.content}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)