### Reciplus
Reciplus is a cross platform recipe sharing app that helps you eat healthier.
#### Framework Documentations and Develop References
1. Link to official Flutter [documentations](https://flutter.dev/docs/get-started/install)
2. Flutter [Barcode Scanner](https://pub.dev/packages/flutter_barcode_scanner)
3. Flutter [QRCode Scanner](https://pub.dev/packages/qr_code_scanner)
4. Flutter [Gmail SignIn](https://pub.dev/packages/google_sign_in)
5. Documentations for [Data and Backend](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
6. Firebase Implementation in Flutter [Docs](https://firebase.google.com/docs/flutter/setup?platform=ios)

#### How to use
##### Environment Setup
1. Follow the flutter [instruction](https://flutter.dev/docs/get-started/install) to setup your environment.
2. Once you have your IDE setup, open the project in your IDE.
3. Open the terminal and go the root directory, type in `flutter doctor -v` to check the environment. Type `flutter pub get` to install the dependencies.
4. Open emulator and type `flutter run` to run the build.

##### Firebase Setup
The program relies on firebase to store the data and [google_sign_in](https://pub.dev/packages/google_sign_in) plugin to login.
1. To use the app, you need to register for [firebase](https://console.firebase.google.com/) first.
2. You need to add firebase to both your [iOS](https://firebase.google.com/docs/ios/setup) and [Android](https://firebase.google.com/docs/android/setup) app. For iOS, you will need a developer's certificate. For android, don't forget to add both your SHA-1 and SHA-256 key to the firebase.
3. On the left panel, click on 'Authentication' and turn Google Sign In on.
4. Go to [Google Cloud Console](https://console.cloud.google.com) and register your app.
5. Then, go to Google Cloud API panel ![Google Cloud API](/assets/readme/google_cloud.png "Google Cloud API") and go to OAuth Consent Screen. 
6. Turn on scope './auth/userinfo.email', './auth/userinfo.profile', and 'openid'.