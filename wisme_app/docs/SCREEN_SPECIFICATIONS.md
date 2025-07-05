# 📱 Screen Specifications

*Detailed requirements for every screen in the Wisme app*

---

## 🎯 **Screen Architecture Overview**

### **App Structure**
```
Wisme App
├── 🔐 Authentication Flow
│   ├── Onboarding Screen
│   ├── Login Screen  
│   └── Signup Screen
├── 🏠 Main App Flow
│   ├── Home Screen
│   ├── Topic Analysis Screen
│   ├── Category Selection Screen
│   ├── Knowledge Level Screen
│   ├── Coach Selection Screen
│   ├── Coach Naming Screen
│   ├── Avatar Selection Screen
│   ├── Journey Planning Screen
│   └── Audio Player Screen
├── 📊 Progress & Profile
│   ├── Progress Dashboard
│   ├── Profile Screen
│   └── Settings Screen
└── 🔧 Utility Screens
    ├── Search Screen
    ├── Library Screen
    └── Component Showcase
```

---

## 🔐 **Authentication Screens**

### **1. Onboarding Screen**

#### **Purpose**
Introduce Wisme's value proposition and guide new users through the core concept.

#### **Layout Requirements**
```
┌─────────────────────────┐
│   [Skip] [Progress 1/3] │
├─────────────────────────┤
│                         │
│    [Animated Coach]     │
│         Avatar          │
│                         │
├─────────────────────────┤
│    "Meet Your AI        │
│   Learning Coach"       │
│                         │
│ "Personalized lessons   │
│  delivered like your    │
│  favorite podcast"      │
├─────────────────────────┤
│      [Next] [Get]       │
│            [Started]    │
└─────────────────────────┘
```

#### **Components**
- **Progress Indicator**: 3 dots showing current step
- **Skip Button**: Top-right, allows bypassing onboarding
- **Hero Animation**: Large coach avatar with subtle animation
- **Value Proposition**: Clear, compelling headline and description
- **CTA Button**: Primary button to continue
- **Page Indicator**: Swipeable page view with 3 screens

#### **Content Screens**
1. **Screen 1**: "Meet Your AI Learning Coach"
2. **Screen 2**: "Learn Any Topic in 10-15 Minutes"  
3. **Screen 3**: "Build Daily Learning Habits"

#### **Interactions**
- Swipe left/right to navigate
- Tap "Next" to advance
- Tap "Skip" to go directly to signup
- Auto-advance after 10 seconds on final screen

---

### **2. Login Screen**

#### **Purpose**
Secure user authentication with multiple options.

#### **Layout Requirements**
```
┌─────────────────────────┐
│      [< Back]           │
├─────────────────────────┤
│                         │
│     [Wisme Logo]        │
│                         │
│   "Welcome Back!"       │
│                         │
├─────────────────────────┤
│ [Email Input Field]     │
│                         │
│ [Password Input Field]  │
│                         │
│   [Forgot Password?]    │
├─────────────────────────┤
│    [Login Button]       │
│                         │
│       -- OR --          │
│                         │
│  [Continue with Google] │
│  [Continue with Apple]  │
├─────────────────────────┤
│ "Don't have an account? │
│      [Sign Up]"         │
└─────────────────────────┘
```

#### **Form Validation**
- **Email**: Valid email format required
- **Password**: Minimum 8 characters
- **Real-time validation**: Show errors as user types
- **Success states**: Green checkmarks for valid fields

#### **Error Handling**
- Invalid credentials: "Email or password incorrect"
- Network errors: "Connection failed. Please try again."
- Account locked: "Too many attempts. Try again in 15 minutes."

#### **Accessibility**
- Screen reader support for all form fields
- High contrast focus indicators
- Keyboard navigation support

---

## 🏠 **Main Learning Flow**

### **3. Home Screen**

#### **Purpose**
Central hub for starting new learning journeys and accessing ongoing content.

