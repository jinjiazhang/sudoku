class SudokuGame {
  final List<List<int>> board;
  final List<List<bool>> isFixed;
  final String difficulty;
  final int gridSize;
  final int mistakes;
  final int secondsElapsed;
  final bool isCompleted;
  final DateTime startTime;
  final int checkCount;    // 剩余检查次数
  final int hintCount;     // 剩余提示次数
  
  SudokuGame({
    required this.board,
    required this.isFixed,
    required this.difficulty,
    required this.gridSize,
    this.mistakes = 0,
    this.secondsElapsed = 0,
    this.isCompleted = false,
    DateTime? startTime,
    this.checkCount = 0,
    this.hintCount = 0,
  }) : startTime = startTime ?? DateTime.now();

  SudokuGame copyWith({
    List<List<int>>? board,
    List<List<bool>>? isFixed,
    String? difficulty,
    int? gridSize,
    int? mistakes,
    int? secondsElapsed,
    bool? isCompleted,
    DateTime? startTime,
    int? checkCount,
    int? hintCount,
  }) {
    return SudokuGame(
      board: board ?? this.board.map((row) => row.toList()).toList(),
      isFixed: isFixed ?? this.isFixed.map((row) => row.toList()).toList(),
      difficulty: difficulty ?? this.difficulty,
      gridSize: gridSize ?? this.gridSize,
      mistakes: mistakes ?? this.mistakes,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
      checkCount: checkCount ?? this.checkCount,
      hintCount: hintCount ?? this.hintCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'isFixed': isFixed,
      'difficulty': difficulty,
      'gridSize': gridSize,
      'mistakes': mistakes,
      'secondsElapsed': secondsElapsed,
      'isCompleted': isCompleted,
      'startTime': startTime.toIso8601String(),
      'checkCount': checkCount,
      'hintCount': hintCount,
    };
  }

  factory SudokuGame.fromJson(Map<String, dynamic> json) {
    return SudokuGame(
      board: List<List<int>>.from(
        json['board'].map((row) => List<int>.from(row))
      ),
      isFixed: List<List<bool>>.from(
        json['isFixed'].map((row) => List<bool>.from(row))
      ),
      difficulty: json['difficulty'],
      gridSize: json['gridSize'] ?? 9,
      mistakes: json['mistakes'] ?? 0,
      secondsElapsed: json['secondsElapsed'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      startTime: DateTime.parse(json['startTime']),
      checkCount: json['checkCount'] ?? 0,
      hintCount: json['hintCount'] ?? 0,
    );
  }
}


enum GameDifficulty {
  level1('1级', 4, 4, 8, 5, 3), // 4x4网格，1-4数字，8个初始数字，5次检查，3次提示
  level2('2级', 4, 4, 5, 5, 3), // 4x4网格，1-4数字，5个初始数字，5次检查，3次提示  
  level3('3级', 6, 6, 16, 5, 3), // 6x6网格，1-6数字，16个初始数字，5次检查，3次提示
  level4('4级', 6, 6, 10, 5, 3), // 6x6网格，1-6数字，10个初始数字，5次检查，3次提示
  level5('5级', 9, 9, 45, 5, 3), // 9x9网格，1-9数字，45个初始数字，5次检查，3次提示
  level6('6级', 9, 9, 40, 5, 2), // 9x9网格，1-9数字，40个初始数字，5次检查，2次提示
  level7('7级', 9, 9, 35, 3, 1), // 9x9网格，1-9数字，35个初始数字，3次检查，1次提示
  level8('8级', 9, 9, 30, 3, 1), // 9x9网格，1-9数字，30个初始数字，3次检查，1次提示
  level9('9级', 9, 9, 25, 1, 0); // 9x9网格，1-9数字，25个初始数字，1次检查，0次提示

  const GameDifficulty(this.displayName, this.gridSize, this.numberRange, this.initialClues, this.checkLimit, this.hintLimit);
  final String displayName;
  final int gridSize;     // 网格大小 (4x4, 6x6, 9x9)
  final int numberRange;  // 使用的数字范围 (1到numberRange)
  final int initialClues; // 初始显示的数字个数
  final int checkLimit;   // 检查次数限制
  final int hintLimit;    // 提示次数限制
}