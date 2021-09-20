## Reciplus
Reciplus is a cross platform recipe sharing app that helps you eat healthier.
### Framework Documentations and Develop References
1. Link to official Flutter [documentations](https://flutter.dev/docs/get-started/install)
2. Flutter [Barcode Scanner](https://pub.dev/packages/flutter_barcode_scanner)
3. Flutter [QRCode Scanner](https://pub.dev/packages/qr_code_scanner)
4. Flutter [Gmail SignIn](https://pub.dev/packages/google_sign_in)
5. Documentations for [Data and Backend](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
6. Firebase Implementation in Flutter [Docs](https://firebase.google.com/docs/flutter/setup?platform=ios)

### How to use
#### Environment Setup
1. Follow the flutter [instruction](https://flutter.dev/docs/get-started/install) to setup your environment.
2. Once you have your IDE setup, open the project in your IDE.
3. Open the terminal and go the root directory, type in `flutter doctor -v` to check the environment. Type `flutter pub get` to install the dependencies.
4. Open emulator and type `flutter run` to run the build.

#### Firebase Setup
The program relies on firebase to store the data and [google_sign_in](https://pub.dev/packages/google_sign_in) plugin to login.
1. To use the app, you need to register for [firebase](https://console.firebase.google.com/) first.
2. You need to add firebase to both your [iOS](https://firebase.google.com/docs/ios/setup) and [Android](https://firebase.google.com/docs/android/setup) app. For iOS, you will need a developer's certificate. For android, don't forget to add both your SHA-1 and SHA-256 key to the firebase.
3. On the left panel, click on 'Authentication' and turn Google Sign In on.
4. Go to [Google Cloud Console](https://console.cloud.google.com) and register your app.
5. Then, go to Google Cloud API panel ![Google Cloud API](/assets/readme/google_cloud.png "Google Cloud API") and go to OAuth Consent Screen. 
6. Turn on scope './auth/userinfo.email', './auth/userinfo.profile', and 'openid'.

#### Using the App
##### Signing in/out
The first time you open the app, you will be requested to sign in on the home page. The sign in uses Google authentication, you will have to use a google account to proceed. 
Follow the steps provided by Google until you are succesfully signed in. You will be then redirected to your Account page where you can decide to either sign out or go to your recipes.
If you already signed in before, your data should be saved and the next time you run the app, you will not be requested to sign in again. 

##### Viewing and adding Recipes
Click on the 'MY RECIPES' button to access your recipes.
From there, you can view, edit, add, and remove recipes. 
To add a new recipe, click on the big plus sign on the bottom right of the screen to open an alert dialog for you to input the new recipe's name. 
To edit a recipe, tap on the recipe, and a new page will open where you can view, edit, add, and remove ingredients. 
To remove a recipe, simply click on the trash icon on the right side of the recipe's name.

##### Viewing and adding Ingredients to Recipe
Once you clicked on a recipe, a new page will open displaying all the available ingredients with their calories. 
To add a new ingredient, click on the big plus sign on the bottom right of the screen where you will be prompted to choose between manually inputting the name of the ingredient, or scanning the barcode of an ingredient. 
If you decide to input the name manually, type it in the text field, and click 'OK'. If you decide to scan a barcode instead, a new page will open (Instructions below).
To add or edit the calorie count of an ingedient manually, tap on the ingredient and you will be prompted to edit the value. (NOTE: Manually adding ingredients automatically sets its calorie count to 0).
To remove an ingredient, simply click on the trash icon on the right side of the ingredient's name.

##### Scanning Barcodes
To add an ingredient by scanning the barcode, click on the add ingredient button and choose 'Scan barcode'. You will be redirected to a new page that will require access to your camera.
Click on 'Start Barcode Scan' to open your camera, and point your camera towards the barcode of your item. If the item is found in the database, the result will show up on the screen in a couple seconds.
Click 'Done' to return to the previous page and click 'OK to add your item or 'Cancel' to not add it. (NOTE: The calorie count is automatically added if an ingredient was scanned).
If not happy with the result, you can rescan a new barcode until satisfied. 
 
 
 



