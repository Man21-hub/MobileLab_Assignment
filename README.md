# Baggage Fee Calculator (Flutter)

## Setup
1. Create/open a Flutter project in Android Studio.
2. Replace `lib/main.dart` with the `lib/main.dart` in this package.
3. Replace or merge your `pubspec.yaml` dependencies with the provided `pubspec.yaml`.
4. In the Android Studio terminal, run:
   ```bash
   flutter pub get
   flutter run
   ```

## Before presenting
Open `lib/main.dart` and replace these placeholders in `AboutPage`:
- `YOUR NAME`
- `YOUR MATRIC NUMBER`
- `YOUR COURSE`
- `https://github.com/YOUR-USERNAME/YOUR-REPOSITORY`

Create your GitHub repository and push your source code before using its URL.

## Calculation
- Economy allowance: 20 kg
- Business allowance: 40 kg
- Excess weight = max(0, baggage weight - allowance)
- Excess charge = excess weight * rate
- Total payable = excess charge + (excess charge * 0.08)

## Example test
Weight 25, class Economy, rate RM15:
- Excess weight: 5 kg
- Excess charge: RM75.00
- 8% service tax: RM6.00
- Total payable: RM81.00
