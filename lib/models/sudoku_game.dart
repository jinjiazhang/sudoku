import 'package:flutter/material.dart';

class SudokuGame {
  final List<List<int>> board;
  final List<List<bool>> isFixed;
  final String difficulty;
  final int gridSize;
  final int mistakes;
  final int score;
  final int secondsElapsed;
  final bool isCompleted;
  final DateTime startTime;
  
  SudokuGame({
    required this.board,
    required this.isFixed,
    required this.difficulty,
    required this.gridSize,
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
    int? gridSize,
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
      gridSize: gridSize ?? this.gridSize,
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
      'gridSize': gridSize,
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
      gridSize: json['gridSize'] ?? 9,
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
  level1('1级', 4, 4, 10), // 4x4网格，1-4数字，10个初始数字
  level2('2级', 6, 6, 20), // 6x6网格，1-6数字，20个初始数字  
  level3('3级', 9, 9, 55), // 9x9网格，1-9数字，55个初始数字
  level4('4级', 9, 9, 50), // 9x9网格，1-9数字，50个初始数字
  level5('5级', 9, 9, 45), // 9x9网格，1-9数字，45个初始数字
  level6('6级', 9, 9, 40), // 9x9网格，1-9数字，40个初始数字
  level7('7级', 9, 9, 35), // 9x9网格，1-9数字，35个初始数字
  level8('8级', 9, 9, 30), // 9x9网格，1-9数字，30个初始数字
  level9('9级', 9, 9, 25); // 9x9网格，1-9数字，25个初始数字

  const GameDifficulty(this.displayName, this.gridSize, this.numberRange, this.initialClues);
  final String displayName;
  final int gridSize;     // 网格大小 (4x4, 6x6, 9x9)
  final int numberRange;  // 使用的数字范围 (1到numberRange)
  final int initialClues; // 初始显示的数字个数
  
  /// 获取子区域大小
  int get subGridSize {
    switch (gridSize) {
      case 4: return 2;  // 4x4网格使用2x2子区域
      case 6: return 2;  // 6x6网格使用2x3子区域（或3x2，待定）
      case 9: return 3;  // 9x9网格使用3x3子区域
      default: return 3;
    }
  }

  /// 获取描述文本
  String get description {
    switch (this) {
      case GameDifficulty.level1:
        return '4x4网格，1-4数字';
      case GameDifficulty.level2:
        return '6x6网格，1-6数字';
      case GameDifficulty.level3:
        return '9x9数独，很多提示';
      case GameDifficulty.level4:
        return '9x9数独，较多提示';
      case GameDifficulty.level5:
        return '9x9数独，适量提示';
      case GameDifficulty.level6:
        return '9x9数独，较少提示';
      case GameDifficulty.level7:
        return '9x9数独，很少提示';
      case GameDifficulty.level8:
        return '9x9数独，极少提示';
      case GameDifficulty.level9:
        return '9x9数独，最少提示';
    }
  }

  /// 获取颜色
  Color get color {
    switch (this) {
      case GameDifficulty.level1:
      case GameDifficulty.level2:
        return const Color(0xFF4CAF50); // 绿色 - 简单
      case GameDifficulty.level3:
      case GameDifficulty.level4:
      case GameDifficulty.level5:
        return const Color(0xFF2196F3); // 蓝色 - 中等
      case GameDifficulty.level6:
      case GameDifficulty.level7:
        return const Color(0xFFFF9800); // 橙色 - 困难
      case GameDifficulty.level8:
      case GameDifficulty.level9:
        return const Color(0xFFF44336); // 红色 - 极难
    }
  }
}