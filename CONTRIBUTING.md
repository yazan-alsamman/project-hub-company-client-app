# Contributing to ProjectHub

First off, thank you for considering contributing to ProjectHub! It's people like you that make ProjectHub such a great project.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots and animated GIFs** if applicable
- **Include system information** (OS, Flutter version, device, etc.)

Use the [bug report template](bug_report.md) to ensure you include all necessary information.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**
- **List some other applications where this enhancement exists**

Use the [feature request template](feature_request.md) to ensure you include all necessary information.

### Pull Requests

- Fill in the required template
- Do not include issue numbers in the PR title
- Include screenshots and animated GIFs in your pull request whenever possible
- Follow the Dart and Flutter style guides
- Include thoughtfully-worded, well-structured tests
- Document new code based on the Documentation Styleguide
- End all files with a newline

## Development Process

### Getting Started

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/yourusername/junior.git
   cd junior
   ```

3. **Add the upstream remote**
   ```bash
   git remote add upstream https://github.com/originalowner/junior.git
   ```

4. **Create a branch for your feature**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

### Making Changes

1. **Ensure Flutter is up to date**
   ```bash
   flutter upgrade
   flutter doctor
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Make your changes**
   - Write clean, maintainable code
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation as needed

6. **Format your code**
   ```bash
   flutter format lib/
   ```

7. **Analyze your code**
   ```bash
   flutter analyze
   ```

### Code Style Guidelines

#### Dart Style Guide

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use `dart format` to format your code
- Maximum line length: 80 characters (soft limit)
- Use meaningful variable and function names
- Prefer `const` constructors when possible
- Use `final` for variables that won't be reassigned

#### Flutter Best Practices

- Use `const` widgets whenever possible for better performance
- Extract widgets into separate files when they become complex
- Use meaningful widget names
- Follow the Material Design guidelines
- Ensure responsive design for all screen sizes

#### Project-Specific Conventions

- **Controllers**: Place in `controller/` directory, one file per controller
- **Models**: Place in `data/Models/` directory
- **Screens**: Place in `view/screens/` directory
- **Widgets**: Place reusable widgets in `view/widgets/` directory
- **Constants**: Place in `core/constant/` directory
- **Services**: Place in `core/services/` directory

#### Naming Conventions

- **Files**: Use snake_case (e.g., `login_controller.dart`)
- **Classes**: Use PascalCase (e.g., `LoginController`)
- **Variables/Functions**: Use camelCase (e.g., `userName`, `getUserData()`)
- **Constants**: Use lowerCamelCase with `const` (e.g., `const maxRetries = 3`)
- **Private members**: Prefix with underscore (e.g., `_privateMethod()`)

#### Code Organization

```dart
// 1. Imports (grouped)
// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:get/get.dart';

// Project imports
import 'package:project_hub/core/constant/routes.dart';

// 2. Class definition
class MyWidget extends StatelessWidget {
  // 3. Constants
  static const String routeName = '/my-widget';
  
  // 4. Fields
  final String title;
  
  // 5. Constructor
  const MyWidget({super.key, required this.title});
  
  // 6. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 7. Private methods
  void _handleTap() {}
}
```

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Aim for high test coverage
- Test edge cases and error scenarios
- Ensure all tests pass before submitting PR

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Documentation

- Document public APIs
- Add comments for complex algorithms
- Update README.md if adding new features
- Update CHANGELOG.md for user-facing changes
- Keep code comments concise and meaningful

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add password reset functionality

fix(project): resolve project deletion bug

docs(readme): update installation instructions

style(controller): format code according to style guide
```

### Submitting Changes

1. **Update your branch**
   ```bash
   git checkout main
   git pull upstream main
   git checkout your-branch
   git rebase upstream/main
   ```

2. **Ensure everything works**
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat(scope): description of changes"
   ```

4. **Push to your fork**
   ```bash
   git push origin your-branch
   ```

5. **Create Pull Request**
   - Go to GitHub and create a pull request
   - Fill out the pull request template
   - Link any related issues
   - Request review from maintainers

### Pull Request Process

1. **Update the CHANGELOG.md**
   - Add your changes under the "Unreleased" section
   - Follow the existing format

2. **Update documentation**
   - Update README.md if needed
   - Update SETUP.md if setup changed
   - Add code comments for new features

3. **Ensure CI passes**
   - All tests must pass
   - Code must pass linting
   - Build must succeed on all platforms

4. **Respond to feedback**
   - Address review comments promptly
   - Make requested changes
   - Keep discussions constructive

### Review Criteria

Your pull request will be reviewed based on:

- **Code Quality**: Clean, readable, maintainable code
- **Functionality**: Works as intended, handles edge cases
- **Tests**: Adequate test coverage
- **Documentation**: Updated and accurate
- **Style**: Follows project conventions
- **Performance**: No performance regressions

## Project Structure

Understanding the project structure will help you contribute effectively:

- `lib/lib_admin/` - Admin interface code
- `lib/lib_client/` - Client interface code
- `lib/core/` - Shared core functionality
- `assets/` - Images and other assets
- `test/` - Test files

## Getting Help

- **Documentation**: Check [SETUP.md](SETUP.md) and [README.md](README.md)
- **Issues**: Search existing issues or create a new one
- **Discussions**: Use GitHub Discussions for questions
- **Code Review**: Ask questions in pull request comments

## Recognition

Contributors will be:
- Listed in the project README
- Credited in release notes
- Acknowledged in the project

Thank you for contributing to ProjectHub! 🎉

