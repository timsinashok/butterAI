import io
from gtts import gTTS
from pydub import AudioSegment
from pydub.playback import play

def text_to_speech_audio(text, lang="en", speed=1.2):
    """
    Convert text to speech and return the audio as a byte stream with adjustable speed.

    Args:
        text (str): The text to be converted into speech.
        lang (str): The language code for speech synthesis (default: "en").
        speed (float): The speed multiplier for the generated audio (default: 1.5).

    Returns:
        io.BytesIO: The generated audio as a byte stream.
    """
    try:
        # Generate the speech audio
        tts = gTTS(text=text, lang=lang, slow=False)
        audio_stream = io.BytesIO()
        tts.write_to_fp(audio_stream)
        audio_stream.seek(0)

        # Convert to pydub AudioSegment
        audio = AudioSegment.from_file(audio_stream, format="mp3")

        # Change speed
        new_audio = audio.speedup(playback_speed=speed)

        # Save to byte stream
        output_stream = io.BytesIO()
        new_audio.export(output_stream, format="mp3")
        output_stream.seek(0)

        return output_stream
    except Exception as e:
        print(f"Error generating speech: {e}")
        return None

