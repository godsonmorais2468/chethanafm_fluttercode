import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:chethanafm/utils/theme/app_theme.dart';
import 'package:chethanafm/utils/helper.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/viewmodels/radio_viewmodel.dart';
import 'package:chethanafm/viewmodels/schedule_viewmodel.dart';
import 'package:chethanafm/viewmodels/chat_viewmodel.dart';
import 'package:chethanafm/viewmodels/home_viewmodel.dart';
import 'package:chethanafm/views/splash_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chethanafm/firebase_options.dart';
import 'package:chethanafm/repo/repository.dart';
import 'package:chethanafm/services/notification_service.dart';

/// Global navigator key — passed to [MaterialApp] and [NotificationService]
/// so that notification taps can navigate to screens from outside the widget tree.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Initialize SharedPreferences helper statically
  await PrefHelper.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM push notifications after Firebase is ready.
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(apiClient: Repository.instance)),
        ChangeNotifierProvider(create: (_) => RadioViewModel(apiClient: Repository.instance)),
        ChangeNotifierProvider(create: (_) => ScheduleViewModel(apiClient: Repository.instance)),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel(apiClient: Repository.instance)),
      ],
      child: const ChethanaApp(),
    ),
  );
}

class ChethanaApp extends StatelessWidget {
  const ChethanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Chethana FM 90.8',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: appTheme,
          navigatorKey: navigatorKey,
          home: const SplashView(),
        );
      },
    );
  }
}
