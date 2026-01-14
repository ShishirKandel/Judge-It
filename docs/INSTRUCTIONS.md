You are a senior Flutter UI/UX engineer.

Context:
- This Flutter app is functionally complete.
- Do NOT change business logic, data models, networking, or app flow.
- Your task is UI/UX only.

Goals:
1. Make the UI clearer, more modern, and visually engaging (not boring).
2. Improve visual hierarchy, spacing, typography, and color usage.
3. Add a proper Light Mode in addition to the existing Dark Mode.
4. Ensure both themes look polished and consistent.

Requirements:
- Use Material 3 (Material You) design principles.
- Introduce a centralized ThemeData setup.
- Define both lightTheme and darkTheme.
- Use ColorScheme.fromSeed where appropriate.
- Improve contrast and accessibility.
- Use modern Flutter widgets (FilledButton, NavigationBar, Card with elevation/tonal color).
- Avoid overly flat or dull surfaces.
- Use subtle motion and visual depth where appropriate.
- Maintain responsiveness across screen sizes.

Theme specifics:
- Light mode should feel clean, soft, and airy.
- Dark mode should feel elegant, high-contrast, and not washed out.
- Avoid pure black backgrounds; use dark surfaces instead.
- Ensure text remains readable in both modes.

Code expectations:
- Refactor theme-related code into a dedicated theme file if not already present.
- Update widgets to rely on Theme.of(context) instead of hardcoded colors.
- Remove magic colors and replace them with theme values.
- Do not introduce new dependencies unless absolutely necessary.

Output:
- Provide updated Flutter code with clear diffs or file-level changes.
- Explain theme decisions briefly where helpful.
- Highlight any UI improvements made.

Constraints:
- Do NOT remove features.
- Do NOT change navigation logic.
- Do NOT redesign the app flow—only visual polish.

If something is unclear, make a reasonable assumption and proceed.
Before making changes, audit the current UI and list the top 5 visual problems, then fix them.
