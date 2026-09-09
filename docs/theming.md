# App theme

The app uses a light neumorphic system: a continuous blue-gray surface, blue primary actions, teal accents, dark slate text, and restrained gold for membership content.

## Sources of truth

- `lib/app/theme/app_colors.dart`: every palette value, semantic status, media overlay, foreground, and shadow color. `surface` is a background; use `textOnPrimary` or `onMedia` for light foregrounds.
- `app_neumorphic_styles.dart`: the top-left light source, paired shadows, raised/inset depth, and animation duration.
- `app_radius.dart` and `app_spacing.dart`: radii and spacing scales.
- `app_text_theme.dart` and `app_text_styles.dart`: typography. Native platform fonts are used; no unbundled font is assumed.
- `app_theme.dart`: Material and Neumorphic defaults. Both are installed in `main.dart` with the same light mode.

## Components

Use `AppCard` for content groups, membership cards, list rows, and navigation. It contains a Material surface so child InkWell and ListTile actions remain functional. Keep at least 12–16px between raised surfaces to leave room for shadows.

Use `PrimaryButton` for primary actions and `NeumorphicIconButton` for compact actions. Native buttons handle keyboard focus, disabled states, hover, and presses. Pass `null` while an action is unavailable and provide tooltips for icon actions. Standard controls provide at least a 48px target.

Use `AppInsetSurface` for input areas and `AppSearchField` for search. Existing `rPrimaryTextField` callers receive the same inset design, preserving password masking, multiline limits, read-only state, labels, focus, prefixes, and change callbacks. Focused fields retain a blue outline.

Use semantic colors rather than `Colors.*` or literal colors in active code. Reserve `error`, `warning`, and `success` for statuses. Photos and live video use dedicated `onMedia`/overlay tokens for legibility. Historical backup/copy files are not part of the active design system.

Text and action foregrounds have contrast checks. Shared motion and banner autoplay respect reduced-motion settings. Navigation height adapts to text scaling.

## Verification

Run `flutter test --no-pub test/app_theme_test.dart test/theme_layout_test.dart test/message_compose_test.dart` for interaction, contrast, narrow-phone, and doubled-text-size checks. The layout suite renders actual sign-in, registration, discovery, and profile views with local test data.

To export review PNGs, set `THEME_PREVIEW_DIR=build/theme-preview` and `THEME_PREVIEW_FONTS` to the Flutter SDK's `bin/cache/artifacts/material_fonts` directory before running `test/theme_layout_test.dart`. Preview rendering loads real fonts and enables shadow blur; ordinary tests require neither environment variable.
