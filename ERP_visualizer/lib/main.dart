import 'dart:convert';
import 'dart:math';

import 'package:erp_visualizer/pages/home_page.dart';
import 'package:erp_visualizer/pages/startup%20menu/complete_process.dart';
import 'package:erp_visualizer/pages/startup%20menu/daily_work_tasks.dart';
import 'package:erp_visualizer/pages/startup%20menu/work_tsak_steps.dart';
import 'package:erp_visualizer/services/error_handling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'config/config.dart';
import 'config/user_data.dart';

const FlutterAppAuth visualizerAuth = FlutterAppAuth();

void main() {
  runApp(ERPVisualizerApp());
}

late bool _isUserLoggedIn;

class ERPVisualizerApp extends StatefulWidget {
  @override
  State<ERPVisualizerApp> createState() {
    return _ERPVisualizerAppState();
  }
}

class _ERPVisualizerAppState extends State<ERPVisualizerApp> {
  late int _pageIndex;
  // late bool _isUserLoggedIn;
  late String? _idToken;
  late String? _accessToken;
  late String? _refreshToken;

  @override
  void initState() {
    super.initState();
    _pageIndex = 1;
    _isUserLoggedIn = false;
    _idToken = '';
    _accessToken = '';
    _refreshToken = '';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LogInPage(loginFunction),
        '/home': (context) => HomePage(
          accessToken: _accessToken,
          // logOutFunction: loginFunction(),
          logOutFunction: logOutFunction,
          refreshTokenFunction: refreshTokenFunction,
        ),
        '/daily_work_task': (context) => DailyWorkTasks(
          accessToken: _accessToken,
          // logOutFunction: loginFunction(),
          logOutFunction: logOutFunction,
          refreshTokenFunction: refreshTokenFunction,
        ),
        '/work_task_steps': (context) => WorkTaskSteps(
          accessToken: _accessToken,
          // logOutFunction: loginFunction(),
          logOutFunction: logOutFunction,
          refreshTokenFunction: refreshTokenFunction,
        ),
        '/complete_process': (context) => CompleteProcess(
          accessToken: _accessToken,
          // logOutFunction: loginFunction(),
          logOutFunction: logOutFunction,
          refreshTokenFunction: refreshTokenFunction,
        ),
        // '/activeWorkOrders': (context) => activeWorkOrders.DetailPage(
        //   accessToken: _accessToken,
        //   refreshToken: _refreshToken,
        // ),
        // '/assignedWorkTasks': (context) => AssignedTasks(
        //   accessToken: _accessToken,
        //   logOutFunction: logOutFunction,
        //   refreshTokenFunction: refreshTokenFunction,
        // ),
        // '/acceptedWorkTasks': (context) => AcceptedTasks(
        //     accessToken: _accessToken, logOutFunction: logOutFunction,refreshTokenFunction: refreshTokenFunction),
        // '/ongoingWorkTasks': (context) => OngoingTasks(
        //   accessToken: _accessToken, logOutFunction: logOutFunction,refreshTokenFunction: refreshTokenFunction,),
        // '/completedWorkTasks': (context) => CompletedTasks(
        //     accessToken: _accessToken, logOutFunction: logOutFunction,refreshTokenFunction: refreshTokenFunction),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
    );
  }

  void setPageIndex(index) {
    setState(() {
      _pageIndex = index;
    });
  }

  // Future<void> loginFunction() async {
  //   try {
  //     final AuthorizationTokenResponse? result =
  //     await visualizerAuth.authorizeAndExchangeCode(
  //       AuthorizationTokenRequest(
  //         Config.clientId,
  //         Config.redirectUrl,
  //         discoveryUrl: Config.discoveryUrl,
  //         promptValues: ['login'],
  //         scopes: ['openid'],
  //       ),
  //     );
  //
  //
  //     setState(() {
  //       print('print token results -> refresh token ${result?.refreshToken}');
  //       _isUserLoggedIn = true;
  //       _idToken = result?.idToken;
  //       _accessToken = result?.accessToken;
  //       _refreshToken = result?.refreshToken;
  //       _pageIndex = 2;
  //       var token = _accessToken!.split('.');
  //       var payload = json.decode(ascii.decode(base64.decode(base64.normalize(token[1]))));  //decode the token
  //       // print(payload['preferred_username']);
  //       UserData.userId = payload['preferred_username'].toString().toUpperCase();
  //       Config.AccessToken = _accessToken!;
  //
  //     });
  //   } catch (e, s) {
  //     print('Error while login to the system: $e - stack: $s');
  //     setState(() {
  //       _isUserLoggedIn = false;
  //     });
  //   }
  // }

  Future<void> _exchangeCode() async {
    try {
      print('inside code exchange try');

      final AuthorizationResponse? resultCodes = await visualizerAuth.authorize(
        AuthorizationRequest(Config.clientId, Config.redirectUrl,
            discoveryUrl: Config.discoveryUrl, scopes: ['openid'], loginHint: 'login'),
      );

      print('result Codes : $resultCodes');
      print('code exchange: ${resultCodes?.codeVerifier}');

      final Random random = Random.secure();
      final String _nonce =
      base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
      print('nonce : $_nonce');
      final TokenResponse? result = await visualizerAuth.token(TokenRequest(
          Config.clientId, Config.redirectUrl,
          authorizationCode: resultCodes?.authorizationCode,
          discoveryUrl: Config.discoveryUrl,
          codeVerifier: resultCodes?.codeVerifier,
          nonce: resultCodes?.nonce,
          scopes: ['openid']));
      print("access token : ${result?.accessToken})");
    } catch (_) {
      print('inside code exchange catch');
    }
  }

  Future<void> loginFunction() async {
    print('login function');
    try {
      print('inside code exchange try');

      final AuthorizationResponse? resultCodes = await visualizerAuth.authorize(
        AuthorizationRequest(Config.clientId, Config.redirectUrl,
            discoveryUrl: Config.discoveryUrl, scopes: ['openid'], loginHint: 'login'),
      );

      print('result Codes : $resultCodes');
      print('code exchange: ${resultCodes?.codeVerifier}');

      final Random random = Random.secure();
      final String _nonce =
      base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
      print('nonce : $_nonce');
      final TokenResponse? result = await visualizerAuth.token(TokenRequest(
          Config.clientId, Config.redirectUrl,
          authorizationCode: resultCodes?.authorizationCode,
          discoveryUrl: Config.discoveryUrl,
          codeVerifier: resultCodes?.codeVerifier,
          nonce: resultCodes?.nonce,
          scopes: ['openid']));
      print("access token : ${result?.accessToken})");


      setState(() {
        print('print token results -> refresh token ${result?.refreshToken}');
        _isUserLoggedIn = true;
        _idToken = result?.idToken;
        _accessToken = result?.accessToken;
        _refreshToken = result?.refreshToken;
        _pageIndex = 2;
        var token = _accessToken!.split('.');
        var payload = json.decode(ascii.decode(base64.decode(base64.normalize(token[1]))));  //decode the token
        // print(payload['preferred_username']);
        UserData.userId = payload['preferred_username'].toString().toUpperCase();
        Config.AccessToken = _accessToken!;

      });
    } catch (e, s) {
      print('Error while login to the system: $e - stack: $s');
      setState(() {
        _isUserLoggedIn = false;
      });
    }
  }

  Future<bool> logOutFunction() async {
    try {
      // send logout request
      String apiEndPoint = Config.logoutUrl;
      Map<String, dynamic>? queryParameters = {"id_token_hint": _idToken};

      final response = await http.get(
        Uri.https(Config.apiURL, apiEndPoint,queryParameters),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isUserLoggedIn = false;
          _pageIndex = 1;
          UserData.userId = "";  // remove user id
        });

        // End the session
        final EndSessionResponse? result = await visualizerAuth.endSession(
          EndSessionRequest(
            idTokenHint: _idToken,
            postLogoutRedirectUrl: Config.redirectUrl,
            discoveryUrl: Config.discoveryUrl,
          ),
        );
      } else {
        if (context.mounted) {
          HttpErrorHandler.showStatusDialog(
              context, response.statusCode, response.reasonPhrase!);
        }
      }
    } catch (e, s) {
      print('Error while login to the system: $e - stack: $s');
      setState(() {
        _isUserLoggedIn = true;
      });
    }
    return _isUserLoggedIn;
  }

  // refresh the access token using refresh token
  Future<String?> refreshTokenFunction() async {
    Map<String, dynamic> requestBody = {
      "client_id": Config.clientId,
      "grant_type": "refresh_token",
      "refresh_token": _refreshToken,
    };

    // Encode the request body to x-www-form-urlencoded format
    String encodedBody = requestBody.entries
        .map((entry) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value.toString())}')
        .join('&');

    String apiEndPoint = Config.tokenUrl;

    final response = await http.post(
      Uri.https(Config.apiURL, apiEndPoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: encodedBody,
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Extract tokens and reset to variables
      setState(() {
        _isUserLoggedIn = true;
        _idToken = jsonResponse['id_token'];
        _accessToken = jsonResponse['access_token'];
        _refreshToken = jsonResponse['refresh_token'];
      });
      return _accessToken;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return 'unsuccessful';
    }
  }
}

class LogInPage extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final loginFunction;

  const LogInPage(this.loginFunction);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/IdeastoSolutionLogo.jpg", scale: 0.5),
          Center(
            heightFactor: 1.5,
            child: ElevatedButton(
              style: ButtonStyle(
                fixedSize: MaterialStatePropertyAll(Size(250, 40)),
              ),
              onPressed: () {
                // loginFunction().then((_) {
                //   if (_isUserLoggedIn == true) {
                //     // Navigate to home page after login successful
                //     Navigator.pushNamed(context, '/home');
                //   }
                // });
                loginFunction();
              },
              child: Text('Sign In', textScaler: TextScaler.linear(1.4)),
            ),
          ),
        ],
      ),
    );
  }
}
