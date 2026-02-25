---
description: Trigger a new production release and APK build
---

1. Verify all tests pass:
// turbo
2. Run `flutter test`
3. Update version in `pubspec.yaml`
4. Commit changes with message `chore: bump version to v[version]`
5. Tag the commit:
// turbo
6. Run `git tag v[version]`
7. Push tag to remote:
// turbo
8. Run `git push origin v[version]`
9. Monitor GitHub Actions for build completion
