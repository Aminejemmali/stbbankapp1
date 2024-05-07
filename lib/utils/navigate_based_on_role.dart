import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';
import 'package:stbbankapplication1/screens/dash_admin.dart';
import 'package:stbbankapplication1/screens/liste-agents.dart';
import 'package:stbbankapplication1/screens/user.dart';

Widget widgetByRole(String userRole) {
  switch (userRole) {
    case 'admin':
      return const AdminDash();
    case 'superAdmin':
      return const SuperAdmin();
    case 'user':
      return const UserScreen();
    default:
      return const Login();
  }
}
