# Weather Blanket App Theme System

## Overview
This theme system provides a comprehensive color palette and styling framework based on the vibrant yarn colors from your Weather Blanket app logo.

## Color Palette
The theme extracts colors from your beautiful logo featuring colorful yarn:

### Primary Colors
- **Warm Orange** (`#FF6B35`) - Main accent color from orange yarn
- **Deep Blue** (`#2E3A87`) - Primary color from blue yarn
- **Royal Purple** (`#6A4C93`) - From purple yarn
- **Bright Pink** (`#FF006E`) - From pink yarn
- **Sky Blue** (`#4ECDC4`) - From light blue yarn
- **Golden Yellow** (`#FFB0B`) - From yellow yarn

### Background Colors
- **Dark Background** (`#1A1B2E`) - Inspired by the logo's center
- **Card Background** (`#16213E`) - Slightly lighter cards
- **Light Background** (`#F8F9FA`) - For light mode

## Usage

### 1. Basic Theme Colors
```dart
import 'package:weather_blanket/theme/app_colors.dart';

// Use predefined colors
Container(
  color: AppColors.warmOrange,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.primaryText),
  ),
)
```

### 2. Temperature-Based Colors
```dart
// Automatically get color based on temperature
Color tempColor = AppColors.getTemperatureColor(22.5); // Returns warm orange
```

### 3. Weather Condition Colors
```dart
// Get color based on weather condition
Color weatherColor = AppColors.getWeatherConditionColor('sunny'); // Returns golden yellow
```

### 4. Themed Text Styles
```dart
import 'package:weather_blanket/theme/theme_extensions.dart';

Text('Large Title', style: AppTextStyles.largeTitle),
Text('Body text', style: AppTextStyles.body),
Text('Caption', style: AppTextStyles.caption),
```

### 5. Pre-built Themed Widgets
```dart
// Primary button with gradient
ThemedWidgets.primaryButton(
  text: 'Save Changes',
  onPressed: () {},
),

// Card container
ThemedWidgets.card(
  child: Text('Card content'),
),

// Temperature display with color coding
ThemedWidgets.temperatureDisplay(
  temperature: 23.5,
  unit: '°C',
),
```

### 6. Context Extensions
```dart
// Easy access to colors via context
Container(
  color: context.temperatureColor(18.0),
  child: Text(
    'Temperature',
    style: TextStyle(color: context.weatherColor('sunny')),
  ),
)
```

### 7. Common Decorations
```dart
import 'package:weather_blanket/theme/app_theme.dart';

// Pre-defined decorations
Container(decoration: AppTheme.cardDecoration),
Container(decoration: AppTheme.primaryButtonDecoration),
Container(decoration: AppTheme.inputDecoration),
```

## Temperature Color Mapping
- **Below 0°C**: Purple (freezing)
- **0-10°C**: Blue (cold)
- **10-15°C**: Light blue (cool)
- **15-20°C**: Yellow (mild)
- **20-25°C**: Orange (warm)
- **25°C+**: Pink (hot)

## Weather Condition Colors
- **Sunny/Clear**: Golden yellow
- **Cloudy/Overcast**: Gray
- **Rainy/Drizzle**: Sky blue
- **Stormy/Thunder**: Deep blue
- **Snowy**: White
- **Windy**: Light blue

## Constants
### Spacing
```dart
AppSpacing.xs   // 4px
AppSpacing.sm   // 8px
AppSpacing.md   // 16px
AppSpacing.lg   // 24px
AppSpacing.xl   // 32px
AppSpacing.xxl  // 48px
```

### Border Radius
```dart
AppBorderRadius.xs     // 4px
AppBorderRadius.sm     // 8px
AppBorderRadius.md     // 12px
AppBorderRadius.lg     // 16px
AppBorderRadius.xl     // 24px
AppBorderRadius.xxl    // 32px
AppBorderRadius.circle // 100px
```

## Files Structure
```
lib/theme/
├── app_colors.dart      # Core color definitions
├── app_theme.dart       # Theme configuration
└── theme_extensions.dart # Utilities, widgets & text styles
```

## Migration from Hardcoded Colors
Replace hardcoded colors throughout your app:

**Before:**
```dart
Container(color: CupertinoColors.systemBlue)
Text('Hello', style: TextStyle(color: CupertinoColors.white))
```

**After:**
```dart
Container(color: AppColors.deepBlue)
Text('Hello', style: AppTextStyles.body)
```

This theme system ensures consistency and makes it easy to maintain your app's visual identity based on your beautiful logo!
