import '../style/colors.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/material.dart';

class PostGame2PlayerResultsCard extends StatelessWidget {
  const PostGame2PlayerResultsCard({
    Key? key,
    required this.cardType,
  }) : super(key: key);

  final int cardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF22283D).withOpacity(0.75),
      ),
      child: Column(
        children: [
          Column(
            children: <Widget>[
              Text(
                'Pushup Challenge',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                'AMRAP, 1min',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
          SizedBox(height:16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'YOU',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('images/avatar-blank.png'),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          ' 155x',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: primaryDojoColor,
                          size: 24.0,
                        ),
                        LowEmphasisButton(title: 'PLAY VIDEO'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .20,
                child: Column(
                  children: <Widget>[
                    Text('VS.', style: Theme.of(context).textTheme.headline4),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .30,
                child: Column(
                  children: <Widget>[
                    Text(
                      'THE HEADKICKER',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 8),
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('images/avatar-blank.png'),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          ' 39x',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: primaryDojoColor,
                          size: 24.0,
                        ),
                        LowEmphasisButton(title: 'PLAY VIDEO'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          //SizedBox(height: 16),
        ],
      ),
    );
  }
}