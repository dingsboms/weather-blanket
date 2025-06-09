# Tempestry

Build IPA:
flutter build ipa --release --export-method=ad-hoc

Deploy to Firebase Web Hosting:
flutter build web --release
firebase deploy

Deploy Firebase Functions:
cd functions && npm run build && cd .. && firebase deploy --only functions

Alternatively push new commit to main, triggers github actions rollout