#### **Layout Requirements**
```
┌─────────────────────────┐
│ [Profile] Wisme [Search]│
├─────────────────────────┤
│                         │
│ "What do you want to    │
│      learn today?"      │
│                         │
│ [Search Input Field]    │ ← Main CTA
│      [🎤 Voice]         │
├─────────────────────────┤
│ "Continue Learning"     │
│                         │
│ [Current Journey Card]  │
│ ████████░░ 60% Complete │
├─────────────────────────┤
│ "Explore Categories"    │
│                         │
│ [📊] [🌐] [🧠] [🔍]    │
│ Biz  Tech Mind Sci      │
│                         │
│ [💡] [🌱] [📚] [🛠]    │
│ Crea Self Hist Skill    │
│                         │
│ [🎯] Career             │
├─────────────────────────┤
│ "Recent Topics"         │
│                         │
│ [Topic Card] [Topic]    │
│ [Topic Card] [Card]     │
└─────────────────────────┘
```

#### **Key Components**
- **Search Bar**: Main interaction, prominent placement
- **Voice Input**: Microphone icon for accessibility
- **Continue Learning**: Current journey with progress
- **Category Grid**: 9 categories with icons and labels
- **Recent Topics**: Personalized suggestions
- **Bottom Navigation**: Home, Library, Profile

#### **States**
- **New User**: Emphasized search with onboarding hints
- **Returning User**: Current journey prominently displayed
- **Offline Mode**: Cached content available, sync indicator

---

### **4. Topic Analysis Screen**

#### **Purpose**
Show AI processing user's topic input and present categorization results.

#### **Layout Requirements**
```
┌─────────────────────────┐
│      [< Back]           │
├─────────────────────────┤
│                         │
│   [AI Thinking Icon]    │ ← Animated
│                         │
│ "Analyzing your topic..." │
│                         │
│ [Progress Animation]    │
├─────────────────────────┤
│ ↓ (After processing) ↓  │
├─────────────────────────┤
│ "I understand you want  │
│  to learn productivity" │
│                         │
│ "This fits best in:"    │
│                         │
│ [🌱 Self-Growth Card]   │
│ "Personal development   │
│  and habit formation"   │
├─────────────────────────┤
│ "Other possibilities:"  │
│                         │
│ [🛠 Skills & Tools]     │
│ [📊 Business & Finance] │
├─────────────────────────┤
│   [Continue with        │
│    Self-Growth]         │
└─────────────────────────┘
```

#### **AI Processing Flow**
1. **Loading State**: Animated thinking indicator (2-5 seconds)
2. **Analysis Results**: Clear category recommendation
3. **Alternative Options**: 2-3 other possible categories
4. **Confidence Indicator**: Visual representation of AI confidence

#### **Error Handling**
- **Ambiguous Topic**: Ask clarifying questions
- **Unknown Topic**: Suggest closest categories
- **API Failure**: Fallback to manual category selection

---

### **5. Knowledge Level Selection Screen**

#### **Purpose**
Allow users to choose their preferred learning depth and style.

#### **Layout Requirements**
```
┌─────────────────────────┐
│      [< Back]           │
├─────────────────────────┤
│ "How do you want to     │
│  learn productivity?"   │
│                         │
│ Self-Growth Category    │
├─────────────────────────┤
│                         │
│ [📖 Philosophy &        │
│     Mental Models]      │
│ "Deep principles and    │
│  foundational concepts" │
│                         │
├─────────────────────────┤
│ [🎯 Self-Development]   │
│ "Practical personal     │
│  improvement techniques"│
│                         │
├─────────────────────────┤
│ [💬 Habits & Mindset]   │
│ "Behavioral change and  │
│  psychology insights"   │
│                         │
├─────────────────────────┤
│ [🎛 Reflective Mix]     │
│ "Blended approach with  │
│  all elements above"    │
├─────────────────────────┤
│    [Continue]           │
└─────────────────────────┘
```

