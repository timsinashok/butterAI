from gtts import gTTS
import io
import tempfile
import os
from playsound import playsound

def text_to_speech_audio(text, lang="en"):
    """
    Convert text to speech and return the audio as a byte stream.
    
    Args:
        text (str): The text to be converted into speech.
        lang (str): The language code for speech synthesis (default: "en").
    
    Returns:
        io.BytesIO: The generated audio as a byte stream.
    """
    try:
        tts = gTTS(text=text, lang=lang, slow=False)
        audio_stream = io.BytesIO()  # Create an in-memory byte stream
        tts.write_to_fp(audio_stream)  # Write the generated audio to the stream
        audio_stream.seek(0)  # Reset stream position to the beginning
        return audio_stream  # Return the audio as bytes
    except Exception as e:
        print(f"Error generating speech: {e}")
        return None

# def play_audio(audio_stream):
#     """
#     Play the generated speech audio.
    
#     Args:
#         audio_stream (io.BytesIO): The generated audio as a byte stream.
#     """
#     try:
#         # Save audio to a temporary file
#         with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as temp_audio:
#             temp_audio.write(audio_stream.read())
#             temp_audio_path = temp_audio.name  # Get the file path
        
#         # Play the audio
#         playsound(temp_audio_path)

#         # Delete the temporary file after playing
#         os.remove(temp_audio_path)
#     except Exception as e:
#         print(f"Error playing audio: {e}")

# # Example Usage
# if __name__ == "__main__":
#     text = "Hello, this is a test. I hope this works!"
#     audio_stream = text_to_speech_audio(text)

#     if audio_stream:
#         print("Audio generated successfully!")
#         play_audio(audio_stream)