import 'package:dojo_app/game_modes/matches/screens/food_image_capture/capture_food_image.dart';
import 'package:flutter/material.dart';

class AddFoodImageButton extends StatefulWidget {
  const AddFoodImageButton({Key? key, required this.matchDetailsMap}) : super(key: key);
  final Map matchDetailsMap;

  @override
  _AddFoodImageButtonState createState() => _AddFoodImageButtonState();
}

class _AddFoodImageButtonState extends State<AddFoodImageButton> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Divider(height: 1.0, thickness: 1.0, indent: 0.0),
      SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('images/avatar-host-Sensei.png'),
            ),
            SizedBox(
              width: 16,
            ),
            Flexible(
              child: Text(
                'Share healthy food you’re eating today.',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            IconButton(
                onPressed: () {
                  takeFoodPicButtonAction(widget.matchDetailsMap, context);
                },
                icon: Icon(Icons.add_circle, color: Colors.red, size: 40))
          ],
        ),
      ),
      SizedBox(height: 8),
    ]);
  }
}

takeFoodPicButtonAction(Map matchDetailsMap, BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CaptureFoodImage(
            matchDetailsMap: matchDetailsMap,
          )));
}
