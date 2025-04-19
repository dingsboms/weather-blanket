# weather_blanket

Build IPA:
flutter build ipa --release --export-method=ad-hoc

Deploy to Firebase Web Hosting:
flutter build web --release
firebase deploy

Alternatively push new commit to main, triggers github actions rollout
