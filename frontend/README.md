# AW40-hub-docker - Frontend

Assuming Flutter 3.7.12 is installed, all commands run from `frontend/app` directory.

## Setup

Basically all commands require generated code to be built beforehand. Do this via:

```shell
flutter pub run build_runner build
```

## Run tests

You can use the `run_checks.sh` script to check formatting, linting, and run tests before pushing your code.
Do run this from the `frontend` directory directly, not the `frontend/app` directory.

Check your formatting with:

```bash
dart format --output=none .
```
Autoformat your code with:

```bash
dart format .
```

Analyze your code with:

```bash
dart analyze
```

Run tests via:

```
flutter test
```


## Development

Easiest in VS Code, but Android Studio and IntelliJ should work as well.
Here's how to run from the CLI:

### Web

By default, Flutter will use a random port.
There's a VS Code run config in the repo that uses port 4200.
To run via cli:

```shell
flutter run -d web-server --web-port=4200
```

### Android

Start the Android emulator, print a list of devices via:

```shell
flutter devices
```

Then run the app via:

```shell
flutter run -d <device-id>
```

In case of graphic artifacts add the `--enable-software-rendering` flag (slight performance cost).

```shell
flutter run -d <device-id> --enable-software-rendering
```

### iOS

Only testable on macOS.
Apple is apple.
