# 🎨 UI/UX Design System

*Complete design guidelines for building a world-class learning platform*

---

## 🎯 **Design Philosophy**

### **Core Principles**
1. **Personal & Warm** - Learning feels like a conversation with a trusted friend
2. **Intelligent & Adaptive** - UI responds to user behavior and learning progress  
3. **Effortless & Intuitive** - Complex AI technology hidden behind simple interactions
4. **Delightful & Engaging** - Micro-animations and feedback create emotional connection
5. **Accessible & Inclusive** - Works for all users regardless of abilities or backgrounds

### **Visual Metaphors**
- **Coach Relationship**: Personal, trusted, adaptive
- **Learning Journey**: Progressive, achievable, visual
- **Knowledge Building**: Layered, connected, growing
- **Audio Experience**: Immersive, focused, high-quality

---

## 🎨 **Color System**

### **Primary Brand Colors**
```css
/* Primary Palette */
--primary-500: #6366F1;      /* Main brand color - Indigo */
--primary-400: #818CF8;      /* Lighter variant */  
--primary-600: #4F46E5;      /* Darker variant */
--primary-50: #EEF2FF;       /* Very light background */
--primary-900: #312E81;      /* Very dark text */

/* Secondary Palette */
--secondary-500: #EC4899;    /* Pink accent */
--secondary-400: #F472B6;    /* Lighter pink */
--secondary-600: #DB2777;    /* Darker pink */

/* Accent Colors */
--accent-500: #10B981;       /* Success green */
--accent-400: #34D399;       /* Light success */
--accent-600: #059669;       /* Dark success */
```

### **Neutral Colors**
```css
/* Neutral Grays */
--gray-50: #F9FAFB;
--gray-100: #F3F4F6;
--gray-200: #E5E7EB;
--gray-300: #D1D5DB;
--gray-400: #9CA3AF;
--gray-500: #6B7280;
--gray-600: #4B5563;
--gray-700: #374151;
--gray-800: #1F2937;
--gray-900: #111827;
```

### **Semantic Colors**
```css
/* Success States */
--success-50: #ECFDF5;
--success-500: #10B981;
--success-900: #064E3B;

/* Warning States */
--warning-50: #FFFBEB;
--warning-500: #F59E0B;
--warning-900: #78350F;

/* Error States */
--error-50: #FEF2F2;
--error-500: #EF4444;
--error-900: #7F1D1D;

/* Info States */
--info-50: #EFF6FF;
--info-500: #3B82F6;
--info-900: #1E3A8A;
```

### **Usage Guidelines**
- **Primary**: Main CTAs, active states, brand elements
- **Secondary**: Accent elements, highlights, coach personalities
- **Accent**: Success states, achievements, progress indicators
- **Neutral**: Text, borders, backgrounds, secondary elements

---

## 📝 **Typography System**

### **Font Family**
```css
/* Primary Font: Inter (Clean, modern, highly readable) */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
```

### **Type Scale**
```css
/* Display Styles */
--text-display-xl: 72px;     /* Hero headings */
--text-display-lg: 60px;     /* Major headings */
--text-display-md: 48px;     /* Section headings */
--text-display-sm: 36px;     /* Card headings */

/* Heading Styles */
--text-heading-xl: 30px;     /* H1 */
--text-heading-lg: 24px;     /* H2 */
--text-heading-md: 20px;     /* H3 */
--text-heading-sm: 18px;     /* H4 */

/* Body Styles */
--text-body-xl: 20px;        /* Large body text */
--text-body-lg: 18px;        /* Regular body text */
--text-body-md: 16px;        /* Default body text */
--text-body-sm: 14px;        /* Small body text */

/* Label Styles */
--text-label-xl: 16px;       /* Large labels */
--text-label-lg: 14px;       /* Regular labels */
--text-label-md: 12px;       /* Small labels */
--text-label-sm: 10px;       /* Tiny labels */
```

### **Font Weights**
```css
--font-light: 300;           /* Light text */
--font-regular: 400;         /* Regular text */
--font-medium: 500;          /* Medium emphasis */
--font-semibold: 600;        /* Strong emphasis */
--font-bold: 700;            /* Bold headings */
```

### **Line Heights**
```css
--leading-tight: 1.25;       /* Headings */
--leading-normal: 1.5;       /* Body text */
--leading-relaxed: 1.75;     /* Long-form content */
```

---

## 📐 **Spacing & Layout**

