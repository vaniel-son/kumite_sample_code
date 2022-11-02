import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:flutter/services.dart';

//ignore: must_be_immutable
class TextAndButtonCard extends StatelessWidget {
  TextAndButtonCard({
    Key? key,
    this.text = '-',
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width) * .90,
          padding: EdgeInsets.all(24.0),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: borderRadius1(),
            color: primarySolidCardColor.withOpacity(0.7),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                   Image.asset(
                    'images/pho-bowl-01.png',
                    height: 40,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                        'Visit UNISWAP to swap PHO for 1 INVITE token', style: PrimaryCaption1(color: onPrimaryWhite)),
                  ),
                ],
              ),
              SizedBox(height: 24),
              MediumEmphasisButton(
                title: 'Copy UNISWAP link',
                onPressAction: () {
                  print('tap');
                  Clipboard.setData(ClipboardData(text: "https://app.uniswap.org/#/swap?chain=ropsten&inputCurrency=0xbe5a7FC4abdBB335A508FdC4b81Cd1Fea46ac90A&outputCurrency=0x595ee94Ef08AA90940d674151907eE5Ad512ae8e&exactField=output&exactAmount=1&use=v1"));
                  GeneralService.displaySnackBar(context, 'Uniswap link copied');

                },
              ),
              SizedBox(height:4),
              Text('(use OPTIMISM CHAIN)', style: PrimaryCaption1(color: onPrimaryWhite)),
            ],
          ),
        ),
      ],
    );
  }
}
