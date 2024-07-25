// ignore_for_file: library_prefixes, prefer_typing_uninitialized_variables
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:erp_visualizer/constants.dart';
import 'package:flutter/material.dart';
// import 'package:i2s_task_card/pages/common/field_types.dart' as fieldTypes;

import 'package:erp_visualizer/services/api_service.dart' as apiService;
import 'package:intl/intl.dart';
import '../config/user_data.dart';
// import 'package:i2s_task_card/pages/work_order_task.dart' as workOrderTask;
import '../services/error_handling.dart';
// import 'Components/buttons.dart';
// import 'Components/colors.dart';
import 'common/image_card.dart';
import 'components/header.dart';
import 'common/logout_popup.dart';
import 'common/pop_up_notification.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.accessToken, required this.logOutFunction, required this.refreshTokenFunction});
  final String? accessToken;
  final logOutFunction;
  final refreshTokenFunction;

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
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

  late String userId;
  late String userName;

  @override
  void initState() {
    super.initState();
    userId = UserData.userId; //get the user id and store it in userId
    userName = UserData.userId.toUpperCase(); //get the user name and convert it to upper case
    setImageCards();
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
      crossAxisCount = 2; //if the device is in portrait mode, then set the number of columns to 2
    }
    return crossAxisCount;
  }

  Future<int> countTasks(String status) async{
    final serverCall = await apiService.Methods();
    String apiEndPoint =
        "main/ifsapplications/projection/v1/WorkAssignmentsHandling.svc/JtExecutionInstanceSet/\$count"; //api endpoint

    Map<String, dynamic>? queryParameters = {
      "\$filter":"ResourceId eq '$userName' and Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'$status'", //filter the work tasks based on the status
    };

    //call the getWithParameters method
    var response = await serverCall.getWithParameters(
        widget.accessToken,
        apiEndPoint,
        queryParameters,
        widget.refreshTokenFunction
    ); //call the getWithParameters method to get the work tasks

    int count=0;
    if(response.statusCode == 200){
      var data = json.decode(response.body);
      // print(data);
      count = data; //get the number of work tasks
      if(status=="ASSIGNED") {
        assigned_work_tasks = data; //get the number of assigned work tasks
      }else{
        accepted_work_tasks = data; //get the number of accepted work tasks
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
    return count;
  }

  Future<int> countOngoingTasks() async{
    final serverCall = await apiService.Methods();
    String apiEndPoint =
        "main/ifsapplications/projection/v1/WorkAssignmentsHandling.svc/JtExecutionInstanceSet/\$count"; //api endpoint

    Map<String, dynamic>? queryParameters = {
      "\$filter":"ResourceId eq '$userName' and (Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'WORKSTARTED' or Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'ONROUTE' or Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'WAITINGATLOCATION' or Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'PENDINGCOMPLETION')", //filter the work tasks based on the status
    };

    //call the getWithParameters method
    var response = await serverCall.getWithParameters(
        widget.accessToken,
        apiEndPoint,
        queryParameters,
        widget.refreshTokenFunction
    ); //call the getWithParameters method to get the work tasks

    int count=0;
    if(response.statusCode == 200){
      var data = json.decode(response.body);
      count = data; //get the number of work tasks
      ongoing_work_tasks = data; //get the number of ongoing work tasks
    }else if(response.body == 'Token refresh failed'){
      if(context.mounted){
        showLogoutPopup(context, widget.logOutFunction);
      }
    }else {
      if(context.mounted){
        HttpErrorHandler.showStatusDialog(context, response.statusCode, response.reasonPhrase!);
      }
    }
    return count;
  }

  Future<int> countCompletedTasks() async{
    final serverCall = await apiService.Methods();
    String apiEndPoint =
        "main/ifsapplications/projection/v1/WorkAssignmentsHandling.svc/JtExecutionInstanceSet/\$count"; //api endpoint

    Map<String, dynamic>? queryParameters = {
      "\$filter":"ResourceId eq '$userName' and (Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'COMPLETED' or Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'INCOMPLETED' or Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'CANCELLED' or Objstate eq IfsApp.WorkAssignmentsHandling.JtExecutionInstanceState'HANDOVER')", //filter the work tasks based on the status
    };

    int count=0;
    //call the getWithParameters method
    var response = await serverCall.getWithParameters(
        widget.accessToken,
        apiEndPoint,
        queryParameters,
        widget.refreshTokenFunction
    ); //call the getWithParameters method to get the work tasks

    if(response.statusCode == 200){
      var data = json.decode(response.body);
      count = data; //get the number of work tasks
      completed_work_tasks = data; //get the number of completed work tasks
    }else if(response.body == 'Token refresh failed'){
      if(context.mounted){
        showLogoutPopup(context, widget.logOutFunction);
      }
    }else {
      if(context.mounted){
        HttpErrorHandler.showStatusDialog(context, response.statusCode, response.reasonPhrase!);
      }
    }
    return count;
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

  Future<void> setImageCards() async{
    imageCards = [  //list of image cards with the number of work tasks
      ImageCard(
          'STARTUP',
          Icons.work_history_outlined,
          '/daily_work_task',
          assigned_work_tasks,
          Colors.white
        // Color.fromARGB(255,218, 245, 255)
      ),
      ImageCard(
          'WORK CENTER',
          Icons.task_alt_outlined,
          '/work_task_steps',
          accepted_work_tasks,
          Colors.white
        // Color.fromARGB(255,205, 250, 219)
      ),
      ImageCard(
          'SHUTDOWN',
          Icons.work_outline,
          '/',
          ongoing_work_tasks,
          Colors.white
        // Color.fromARGB(255, 248, 236, 227)
      ),
      ImageCard(
          'PRODUCT LINE',
          Icons.done_all_outlined,
          '/',
          completed_work_tasks,
          Colors.white
        // Color.fromARGB(255,241, 234, 255)
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    double desiredItemWidth = 180.0; // width of a item
    double height = 300.0; // height of a item
    int crossAxisCount = calculateCrossAxisCount(context, desiredItemWidth,height); //calculate the number of columns

    return Scaffold(
        // backgroundColor: Color(0xFF00428c),
      // backgroundColor: Color(0xFF012169),
      // backgroundColor:Color(0xFF7cb9e8) ,
      // backgroundColor: Color.fromARGB(255, 230, 240, 255),
        appBar: CommonHeader(logOutFunction: widget.logOutFunction,),
        body: FutureBuilder(
            future: workTaskListFuture,
            builder: (context, snapshot) {
                return Container(
                child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, //set the main axis alignment to start
                  crossAxisAlignment: CrossAxisAlignment.start, //set the cross axis alignment to start
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width, //set the width of the container to the screen width
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Text("Hi " + userName + " !",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 22
                              ),),
                            // child: AppFonts.customizeText(
                            //     'Hi' + ' ' + userName+'!',
                            //     Colors.white,
                            //     22,
                            //     FontWeight.bold
                            // )
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 0.0, top: 0.0, bottom: 10.0, right: 0.0),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                              // child: AppFonts.customizeText(
                              //     DateFormat('MMM d, y').format(DateTime.now()), //format the date as 'MMM d, y'
                              //     Colors.white,
                              //     13,
                              //     FontWeight.w400
                              // )
                              child: Text(DateFormat('MMM d, y').format(DateTime.now()),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 22
                                ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:EdgeInsets.all(getPadding()),
                      child: GridView.builder( //grid view for the image cards
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: imageCards.length,
                        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          //if imageCards.length is less than crossAxisCount, then crossAxisCount will be imageCards.length
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1,
                          crossAxisSpacing: MediaQuery.of(context).size.width*0.02, //set the cross axis spacing
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return imageCards[index]; //return the image card at the index
                        },
                      ),
                    ),


                    SizedBox(height: 20)
                  ],
                ),
              ),
                );
              }
        )
    );
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