#### **Level Descriptions by Category**

**🌐 Technology**
- 🔹 Core Concepts
- 💼 Case Studies  
- 🛠 Tools & Trends
- 🎛 Bit of Everything

**📊 Business & Finance**
- 💡 Fundamentals
- 💼 Case Studies
- 📈 Growth Strategy
- 🎛 Balanced Mix

**🧠 Psychology & Mind**
- 🧠 Theories & Experiments
- 💬 Real-Life Application
- 🧘 Mindfulness & Behavior
- 🎛 Mixed Approach

#### **Selection Behavior**
- **Single Selection**: Only one level can be chosen
- **Preview Content**: Show sample topics for each level
- **Recommendation**: AI suggests optimal level based on user profile

---

### **6. Coach Selection Screen**

#### **Purpose**
Allow users to choose their AI coach personality and see the differences.

#### **Layout Requirements**
```
┌─────────────────────────┐
│      [< Back]           │
├─────────────────────────┤
│ "Choose Your Learning   │
│       Coach"            │
│                         │
│ "Your coach will guide  │
│ you through every lesson"│
├─────────────────────────┤
│                         │
│ [Kai Coach Card]        │
│ [Avatar Image]          │
│ "Kai"                   │
│ Strategic • Calm        │
│ Mentor-like             │
│ [🔊 Preview Voice]      │
│ [Select Kai]            │
│                         │
├─────────────────────────┤
│ [Vee Coach Card]        │
│ [Avatar Image]          │
│ "Vee"                   │
│ Bold • Energetic        │
│ Friend-like             │
│ [🔊 Preview Voice]      │
│ [Select Vee]            │
│                         │
├─────────────────────────┤
│ [Custom Coach Card]     │
│ "Create Your Own"       │
│ [Customize →]           │
└─────────────────────────┘
```

#### **Coach Personalities**

**🧠 Kai - The Strategic Mentor**
- **Visual**: Professional, calm avatar
- **Voice**: Lower pitch, measured pace
- **Teaching Style**: Structured, logical progression
- **Best For**: Business, technology, analytical topics

**⚡ Vee - The Energetic Friend**
- **Visual**: Vibrant, approachable avatar
- **Voice**: Higher energy, faster pace
- **Teaching Style**: Story-driven, motivational
- **Best For**: Creative, self-growth, inspirational topics

#### **Voice Previews**
- 10-15 second audio samples
- Demonstrates personality and teaching style
- Topic-relevant content preview

---

### **7. Coach Naming Screen**

#### **Purpose**
Personalize the coaching relationship by allowing custom names.

#### **Layout Requirements**
```
┌─────────────────────────┐
│      [< Back]           │
├─────────────────────────┤
│                         │
│   [Selected Coach       │
│      Avatar]            │
│                         │
│ "What would you like    │
│   to call your coach?"  │
│                         │
├─────────────────────────┤
│                         │
│ [Name Input Field]      │
│ Placeholder: "Sarah"    │
│                         │
│ "Suggestions:"          │
│ [Sarah] [Alex] [Maya]   │
│ [Jordan] [Sam] [Riley]  │
│                         │
├─────────────────────────┤
│                         │
│ "Preview:"              │
│ [🔊] "Hi, I'm Sarah!    │
│     Ready to learn      │
│     about productivity?"│
│                         │
├─────────────────────────┤
│      [Continue]         │
└─────────────────────────┘
```

#### **Features**
- **Smart Suggestions**: Popular, diverse names
- **Custom Input**: Allow any name user wants
- **Real-time Preview**: Hear coach say the chosen name
- **Validation**: Prevent inappropriate names
- **Accessibility**: Support for screen readers and voice input

---

### **8. Avatar Selection Screen**

#### **Purpose**
Allow visual customization of the coach's appearance.

