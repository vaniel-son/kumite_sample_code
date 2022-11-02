
class JudgeCountsModelKOH {
  JudgeCountsModelKOH({
    this.openCount = 0, // total # of open judgements
    this.userJudgeCount = 0, // # of games a specific user judged
    this.totalClosedCount = 0, // total # of games closed
    this.userSuccessCount = 0, // # of successfully judged games
    this.userFailureCount = 0, // # of failed judged games where they did not agree w/ consensus
  });

  int openCount;
  int userJudgeCount;
  int totalClosedCount;
  int userSuccessCount;
  int userFailureCount;

  Map<String, dynamic> toMap(){
    return {
      'openCount': openCount,
      'userJudgeCount': userJudgeCount,
      'totalClosedCount': totalClosedCount,
      'userSuccessCount': userSuccessCount,
      'userFailureCount': userFailureCount,
    };
  }

}