### **Spacing Scale**
```css
/* Base unit: 4px */
--space-1: 4px;      /* 0.25rem */
--space-2: 8px;      /* 0.5rem */
--space-3: 12px;     /* 0.75rem */
--space-4: 16px;     /* 1rem */
--space-5: 20px;     /* 1.25rem */
--space-6: 24px;     /* 1.5rem */
--space-8: 32px;     /* 2rem */
--space-10: 40px;    /* 2.5rem */
--space-12: 48px;    /* 3rem */
--space-16: 64px;    /* 4rem */
--space-20: 80px;    /* 5rem */
--space-24: 96px;    /* 6rem */
```

### **Component Spacing**
```css
/* Internal component spacing */
--padding-xs: var(--space-2);    /* 8px */
--padding-sm: var(--space-3);    /* 12px */
--padding-md: var(--space-4);    /* 16px */
--padding-lg: var(--space-6);    /* 24px */
--padding-xl: var(--space-8);    /* 32px */

/* External component spacing */
--margin-xs: var(--space-2);     /* 8px */
--margin-sm: var(--space-4);     /* 16px */
--margin-md: var(--space-6);     /* 24px */
--margin-lg: var(--space-8);     /* 32px */
--margin-xl: var(--space-12);    /* 48px */
```

### **Grid System**
```css
/* 12-column grid with 16px gutters */
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--space-4);
}

.grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: var(--space-4);
}

/* Responsive breakpoints */
@media (max-width: 768px) {
  .grid {
    grid-template-columns: 1fr;
    gap: var(--space-3);
  }
}
```

---

## 🔘 **Component Library**

### **Buttons**

#### **Primary Button**
```css
.btn-primary {
  background: linear-gradient(135deg, var(--primary-500), var(--secondary-500));
  color: white;
  padding: var(--padding-md) var(--space-6);
  border-radius: 12px;
  font-weight: var(--font-semibold);
  font-size: var(--text-body-md);
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(99, 102, 241, 0.4);
}

.btn-primary:active {
  transform: translateY(0);
}
```

#### **Secondary Button**
```css
.btn-secondary {
  background: var(--gray-100);
  color: var(--gray-700);
  padding: var(--padding-md) var(--space-6);
  border-radius: 12px;
  font-weight: var(--font-medium);
  border: 1px solid var(--gray-200);
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: var(--gray-200);
  border-color: var(--gray-300);
}
```

### **Cards**

#### **Learning Card**
```css
.learning-card {
  background: white;
  border-radius: 16px;
  padding: var(--space-6);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--gray-100);
  transition: all 0.3s ease;
}

.learning-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
}

.learning-card-header {
  display: flex;
  align-items: center;
  margin-bottom: var(--space-4);
}

.learning-card-icon {
  width: 48px;
  height: 48px;
  background: var(--primary-50);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: var(--space-3);
}
```

#### **Coach Card**
```css
.coach-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px;
  padding: var(--space-8);
  text-align: center;
  position: relative;
  overflow: hidden;
}

.coach-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin: 0 auto var(--space-4);
  border: 4px solid rgba(255, 255, 255, 0.2);
}

.coach-personality {
  font-size: var(--text-body-sm);
  opacity: 0.9;
  margin-bottom: var(--space-2);
}
```

### **Form Elements**

#### **Text Input**
```css
.text-input {
  width: 100%;
  padding: var(--space-4);
  border: 2px solid var(--gray-200);
  border-radius: 12px;
  font-size: var(--text-body-md);
  background: var(--gray-50);
  transition: all 0.2s ease;
}

.text-input:focus {
  border-color: var(--primary-500);
  background: white;
  box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
  outline: none;
}

.text-input::placeholder {
  color: var(--gray-400);
}
```

#### **Toggle Switch**
```css
.toggle {
  position: relative;
  width: 48px;
  height: 24px;
  background: var(--gray-300);
  border-radius: 12px;
  cursor: pointer;
  transition: background 0.3s ease;
}

.toggle.active {
  background: var(--primary-500);
}

.toggle-handle {
  position: absolute;
  top: 2px;
  left: 2px;
  width: 20px;
  height: 20px;
  background: white;
  border-radius: 50%;
  transition: transform 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.toggle.active .toggle-handle {
  transform: translateX(24px);
}
```

---

## 🎬 **Animation & Motion**

### **Timing Functions**
```css
/* Easing curves */
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
--ease-back: cubic-bezier(0.68, -0.55, 0.265, 1.55);

/* Duration */
--duration-fast: 150ms;
--duration-normal: 300ms;
--duration-slow: 500ms;
```

### **Micro-Interactions**
```css
/* Button hover effect */
.interactive-element {
  transition: all var(--duration-normal) var(--ease-out);
}

.interactive-element:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

/* Loading animations */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.loading {
  animation: pulse 2s var(--ease-in-out) infinite;
}

/* Slide in animations */
@keyframes slideInFromBottom {
  0% {
    transform: translateY(100%);
    opacity: 0;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}

.slide-in {
  animation: slideInFromBottom var(--duration-slow) var(--ease-out);
}
```

