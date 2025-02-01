import whisper

# Load the Whisper model (can be done once when the function is called)
model = whisper.load_model("base")

# Function to transcribe an audio file (MP3) and return the transcription
def transcribe_audio(audio_path):
    # Transcribe the audio using Whisper
    result = model.transcribe(audio_path)

    # Extract the transcription text
    transcription = result["text"]
    
    # Return the transcription text
    return transcription

# # Example usage
# audio_path = "manoj-s.wav"  # Replace with your MP3 file path
# transcription = transcribe_audio(audio_path)

# # Print the transcription result
# print("Transcription:")
# print(transcription)