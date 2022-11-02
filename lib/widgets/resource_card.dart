import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//ignore: must_be_immutable
class ResourceCard extends StatelessWidget {
  ResourceCard({
    Key? key,
    this.type = 'image',
    this.resourceCount = 0,
    this.resourceName = 'ITEM',
    this.resourceTitle = 'TITLE',
    this.imageAsset = 'images/avatar-blank.png',
    this.icon = FontAwesomeIcons.anchor,
  }) : super(key: key);

  final String type; // options: image, icon, avatar
  final String resourceTitle;
  final int resourceCount;
  final String resourceName;

  final String imageAsset;
  final IconData? icon;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          //width: (MediaQuery.of(context).size.width) * .4,
          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: borderRadius1(),
            color: primarySolidCardColor.withOpacity(0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height:4),
              Visibility(
                  visible: (resourceTitle != 'TITLE'),
                  child: Text(resourceTitle, style: PrimaryCaption1())),
              SizedBox(height:8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Visibility(
                      visible: (type == 'icon'),
                      child: FaIcon(icon, size: 32, color: Colors.yellow,)),
                  Visibility(
                    visible: (type == 'image'),
                    child: Image.asset(
                      imageAsset,
                      height: 32,
                    ),
                  ),
                  Visibility(
                    visible: (type == 'avatar'),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage(imageAsset),
                    ),
                  ),
                  SizedBox(width: 8),
                  Visibility(
                      visible: (resourceCount != 0),
                      child: Text('$resourceCount', style: PrimaryStyleH6())),
                ],
              ),
              SizedBox(height:8),
              Visibility(
                  visible: (resourceName != 'ITEM'),
                  child: Text(resourceName, style: PrimaryCaption1(color: onPrimaryWhite))),
            ],
          ),
        ),
      ],
    );
  }
}
