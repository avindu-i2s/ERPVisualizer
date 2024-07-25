// ignore_for_file: library_prefixes, prefer_typing_uninitialized_variables
import 'dart:async';
import 'dart:convert';

import 'package:erp_visualizer/constants.dart';
import 'package:erp_visualizer/pages/components/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

import '../../config/user_data.dart';
import '../../services/error_handling.dart';
import '../common/image_card.dart';
import 'package:erp_visualizer/services/api_service.dart' as apiService;

import '../common/logout_popup.dart';
import '../components/header.dart';


class WorkTaskSteps extends StatefulWidget {
  WorkTaskSteps({super.key, required this.accessToken, required this.logOutFunction, required this.refreshTokenFunction});
  final String? accessToken;
  final logOutFunction;
  final refreshTokenFunction;

  @override
  State<WorkTaskSteps> createState() => _WorkTaskStepsState();

}

class _WorkTaskStepsState extends State<WorkTaskSteps> {
  late bool hasBeenInitialized;
  List<ImageCard> imageCards = [];  //list of image cards
  int assigned_work_tasks=0;
  int accepted_work_tasks = 0;
  int ongoing_work_tasks = 0;
  int completed_work_tasks = 0;
  int cardCount = 3;
  late StreamSubscription subscription;
  bool isDeviceConnected=true;
  Future<void>? workTaskListFuture;//list of work tasks will be stored here
  var workTasks=[];
  Color fabColor = Colors.red;
  List<Widget> cardList = [];

  //today
  DateTime today = DateTime.now();

  late String userId;
  late String userName;

  @override
  void initState() {
    super.initState();
    userId = UserData.userId; //get the user id and store it in userId
    userName = UserData.userId.toUpperCase(); //get the user name and convert it to upper case
    getWorkOrderList();
  }

