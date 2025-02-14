
# butterAI  

**butterAI** is an AI-powered speech therapy platform designed to help individuals with speech disorders, such as stuttering, improve their communication skills. Using advanced AI-driven techniques, ButterAI provides real-time feedback, personalized voice exercises, and progress tracking to make speech therapy more accessible and effective.  

## Problem Description  

Speech disorders, such as stuttering, affect over 370 million people worldwide, creating daily challenges in communication and confidence. For many, professional speech therapy is inaccessible due to high costs—often reaching $250 per hour—and limited availability. Existing solutions lack personalized, adaptive support, leaving a significant gap in accessible, effective speech therapy tools.  

## Solution  

ButterAI is a revolutionary platform designed to make speech therapy accessible, affordable, and adaptive. Like "Duolingo for Speech Therapy," it combines:  

- **3D AI Speech Therapist**: A virtual AI assistant that guides users through speech exercises.  
- **Stutter Detection Algorithms**: AI-powered detection to identify speech disfluencies and provide real-time corrective feedback.  
- **Personalized Voice Exercises**: Tailored exercises based on each user's progress and specific speech challenges.  
- **Progress Tracking Reports**: Detailed analytics and improvement tracking to monitor speech development over time.  
- **24/7 Accessibility**: AI-driven speech therapy available anytime, removing barriers to traditional in-person sessions.  

## Features  

- **AI Speech Coach**: Interactive virtual speech therapist for guided practice.  
- **Real-Time Feedback**: Instant analysis and correction of speech patterns.  
- **Custom Speech Exercises**: Exercises tailored to the user's speech needs.  
- **Progress Analytics**: Visual reports to track improvements over time.  
- **Voice Recognition & Stutter Detection**: AI-powered evaluation of speech fluency.  

## Installation  

To get started with ButterAI, follow these steps:  

1. **Clone the repository**:  
   ```
   git clone https://github.com/kiandrew08/butterAI.git
   ```

2. **Install dependencies**:  
   Navigate to the project directory and install the necessary dependencies using:  
   ```
   pip install -r requirements.txt
   ```

3. **Run the application**:  
   You can run the app locally by executing:  
   ```
   python app.py
   ```
   This will start a local development server. You can access the app by visiting http://localhost:5000 in your web browser.

## Usage

1. **Start a Speech Session**: Click on the "Start Session" button to begin practicing with the AI speech therapist.
2. **Receive Real-Time Feedback**: Speak into the microphone, and ButterAI will analyze speech patterns, detect stuttering, and provide corrective feedback.
3. **Practice Exercises**: Follow AI-generated exercises designed to improve fluency and pronunciation.
4. **Track Progress**: View detailed analytics on speech improvements over time.

## API

ButterAI offers a RESTful API for integrating speech therapy features into other applications.

### Speech Analysis API
- **Endpoint**: /analyze
- **Method**: POST
- **Parameters**:
  - `audio_file` (required): The recorded audio file for analysis.
- **Response**:
  - `feedback` (string): AI-generated speech improvement feedback.
  - `stutter_score` (float): A score representing the severity of detected speech disfluencies.

## Contributing

We welcome contributions to ButterAI! If you have suggestions, improvements, or bug fixes, feel free to open an issue or submit a pull request.

1. **Fork the repository**.
2. **Create a new branch**:
   ```
   git checkout -b feature-branch
   ```

3. **Commit your changes**:
   ```
   git commit -m 'Add feature'
   ```

4. **Push to the branch**:
   ```
   git push origin feature-branch
   ```

5. **Create a new Pull Request**.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to the developers and contributors of speech recognition and AI-based speech therapy technologies that made ButterAI possible.


