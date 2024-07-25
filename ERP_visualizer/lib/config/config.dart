class Config {
  static const String apiURL = "ifscloud.tsunamit.com";

  static const clientId = 'I2S_Client';
  static const redirectUrl = 'org.i2s.taskcard://login-callback';
  static const discoveryUrl =
      'https://ifscloud.tsunamit.com/auth/realms/tsutst/.well-known/openid-configuration';
  static const tokenUrl = 'auth/realms/tsutst/protocol/openid-connect/token';
  static const logoutUrl = '';
  static String AccessToken = '';
  static bool isFirstTime = true;
}
