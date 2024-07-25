import 'package:erp_visualizer/constants.dart';
import 'package:erp_visualizer/pages/common/pop_up_notification.dart';
import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  // Drop down menu options
  final List<String> dropdownOptions = ['profile', 'logout'];

  // Selected value from drop down menu
  String selectedValue = "";

  final String? title;
  final Function()? logOutFunction;
  final VoidCallback? onPressed;

  CommonHeader({this.title, this.logOutFunction, this.onPressed});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: title != null
            ? Text(
          title!,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Set the text color here
        )
            : null, // Show title only if provided
      leading:
          title != null // Show leading back button only if title is provided
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                  onPressed: onPressed ??
                      () {
                        Navigator.pop(context);
                      },
                )
              : null,
      automaticallyImplyLeading: false,
      actions: logOutFunction != null
          ? [
              PopupMenuButton<String>(
                // Popup menu for profile and logout
                onSelected: (value) {
                  selectedValue = value;
                  if (selectedValue == 'logout') {
                    print('inside logout if');
                    // logOutFunction!();
                    CustomNotificationPopup.showCustomNotificationPopup(context,
                        title: 'Logout',
                        description: 'Are you sure to logout?',
                        messageType: MessageType.Information,
                        buttons: [
                          CustomNotificationButton(
                            name: 'Cancel',
                            color: Colors.grey,
                            textColor: Colors.white,
                            onPressed: () {
                              // Do something when BtnCancel is pressed
                              Navigator.of(context).pop();
                            },
                          ),
                          CustomNotificationButton(
                            name: 'Yes',
                            onPressed: () {
                              Navigator.of(context).pop();
                              logOutFunction!().then((isLogged) {
                                print('check log status in pop up: $isLogged');
                                if (isLogged == false) {
                                  print('inside logout popup function');
                                  // Navigator.pushNamed(context, '/');
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/', (Route<dynamic> route) => false);
                                  // Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                                  // Navigator.pushNamed(context, '/login');
                                }
                              });
                            },
                          ),
                        ]);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return dropdownOptions.map((String option) {
                    return PopupMenuItem(
                      height: 30,
                      value: option,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList();
                },
                icon: Row(
                  children: [
                    CircleAvatar(
                      // Profile picture
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        'assets/images/technician.jpg',
                      ),
                    ),
                    Icon(Icons.arrow_drop_down_outlined), // Dropdown icon
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
              ),
            ]
          : null,
      // backgroundColor: AppColor.secondaryColor,
      backgroundColor: AppColors.primaryColor
    );
  }
}
