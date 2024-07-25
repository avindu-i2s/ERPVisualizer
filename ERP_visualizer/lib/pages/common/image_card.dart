import'package:flutter/material.dart';


class ImageCard extends StatelessWidget {
  ImageCard(this.title, this.icon, this.routeLink,this.count,this.cardColor);
  final String title;  //title of the card
  final IconData icon;  //icon of the card
  final String routeLink; //route link of the card
  final int count; //count to be displayed in the card
  final Color cardColor;
  @override
  Widget build(BuildContext context) {
    double getFontSize(BuildContext context) {  //function to get font size for the count based on screen size
      double width = MediaQuery.of(context).size.width;
      if (width < 400) {
        return 35;
      } else if (width < 1000) {
        return 40;
      } else if (width < 1500) {
        return 45;
      } else {
        return 50;
      }
    }

    double getTextSize(BuildContext context) { //function to get font size for the title based on screen size
      double width = MediaQuery.of(context).size.width;
      if (width < 600) {
        return 15;
      } else if (width < 1000) {
        return 20;
      } else if (width < 1500) {
        return 20;
      } else {
        return 30;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4), // change the color and opacity
            spreadRadius: 1,
            blurRadius: 15,
            offset: Offset(4, 9), // changes position of shadow
          ),
        ],
        // border: Border(
        //   top: BorderSide(width: 4.0, color: AppColor.primaryColor),
        //   // bottom: BorderSide(width: 4.0, color: AppColor.secondaryColor),
        // )
        color: Colors.white.withOpacity(0.2),
      ),
      child: Card(
          color: cardColor,
          child:InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              Navigator.pushNamed(context, routeLink); //navigate to the route link when the card is tapped
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize:MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 30,
                    // change this
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: getTextSize(context),
                      ),
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: TextStyle(
                        fontSize: getFontSize(context),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}