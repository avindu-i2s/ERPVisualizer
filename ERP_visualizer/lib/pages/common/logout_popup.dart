import 'package:erp_visualizer/pages/common/pop_up_notification.dart';
import 'package:flutter/material.dart';

void showLogoutPopup(BuildContext context, Function logOutFunction) {
  CustomNotificationPopup.showCustomNotificationPopup(
    context,
    title: '401',
    description: 'Session time out. Please login again.',
    messageType: MessageType.Error,
    buttons: [
      CustomNotificationButton(
        name: 'OK',
        onPressed: () {
          Navigator.of(context).pop();
          logOutFunction().then((isLogged) {
            print('check log status in pop up: $isLogged');
            if (isLogged == false) {
              print('inside logout popup function');
              Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            }
          });
        },
      ),
    ],
  );
}