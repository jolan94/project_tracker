# Project Tracker 🚀💀

A brutally honest project tracker for developers who start more projects than they finish. Built with Flutter, embracing the reality of our digital graveyards.

## Features 🎯

- **Track Projects**: Simple project management with statuses: Building 🔨, Stuck 😰, Shipped 🚀, or Abandoned 💀
- **Brutal Honesty**: Real stats about your completion rate (prepare to be humbled)
- **Developer Personality**: Sarcastic but supportive messages throughout the app
- **Abandon with Dignity**: Mark projects as abandoned with pre-written excuses like "Found something shinier ✨"
- **Dark Theme**: Because we code at 2 AM
- **Local Storage**: Your failures stay private with Hive local storage

## Tech Stack 💻

- **Flutter**: Cross-platform mobile framework
- **GetX**: State management and routing
- **Hive**: Local NoSQL database
- **JetBrains Mono**: The only acceptable font for developers

## Getting Started 🏃‍♂️

1. Clone the repository
```bash
git clone https://github.com/yourusername/project-tracker.git
cd project-tracker
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the build runner for Hive
```bash
flutter pub run build_runner build
```

4. Run the app
```bash
flutter run
```

## Project Structure 📁

```
lib/
├── app/
│   ├── routes/        # App navigation
│   └── theme/         # Dark theme configuration
├── controllers/       # GetX controllers
├── models/           # Data models
├── views/            # UI screens
├── widgets/          # Reusable components
└── services/         # Storage service
```

## Screenshots 📱

(Coming soon - after we actually finish building it 😅)

## Contributing 🤝

Feel free to submit PRs! Just remember, this app is about embracing imperfection, so your code doesn't need to be perfect either.

## License 📄

MIT License - Use it, abandon it, we don't judge.

## Acknowledgments 🙏

To all the unfinished projects that inspired this app. You may be abandoned, but you're not forgotten. 💀

---

Built with ❤️ and a healthy dose of self-deprecating humor.
