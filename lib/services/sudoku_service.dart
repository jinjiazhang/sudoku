import '../models/sudoku_game.dart';

class SudokuService {
  static const int _gridSize = 9;
  static const int _subGridSize = 3;

  /// 创建新的数独游戏
  SudokuGame createNewGame(GameDifficulty difficulty) {
    final board = _generateSudokuBoard(difficulty);
    final isFixed = _createFixedCellsMatrix(board);
    
    return SudokuGame(
      board: board,
      isFixed: isFixed,
      difficulty: difficulty.displayName,
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
      secondsElapsed: isResuming ? 35 : 0,
    );
  }

  /// 验证数字是否可以放置在指定位置
  bool isValidMove(SudokuGame game, int row, int col, int number) {
    if (game.isFixed[row][col]) return false;
    if (number < 1 || number > 9) return false;

    // 检查行
    for (int c = 0; c < _gridSize; c++) {
      if (c != col && game.board[row][c] == number) {
        return false;
      }
    }

    // 检查列
    for (int r = 0; r < _gridSize; r++) {
      if (r != row && game.board[r][col] == number) {
        return false;
      }
    }

    // 检查3x3子网格
    int subGridRow = (row ~/ _subGridSize) * _subGridSize;
    int subGridCol = (col ~/ _subGridSize) * _subGridSize;
    
    for (int r = subGridRow; r < subGridRow + _subGridSize; r++) {
      for (int c = subGridCol; c < subGridCol + _subGridSize; c++) {
        if ((r != row || c != col) && game.board[r][c] == number) {
          return false;
        }
      }
    }

    return true;
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
    // 检查是否所有单元格都已填充
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (game.board[row][col] == 0) return false;
      }
    }

    // 验证数独规则
    return _isValidSudoku(game.board);
  }

  /// 获取提示
  List<int> getHint(SudokuGame game, int row, int col) {
    if (game.isFixed[row][col]) return [];

    List<int> possibleNumbers = [];
    
    for (int number = 1; number <= 9; number++) {
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

  /// 生成数独棋盘（简化版，实际应用中需要更复杂的算法）
  List<List<int>> _generateSudokuBoard(GameDifficulty difficulty) {
    // 这里使用示例棋盘，实际应用中应该实现完整的数独生成算法
    return _getSampleBoard();
  }

  /// 创建固定单元格矩阵
  List<List<bool>> _createFixedCellsMatrix(List<List<int>> board) {
    return board.map((row) => 
      row.map((cell) => cell != 0).toList()
    ).toList();
  }

  /// 获取示例棋盘
  List<List<int>> _getSampleBoard() {
    return [
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
  }

  /// 验证数独是否有效
  bool _isValidSudoku(List<List<int>> board) {
    // 验证行
    for (int row = 0; row < _gridSize; row++) {
      if (!_isValidGroup(board[row])) return false;
    }

    // 验证列
    for (int col = 0; col < _gridSize; col++) {
      List<int> column = [];
      for (int row = 0; row < _gridSize; row++) {
        column.add(board[row][col]);
      }
      if (!_isValidGroup(column)) return false;
    }

    // 验证3x3子网格
    for (int subGrid = 0; subGrid < _gridSize; subGrid++) {
      List<int> subGridValues = [];
      int subGridRow = (subGrid ~/ _subGridSize) * _subGridSize;
      int subGridCol = (subGrid % _subGridSize) * _subGridSize;
      
      for (int r = subGridRow; r < subGridRow + _subGridSize; r++) {
        for (int c = subGridCol; c < subGridCol + _subGridSize; c++) {
          subGridValues.add(board[r][c]);
        }
      }
      if (!_isValidGroup(subGridValues)) return false;
    }

    return true;
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