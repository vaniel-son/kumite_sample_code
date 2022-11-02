
class LeaderboardAndPlayerRankModelKOH {
  LeaderboardAndPlayerRankModelKOH({
    required this.leaderboardRecords,
    required this.rank,
    required this.playerUserID,
  });

  List leaderboardRecords;
  int rank;
  String playerUserID;

  Map<String, dynamic> toMap(){
    return {
    'leaderboards': leaderboardRecords,
    'rank': rank,
    'playerUserID': playerUserID,
    };
  }

}
