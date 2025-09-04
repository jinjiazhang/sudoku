class SudokuGame {
  final List<List<int>> board;
  final List<List<bool>> isFixed;
  final String difficulty;
  final int mistakes;
  final int score;
  final int secondsElapsed;
  final bool isCompleted;
  final DateTime startTime;
  
  SudokuGame({
    required this.board,
    required this.isFixed,
    required this.difficulty,
    this.mistakes = 0,
    this.score = 0,
    this.secondsElapsed = 0,
    this.isCompleted = false,
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  SudokuGame copyWith({
    List<List<int>>? board,
    List<List<bool>>? isFixed,
    String? difficulty,
    int? mistakes,
    int? score,
    int? secondsElapsed,
    bool? isCompleted,
    DateTime? startTime,
  }) {
    return SudokuGame(
      board: board ?? this.board.map((row) => row.toList()).toList(),
      isFixed: isFixed ?? this.isFixed.map((row) => row.toList()).toList(),
      difficulty: difficulty ?? this.difficulty,
      mistakes: mistakes ?? this.mistakes,
      score: score ?? this.score,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'isFixed': isFixed,
      'difficulty': difficulty,
      'mistakes': mistakes,
      'score': score,
      'secondsElapsed': secondsElapsed,
      'isCompleted': isCompleted,
      'startTime': startTime.toIso8601String(),
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
      mistakes: json['mistakes'] ?? 0,
      score: json['score'] ?? 0,
      secondsElapsed: json['secondsElapsed'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      startTime: DateTime.parse(json['startTime']),
    );
  }
}

class SudokuCell {
  final int row;
  final int col;
  final int value;
  final bool isFixed;
  final List<int> notes;

  SudokuCell({
    required this.row,
    required this.col,
    this.value = 0,
    this.isFixed = false,
    this.notes = const [],
  });

  SudokuCell copyWith({
    int? value,
    bool? isFixed,
    List<int>? notes,
  }) {
    return SudokuCell(
      row: row,
      col: col,
      value: value ?? this.value,
      isFixed: isFixed ?? this.isFixed,
      notes: notes ?? List.from(this.notes),
    );
  }
}

enum GameDifficulty {
  beginner('入门'),
  easy('简单'),
  medium('中等'),
  hard('困难');

  const GameDifficulty(this.displayName);
  final String displayName;
}