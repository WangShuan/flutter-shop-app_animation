import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firebaseUrl = dotenv.env['FIREBASE_URL'];

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  String get userId {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(String mail, String pwd, String urlPath) async {
    final Uri url = Uri.https(
      'identitytoolkit.googleapis.com',
      urlPath,
      {'key': dotenv.env['FIREBASE_API_KEY']},
    );
    try {
      final res = await http.post(
        url,
        body: json.encode({
          "email": mail,
          "password": pwd,
          "returnSecureToken": true,
        }),
      );
      if (json.decode(res.body)['error'] != null) {
        throw (json.decode(res.body)['error']['message']);
      }
      _token = json.decode(res.body)['idToken'];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(json.decode(res.body)['expiresIn']),
      ));
      _userId = json.decode(res.body)['localId'];
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String(),
      });
      prefs.setString("userData", userData);
    } catch (err) {
      throw err;
    }
  }

  Future<void> signup(String mail, String pwd) async {
    return _authenticate(mail, pwd, 'v1/accounts:signUp');
  }

  Future<void> login(String mail, String pwd) async {
    return _authenticate(mail, pwd, 'v1/accounts:signInWithPassword');
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    }
    final data = json.decode(prefs.getString("userData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(data['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = data['token'];
    _expiryDate = expiryDate;
    _userId = data['userId'];
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _authTimer = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userData");
    // prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    int expirySeconds = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expirySeconds), logout);
  }
}
