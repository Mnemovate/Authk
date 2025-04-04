import 'package:authk/auth_service.dart';
import 'package:authk/home_screen.dart';
import 'package:authk/register_screen.dart';
import 'package:flutter/material.dart'; 

class AuthLayout extends StatelessWidget { 
  const AuthLayout({ 
    super.key, 
    this.pageIfNotConnected, 
  }); 
  
  final Widget? pageIfNotConnected; 

  @override 
  Widget build (BuildContext context) { 
    return ValueListenableBuilder( 
      valueListenable: authService,
      builder: (context, authService, child) { 
        return StreamBuilder(
          stream: authService.authStateChanges, 
          builder: (context, snapshot) { 
            if (snapshot.connectionState == ConnectionState.waiting) { 
              return const Scaffold( 
                body: Center( 
                  child: CircularProgressIndicator.adaptive(), 
                ), 
              ); 
            } 
            if (snapshot.hasData) { 
              return const HomePage(); 
            } 
            return pageIfNotConnected ?? const RegisterPage(); 
          },
        );
      }, 
    );
  }
}