#### **Layout Requirements**
```
┌─────────────────────────┐
│      [< Back]           │
├─────────────────────────┤
│ "Choose Sarah's Look"   │
│                         │
│ Coach: Kai Personality  │
├─────────────────────────┤
│                         │
│ [Large Preview]         │
│ [Selected Avatar]       │
│                         │
├─────────────────────────┤
│ "Avatar Gallery"        │
│                         │
│ [Avatar] [Avatar] [Av]  │
│ [Option] [Option] [Op]  │
│                         │
│ [Avatar] [Avatar] [Av]  │
│ [Option] [Option] [Op]  │
│                         │
├─────────────────────────┤
│ "Style Categories"      │
│ [Professional] [Casual] │
│ [Creative] [Academic]   │
├─────────────────────────┤
│   [Meet Sarah →]        │
└─────────────────────────┘
```

#### **Avatar System**
- **Personality Consistency**: Avatars match coach personality
- **Diverse Representation**: Multiple ethnicities, ages, styles
- **Style Categories**: Professional, Casual, Creative, Academic
- **Animation Preview**: Show avatar with voice sample
- **Accessibility**: Alt text descriptions for each avatar

#### **Avatar Categories for Kai (Strategic)**
- Professional business attire
- Calm, confident expressions
- Neutral, approachable appearance

#### **Avatar Categories for Vee (Energetic)**
- Casual, creative clothing
- Bright, enthusiastic expressions
- Dynamic, engaging appearance

---

### **9. Journey Planning Screen**

#### **Purpose**
Show the personalized learning curriculum and allow customization.

#### **Layout Requirements**
```
┌─────────────────────────┐
│      [< Back]           │
├─────────────────────────┤
│ "Your Productivity      │
│   Learning Journey"     │
│                         │
│ With Sarah • 5 days     │
├─────────────────────────┤
│                         │
│ [Journey Timeline]      │
│                         │
│ Day 1 ● "Foundations"   │
│ ↓      12 min           │
│ Day 2 ○ "Time Systems"  │
│ ↓      14 min           │ 
│ Day 3 ○ "Energy Focus"  │
│ ↓      11 min           │
│ Day 4 ○ "Habit Science" │
│ ↓      13 min           │
│ Day 5 ○ "Your System"   │
│        15 min           │
│                         │
├─────────────────────────┤
│ [Customize Journey]     │
│                         │
│ Pace: ◐ Standard        │
│ Length: [5] [10] [30]   │
│ Focus: [Habits] [Tools] │
├─────────────────────────┤
│   [Start Learning!]     │
└─────────────────────────┘
```

#### **Journey Customization**
- **Pace Selection**: Slow, Standard, Fast
- **Length Options**: 3, 5, 10, 15, 30 days
- **Focus Areas**: Emphasize specific aspects
- **Schedule**: Preferred learning times
- **Episode Preview**: Tap to see episode outline

#### **Visual Timeline**
- **Current Day**: Highlighted and accessible
- **Completed Days**: Checkmarks and progress
- **Future Days**: Grayed out but visible
- **Episode Details**: Duration, key topics, difficulty

---

### **10. Audio Player Screen**

#### **Purpose**
Immersive learning experience with coach interaction and content consumption.

#### **Layout Requirements**
```
┌─────────────────────────┐
│ [< Back] Day 1 [Share]  │
├─────────────────────────┤
│                         │
│    [Coach Avatar]       │
│    Speaking/Idle        │
│                         │
│ "Hi! I'm Sarah. Today   │
│ we're exploring the     │
│ psychology behind       │
│ procrastination..."     │
│                         │
├─────────────────────────┤
│ [Speed] [Bookmark] [⋯]  │
│ 1.2x      🔖          │
├─────────────────────────┤
│ ⏮️ ⏸️ ⏭️   [Sleep]     │
│   15s Play 15s    💤   │
├─────────────────────────┤
│ ████████░░░░ 8:24/12:15 │
│                         │
├─────────────────────────┤
│ "Foundations"           │
│ Episode 1 of 5          │
│                         │
│ [📝 Notes] [📋 Actions] │
└─────────────────────────┘
```

