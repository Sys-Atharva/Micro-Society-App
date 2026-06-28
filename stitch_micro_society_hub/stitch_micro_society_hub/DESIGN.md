---
name: Micro-Society Design System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#45464d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#191c1e'
  on-tertiary-container: '#818486'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#e0e3e5'
  tertiary-fixed-dim: '#c4c7c9'
  on-tertiary-fixed: '#191c1e'
  on-tertiary-fixed-variant: '#444749'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter-desktop: 24px
  gutter-mobile: 16px
  margin-desktop: 40px
  margin-mobile: 20px
  stack-xs: 4px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style
The design system is engineered for "Micro-Society," an application centered on high-trust, localized interactions. The brand personality is **Modern Professionalism** mixed with **Digital Sophistication**. It balances the reliability of institutional tools with the fluidity of contemporary social platforms.

The aesthetic follows a **Corporate Minimalist** direction with **Glassmorphic accents**. It prioritizes heavy whitespace, crisp structural alignment, and subtle depth through tonal layering rather than excessive decoration. The goal is to evoke an emotional response of security, clarity, and premium craftsmanship.

## Colors
The palette is anchored by **Deep Navy (#0F172A)**, used for primary branding, high-level navigation, and core text to establish immediate authority. **Vibrant Indigo (#6366F1)** serves as the functional accent, reserved for primary actions, active states, and critical notifications.

For light surfaces, use **#F8FAFC** as the base background to maintain a "breathable" feel. For dark modes or high-contrast surfaces, utilize the primary navy with 5-10% opacity adjustments for container nesting. All semantic colors (Success, Warning, Error) should follow the Tailwind Slate/Zinc scale to maintain a cohesive, desaturated professional look, except for the Indigo-based primary interactions.

## Typography
This design system utilizes **Inter** exclusively to leverage its systematic, utilitarian nature. The type hierarchy relies on strict weight differentiation rather than font mixing. 

Headlines use semi-bold and bold weights with tight letter-spacing to appear "inked" and intentional. Body text defaults to Regular (400) for maximum legibility. For data-dense views, the `label-md` role should be used in Medium (500) or Semi-bold (600) with slight tracking increases to ensure scannability.

## Layout & Spacing
The design system employs a **12-column fluid grid** for desktop and a **4-column grid** for mobile. A strict 4px baseline grid governs all internal component spacing (e.g., 8px, 12px, 16px).

Content should be grouped using "Stack" logic, where related elements (like a header and its description) use `stack-sm`, while distinct sections use `stack-lg`. Use generous margins on desktop to create a centered, focused reading experience, while allowing the grid to expand to a maximum width of 1440px.

## Elevation & Depth
Depth is communicated through **Soft Ambient Shadows** and **Tonal Layering**. Surfaces do not "float" aggressively; instead, they lift slightly from the background using low-opacity Indigo-tinted shadows.

- **Level 0 (Base):** #F8FAFC. No shadow.
- **Level 1 (Cards/Lists):** White surface with a 4px blur, 2% opacity shadow (0 2px 4px rgba(15, 23, 42, 0.05)).
- **Level 2 (Dropdowns/Modals):** White surface with a 12px blur, 8% opacity shadow (0 10px 15px rgba(15, 23, 42, 0.1)).
- **Level 3 (Overlays):** 20px blur, 12% opacity shadow.

Use backdrop blurs (10px - 20px) behind navigation bars and modal backdrops to maintain context while focusing user attention.

## Shapes
The shape language is defined by **12px (0.75rem) corner radii** for all standard containers and inputs. This specific value bridges the gap between "playful" and "rigid," reinforcing the trustworthy yet modern vibe. Small components like tags or checkboxes should scale down to 4px or 6px, while prominent cards and modals strictly adhere to the 12px rule.

## Components
### Buttons
Primary buttons use the Vibrant Indigo background with White text. Secondary buttons use a subtle Slate-100 ghost background or a 1px border. All buttons have a height of 44px (Large) or 36px (Medium) with 12px rounded corners.

### Input Fields
Fields feature a 1px Slate-200 border that transitions to a 2px Indigo border on focus. Placeholders are Slate-400. Ensure a 12px internal padding for comfort.

### Chips & Tags
Used for categorization, chips should have a light Indigo-50 background with Indigo-600 text. They use a smaller 6px radius to distinguish them from primary buttons.

### Cards
Cards are the primary container for "Micro-Society" content. They must have a 1px Slate-100 border or a Level 1 shadow. Headers within cards should be separated by a subtle horizontal rule or distinct tonal change.

### Lists
List items use 16px vertical padding. Active or hovered states should be indicated by a soft Indigo-50 background tint rather than a border change.