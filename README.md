# Cockpit Tools Mobile 🚀

A high-performance, premium Flutter application for managing AI IDE accounts and monitoring usage quotas across multiple platforms.

## 🌟 Key Features

- **Multi-Platform Monitoring**: Support for Anthropic, OpenAI, GitHub, Windsurf, Codeium, and Cursor.
- **Premium Iconography**: High-fidelity SVG assets for all major AI brands.
- **Dynamic Quota Gauges**: Real-time visualization of usage limits and remaining units.
- **One-Click Switch**: Seamlessly transition between multiple active accounts.
- **Secure by Design**: Sensitive API keys and session tokens stored in `flutter_secure_storage`.
- **60fps Fluidity**: Staggered entrance animations and optimized rendering paths.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart 3.x)
- **State Management**: Riverpod 2.0 with asynchronous providers.
- **Backend-as-a-Service**: Supabase (Auth, Realtime, PostgreSQL).
- **Storage**: `flutter_secure_storage` for credentials, `shared_preferences` for UI settings.
- **Animations**: `flutter_animate` for high-end micro-interactions.
- **Iconography**: `flutter_svg` for crisp, scale-independent assets.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.29.0)
- Supabase Project URL and Anon Key
- Android/iOS/Web development environment

### Setup

1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure Environment**:
   Create a `.env` file in the root with:
   ```env
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```
4. **Run the App**:
   ```bash
   flutter run
   ```

## 🤖 Antigravity Workflows

We use custom workflows to automate common tasks:

- `/setup`: Initialize the development environment.
- `/release`: Trigger a production release and APK build.

## 🚢 CI/CD

Our GitHub Actions pipeline (`release.yml`) automatically builds and releases an APK whenever a new version tag (`v*`) is pushed.

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.
