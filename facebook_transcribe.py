from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
import torch
import librosa

def transcribe_audio_with_timestamps(audio_path):
    # Load model and processor
    processor = Wav2Vec2Processor.from_pretrained("facebook/wav2vec2-large-960h")
    model = Wav2Vec2ForCTC.from_pretrained("facebook/wav2vec2-large-960h")

    # Load audio with correct sampling rate
    waveform, _ = librosa.load(audio_path, sr=16000)

    # Process audio
    inputs = processor(waveform, return_tensors="pt", sampling_rate=16000)
    with torch.no_grad():
        logits = model(**inputs).logits
    
    # Decode tokens with word boundaries
    predicted_ids = torch.argmax(logits, dim=-1)[0]
    tokens = processor.tokenizer.convert_ids_to_tokens(predicted_ids.tolist())
    
    # Process tokens with word boundaries and remove padding tokens
    words_with_timestamps = []
    current_word = []
    start_time = 0
    last_token_time = 0
    
    for i, token in enumerate(tokens):
        if token == processor.tokenizer.pad_token:
            continue  # Skip padding tokens
        
        current_time = i * 0.02  # Each frame is 20ms
        
        if token == processor.tokenizer.word_delimiter_token:
            if current_word:
                words_with_timestamps.append(f"{''.join(current_word)}: {start_time:.2f}s - {last_token_time + 0.02:.2f}s")
                current_word = []
            continue
            
        if not current_word:
            start_time = current_time
            
        current_word.append(token.replace('##', ''))
        last_token_time = current_time

    # Add final word if any
    if current_word:
        words_with_timestamps.append(f"{''.join(current_word)}: {start_time:.2f}s - {last_token_time + 0.02:.2f}s")

    # Post-process to handle special cases
    full_transcription = ' '.join(w.split(':')[0] for w in words_with_timestamps)

    # Return both the formatted words with timestamps and the full transcription
    return ' | '.join(words_with_timestamps), full_transcription

# # Example usage:
# audio_path = "manoj-s.wav"  # Replace with your own audio path
# words_with_timestamps, full_transcription = transcribe_audio_with_timestamps(audio_path)

# # Print the resultss
# print("Words with Timestamps:")
# print(words_with_timestamps)

# print("\nFull Transcription:")
# print(full_transcription)