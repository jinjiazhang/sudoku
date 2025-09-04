import '../models/sudoku_game.dart';
import 'dart:math';

class SudokuService {
  final Random _random = Random();

  /// 创建新的数独游戏
  SudokuGame createNewGame(GameDifficulty difficulty) {
    final result = _generateSudokuBoard(difficulty);
    
    return SudokuGame(
      board: result['board'] as List<List<int>>,
      isFixed: result['isFixed'] as List<List<bool>>,
      difficulty: difficulty.displayName,
      gridSize: difficulty.gridSize,
    );
  }

  /// 加载示例游戏（基于设计图）
  SudokuGame createSampleGame(String difficulty, {bool isResuming = false}) {
    List<List<int>> sampleBoard = [
      [0, 0, 2, 7, 0, 1, 0, 0, 6],
      [0, 0, 0, 6, 9, 0, 0, 1, 0],
      [9, 6, 0, 0, 8, 0, 5, 3, 0],
      [9, 8, 4, 0, 0, 0, 6, 4, 0],
      [2, 0, 0, 0, 0, 0, 0, 0, 0],
      [6, 0, 3, 0, 5, 8, 0, 0, 0],
      [0, 7, 8, 0, 1, 4, 9, 0, 0],
      [4, 2, 0, 3, 6, 7, 0, 0, 5],
      [5, 0, 1, 0, 0, 9, 3, 0, 4],
    ];
    
    List<List<bool>> fixedCells = [
      [false, false, true, true, false, true, false, false, true],
      [false, false, false, true, true, false, false, true, false],
      [true, true, false, false, true, false, true, true, false],
      [true, true, true, false, false, false, true, true, false],
      [true, false, false, false, false, false, false, false, false],
      [true, false, true, false, true, true, false, false, false],
      [false, true, true, false, true, true, true, false, false],
      [true, true, false, true, true, true, false, false, true],
      [true, false, true, false, false, true, true, false, true],
    ];
    
    return SudokuGame(
      board: sampleBoard,
      isFixed: fixedCells,
      difficulty: difficulty,
      gridSize: 9,
      secondsElapsed: isResuming ? 35 : 0,
    );
  }

  /// 验证数字是否可以放置在指定位置
  bool isValidMove(SudokuGame game, int row, int col, int number) {
    if (game.isFixed[row][col]) return false;
    
    // 根据游戏难度获取数字范围
    GameDifficulty? difficulty = _getDifficultyFromName(game.difficulty);
    int maxNumber = difficulty?.numberRange ?? 9;
    
    if (number < 1 || number > maxNumber) return false;

    return _isValidPlacement(game.board, row, col, number, game.gridSize);
  }
  
  /// 检查数字放置是否有效
  bool _isValidPlacement(List<List<int>> board, int row, int col, int number, int gridSize) {
    // 检查行
    for (int c = 0; c < gridSize; c++) {
      if (c != col && board[row][c] == number) {
        return false;
      }
    }

    // 检查列
    for (int r = 0; r < gridSize; r++) {
      if (r != row && board[r][col] == number) {
        return false;
      }
    }

    // 根据网格大小选择子区域验证
    switch (gridSize) {
      case 4:
        return _isValid2x2Region(board, row, col, number);
      case 6:
        return _isValid2x3Region(board, row, col, number);
      case 9:
      default:
        return _isValid3x3Region(board, row, col, number);
    }
  }
  
  /// 检查2x2区域是否有效（用于4x4数独）
  bool _isValid2x2Region(List<List<int>> board, int row, int col, int number) {
    int subGridRow = (row ~/ 2) * 2;
    int subGridCol = (col ~/ 2) * 2;
    
    for (int r = subGridRow; r < subGridRow + 2; r++) {
      for (int c = subGridCol; c < subGridCol + 2; c++) {
        if ((r != row || c != col) && board[r][c] == number) {
          return false;
        }
      }
    }
    return true;
  }
  
  /// 检查2x3区域是否有效（用于6x6数独）
  bool _isValid2x3Region(List<List<int>> board, int row, int col, int number) {
    // 6x6数独有6个2x3子区域，排列为3行2列
    int subGridRow = (row ~/ 2) * 2;
    int subGridCol = (col ~/ 3) * 3;
    
    for (int r = subGridRow; r < subGridRow + 2; r++) {
      for (int c = subGridCol; c < subGridCol + 3; c++) {
        if ((r != row || c != col) && board[r][c] == number) {
          return false;
        }
      }
    }
    return true;
  }
  
