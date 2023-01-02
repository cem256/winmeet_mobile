import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app/theme/theme_bloc.dart';
import 'core/constants/strings.dart';
import 'core/router/app_router.gr.dart';
import 'core/theme/theme_manager.dart';
import 'core/utility/bloc/app_bloc_observer.dart';
import 'locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  initServices();

  runApp(WinMeetMobile());
}

class WinMeetMobile extends StatelessWidget {
  WinMeetMobile({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => getIt<ThemeBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: Strings.appName,
            debugShowCheckedModeBanner: false,

            //theme
            themeMode: themeState.theme,
            theme: getIt<ThemeManager>().lightTheme,
            darkTheme: getIt<ThemeManager>().darkTheme,

            // routing
            routerDelegate: _appRouter.delegate(),
            routeInformationParser: _appRouter.defaultRouteParser(),
          );
        },
      ),
    );
  }
}
