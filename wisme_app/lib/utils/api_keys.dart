// API Keys Configuration
// Add your actual API keys here before deployment

class ApiKeys {
  // OpenAI API Key for content generation
  // Get from: https://platform.openai.com/api-keys
  static const String openAiApiKey = 'your-openai-api-key-here';
  
  // ElevenLabs API Key for text-to-speech
  // Get from: https://elevenlabs.io/app/settings
  static const String elevenLabsApiKey = 'your-elevenlabs-api-key-here';
  
  // Voice IDs for coaches (ElevenLabs)
  static const String kaiVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Professional male
  static const String veeVoiceId = '2EiwWnXFnvU5JabPnv8n'; // Energetic female
  static const String defaultVoiceId = 'pNInz6obpgDQGcFmaJgB'; // Neutral voice
}

// Firebase configuration will be added during setup
// Follow the Firebase setup guide in FINAL_SETUP.md

