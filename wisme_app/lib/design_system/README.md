# Wisme Design System

## Overview
This design system provides maximum flexibility and customizability for UI/UX developers. Every visual element can be easily modified without touching backend code.

## Architecture Philosophy
- **Complete separation** between UI and business logic
- **Component-driven** development with maximum reusability
- **Theme-first** approach - everything is customizable through themes
- **Documentation-driven** - every component is self-documenting
- **Type-safe** customization options

## Directory Structure

```
lib/
├── design_system/           # All UI/design related code
│   ├── atoms/              # Basic building blocks
│   ├── molecules/          # Simple combinations of atoms
│   ├── organisms/          # Complex UI components
│   ├── templates/          # Page layouts without data
│   ├── themes/             # All theme configurations
│   └── tokens/             # Design tokens (colors, spacing, etc.)
├── business_logic/         # All backend/business logic
│   ├── models/            # Data models
│   ├── services/          # API and business services
│   └── providers/         # State management
└── features/              # Feature-specific code
    └── [feature]/
        ├── presentation/  # UI for this feature
        └── data/         # Data layer for this feature
```

## For UI/UX Developers

### Quick Start
1. All visual changes happen in `design_system/`
2. Colors: Edit `tokens/app_colors.dart`
3. Typography: Edit `tokens/app_typography.dart`
4. Spacing: Edit `tokens/app_spacing.dart`
5. Components: Modify files in `atoms/`, `molecules/`, `organisms/`

### Key Principles
- Never edit anything in `business_logic/` or `services/`
- All components accept customization props
- Use theme tokens instead of hardcoded values
- Follow the component hierarchy: atoms → molecules → organisms

### Component Guidelines
- Every component should be in its own file
- Components should accept all necessary customization props
- Use composition over inheritance
- Include usage examples in comments
