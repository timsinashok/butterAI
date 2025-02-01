# Import functions from the respective files
from whisper_transcribe import transcribe_audio
from facebook_transcribe import transcribe_audio_with_timestamps
import re
def calculate_stuttering_score(text1, text2, timestamp_string):
    # Extract timestamps from the string
    timestamps = extract_timestamps(timestamp_string)
    
    # Identify stuttering features (repetitions, elongations, pauses)
    stuttering_count = 0
    
    # Identify word repetitions/elongations in text2
    words1 = text1.split()
    words2 = text2.split()
    
    # Find repeated words or elongations in text2
    for i in range(1, len(words2)):
        if words2[i] == words2[i - 1]:
            stuttering_count += 1  # Repeated word
    
    # Identify elongations (similar to repeated words, but lengthened versions)
    elongation_patterns = [r'(.)\1{2,}']  # Regex pattern for word elongation (e.g., "ssshhhhoool")
    for word in words2:
        if any(re.match(pattern, word) for pattern in elongation_patterns):
            stuttering_count += 1  # Elongated word

    # Identify pauses based on the timestamps
    pause_threshold = 0.2  # seconds (tune as necessary)
    pause_count = 0
    for i in range(1, len(timestamps)):
        prev_end = timestamps[i - 1][1]
        curr_start = timestamps[i][0]
        if curr_start - prev_end > pause_threshold:
            pause_count += 1
    
    # Add the number of pauses to the stuttering count
    stuttering_count += pause_count
    
    # Calculate the stuttering score
    stuttering_score = (stuttering_count / len(words2)) * 100  # Normalize by total words in text2
    return stuttering_score

def extract_timestamps(timestamp_string):
    # Step 1: Parse the timestamp string and extract the word with timestamps
    timestamps = []
    pattern = r'(\S+): (\d+\.\d+)s - (\d+\.\d+)s'
    matches = re.findall(pattern, timestamp_string)
    
    # Convert matches into a list of (start_time, end_time) tuples
    for match in matches:
        word = match[0]
        start_time = float(match[1])
        end_time = float(match[2])
        timestamps.append((start_time, end_time))
    
    return timestamps

def process_audio_and_calculate_stuttering(audio_path):
    # Get text1 from whisper_transcribe.py
    text1 = transcribe_audio(audio_path)
    
    # Get text2 and timestamps from facebook_transcribe.py
    timestamp_string, text2 = transcribe_audio_with_timestamps(audio_path)
    
    # Calculate stuttering score
    stuttering_score = calculate_stuttering_score(text1, text2, timestamp_string)
    return text1, text2, timestamp_string, stuttering_score


# # Example Usage:
# audio_path = "short_stutter.wav"
# _, _, _,stuttering_score = process_audio_and_calculate_stuttering(audio_path)
# print(f"Stuttering Score: {stuttering_score:.2f}")