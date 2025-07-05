# 🎨 Wisme Design System

*Ultra-customizable, component-driven design system for maximum flexibility*

---

## 🎯 Overview

This design system provides complete UI/UX flexibility, allowing visual changes without touching business logic. Every component is theme-aware and fully customizable.

## 🏗️ Architecture Philosophy

- **🔄 Complete Separation** - UI and business logic are completely independent
- **🧱 Component-Driven** - Atomic design with maximum reusability
- **🎨 Theme-First** - Everything customizable through centralized themes
- **📚 Self-Documenting** - Components include usage examples and guidelines
- **⚡ Type-Safe** - Full TypeScript-style safety for all customization options

---

## 📁 Directory Structure

```
lib/design_system/
├── tokens/                  # 🎯 Design tokens (the foundation)
│   ├── app_colors.dart     # Color palette and semantic colors
│   ├── app_typography.dart # Text styles and font definitions
│   ├── app_spacing.dart    # Spacing scale and layout constants
│   ├── app_shadows.dart    # Shadow and elevation definitions
│   └── app_borders.dart    # Border radius and stroke definitions
├── theme/                   # 🎨 Theme configurations
│   ├── app_theme.dart      # Main theme combining all tokens
│   ├── light_theme.dart    # Light mode theme
│   ├── dark_theme.dart     # Dark mode theme
│   └── theme_extensions.dart # Custom theme extensions
├── components/              # 🧱 Reusable UI components
│   ├── atoms/              # Basic building blocks
│   │   ├── buttons/        # Button variants and styles
│   │   ├── inputs/         # Text fields and form controls
│   │   ├── icons/          # Icon components and wrappers
│   │   └── text/           # Text components with theme integration
│   ├── molecules/          # Combinations of atoms
│   │   ├── cards/          # Card layouts and variants
│   │   ├── navigation/     # Navigation components
│   │   ├── media/          # Audio/video player components
│   │   └── forms/          # Form layouts and validation
│   └── organisms/          # Complex UI sections
│       ├── headers/        # App bars and headers
│       ├── lists/          # List layouts and item templates
│       ├── modals/         # Dialog and modal components
│       └── layouts/        # Page layout templates
└── utils/                   # 🔧 Design system utilities
    ├── responsive.dart     # Responsive design helpers
    ├── animations.dart     # Animation constants and curves
    └── accessibility.dart  # Accessibility utilities
```

---

## 🚀 Quick Start for UI/UX Developers

### **Step 1: Understanding Tokens**
Tokens are the foundation - change these to transform the entire app:

```dart
// Colors - lib/design_system/tokens/app_colors.dart
class WismeColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6366F1);      // Indigo
  static const Color secondary = Color(0xFF8B5CF6);    // Purple
  static const Color accent = Color(0xFF06B6D4);       // Cyan
  
  // Semantic colors
  static const Color success = Color(0xFF10B981);      // Green
  static const Color warning = Color(0xFFF59E0B);      // Amber
  static const Color error = Color(0xFFEF4444);        // Red
  
  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);   // Light gray
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color onSurface = Color(0xFF1F2937);    // Dark gray
}
```

### **Step 2: Typography System**
```dart
// Typography - lib/design_system/tokens/app_typography.dart
class WismeTypography {
  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  // Captions
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
}
```

### **Step 3: Spacing System**
```dart
// Spacing - lib/design_system/tokens/app_spacing.dart
class WismeSpacing {
  // Base unit (4px)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Semantic spacing
  static const double cardPadding = md;
  static const double screenMargin = lg;
  static const double buttonHeight = 48.0;
}
```

---

## 🧱 Component Usage Guide

### **Atoms (Basic Building Blocks)**

#### **WismeButton**
```dart
// Primary button
WismeButton(
  text: 'Start Learning',
  onPressed: () => startLearning(),
  variant: WismeButtonVariant.primary,
)

// Secondary button
WismeButton(
  text: 'Cancel',
  onPressed: () => Navigator.pop(context),
  variant: WismeButtonVariant.secondary,
  size: WismeButtonSize.small,
)

// Custom styling
WismeButton(
  text: 'Custom',
  onPressed: () {},
  backgroundColor: WismeColors.accent,
  textColor: Colors.white,
  borderRadius: 12.0,
)
```

#### **WismeTextField**
```dart
// Standard text field
WismeTextField(
  label: 'Enter your topic',
  placeholder: 'e.g., Startup Funding',
  onChanged: (value) => handleTopicChange(value),
)

// With validation
WismeTextField(
  label: 'Email',
  validator: (value) => EmailValidator.validate(value),
  keyboardType: TextInputType.emailAddress,
)
```

### **Molecules (Component Combinations)**

#### **WismeCard**
```dart
// Lesson card
WismeCard(
  title: 'How Airbnb Almost Died',
  subtitle: 'The $40k Debt Story',
  duration: '12 min',
  imageUrl: 'assets/images/airbnb-lesson.jpg',
  onTap: () => playLesson(lessonId),
  variant: WismeCardVariant.lesson,
)

// Coach selection card
WismeCard(
  title: 'Kai',
  subtitle: 'Strategic, calm mentor',
  trailing: coachSelected ? Icons.check : null,
  onTap: () => selectCoach('kai'),
  variant: WismeCardVariant.selection,
)
```

