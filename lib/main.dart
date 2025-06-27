import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restfoodblindbox/bloc/cart/cart_bloc.dart';
import 'package:restfoodblindbox/firebase_options.dart';
import 'package:restfoodblindbox/pages/auth_wrapper.dart';
import 'package:restfoodblindbox/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FcmService().initNotifications();
  FcmService().initPushNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 BlocProvider 來建立並提供 CartBloc
    return BlocProvider(
      create: (_) => CartBloc(), // 建立 CartBloc 實例
      child: MaterialApp(
        title: '剩食盲盒',
        home: const AuthWrapper(),
      ),
    );
  }
}