  // calculate the number of columns for the grid view
  int calculateCrossAxisCount(BuildContext context, double desiredItemWidth, double height) {
    int crossAxisCount = 1;
    double screenWidth = MediaQuery.of(context).size.width; //get the screen width
    double screenHeight = MediaQuery.of(context).size.height; //get the screen height
    double itemWidth = desiredItemWidth + 20;
    double screenWidthWithoutPadding = screenWidth - 20;
    crossAxisCount = (screenWidthWithoutPadding / itemWidth).floor(); //calculate the number of columns
    double totalHeight = crossAxisCount * height; //calculate the total height
    if (totalHeight > screenHeight) { //if the total height is greater than the screen height, then reduce the number of columns
      crossAxisCount--;
    }
    if (crossAxisCount > 4) {
      crossAxisCount = 4;  //if the number of columns is greater than the number of image cards, then set the number of columns to the number of image cards
    }
    //check whether the  device is in landscape mode
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      crossAxisCount = 3; //if the device is in portrait mode, then set the number of columns to 2
    }
    return crossAxisCount;
  }

  int calculateCardCrossAxisCount(BuildContext context, double desiredItemWidth) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    int crossAxisCount = (screenWidth / desiredItemWidth).floor();
    return crossAxisCount > 0 ? crossAxisCount : 1;
  }

  // TODO : Fix this to make card size according to the content
  double calculateChildAspectRatio(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      // For landscape orientation
      return screenWidth > 700 ? 10 / 12 : 12 / 11;
    } else {
      // For portrait orientation
      return screenWidth > 600 ? 12 / 6 : 6 / 2.5;
    }
  }


  Future<void> getWorkOrderList() async {
    print("from online get work order list");
    final serverCall = await apiService.Methods();
    String apiEndPoint =
        "main/ifsapplications/projection/v1/WorkAssignmentsHandling.svc/JtExecutionInstanceSet"; //api endpoint

    DateTime date = DateTime.now();

    //convert the date to be T00:00:00Z
    String todayT00 = DateFormat('yyyy-MM-dd').format(today) + "T00:00:00Z";

    //convert the date to be T23:59:59Z
    String todayT23 = DateFormat('yyyy-MM-dd').format(today) + "T23:59:59Z";

    Map<String, dynamic>? queryParameters = {
      // "\$filter": "(ResourceId eq '$userName' and (AllocatedStart le $todayT00 and AllocatedFinish ge $todayT00) and ((Objstate ne IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'COMPLETED') or (Objstate ne IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'INCOMPLETED') or (Objstate ne IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'CANCELLED') or (Objstate ne IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'HANDOVER')))", //filter the work tasks based on the date
      "\$filter":"ResourceId eq '$userName'", //filter the work tasks based on the user id
      "\$orderby":"TaskSeq"
    };

    var response = await serverCall.getWithParameters(
        widget.accessToken, apiEndPoint, queryParameters,widget.refreshTokenFunction); //call the getWithParameters method to get the work tasks

    List<Map<String, dynamic>> workTasksOnline = [];
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      for (var i = 0; i < data["value"].length; i++) {
        if( data["value"][i]["TaskSeq"] == 603){
          print("Found task 603 in online");
        }
        workTasksOnline.add({
          'TaskSeq': data["value"][i]["TaskSeq"],
          'OrderNo': data["value"][i]["WoNo"],
          'Description': data["value"][i]["TaskDescription"],
          'PlannedFinish': data["value"][i]["AllocatedFinish"],
          'StartDate': data["value"][i]["AllocatedStart"],
          'objstate': data["value"][i]["Objstate"],
          'AllocatedHours': data["value"][i]["AllocatedHours"],
          'CustomerNo': data["value"][i]["CustomerNo"],
          'executionInstanceSeq': data["value"][i]["ExecutionInstanceSeq"],
          'eTag': data["value"][i]["@odata.etag"],
          'resourceId': data["value"][i]["ResourceId"],
        }); //add the record to the workTasks array as a map
      }
    }else if(response.body == 'Token refresh failed'){
      if(context.mounted){
        showLogoutPopup(context, widget.logOutFunction);
      }
    }else {
      if(context.mounted){
        HttpErrorHandler.showStatusDialog(context, response.statusCode, response.reasonPhrase!);
      }
    }
    setState(() {
      workTasks = workTasksOnline;
    });
  }

  Future<void> getAllTasksandCount() async{
    final serverCall = await apiService.Methods();
    String apiEndPoint =
        "main/ifsapplications/projection/v1/WorkAssignmentsHandling.svc/JtExecutionInstanceSet"; //api endpoint

    Map<String, dynamic>? queryParameters = {
      "\$filter":"ResourceId eq '$userName'", //filter the work tasks based on the user id
      "\$orderby":"TaskSeq"
    };

    var response = await serverCall.getWithParameters(
        widget.accessToken, apiEndPoint, queryParameters,widget.refreshTokenFunction); //call the getWithParameters method to get the work tasks

    List<Map<String, dynamic>> workTasksOnline = [];
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      int assigned = 0;
      int accepted = 0;
      int ongoing = 0;
      int completed = 0;
      for (var i = 0; i < data["value"].length; i++) {
        if( data["value"][i]["TaskSeq"] == 603){
          print("Found task 603 in count tasks");
        }
        workTasksOnline.add({
          'TaskSeq': data["value"][i]["TaskSeq"],
          'OrderNo': data["value"][i]["WoNo"],
          'Description': data["value"][i]["TaskDescription"],
          'PlannedFinish': data["value"][i]["AllocatedFinish"],
          'StartDate': data["value"][i]["AllocatedStart"],
          'objstate': data["value"][i]["Objstate"],
          'AllocatedHours': data["value"][i]["AllocatedHours"],
          'CustomerNo': data["value"][i]["CustomerNo"],
          'executionInstanceSeq': data["value"][i]["ExecutionInstanceSeq"],
          'eTag': data["value"][i]["@odata.etag"],
          'resourceId': data["value"][i]["ResourceId"],
        });//add the record to the workTasks array as a map
        if(data["value"][i]["Objstate"] == "ASSIGNED"){
          assigned++;
        }else if(data["value"][i]["Objstate"] == "ACCEPTED"){
          accepted++;
        }else if(data["value"][i]["Objstate"] == "WORKSTARTED" || data["value"][i]["Objstate"] == "ONROUTE" || data["value"][i]["Objstate"] == "WAITINGATLOCATION" || data["value"][i]["Objstate"] == "PENDINGCOMPLETION"){
          ongoing++;
        }else{
          completed++;
        }
      }
      setState(() {
        assigned_work_tasks = assigned;
        accepted_work_tasks = accepted;
        ongoing_work_tasks = ongoing;
        completed_work_tasks = completed;
      });

    }else if(response.body == 'Token refresh failed'){
      if(context.mounted){
        showLogoutPopup(context, widget.logOutFunction);
      }
    }else {
      if(context.mounted){
        HttpErrorHandler.showStatusDialog(context, response.statusCode, response.reasonPhrase!);
      }
    }
    setState(() {
      workTasks = workTasksOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    double desiredItemWidth = 180.0; // width of an item
    double height = 300.0; // height of an item
    int crossAxisCount = calculateCrossAxisCount(context, desiredItemWidth, height); // calculate the number of columns

    return Scaffold(
      appBar: CommonHeader(title: 'Work Task Steps', logOutFunction: widget.logOutFunction),
      body: FutureBuilder(
        future: workTaskListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // set the main axis alignment to start
                crossAxisAlignment: CrossAxisAlignment.start, // set the cross axis alignment to start
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: workTasks.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: calculateCardCrossAxisCount(context, 300), // Set crossAxisCount to 1 for a single column layout
                        childAspectRatio: calculateChildAspectRatio(context),
                        crossAxisSpacing: MediaQuery.of(context).size.width * 0.02,
                        mainAxisSpacing: MediaQuery.of(context).size.width * 0.02,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: getBorder(workTasks[index]['objstate']), // set the color of the border based on the status of the work task
                              width: 1.2,
                            ),
                            color: Colors.white, // set the color of the container to white
                            borderRadius: BorderRadius.circular(10), // set the border radius of the container
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2), // set the color of the shadow
                                spreadRadius: 2, // set the spread radius of the shadow
                                blurRadius: 2, // set the blur radius of the shadow
                                offset: Offset(2, 2), // set the offset of the shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AppText.headline2(text: 'Wo No: '), // print the work order number
                                    AppText.bodyText(text: workTasks[index]['OrderNo'].toString()),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    AppText.headline2(text: 'Description: '), // print the work order number
                                    Expanded(child: AppText.bodyText(text: workTasks[index]['Description'].toString())),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CommonButton.primaryButton(
                                        text: 'Start',
                                        onPressed: () { Navigator.pushNamed(context, '/complete_process');},
                                        backgroundColor: AppColors.green,
                                        textColor: Colors.white),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  getColor(workTask) { //get the color for the highlighted text based on the status of the work task
    if(workTask=="ASSIGNED"){
      return Color.fromRGBO(144, 225, 170, 1);
    }else{
      return Colors.white;
    }
  }

  Color getBorder(String string) { //get the color for the border based on the status of the work task
    if(string=="ASSIGNED"){
      return Colors.redAccent;
    }else{
      //no border
      return Colors.white;
    }
  }

  double getPadding() { //function to get the padding for the image cards based on the screen size
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 25;
    } else if (width < 1000) {
      return 50;
    } else if (width < 1500) {
      return 60;
    } else {
      return 70;
    }
  }
}