  /// 检查3x3区域是否有效（用于9x9数独）
  bool _isValid3x3Region(List<List<int>> board, int row, int col, int number) {
    int subGridRow = (row ~/ 3) * 3;
    int subGridCol = (col ~/ 3) * 3;
    
    for (int r = subGridRow; r < subGridRow + 3; r++) {
      for (int c = subGridCol; c < subGridCol + 3; c++) {
        if ((r != row || c != col) && board[r][c] == number) {
          return false;
        }
      }
    }
    return true;
  }
  
  /// 从难度名称获取难度枚举
  GameDifficulty? _getDifficultyFromName(String difficultyName) {
    for (GameDifficulty difficulty in GameDifficulty.values) {
      if (difficulty.displayName == difficultyName) {
        return difficulty;
      }
    }
    return null;
  }

  /// 放置数字
  SudokuGame placeNumber(SudokuGame game, int row, int col, int number) {
    if (game.isFixed[row][col]) return game;

    List<List<int>> newBoard = game.board.map((row) => row.toList()).toList();
    int mistakes = game.mistakes;

    if (newBoard[row][col] == number) {
      // 如果点击相同数字，则清除
      newBoard[row][col] = 0;
    } else {
      // 验证是否是有效移动
      if (isValidMove(game, row, col, number)) {
        newBoard[row][col] = number;
      } else {
        newBoard[row][col] = number; // 仍然放置，但增加错误计数
        mistakes = (mistakes + 1).clamp(0, 3);
      }
    }

    return game.copyWith(
      board: newBoard,
      mistakes: mistakes,
    );
  }

  /// 擦除单元格
  SudokuGame eraseCell(SudokuGame game, int row, int col) {
    if (game.isFixed[row][col]) return game;

    List<List<int>> newBoard = game.board.map((row) => row.toList()).toList();
    newBoard[row][col] = 0;

    return game.copyWith(board: newBoard);
  }

