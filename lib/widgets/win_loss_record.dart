import 'package:dojo_app/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/services/auth_service.dart';

class WinLossTieRecord extends StatelessWidget {
  WinLossTieRecord({
    Key? key,
    required this.winLossTieRecord,
  }) : super(key: key);

  final String winLossTieRecord;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 64,
        ),
        // ignore: deprecated_member_use
        TextButton.icon(
          icon: Icon(Icons.person),
          label: Text('logout'),
          onPressed: () async {
            await _auth.signOut();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        Text('WIN/LOSS $winLossTieRecord',
            style: Theme.of(context).textTheme.bodyText2),
        SizedBox(width: 16),
        CircleAvatar(
          radius: 25,
          backgroundColor: primaryDojoColorLighter,
          child: Text('XX', style: Theme.of(context).textTheme.headline5),
          //backgroundImage: AssetImage('images/naruto.png'),
        ),
      ],
    );
  }
}
