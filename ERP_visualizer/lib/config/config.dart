// class Config {
//   static const String apiURL = "ifscloud.tsunamit.com";
//
//   static const clientId = 'I2S_Client';
//   static const redirectUrl = 'org.i2s.erpvisualizer://login-callback';
//   static const discoveryUrl =
//       'https://ifscloud.tsunamit.com/auth/realms/tsutst/.well-known/openid-configuration';
//   static const tokenUrl = 'auth/realms/tsutst/protocol/openid-connect/token';
//   static const logoutUrl = '';
//   static String AccessToken = '';
//   static bool isFirstTime = true;
// }

class Config {
  static const String apiURL = "culligan-sandbx.ifs.cloud:48080";

  static const clientId = 'ee9f3f14-aad0-42a5-8b78-be97233ba9e4';
  static const redirectUrl = 'org.i2s.erpvisualizer://login-callback';
  // static const redirectUrl = 'https://culligan-sandbx.ifs.cloud:48080/main/ifsapplications/web/oauth2/callback/';
  static const discoveryUrl =
      'https://culligan-sandbx.ifs.cloud:48080/openid-connect-provider/.well-known/openid-configuration';
  static const tokenUrl = 'openid-connect-provider/idp/token';
  static const logoutUrl = '';
  static String AccessToken = '';
  static bool isFirstTime = true;
}