  /// 检查游戏是否完成
  bool isGameComplete(SudokuGame game) {
    int gridSize = game.gridSize;
    // 检查是否所有单元格都已填充
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (game.board[row][col] == 0) return false;
      }
    }

    // 验证数独规则
    return _isValidSudoku(game.board, gridSize);
  }

  /// 获取提示
  List<int> getHint(SudokuGame game, int row, int col) {
    if (game.isFixed[row][col]) return [];

    List<int> possibleNumbers = [];
    
    // 根据游戏难度获取数字范围
    GameDifficulty? difficulty = _getDifficultyFromName(game.difficulty);
    int maxNumber = difficulty?.numberRange ?? 9;
    
    for (int number = 1; number <= maxNumber; number++) {
      if (isValidMove(game, row, col, number)) {
        possibleNumbers.add(number);
      }
    }

    return possibleNumbers;
  }

  /// 格式化时间
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 生成分级数独棋盘
  Map<String, List<List<dynamic>>> _generateSudokuBoard(GameDifficulty difficulty) {
    // 根据难度生成不同的数独
    switch (difficulty) {
      case GameDifficulty.level1:
        return _generateLevel1Board(); // 1-4数字
      case GameDifficulty.level2:
        return _generateLevel2Board(); // 1-6数字
      default:
        return _generateStandardBoard(difficulty); // 1-9数字，不同提示数量
    }
  }
  
  /// 生成1级难度棋盘（4x4网格，1-4数字）
  Map<String, List<List<dynamic>>> _generateLevel1Board() {
    // 基于你的图片创建一个完整的4x4数独解
    List<List<int>> completedBoard = [
      [1, 4, 2, 3],
      [3, 2, 4, 1], 
      [4, 1, 3, 2],
      [2, 3, 1, 4],
    ];
    
    // 创建游戏棋盘，移除一些数字作为谜题
    List<List<int>> board = completedBoard.map((row) => row.toList()).toList();
    
    // 根据你的图片，保留这些位置的数字
    List<List<bool>> fixedPositions = [
      [false, false, false, false],
      [false, true,  true,  true ],  // 2, 3, 1
      [false, true,  true,  true ],  // 3, 2, 4  
      [true,  false, false, true ],  // 2,       3
    ];
    
    // 根据固定位置设置棋盘
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (!fixedPositions[row][col]) {
          board[row][col] = 0;
        }
      }
    }
    
    return {'board': board, 'isFixed': fixedPositions};
  }
  
  /// 生成2级难度棋盘（6x6数字，1-6数字）
  Map<String, List<List<dynamic>>> _generateLevel2Board() {
    // 完全按照2.png图片显示的数独棋盘
    List<List<int>> board = [
      [0, 5, 0, 2, 0, 6],  // 第1行：_, 5, _, 2, _, 6
      [2, 4, 6, 0, 0, 3],  // 第2行：2, 4, 6, _, _, 3
      [1, 2, 4, 0, 6, 5],  // 第3行：1, 2, 4, _, 6, 5
      [5, 6, 0, 4, 2, 1],  // 第4行：5, 6, _, 4, 2, 1
      [4, 0, 0, 6, 3, 2],  // 第5行：4, _, _, 6, 3, 2
      [6, 0, 2, 0, 1, 0],  // 第6行：6, _, 2, _, 1, _
    ];
    
    // 设置固定位置（有数字的位置为固定）
    List<List<bool>> fixedPositions = [
      [false, true,  false, true,  false, true ],  // _, 5, _, 2, _, 6
      [true,  true,  true,  false, false, true ],  // 2, 4, 6, _, _, 3
      [true,  true,  true,  false, true,  true ],  // 1, 2, 4, _, 6, 5
      [true,  true,  false, true,  true,  true ],  // 5, 6, _, 4, 2, 1
      [true,  false, false, true,  true,  true ],  // 4, _, _, 6, 3, 2
      [true,  false, true,  false, true,  false],  // 6, _, 2, _, 1, _
    ];
    
    return {'board': board, 'isFixed': fixedPositions};
  }
  
  /// 生成标准数独棋盘（1-9数字）
  Map<String, List<List<dynamic>>> _generateStandardBoard(GameDifficulty difficulty) {
    List<List<int>> board = [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ];
    
    // 根据难度移除不同数量的数字
    int totalCells = 9 * 9;
    int cluesToRemove = totalCells - difficulty.initialClues;
    _removeClues(board, 9, cluesToRemove);
    
    List<List<bool>> isFixed = board.map((row) => 
      row.map((cell) => cell != 0).toList()
    ).toList();
    
    return {'board': board, 'isFixed': isFixed};
  }
  
  /// 随机移除棋盘上的数字
  void _removeClues(List<List<int>> board, int gridSize, int cluesToRemove) {
    int removed = 0;
    int totalPositions = gridSize * gridSize;
    List<int> positions = List.generate(totalPositions, (i) => i);
    positions.shuffle(_random);
    
    for (int pos in positions) {
      if (removed >= cluesToRemove) break;
      
      int row = pos ~/ gridSize;
      int col = pos % gridSize;
      
      if (board[row][col] != 0) {
        board[row][col] = 0;
        removed++;
      }
    }
  }

  /// 验证数独是否有效
  bool _isValidSudoku(List<List<int>> board, int gridSize) {
    // 验证行
    for (int row = 0; row < gridSize; row++) {
      if (!_isValidGroup(board[row])) return false;
    }

    // 验证列
    for (int col = 0; col < gridSize; col++) {
      List<int> column = [];
      for (int row = 0; row < gridSize; row++) {
        column.add(board[row][col]);
      }
      if (!_isValidGroup(column)) return false;
    }

    // 验证子网格
    int subGridSize = _getSubGridSize(gridSize);
    int subGridCount = gridSize;
    
    for (int subGrid = 0; subGrid < subGridCount; subGrid++) {
      List<int> subGridValues = [];
      int subGridRow = (subGrid ~/ subGridSize) * subGridSize;
      int subGridCol = (subGrid % subGridSize) * subGridSize;
      
      for (int r = subGridRow; r < subGridRow + subGridSize; r++) {
        for (int c = subGridCol; c < subGridCol + subGridSize; c++) {
          subGridValues.add(board[r][c]);
        }
      }
      if (!_isValidGroup(subGridValues)) return false;
    }

    return true;
  }
  
  /// 获取子网格大小
  int _getSubGridSize(int gridSize) {
    switch (gridSize) {
      case 4: return 2;
      case 6: return 2; // 6x6使用2x3子网格
      case 9: return 3;
      default: return 3;
    }
  }

  /// 验证一组数字是否有效（1-9各出现一次）
  bool _isValidGroup(List<int> group) {
    Set<int> seen = {};
    for (int number in group) {
      if (number != 0) {
        if (seen.contains(number)) return false;
        seen.add(number);
      }
    }
    return true;
  }
}