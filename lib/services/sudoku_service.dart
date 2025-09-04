import '../models/sudoku_game.dart';
import 'dart:math';

class SudokuService {
  final Random _random = Random();
  static SudokuGame? _savedGame;

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

    // 检查子区域
    List<List<int>> subRegionPositions = _getSubRegionPositions(row, col, gridSize);
    for (List<int> pos in subRegionPositions) {
      int r = pos[0];
      int c = pos[1];
      if ((r != row || c != col) && board[r][c] == number) {
        return false;
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

    if (newBoard[row][col] == number) {
      // 如果点击相同数字，则清除
      newBoard[row][col] = 0;
    } else {
      // 直接放置数字，不再验证或计数错误
      newBoard[row][col] = number;
    }

    return game.copyWith(
      board: newBoard,
    );
  }

  /// 擦除单元格
  SudokuGame eraseCell(SudokuGame game, int row, int col) {
    if (game.isFixed[row][col]) return game;

    List<List<int>> newBoard = game.board.map((row) => row.toList()).toList();
    newBoard[row][col] = 0;

    return game.copyWith(board: newBoard);
  }

  /// 检查数字在当前位置是否有冲突
  bool hasConflict(SudokuGame game, int row, int col) {
    int number = game.board[row][col];
    // 固定数字和空格不检查冲突
    if (number == 0) return false;
    
    // 检查与当前数字冲突的其他位置
    List<int> conflictPositions = _findConflictingPositions(game, row, col, number);
    
    return conflictPositions.isNotEmpty;
  }
  
  /// 查找与指定位置数字冲突的其他位置
  List<int> _findConflictingPositions(SudokuGame game, int row, int col, int number) {
    List<int> conflicts = [];
    int gridSize = game.gridSize;
    
    // 检查同行
    for (int c = 0; c < gridSize; c++) {
      if (c != col && game.board[row][c] == number) {
        conflicts.addAll([row, c]);
      }
    }
    
    // 检查同列
    for (int r = 0; r < gridSize; r++) {
      if (r != row && game.board[r][col] == number) {
        conflicts.addAll([r, col]);
      }
    }
    
    // 检查同子区域
    List<List<int>> subRegionPositions = _getSubRegionPositions(row, col, gridSize);
    for (List<int> pos in subRegionPositions) {
      int r = pos[0];
      int c = pos[1];
      if ((r != row || c != col) && game.board[r][c] == number) {
        conflicts.addAll([r, c]);
      }
    }
    
    return conflicts;
  }
  
  /// 获取指定位置所在子区域的所有位置
  List<List<int>> _getSubRegionPositions(int row, int col, int gridSize) {
    List<List<int>> positions = [];
    
    switch (gridSize) {
      case 4:
        int subGridRow = (row ~/ 2) * 2;
        int subGridCol = (col ~/ 2) * 2;
        for (int r = subGridRow; r < subGridRow + 2; r++) {
          for (int c = subGridCol; c < subGridCol + 2; c++) {
            positions.add([r, c]);
          }
        }
        break;
      case 6:
        int subGridRow = (row ~/ 2) * 2;
        int subGridCol = (col ~/ 3) * 3;
        for (int r = subGridRow; r < subGridRow + 2; r++) {
          for (int c = subGridCol; c < subGridCol + 3; c++) {
            positions.add([r, c]);
          }
        }
        break;
      case 9:
      default:
        int subGridRow = (row ~/ 3) * 3;
        int subGridCol = (col ~/ 3) * 3;
        for (int r = subGridRow; r < subGridRow + 3; r++) {
          for (int c = subGridCol; c < subGridCol + 3; c++) {
            positions.add([r, c]);
          }
        }
        break;
    }
    
    return positions;
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

  /// 保存游戏状态
  static void saveGame(SudokuGame game) {
    _savedGame = game;
  }

  /// 获取保存的游戏
  static SudokuGame? getSavedGame() {
    return _savedGame;
  }

  /// 清除保存的游戏
  static void clearSavedGame() {
    _savedGame = null;
  }

  /// 检查是否有保存的游戏
  static bool hasSavedGame() {
    return _savedGame != null;
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
    // 生成完整的4x4数独解
    List<List<int>> completedBoard = _generateComplete4x4Board();
    
    // 创建游戏棋盘
    List<List<int>> board = completedBoard.map((row) => row.toList()).toList();
    
    // 随机移除数字，保留10个数字（根据难度设置）
    int totalCells = 4 * 4;
    int cluesToRemove = totalCells - GameDifficulty.level1.initialClues;
    _removeClues(board, 4, cluesToRemove);
    
    // 设置固定位置
    List<List<bool>> isFixed = board.map((row) => 
      row.map((cell) => cell != 0).toList()
    ).toList();
    
    return {'board': board, 'isFixed': isFixed};
  }

  /// 生成完整的4x4数独解
  List<List<int>> _generateComplete4x4Board() {
    // 创建基础模板
    List<List<int>> board = [
      [1, 2, 3, 4],
      [3, 4, 1, 2],
      [2, 3, 4, 1],
      [4, 1, 2, 3],
    ];
    
    // 随机变换来创建不同的解
    _shuffle4x4Board(board);
    
    return board;
  }

  /// 随机变换4x4数独棋盘
  void _shuffle4x4Board(List<List<int>> board) {
    // 随机交换行（在同一2行子区域内）
    if (_random.nextBool()) {
      _swapRows(board, 0, 1);
    }
    if (_random.nextBool()) {
      _swapRows(board, 2, 3);
    }
    
    // 随机交换列（在同一2列子区域内）
    if (_random.nextBool()) {
      _swapColumns(board, 0, 1);
    }
    if (_random.nextBool()) {
      _swapColumns(board, 2, 3);
    }
    
    // 随机交换2x2子区域行
    if (_random.nextBool()) {
      _swapRows(board, 0, 2);
      _swapRows(board, 1, 3);
    }
    
    // 随机交换2x2子区域列
    if (_random.nextBool()) {
      _swapColumns(board, 0, 2);
      _swapColumns(board, 1, 3);
    }
    
    // 随机重新映射数字
    _remapNumbers(board, 4);
  }
  
  /// 生成2级难度棋盘（6x6数字，1-6数字）
  Map<String, List<List<dynamic>>> _generateLevel2Board() {
    // 生成完整的6x6数独解
    List<List<int>> completedBoard = _generateComplete6x6Board();
    
    // 创建游戏棋盘
    List<List<int>> board = completedBoard.map((row) => row.toList()).toList();
    
    // 随机移除数字，保留20个数字（根据难度设置）
    int totalCells = 6 * 6;
    int cluesToRemove = totalCells - GameDifficulty.level2.initialClues;
    _removeClues(board, 6, cluesToRemove);
    
    // 设置固定位置
    List<List<bool>> isFixed = board.map((row) => 
      row.map((cell) => cell != 0).toList()
    ).toList();
    
    return {'board': board, 'isFixed': isFixed};
  }

  /// 生成完整的6x6数独解
  List<List<int>> _generateComplete6x6Board() {
    // 创建基础模板
    List<List<int>> board = [
      [1, 2, 3, 4, 5, 6],
      [4, 5, 6, 1, 2, 3],
      [2, 3, 1, 6, 4, 5],
      [5, 6, 4, 2, 3, 1],
      [3, 1, 2, 5, 6, 4],
      [6, 4, 5, 3, 1, 2],
    ];
    
    // 随机变换来创建不同的解
    _shuffle6x6Board(board);
    
    return board;
  }

  /// 随机变换6x6数独棋盘
  void _shuffle6x6Board(List<List<int>> board) {
    // 随机交换行（在同一2行子区域内）
    for (int subGrid = 0; subGrid < 3; subGrid++) {
      if (_random.nextBool()) {
        _swapRows(board, subGrid * 2, subGrid * 2 + 1);
      }
    }
    
    // 随机交换列（在同一3列子区域内）
    for (int subGrid = 0; subGrid < 2; subGrid++) {
      int base = subGrid * 3;
      if (_random.nextBool()) {
        _swapColumns(board, base, base + 1);
      }
      if (_random.nextBool()) {
        _swapColumns(board, base + 1, base + 2);
      }
    }
    
    // 随机交换2x3子区域行组
    if (_random.nextBool()) {
      _swapRows(board, 0, 2);
      _swapRows(board, 1, 3);
    }
    if (_random.nextBool()) {
      _swapRows(board, 2, 4);
      _swapRows(board, 3, 5);
    }
    
    // 随机交换2x3子区域列组
    if (_random.nextBool()) {
      _swapColumns(board, 0, 3);
      _swapColumns(board, 1, 4);
      _swapColumns(board, 2, 5);
    }
    
    // 随机重新映射数字
    _remapNumbers(board, 6);
  }
  
  /// 生成标准数独棋盘（1-9数字）
  Map<String, List<List<dynamic>>> _generateStandardBoard(GameDifficulty difficulty) {
    // 生成完整的9x9数独解
    List<List<int>> completedBoard = _generateComplete9x9Board();
    
    // 创建游戏棋盘
    List<List<int>> board = completedBoard.map((row) => row.toList()).toList();
    
    // 根据难度移除不同数量的数字
    int totalCells = 9 * 9;
    int cluesToRemove = totalCells - difficulty.initialClues;
    _removeClues(board, 9, cluesToRemove);
    
    List<List<bool>> isFixed = board.map((row) => 
      row.map((cell) => cell != 0).toList()
    ).toList();
    
    return {'board': board, 'isFixed': isFixed};
  }

  /// 生成完整的9x9数独解
  List<List<int>> _generateComplete9x9Board() {
    // 创建基础模板
    List<List<int>> board = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [4, 5, 6, 7, 8, 9, 1, 2, 3],
      [7, 8, 9, 1, 2, 3, 4, 5, 6],
      [2, 3, 1, 5, 6, 4, 8, 9, 7],
      [5, 6, 4, 8, 9, 7, 2, 3, 1],
      [8, 9, 7, 2, 3, 1, 5, 6, 4],
      [3, 1, 2, 6, 4, 5, 9, 7, 8],
      [6, 4, 5, 9, 7, 8, 3, 1, 2],
      [9, 7, 8, 3, 1, 2, 6, 4, 5],
    ];
    
    // 随机变换来创建不同的解
    _shuffle9x9Board(board);
    
    return board;
  }

  /// 随机变换9x9数独棋盘
  void _shuffle9x9Board(List<List<int>> board) {
    // 随机交换行（在同一3行子区域内）
    for (int subGrid = 0; subGrid < 3; subGrid++) {
      int base = subGrid * 3;
      if (_random.nextBool()) {
        _swapRows(board, base, base + 1);
      }
      if (_random.nextBool()) {
        _swapRows(board, base + 1, base + 2);
      }
    }
    
    // 随机交换列（在同一3列子区域内）
    for (int subGrid = 0; subGrid < 3; subGrid++) {
      int base = subGrid * 3;
      if (_random.nextBool()) {
        _swapColumns(board, base, base + 1);
      }
      if (_random.nextBool()) {
        _swapColumns(board, base + 1, base + 2);
      }
    }
    
    // 随机交换3x3子区域行组
    if (_random.nextBool()) {
      _swapRows(board, 0, 3);
      _swapRows(board, 1, 4);
      _swapRows(board, 2, 5);
    }
    if (_random.nextBool()) {
      _swapRows(board, 3, 6);
      _swapRows(board, 4, 7);
      _swapRows(board, 5, 8);
    }
    
    // 随机交换3x3子区域列组
    if (_random.nextBool()) {
      _swapColumns(board, 0, 3);
      _swapColumns(board, 1, 4);
      _swapColumns(board, 2, 5);
    }
    if (_random.nextBool()) {
      _swapColumns(board, 3, 6);
      _swapColumns(board, 4, 7);
      _swapColumns(board, 5, 8);
    }
    
    // 随机重新映射数字
    _remapNumbers(board, 9);
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
    if (gridSize == 4) {
      // 4x4: 4个2x2子网格
      return _validate4x4SubGrids(board);
    } else if (gridSize == 6) {
      // 6x6: 6个2x3子网格
      return _validate6x6SubGrids(board);
    } else if (gridSize == 9) {
      // 9x9: 9个3x3子网格
      return _validate9x9SubGrids(board);
    }

    return true;
  }

  /// 验证4x4子网格
  bool _validate4x4SubGrids(List<List<int>> board) {
    for (int subRow = 0; subRow < 2; subRow++) {
      for (int subCol = 0; subCol < 2; subCol++) {
        List<int> subGridValues = [];
        for (int r = subRow * 2; r < subRow * 2 + 2; r++) {
          for (int c = subCol * 2; c < subCol * 2 + 2; c++) {
            subGridValues.add(board[r][c]);
          }
        }
        if (!_isValidGroup(subGridValues)) return false;
      }
    }
    return true;
  }

  /// 验证6x6子网格  
  bool _validate6x6SubGrids(List<List<int>> board) {
    for (int subRow = 0; subRow < 3; subRow++) {
      for (int subCol = 0; subCol < 2; subCol++) {
        List<int> subGridValues = [];
        for (int r = subRow * 2; r < subRow * 2 + 2; r++) {
          for (int c = subCol * 3; c < subCol * 3 + 3; c++) {
            subGridValues.add(board[r][c]);
          }
        }
        if (!_isValidGroup(subGridValues)) return false;
      }
    }
    return true;
  }

  /// 验证9x9子网格
  bool _validate9x9SubGrids(List<List<int>> board) {
    for (int subRow = 0; subRow < 3; subRow++) {
      for (int subCol = 0; subCol < 3; subCol++) {
        List<int> subGridValues = [];
        for (int r = subRow * 3; r < subRow * 3 + 3; r++) {
          for (int c = subCol * 3; c < subCol * 3 + 3; c++) {
            subGridValues.add(board[r][c]);
          }
        }
        if (!_isValidGroup(subGridValues)) return false;
      }
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

  /// 交换两行
  void _swapRows(List<List<int>> board, int row1, int row2) {
    List<int> temp = board[row1];
    board[row1] = board[row2];
    board[row2] = temp;
  }

  /// 交换两列
  void _swapColumns(List<List<int>> board, int col1, int col2) {
    for (int row = 0; row < board.length; row++) {
      int temp = board[row][col1];
      board[row][col1] = board[row][col2];
      board[row][col2] = temp;
    }
  }

  /// 随机重新映射数字
  void _remapNumbers(List<List<int>> board, int maxNumber) {
    // 创建数字映射
    List<int> numbers = List.generate(maxNumber, (i) => i + 1);
    numbers.shuffle(_random);
    
    Map<int, int> mapping = {};
    for (int i = 0; i < maxNumber; i++) {
      mapping[i + 1] = numbers[i];
    }
    
    // 应用映射
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] != 0) {
          board[row][col] = mapping[board[row][col]]!;
        }
      }
    }
  }
}