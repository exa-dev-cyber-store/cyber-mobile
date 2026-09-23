import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cyber/app/modules/home/controllers/home_controller.dart';
import 'package:cyber/app/modules/home/views/home_view.dart';
import 'package:cyber/core/network/api_client.dart';
import 'package:cyber/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/rendering.dart';

void main() {
  testWidgets('Find Profile widgets test', (WidgetTester tester) async {
    FlutterError.onError = (details) {};




    dotenv.testLoad(mergeWith: {
      'BASE_URL': 'https://be-apple-store.eka-dev.cloud',
      'API_URL': 'https://be-apple-store.eka-dev.cloud/api',
    });
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.getInstance();
    await ApiClient.initialize(storage);
    
    final ctrl = Get.put(HomeController());
    // Simulate logged in data
    ctrl.userName = "bloodsuker18";
    ctrl.userEmail = "bloodsuker18@gmail.com";
    ctrl.linkedAccounts = {
      "signupProvider": "local",
      "isAppleSignup": false,
      "currentEmail": "bloodsuker18@gmail.com",
      "google": {"linked": false, "canUnbind": false},
      "apple": {"linked": false, "canUnbind": false},
      "canLinkGoogle": true,
      "canUnbindApple": false,
      "canLinkApple": true
    };


    await tester.pumpWidget(
      GetMaterialApp(
        home: HomeView(),
      ),
    );
    await tester.pump();
    
    ctrl.changePage(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Shopping Activity'), findsOneWidget);
    expect(find.text('Order History'), findsOneWidget);
    expect(find.text('Address Book'), findsOneWidget);
    expect(find.text('Linked Accounts'), findsOneWidget);
    expect(find.text('Information & Support'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}



