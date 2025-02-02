# butterAI 

**butterAI** is an innovative speech-to-text application designed to transcribe audio into text with high accuracy. It provides fast and seamless transcription capabilities for various audio formats, making it ideal for both casual and professional use.

## Features

- **Speech-to-Text Transcription**: Convert audio recordings into written text in real-time or from uploaded files.
- **Multi-Language Support**: Transcribe audio in multiple languages with high accuracy.
- **Customizable Models**: Use pre-trained or custom models to improve transcription accuracy for specific domains.
- **User-Friendly Interface**: Simple and intuitive design for ease of use.
- **Audio File Support**: Upload and transcribe audio files in various formats (e.g., MP3, WAV).
- **Real-Time Transcription**: For live speech or direct input.

## Installation

To get started with butterAI, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/kiandrew08/butterAI.git
```
	2.	Install dependencies:
Navigate to the project directory and install the necessary dependencies using:
```bash
pip install -r requirements.txt
```

	3.	Run the application:
You can run the app locally by executing:
```bash
python app.py
```
This will start a local development server. You can access the app by visiting http://localhost:5000 in your web browser.

## Usage
	1.	Upload an Audio File: Click on the “Upload Audio” button and select an audio file (MP3, WAV).
	2.	Start Transcription: Once the file is uploaded, hit the “Transcribe” button to start the transcription process.
	3.	Real-Time Mode: For live speech, click on the “Start Speaking” button and speak into your microphone. The app will transcribe your speech in real-time.
	4.	Download Transcription: Once the transcription is complete, you can download the text file or copy the transcribed text.

## API

You can integrate butterAI’s transcription service into your own applications by using the provided RESTful API.

Transcription API
	•	Endpoint: /ask
	•	Method: POST
	•	Parameters:
	•	audio_file: (required) The audio file to be transcribed (e.g., MP3, WAV).
Response:
	•	response: (string) the response text from ai
	•	audio: (file) the audio from ai


## Contributing

We welcome contributions to butterAI! If you have suggestions, improvements, or bug fixes, feel free to open an issue or submit a pull request.
	1.	Fork the repository.
	2.	Create a new branch (git checkout -b feature-branch).
	3.	Commit your changes (git commit -am 'Add feature').
	4.	Push to the branch (git push origin feature-branch).
	5.	Create a new Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
	•	Thanks to the developers and contributors of speech recognition libraries and models that helped make butterAI possible.
