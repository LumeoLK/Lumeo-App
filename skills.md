# Lumeo Project Skills & Rules

## Technical Stack
- Frontend: Flutter (Mobile/Web)
- Backend: Node.js (Express)
- ML: Python (FastAPI/Jupyter)

## UI Development Rules
- Use the Widget Previewer for all component fixes.
- Follow the theme defined in `lib/Constants.dart` for colors and fonts.
- Always check `lib/widgets/` before creating a new UI component to avoid duplication.

## API & Network Rules
- Backend Base URL is defined in `lib/Constants.dart`.
- Use the `AuthService` in `lib/services/auth_service.dart` for all protected calls.
- When an API call fails, use the Network Inspector to check the JSON structure before refactoring models.

## Agent Behavior
- Before applying a fix, explain the "Why" behind the architectural change.
- If a UI fix requires a new asset, check `assets/images` or `assets/icons` first.