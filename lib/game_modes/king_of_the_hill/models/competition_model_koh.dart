
class CompetitionModelKOH {
  CompetitionModelKOH({
    this.competitionStatus = '0', // total # of open judgements
    this.dateCreated, // # of games a specific user judged
    this.dateEnd,
    this.dateStart,
    this.dateUpdated,
    this.gameRulesID = '0',
    this.id = '0',
  });

  String competitionStatus;
  DateTime? dateCreated = DateTime.now();
  DateTime? dateEnd = DateTime.now();
  DateTime? dateStart = DateTime.now();
  DateTime? dateUpdated = DateTime.now();
  String gameRulesID;
  String id;

  Map<String, dynamic> toMap(){
    return {
      'competitionStatus': competitionStatus,
      'dateCreated': dateCreated,
      'dateEnd': dateEnd,
      'dateStart': dateStart,
      'dateUpdated': dateUpdated,
      'gameRulesID': gameRulesID,
      'id': id,
    };
  }

}