---
name: Premium Travel Pass
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded8e0'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f2fa'
  surface-container: '#f2ecf4'
  surface-container-high: '#ece6ee'
  surface-container-highest: '#e6e0e9'
  on-surface: '#1d1b20'
  on-surface-variant: '#494551'
  inverse-surface: '#322f35'
  inverse-on-surface: '#f5eff7'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#cfbcff'
  secondary: '#63597c'
  on-secondary: '#ffffff'
  secondary-container: '#e1d4fd'
  on-secondary-container: '#645a7d'
  tertiary: '#765b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#fdf7ff'
  on-background: '#1d1b20'
  surface-variant: '#e6e0e9'
typography:
  display:
    fontFamily: Noto Serif
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 42px
    letterSpacing: -0.02em
  h1:
    fontFamily: Noto Serif
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  h2:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  button:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  margin-page: 24px
  gutter-card: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  section-gap: 48px
---

## Brand & Style
The design system is centered on the "Premium Travel Pass" aesthetic—an approach that blends the exclusivity of luxury travel concierge services with the creative energy of UGC creators. The brand personality is sophisticated yet welcoming, evoking the feeling of a sun-drenched morning at a high-end coastal resort.

The visual style is a hybrid of **Modern Corporate** and **Glassmorphism**, emphasizing airy layouts and high-quality photography. It prioritizes a sense of "breathable" luxury through generous white space and soft, sky-inspired gradients. The goal is to make tour agencies feel secure in a professional partnership while making creators feel inspired to produce high-end content.

## Colors
This design system utilizes a warm, light-mode palette to maintain an "airy" feel. The Deep Navy (#1E2A5A) provides the structural authority for navigation and headings, while the Royal Indigo (#4F46E5) serves as the primary driver for user action. 

The background system uses "Warm White" as the foundation, with tinted surfaces (Sand, Sky, Lavender) used to differentiate content blocks without the need for heavy borders. Soft Coral is reserved strictly for high-engagement moments, such as "liked" states, active notifications, or highlighting a creator's top-performing content.

## Typography
The typography strategy pairings reflect a "Classic Editorial" meets "Modern App" vibe. **Noto Serif** is used for primary headings to establish a premium, literary feel suitable for high-end travel. **Plus Jakarta Sans** handles all functional UI and body text, providing high legibility and a friendly, optimistic tone.

Turkish labels should prioritize generous line height to accommodate longer word lengths (agglutinative nature). Use "label-caps" for small metadata or section overlines to add an extra layer of hierarchy and polish.

## Layout & Spacing
The layout follows a fluid-width mobile model with a 4px baseline grid. Page margins are set to a wide 24px to enforce the "airy" brand pillar. Content should never feel cramped; vertical spacing between distinct sections should be significant (32px to 48px).

Use "Internal Breathing Room": elements inside cards should have at least 20px of padding to ensure the UI feels expansive. Group related items using 8px or 16px increments, but leave 48px between unrelated content blocks to guide the eye effectively.

## Elevation & Depth
Depth is created through **Ambient Shadows** and **Tonal Layering** rather than harsh lines. 
- **Level 1 (Surface):** Warm White background.
- **Level 2 (Cards):** Tinted surfaces (Sand/Sky) with a very soft, diffused shadow (Blur: 20px, Y: 8px, Color: #1E2A5A at 4% opacity).
- **Level 3 (Modals/Overlays):** Utilizes background blur (Glassmorphism) behind the Navy or Indigo elements to maintain a sense of space.

Gradients should be used sparingly behind content, blending Soft Sky Blue into Soft Lavender at a 135-degree angle to mimic a horizon.

## Shapes
The shape language is consistently rounded to evoke comfort and approachability. Standard components (buttons, input fields) use a 0.5rem (8px) radius. Larger containers and image cards use "rounded-xl" (1.5rem/24px) to create a soft, friendly frame for travel imagery. Icons should be drawn with rounded caps and joins to match the soft-cornered UI elements.

## Components
- **Buttons:** Primary buttons are fully rounded (pill-shaped) or heavily rounded (12px+), using the Royal Indigo background with White text. They should have a subtle drop shadow to appear "pressable."
- **Cards:** Travel cards should feature a large image header with the Noto Serif title overlaid on a subtle dark gradient. Use the "Sand Cream" surface for the text area of the card.
- **Bottom Navigation:** A clean, Deep Navy bar with a high blur background. Icons should be 2px stroke weight, with the active state indicated by a Soft Coral dot or icon fill.
- **Chips/Badges:** Used for tour categories (e.g., "Kültür," "Macera"). These should use the Soft Sky Blue or Soft Lavender backgrounds with Deep Navy text.
- **Input Fields:** Minimalist with a 1px border in a muted slate or a light tinted fill. Labels sit above the field in "label-caps" style.
- **UGC Preview:** A specialized component showing creator profiles with a circular avatar and a "Verified" badge in Royal Indigo.