import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dojo_app/screens/onboarding/onboarding_start/onboarding_start_screen.dart';
import 'package:dojo_app/screens/game_mode_select/game_mode_select_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:http/http.dart' as http;
import 'package:dojo_app/playground/moralis_poc/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

DatabaseServices dataService = DatabaseServices();

Future<bool> verifyAndSaveEthereumAddress(BuildContext context,String walletAddress, String userID, bool updateScreen) async {

  // Verify ethereum address is a real address
  final response = await verifyEthereumAddress(walletAddress);

  if (response.statusCode == 200) { // success
    final responseVerification = true;

    if(walletAddress != '0x3b01E62f3734533C492a3C49dd4A72A1512d1547') {
      // let user know they can wait...
      String message = 'Saving...';
      GeneralService.displaySnackBar(context, message);

      // update user table with the new eth address
      await dataService.updateEthereumAddress(userID, walletAddress);

      // display success message
      message = 'Address was added successfully';
      GeneralService.displaySnackBar(context, message);

      // route the user
      routeUserAfterSavingEthereumAddressSuccessfully(context, updateScreen);
    }

    return responseVerification;

  } else if(response.statusCode == 400) {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Invalid eth address');
  } else {
    throw Exception('Something went wrong');
  }
}

Future<String> fetchWalletAddress(String userID) async {
  String ethAddress = await dataService.retrieveWalletAddress(userID);
  return ethAddress;
}

/// verify wallet address
Future verifyEthereumAddress(String walletAddress) async {
  // Verify ethereum address is a real address
  final response = await http
      .get(Uri.parse(
      'https://deep-index.moralis.io/api/v2/$walletAddress/balance?chain=eth'),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',
      }
  );

  return response;
}

routeUserAfterSavingEthereumAddressSuccessfully(BuildContext context, bool updateScreen) {
  Widget routeUserToHere = GameModeSelectScreen(); // default value

  // if the user is updating outside of onboarding...
  if (updateScreen == true) {
    routeUserToHere = Wrapper();
  } else { // if the user is updating during onboarding...
    // routeUserToHere = OnboardingStartScreen();
    routeUserToHere = Wrapper();
  }

  // Wait 2 seconds before auto routing the user to the next screen
  Timer(Duration(seconds: 2), () {
    Navigator.pushReplacement(context, PageTransition(
        type: PageTransitionType.leftToRightWithFade,
        child: routeUserToHere));
  });
}

/// ******************* Unused Below *****************************

// MainNet - eth balance (Test wallet)
Future<WalletBalance> fetchWalletBalanceMainNet() async {
  final response = await http
      .get(Uri.parse('https://deep-index.moralis.io/api/v2/0xCbE268287CB39Ac33F1bcF92DE590000bb3f0415/balance?chain=eth'),
      headers: {HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',}
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WalletBalance.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

// TestNet - DOJO Token balance
Future<TokenData> fetchTokenDataTestNet() async {
  final response = await http
      .get(Uri.parse('https://deep-index.moralis.io/api/v2/0x80a3fD1F1fFe4aE862693112675C34726254ABA0/erc20?chain=ropsten&token_addresses=0x9abc4af7109197f360c83367b4a45054d37041ab'),
      headers: {HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',}
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return TokenData.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<bool> fetchTokenTransactions(String date) async {
  final response = await http
      .get(Uri.parse('https://deep-index.moralis.io/api/v2/0x32667CeF4275373FF346EE75373E5305Ff020004/erc20/transfers?chain=ropsten&from_date=$date'),
      headers: {HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',}
  );

  if (response.statusCode == 200) {

    var results = jsonDecode(response.body);

    var onlyPlayerTransactions = results['result'];
    print(onlyPlayerTransactions);

    List transactions = [];
    var transactionAmount;


    if(onlyPlayerTransactions.length > 1) {
      for (var i = 0; i < onlyPlayerTransactions.length - 1; i++) {
        if (onlyPlayerTransactions[i]['from_address'] ==
            '0xcbe268287cb39ac33f1bcf92de590000bb3f0415') {
          transactionAmount =
              (BigInt.parse(onlyPlayerTransactions[i]['value'])) /
                  BigInt.from(1000000000000000000);
          transactions.add(transactionAmount);
        }
      }
      var finalAmount = transactions.reduce((a, b) => a + b);
      print('The players transaction to Dojo Wallet: $onlyPlayerTransactions');
      print('THE AMOUNT TOKENS DEPOSITED IS: $finalAmount');
      if(finalAmount > 5) {
        return true;
      } else {
        return false;
      }
    } else {
      if (onlyPlayerTransactions[0]['from_address'] == '0xcbe268287cb39ac33f1bcf92de590000bb3f0415') {
        transactionAmount =
            (BigInt.parse(onlyPlayerTransactions[0]['value'])) /
                BigInt.from(1000000000000000000);
        transactions.add(transactionAmount);
        if(transactionAmount > 5) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
}

//Check Moralis API to see if the ethAddress is in hex format
Future<bool> verifyAndSaveEthereumAddress3(BuildContext context,String walletAddress, String userID, bool updateScreen) async {

  // Verify ethereum address is a real address
  final response = await http
      .get(Uri.parse('https://deep-index.moralis.io/api/v2/$walletAddress/balance?chain=eth'),
      headers: {HttpHeaders.acceptHeader: 'application/json',
        'X-API-Key': '7OO7erzI4sZgilQLuVbTVzqmj3FXX5pJP0VH6GgjIowCYPFGAi4JAjsfoMtm7wcm',}
  );

  if (response.statusCode == 200) {

    final responseVerification = true;

    if(walletAddress != '0x3b01E62f3734533C492a3C49dd4A72A1512d1547') {
      await dataService.updateEthereumAddress(userID, walletAddress);

      if(updateScreen == true) {

        final snackBar = SnackBar(
          content: const Text('Address was updated successfully'),
        );

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Wait 3 seconds before auto routing the user to the next screen
        Timer(Duration(seconds: 2), () {
          Navigator.pushReplacement(context, PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              child: GameModeSelectScreen()));
        });
      } else {

        final snackBar = SnackBar(
          content: const Text('Address was added successfully'),
        );

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Wait 3 seconds before auto routing the user to the next screen
        Timer(Duration(seconds: 2), () {
          Navigator.pushReplacement(context, PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              child: OnboardingStartScreen()));
        });

      }
    }
    return responseVerification;

  } else if(response.statusCode == 400) {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Invalid eth address');
  } else {
    throw Exception('Something went wrong');
  }
}

