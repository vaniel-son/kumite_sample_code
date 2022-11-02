/// When loading Dojo
// this is the default data since there are no alternatives yet
// in the future, this cannot be hard coded
String category = 'fitness';
String levelGroupID = 'TnexLXrjpwnHaWJ3FeGG';
String matchGroupID = 'NUcZNP5oto6XZP7oictP';
Map gameModeMatchesMap = {'groupID': 'NUcZNP5oto6XZP7oictP', 'gameMode': 'matches'};
List fitnessGameModesList = [{'gameMode': 'levels', 'groupID': 'TnexLXrjpwnHaWJ3FeGG'},{'gameMode': 'matches', 'groupID': 'NUcZNP5oto6XZP7oictP'},{'gameMode': 'king of the hill', 'groupID': 'xyz'}];

// TODO: remove usage of wrapper global files
// Wrappers fetch data,
// then store in this global file,
// which is used to inform the corresponding screen
Map gameModesWrapperMap = {};
Map matchesWrapperMap = {};
Map levelsWrapperMap = {};
Map gameScreenWrapperMap = {};
Map viewReplayWrapperMap = {};
Map judgeListWrapperMap = {};