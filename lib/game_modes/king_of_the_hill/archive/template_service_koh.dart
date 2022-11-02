import 'package:dojo_app/game_modes/king_of_the_hill/models/game_model_king_of_hill.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';

class TemplateServiceKOH {
  // Initialize DB object with methods to call DB
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();

  /// Constructor
  TemplateServiceKOH() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  ///  Short Description
  /// ***********************************************************************
  /// ***********************************************************************

  void someFunction({required GameModelKOH gameInfo}) async {

  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Short Description
  /// ***********************************************************************
  /// ***********************************************************************

  Future<Map> someFunction2(String gameRulesID, String userID) async {
    Map someMap = {};
    return someMap;
  }


}
