// ==============================================================================
// WISME APP - CENTRAL EXPORTS FILE
// ==============================================================================
// This file serves as the single source of truth for all imports across the app.
// Import this file instead of individual files to avoid import path issues.
// ==============================================================================

// Flutter Core
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter/foundation.dart';

// State Management
export 'package:provider/provider.dart';

// App Constants
export '../constants/app_colors.dart';
export '../constants/app_text_styles.dart';
export '../constants/app_assets.dart';
export '../constants/app_dimensions.dart';

// Core Models
export '../models/user_profile.dart';
export '../models/content_block.dart';
export '../models/topic_model.dart';
export '../models/learning_session.dart';
export '../models/achievement.dart' hide Achievement; // Use Achievement from user_profile.dart
export '../models/voice.dart';
export '../models/voice_model.dart'; // ElevenLabsVoice
export '../models/result.dart';
export '../models/analytics.dart';
export '../models/coach_model.dart';
export '../models/lesson_model.dart' hide ContentBlock, UserProgress; // Use ContentBlock from content_block.dart, UserProgress from user_model.dart
export '../models/user_model.dart';

// Core Services  
export '../services/auth_services.dart'; // Primary auth service (AuthService)
export '../services/firestore_service.dart';
export '../services/gpt_service.dart';
export '../services/elevenlabs_service.dart';
export '../services/audio_player_service.dart';
export '../services/cache_service.dart';
export '../services/analytics_service.dart';
export '../services/storage_service.dart';
export '../services/tts_service.dart';
export '../services/content_matching_service.dart';

// Note: Temporarily excluding conflicting services:
// export '../services/auth_service.dart'; // Conflicts with auth_services.dart

// Providers
export '../providers/user_provider.dart';
export '../providers/lesson_provider.dart'; // Keep the provider version
export '../providers/audio_provider.dart';
export '../providers/auth_provider.dart';
export '../providers/voice_provider.dart';
export '../providers/coach_provider.dart';
export '../providers/settings_provider.dart';

// Managers
export '../managers/app_state_manager.dart';

// Routes
export '../routes.dart';

// UI Widgets
export '../UI/widgets/modern_components.dart';
export '../UI/widgets/lesson_card.dart';
export '../UI/widgets/app_text_field.dart';

// Utilities
export '../utils/helper_functions.dart';
export '../utils/logger.dart';
export '../utils/api_keys.dart';

// ==============================================================================
// SCREEN EXPORTS (Organized by Category)
// ==============================================================================

// Core Screens
export '../UI/screens/home_screen.dart';
export '../UI/screens/dashboard_screen.dart';
export '../UI/screens/profile_screen.dart';

// Authentication & Onboarding
export '../UI/screens/onboarding_screen.dart';
export '../UI/screens/login_screen.dart';
export '../UI/screens/welcome_back_screen.dart';
export '../UI/screens/splash_screen.dart';

// Learning Screens
export '../UI/screens/lesson_screen.dart';
export '../UI/screens/topic_selection_screen.dart';
export '../UI/screens/topic_analysis_screen.dart';
export '../UI/screens/topic_screen.dart';
export '../UI/screens/learning_stats_screen.dart';
export '../UI/screens/learning_data_screen.dart';
export '../UI/screens/learning_history_screen.dart';
export '../UI/screens/knowledge_level_screen.dart';

// Coach & Content
export '../UI/screens/coach_selection_screen.dart';
export '../UI/screens/coach_naming_screen.dart';
export '../UI/screens/content_library_screen.dart';

// Media & Audio
export '../UI/screens/enhanced_audio_player_screen.dart';
export '../UI/screens/voice_settings_screen.dart';

// Social & Achievements
export '../UI/screens/social_leaderboard_screen.dart';
export '../UI/screens/achievements_gallery_screen.dart';

// Settings & Support
export '../UI/screens/settings_screen.dart';
export '../UI/screens/advanced_settings_screen.dart';
export '../UI/screens/help_support_screen.dart';
export '../UI/screens/privacy_policy_screen.dart';
export '../UI/screens/terms_of_service_screen.dart';

// Utility Screens
export '../UI/screens/search_screen.dart';
export '../UI/screens/downloads_screen.dart';
export '../UI/screens/favorites_screen.dart';
export '../UI/screens/analytics_screen.dart';
export '../UI/screens/component_showcase_screen.dart';

// ==============================================================================
// COMMON EXTERNAL PACKAGES
// ==============================================================================
// Add commonly used external package exports here as your app grows
// Example:
// export 'package:http/http.dart';
// export 'package:shared_preferences/shared_preferences.dart';
// export 'package:firebase_core/firebase_core.dart';
// export 'package:firebase_auth/firebase_auth.dart';