#### **WismeAudioPlayer**
```dart
// Full audio player
WismeAudioPlayer(
  title: 'Current Episode',
  duration: Duration(minutes: 12, seconds: 30),
  position: currentPosition,
  isPlaying: isPlaying,
  onPlayPause: () => togglePlayback(),
  onSeek: (position) => seekTo(position),
  onSpeedChange: (speed) => setPlaybackSpeed(speed),
)
```

### **Organisms (Complex Components)**

#### **WismeLessonList**
```dart
// Complete lesson listing
WismeLessonList(
  lessons: lessonProvider.lessons,
  isLoading: lessonProvider.isLoading,
  onLessonTap: (lesson) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
  ),
  onRefresh: () => lessonProvider.refreshLessons(),
)
```

#### **WismeNavigationBar**
```dart
// Bottom navigation
WismeNavigationBar(
  currentIndex: selectedIndex,
  onTap: (index) => navigateToTab(index),
  items: [
    WismeNavItem(icon: Icons.home, label: 'Home'),
    WismeNavItem(icon: Icons.library_books, label: 'Library'),
    WismeNavItem(icon: Icons.person, label: 'Profile'),
  ],
)
```

---

## 🎨 Theming & Customization

### **Applying Custom Themes**
```dart
// In main.dart
MaterialApp(
  theme: WismeTheme.lightTheme,
  darkTheme: WismeTheme.darkTheme,
  themeMode: ThemeMode.system,
  home: HomeScreen(),
)
```

### **Creating Brand Variations**
```dart
// Custom brand theme
class CustomWismeTheme {
  static ThemeData customTheme = WismeTheme.lightTheme.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF8B5CF6), // Your brand color
      brightness: Brightness.light,
    ),
    textTheme: WismeTheme.lightTheme.textTheme.copyWith(
      headline1: WismeTypography.headline1.copyWith(
        fontFamily: 'YourCustomFont',
      ),
    ),
  );
}
```

### **Runtime Theme Switching**
```dart
// Theme provider for dynamic switching
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  void setTheme(ThemeMode theme) {
    _themeMode = theme;
    notifyListeners();
  }
}
```

---

## 🎯 Customization Guidelines

### **✅ Do This**
- ✅ Use design tokens for all values
- ✅ Create component variants for different use cases
- ✅ Follow the atomic design hierarchy
- ✅ Test components in both light and dark themes
- ✅ Document component props and usage examples
- ✅ Use semantic naming for colors and spacing

### **❌ Avoid This**
- ❌ Hardcoding colors, fonts, or spacing values
- ❌ Mixing business logic with UI components
- ❌ Creating components without customization props
- ❌ Ignoring accessibility requirements
- ❌ Breaking the component hierarchy
- ❌ Using platform-specific code in shared components

---

## 🧪 Component Development Workflow

### **Step 1: Design Token First**
Before creating any component, ensure the necessary tokens exist:
```dart
// Add new tokens if needed
class WismeColors {
  // ...existing colors...
  static const Color newBrandColor = Color(0xFF..);
}
```

### **Step 2: Create Atomic Component**
Start with the smallest reusable piece:
```dart
// atoms/my_new_button.dart
class MyNewButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  
  const MyNewButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? WismeColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      child: Text(
        text,
        style: WismeTypography.bodyLarge.copyWith(
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
```

### **Step 3: Compose into Molecules**
Combine atoms to create more complex components:
```dart
// molecules/lesson_card.dart
class LessonCard extends StatelessWidget {
  // Combines: Image, Text, Button, Container
  // ...implementation
}
```

### **Step 4: Build Organisms**
Create full sections using molecules and atoms:
```dart
// organisms/lesson_list.dart
class LessonList extends StatelessWidget {
  // Combines: LessonCard, LoadingIndicator, RefreshIndicator
  // ...implementation
}
```

---

## 📱 Responsive Design

### **Breakpoint System**
```dart
// utils/responsive.dart
class WismeBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
      
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;
}
```

### **Responsive Components**
```dart
// Responsive layout example
class ResponsiveLessonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = WismeBreakpoints.isMobile(context) ? 1 : 2;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: WismeSpacing.md,
        mainAxisSpacing: WismeSpacing.md,
      ),
      itemBuilder: (context, index) => LessonCard(/*...*/),
    );
  }
}
```

---

## ♿ Accessibility

### **Built-in Accessibility**
All components include accessibility features:
```dart
// Example with semantic labels
WismeButton(
  text: 'Play',
  onPressed: playAudio,
  semanticLabel: 'Play audio lesson',
  tooltip: 'Start playing the current lesson',
)
```

### **Accessibility Guidelines**
- 🔤 **Text Scaling**: All text respects user font size preferences
- 🎨 **Color Contrast**: Minimum 4.5:1 contrast ratio for all text
- 🎯 **Touch Targets**: Minimum 48px touch target size
- 🔊 **Screen Readers**: Semantic labels for all interactive elements
- ⌨️ **Keyboard Navigation**: Full keyboard support for all interactions

---

## 🚀 Best Practices

### **Performance**
- Use `const` constructors wherever possible
- Implement `shouldRebuild` for expensive widgets
- Lazy-load images and heavy content
- Cache theme data for better performance

### **Maintainability**
- Keep components small and focused
- Use composition over inheritance
- Write tests for complex components
- Document component APIs thoroughly

### **Scalability**
- Design for multiple screen sizes
- Plan for internationalization
- Consider future theme variations
- Build with team collaboration in mind

---

*Building beautiful, accessible, and maintainable UI components for the future of learning* ✨