### **Page Transitions**
```css
/* Screen transitions */
.page-transition-enter {
  opacity: 0;
  transform: translateX(100%);
}

.page-transition-enter-active {
  opacity: 1;
  transform: translateX(0);
  transition: all var(--duration-normal) var(--ease-out);
}

.page-transition-exit {
  opacity: 1;
  transform: translateX(0);
}

.page-transition-exit-active {
  opacity: 0;
  transform: translateX(-100%);
  transition: all var(--duration-normal) var(--ease-in);
}
```

---

## 🖼️ **Iconography**

### **Icon System**
- **Style**: Outline icons with 2px stroke weight
- **Size Scale**: 16px, 20px, 24px, 32px, 48px
- **Grid**: 24x24px grid system
- **Rounding**: 2px border radius for consistency

### **Icon Categories**
```css
/* Navigation Icons */
.icon-home { /* House outline */ }
.icon-search { /* Magnifying glass */ }
.icon-profile { /* User circle */ }
.icon-settings { /* Gear outline */ }

/* Learning Icons */
.icon-play { /* Play triangle */ }
.icon-pause { /* Pause bars */ }
.icon-book { /* Open book */ }
.icon-trophy { /* Achievement cup */ }

/* Category Icons */
.icon-tech { /* Laptop/code */ }
.icon-business { /* Briefcase */ }
.icon-psychology { /* Brain */ }
.icon-science { /* Atom */ }
.icon-creativity { /* Palette */ }
.icon-growth { /* Trending up */ }
.icon-history { /* Clock */ }
.icon-skills { /* Tool */ }
.icon-career { /* Target */ }
```

---

## 📱 **Responsive Design**

### **Breakpoints**
```css
/* Mobile First Approach */
--mobile: 320px;      /* Small phones */
--mobile-lg: 425px;   /* Large phones */
--tablet: 768px;      /* Tablets */
--desktop: 1024px;    /* Desktop */
--desktop-lg: 1440px; /* Large desktop */
```

### **Component Scaling**
```css
/* Typography scaling */
@media (max-width: 768px) {
  :root {
    --text-display-xl: 48px;
    --text-display-lg: 40px;
    --text-heading-xl: 24px;
    --text-heading-lg: 20px;
  }
}

/* Spacing scaling */
@media (max-width: 768px) {
  :root {
    --padding-xl: var(--space-6);
    --margin-xl: var(--space-8);
  }
}
```

---

## ♿ **Accessibility Guidelines**

### **Color Contrast**
- **Minimum**: 4.5:1 for normal text
- **Enhanced**: 7:1 for important content
- **Large Text**: 3:1 minimum (18px+ or 14px+ bold)

### **Focus States**
```css
.focusable:focus {
  outline: 2px solid var(--primary-500);
  outline-offset: 2px;
}

.focusable:focus-visible {
  box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.2);
}
```

### **Interactive Targets**
- **Minimum Size**: 44x44px for touch targets
- **Spacing**: 8px minimum between interactive elements
- **Clear Labels**: All interactive elements have descriptive labels

### **Motion Preferences**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 🎯 **Component Usage Examples**

### **Learning Journey Card**
```html
<div class="learning-card">
  <div class="learning-card-header">
    <div class="learning-card-icon">
      <svg class="icon-business"></svg>
    </div>
    <div>
      <h3>Startup Funding</h3>
      <p class="text-body-sm text-gray-600">Business & Finance</p>
    </div>
  </div>
  <div class="progress-bar">
    <div class="progress-fill" style="width: 60%"></div>
  </div>
  <p class="text-body-sm">3 of 5 episodes completed</p>
</div>
```

### **Coach Selection Interface**
```html
<div class="coach-grid">
  <div class="coach-card kai-theme">
    <img src="kai-avatar.png" class="coach-avatar" alt="Kai">
    <h3>Kai</h3>
    <p class="coach-personality">Strategic • Calm • Mentor-like</p>
    <button class="btn-secondary">Select Kai</button>
  </div>
  
  <div class="coach-card vee-theme">
    <img src="vee-avatar.png" class="coach-avatar" alt="Vee">
    <h3>Vee</h3>
    <p class="coach-personality">Bold • Energetic • Friend-like</p>
    <button class="btn-secondary">Select Vee</button>
  </div>
</div>
```

---

*This design system ensures consistency, accessibility, and world-class user experience across the entire Wisme platform.*