#### **Audio Controls**
- **Play/Pause**: Large, accessible button
- **Skip Controls**: 15-second forward/back
- **Speed Control**: 0.5x to 2x with clarity
- **Sleep Timer**: 5, 10, 15, 30, 60 minutes
- **Bookmark**: Save current position

#### **Coach Avatar**
- **Lip Sync**: Mouth movement with audio
- **Gestures**: Hand movements for emphasis  
- **Expressions**: Match content emotion
- **Idle State**: Gentle breathing/blinking

#### **Transcript**
- **Live Highlighting**: Follow spoken words
- **Tap to Seek**: Jump to specific part
- **Note Taking**: Highlight and annotate
- **Search**: Find specific content

#### **Additional Features**
- **Chapter Navigation**: Jump between sections
- **Offline Mode**: Downloaded content playback
- **Background Play**: Continue when minimized
- **Lock Screen Controls**: Standard media controls

---

## 📊 **Progress & Profile Screens**

### **11. Progress Dashboard**

#### **Purpose**
Comprehensive view of learning progress, achievements, and analytics.

#### **Layout Requirements**
```
┌─────────────────────────┐
│  Progress [Filter] [⚙️] │
├─────────────────────────┤
│                         │
│ [Streak Counter]        │
│     🔥 7 Days           │
│ "Great momentum!"       │
│                         │
├─────────────────────────┤
│ This Week: 2.5 hours    │
│ ████████░░ 83% of goal  │
│                         │
├─────────────────────────┤
│ "Recent Achievements"   │
│                         │
│ 🏆 Productivity Master  │
│ 📚 5-Day Streak        │
│ 🎯 First Journey       │
│                         │
├─────────────────────────┤
│ "Learning Stats"        │
│                         │
│ Topics Explored: 12     │
│ Hours Learned: 28.5     │
│ Favorite Coach: Sarah   │
│ Best Time: 7:30 PM      │
│                         │
├─────────────────────────┤
│ [Knowledge Map] [Goals] │
└─────────────────────────┘
```

---

### **12. Settings Screen**

#### **Purpose**
Comprehensive app configuration and preferences.

#### **Content Sections**
1. **App Preferences**
   - Theme (Dark/Light/Auto)
   - Language selection
   - Notifications settings

2. **Audio & Playback**
   - Default playback speed
   - Auto-play next episode
   - Download quality
   - Sleep timer default

3. **Learning Preferences**
   - Daily learning goal
   - Reminder times
   - Difficulty progression
   - Coach interaction style

4. **Privacy & Data**
   - Analytics opt-out
   - Data sharing preferences
   - Account management
   - Export data

5. **About & Support**
   - Version information
   - Help & FAQ
   - Contact support
   - Terms & Privacy

---

## 🔧 **Component Specifications**

### **Reusable Components**

#### **Progress Bar**
```css
height: 8px
background: gray-200
border-radius: 4px
fill-color: primary-500
animation: smooth 0.3s ease
```

#### **Coach Avatar**
```css
size: 80px (small), 120px (medium), 160px (large)
border-radius: 50%
border: 2px solid white
shadow: 0 4px 12px rgba(0,0,0,0.15)
animation: breathing, speaking states
```

#### **Category Card**
```css
padding: 24px
border-radius: 16px
background: gradient based on category
icon: 32px category-specific
title: 16px semibold
description: 14px regular
hover: transform scale(1.02)
```

#### **Episode Card**
```css
background: white
border-radius: 12px
padding: 20px
shadow: 0 2px 8px rgba(0,0,0,0.1)
border-left: 4px solid primary-500
```

---

*These specifications ensure consistent, accessible, and delightful user experiences across all screens.*
