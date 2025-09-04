import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sudoku_game.dart';
import '../services/sudoku_service.dart';
import '../dialogs/complete_dialog.dart';

class SudokuScreen extends StatefulWidget {
  final String difficulty;
  final bool isResuming;

  const SudokuScreen({
    super.key,
    required this.difficulty,
    this.isResuming = false,
  });

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late SudokuGame _game;
  late SudokuService _sudokuService;
  late Timer _gameTimer;
  
  int selectedRow = -1;
  int selectedCol = -1;
  int selectedNumber = 0;
  bool isNoteMode = false;
  bool isHintSelected = false;  // 标记是否通过提示选中
  bool isCheckMode = false;     // 标记是否在检查模式
  
  @override
  void initState() {
    super.initState();
    _sudokuService = SudokuService();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    if (widget.isResuming) {
      // 尝试加载保存的游戏
      final savedGame = SudokuService.getSavedGame();
      if (savedGame != null) {
        _game = savedGame;
        return;
      }
    }
    
    // 创建新游戏
    GameDifficulty? difficulty = _getDifficultyFromName(widget.difficulty);
    if (difficulty != null) {
      _game = _sudokuService.createNewGame(difficulty);
    } else {
      // 如果找不到对应难度，使用Level 1作为默认值
      _game = _sudokuService.createNewGame(GameDifficulty.level1);
    }
    
    // 保存新创建的游戏
    SudokuService.saveGame(_game);
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _game = _game.copyWith(secondsElapsed: _game.secondsElapsed + 1);
        // 每秒保存游戏状态
        SudokuService.saveGame(_game);
      });
    });
  }

  void _selectCell(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
      isHintSelected = false;  // 手动选择时清除提示标记
      isCheckMode = false;     // 手动选择时退出检查模式
    });
  }

  void _inputNumber(int number) {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        _game = _sudokuService.placeNumber(_game, selectedRow, selectedCol, number);
        selectedNumber = number;
        isCheckMode = false;  // 输入数字时退出检查模式
        
        // 保存游戏状态
        SudokuService.saveGame(_game);
        
        // 检查游戏是否完成
        if (_sudokuService.isGameComplete(_game)) {
          _gameTimer.cancel();
          SudokuService.clearSavedGame(); // 游戏完成时清除保存
          _showGameCompleteDialog();
        }
      });
    }
  }

  void _eraseCell() {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        _game = _sudokuService.eraseCell(_game, selectedRow, selectedCol);
        isCheckMode = false;  // 擦除时退出检查模式
        // 保存游戏状态
        SudokuService.saveGame(_game);
      });
    }
  }

  void _checkGame() {
    if (_game.checkCount <= 0) return; // 防护检查
    
    setState(() {
      isCheckMode = !isCheckMode;  // 切换检查模式
      // 只有在开启检查模式时才消耗次数
      if (isCheckMode) {
        _game = _game.copyWith(checkCount: _game.checkCount - 1);
        SudokuService.saveGame(_game);
      }
    });
  }

  void _toggleNoteMode() {
    setState(() {
      isNoteMode = !isNoteMode;
    });
  }

  void _showHint() {
    if (_game.hintCount <= 0) return; // 防护检查
    
    // 使用智能提示功能选择最容易的格子
    final hint = _sudokuService.getSmartHint(_game);
    if (hint != null) {
      setState(() {
        // 自动选中建议的格子
        selectedRow = hint['row']!;
        selectedCol = hint['col']!;
        isHintSelected = true;  // 标记为提示选中
        // 消耗提示次数
        _game = _game.copyWith(hintCount: _game.hintCount - 1);
        SudokuService.saveGame(_game);
      });
    }
  }

  void _showGameCompleteDialog() {
    GameCompleteDialog.show(context, _game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_game.difficulty}难度',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            // 使用统一的LayoutBuilder计算棋盘尺寸并限制控件宽度
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 棋盘绝对最大化，压缩所有其他空间
                    double reservedSpace = 20; // 极小化预留空间
                    double availableHeight = constraints.maxHeight - reservedSpace;
                    
                    // 确保availableHeight不会为负数
                    if (availableHeight < 200) {
                      availableHeight = 200;
                    }
                    
                    // 计算棋盘尺寸，在宽屏上限制最大尺寸
                    double maxBoardSize = availableHeight * 0.7; // 限制棋盘为可用高度的70%
                    double availableSize = constraints.maxWidth < maxBoardSize 
                        ? constraints.maxWidth 
                        : maxBoardSize;
                    
                    // 调整间距以适应不同屏幕尺寸
                    double dynamicSpacing = 16.0;
                    double smallSpacing = 12.0;
                    
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 棋盘区域和时间显示 - 确保居中
                        Center(
                          child: SizedBox(
                            width: availableSize,
                            child: Column(
                            children: [
                              // 时间显示在棋盘上方右侧
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: '时间: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text: _sudokuService.formatTime(_game.secondsElapsed),
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: [FontFeature.tabularFigures()],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // 棋盘
                              Center(
                                child: SizedBox(
                                  width: availableSize,
                                  height: availableSize,
                                  child: _buildSudokuGrid(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                        
                        // 动态间距 - 屏幕窄时自动减小
                        SizedBox(height: dynamicSpacing),
                        
                        // 工具栏 - 紧凑布局
                        Container(
                          width: availableSize,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0, 
                            vertical: 16
                          ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildToolButton(
                                  icon: Icons.brush,
                                  label: '擦除',
                                  onPressed: _eraseCell,
                                ),
                                _buildToolButton(
                                  icon: Icons.edit,
                                  label: '备注',
                                  isActive: isNoteMode,
                                  activeText: 'OFF',
                                  onPressed: _toggleNoteMode,
                                ),
                                _buildToolButton(
                                  icon: Icons.check_circle_outline,
                                  label: '检查',
                                  badgeCount: _game.checkCount,
                                  onPressed: _game.checkCount > 0 ? _checkGame : null,
                                ),
                                _buildToolButton(
                                  icon: Icons.lightbulb_outline,
                                  label: '提示',
                                  badgeCount: _game.hintCount,
                                  onPressed: _game.hintCount > 0 ? _showHint : null,
                                ),
                              ],
                            ),
                        ),
                        
                        // 工具栏和键盘动态间距
                        SizedBox(height: smallSpacing),
                        
                        // 数字输入键盘 - 居中紧凑布局
                        Flexible(
                          child: Container(
                            width: availableSize,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 20),
                            child: _buildNumberKeyboard(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildToolButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isActive = false,
    String? activeText,
    int? badgeCount,
  }) {
    bool isDisabled = onPressed == null;
    
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isDisabled ? Colors.grey[300] : Colors.grey[200],
                  child: isActive && activeText != null
                      ? Text(
                          activeText,
                          style: TextStyle(
                            color: isDisabled ? Colors.grey[400] : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Icon(
                          icon,
                          color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                          size: 28,
                        ),
                ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数字键盘，根据游戏难度显示不同数量的数字
  Widget _buildNumberKeyboard() {
    GameDifficulty? difficulty = _getDifficultyFromName(_game.difficulty);
    int numberRange = difficulty?.numberRange ?? 9;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(numberRange, (index) {
        int number = index + 1;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => _inputNumber(number),
            child: Container(
              height: 55,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    color: Colors.blue,
                    fontFamily: 'SF Pro Display',
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
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

  /// 判断单元格是否需要高亮显示
  bool _isHighlightedCell(int row, int col) {
    if (selectedRow == -1 || selectedCol == -1) return false;
    
    // 高亮同行、同列的单元格
    if (row == selectedRow || col == selectedCol) return true;
    
    // 高亮同子区域的单元格
    if (_isInSameSubRegion(row, col, selectedRow, selectedCol)) return true;
    
    // 如果选中的单元格有数字，高亮棋盘上所有相同数字的单元格
    int selectedNumber = _game.board[selectedRow][selectedCol];
    if (selectedNumber != 0 && _game.board[row][col] == selectedNumber) {
      return true;
    }
    
    return false;
  }
  
  /// 判断是否为相同数字且非当前选中单元格（用于深色背景）
  bool _isSameNumberCell(int row, int col) {
    if (selectedRow == -1 || selectedCol == -1) return false;
    if (row == selectedRow && col == selectedCol) return false; // 排除当前选中的单元格
    
    int selectedNumber = _game.board[selectedRow][selectedCol];
    return selectedNumber != 0 && _game.board[row][col] == selectedNumber;
  }

  /// 判断两个单元格是否在同一子区域
  bool _isInSameSubRegion(int row1, int col1, int row2, int col2) {
    switch (_game.gridSize) {
      case 4:
        // 2x2子区域
        return (row1 ~/ 2 == row2 ~/ 2) && (col1 ~/ 2 == col2 ~/ 2);
      case 6:
        // 2x3子区域（6x6数独有6个2x3子区域，排列为3行2列）
        return (row1 ~/ 2 == row2 ~/ 2) && (col1 ~/ 3 == col2 ~/ 3);
      case 9:
      default:
        // 3x3子区域
        return (row1 ~/ 3 == row2 ~/ 3) && (col1 ~/ 3 == col2 ~/ 3);
    }
  }



  /// 获取自适应字体大小
  double _getCellFontSize() {
    switch (_game.gridSize) {
      case 4:
        return 52.0;  // 4x4网格适中大字体
      case 6:
        return 38.0;  // 6x6网格适中大字体
      case 9:
      default:
        return 30.0;  // 9x9网格适中大字体
    }
  }
  
  /// 获取单元格文本颜色
  Color _getCellTextColor(int row, int col) {
    // 如果是固定数字，显示黑色
    if (_game.isFixed[row][col]) {
      return Colors.black;
    }
    
    // 用户输入的数字显示蓝色
    return Colors.blue;
  }
  
  /// 获取单元格背景颜色
  Color _getCellBackgroundColor(int row, int col) {
    bool isSelected = row == selectedRow && col == selectedCol;
    bool isHighlighted = _isHighlightedCell(row, col);
    bool isSameNumber = _isSameNumberCell(row, col);
    bool hasConflict = _sudokuService.hasConflict(_game, row, col);
    
    // 检查模式：显示输入格子的冲突状态
    if (isCheckMode && _game.board[row][col] != 0 && !_game.isFixed[row][col]) {
      if (hasConflict) {
        return const Color(0xFFFFCCCC);  // 红色背景：有冲突的输入格子
      } else {
        return const Color(0xFFCCFFCC);  // 绿色背景：没有冲突的输入格子
      }
    }
    
    // 正常模式：不显示冲突红色背景
    if (isSelected) {
      // 如果是通过提示选中的，显示特殊的绿色高亮
      if (isHintSelected) {
        return const Color(0xFFE8F5E8);  // 浅绿色背景，表示智能提示
      } else {
        return const Color(0xFFBBDEFB);  // 当前选中单元格的浅蓝色
      }
    } else if (isSameNumber) {
      return const Color(0xFF81C4E7);  // 相同数字的中等蓝色背景，匹配截图
    } else if (isHighlighted) {
      return const Color(0xFFE3F2FD);  // 其他高亮区域的非常浅的蓝色
    } else {
      return Colors.white;
    }
  }

  /// 构建数独网格，包含正确的边框样式
  Widget _buildSudokuGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _buildSubGridLayout(),
      ),
    );
  }

  /// 构建子网格布局
  Widget _buildSubGridLayout() {
    if (_game.gridSize == 6) {
      return _build6x6Grid();
    }
    
    int subGridSize = _getSubGridSize();
    int subGridCount = _game.gridSize ~/ subGridSize;

    return Column(
      children: List.generate(subGridCount, (subGridRow) {
        return Expanded(
          child: Row(
            children: List.generate(subGridCount, (subGridCol) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: subGridCol < subGridCount - 1 
                          ? const BorderSide(color: Colors.black, width: 2)
                          : BorderSide.none,
                      bottom: subGridRow < subGridCount - 1
                          ? const BorderSide(color: Colors.black, width: 2)
                          : BorderSide.none,
                    ),
                  ),
                  child: _buildSubGrid(subGridRow, subGridCol),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  /// 专门为6x6网格构建布局（3行2列的2x3子网格）
  Widget _build6x6Grid() {
    return Column(
      children: [
        // 第1行：2个子网格
        Expanded(
          child: Row(
            children: [
              // 左上子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black, width: 2),
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(0, 0),
                ),
              ),
              // 右上子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(0, 1),
                ),
              ),
            ],
          ),
        ),
        // 第2行：2个子网格
        Expanded(
          child: Row(
            children: [
              // 左中子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black, width: 2),
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(1, 0),
                ),
              ),
              // 右中子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(1, 1),
                ),
              ),
            ],
          ),
        ),
        // 第3行：2个子网格
        Expanded(
          child: Row(
            children: [
              // 左下子网格 (2x3)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: _build2x3SubGrid(2, 0),
                ),
              ),
              // 右下子网格 (2x3)
              Expanded(
                flex: 3,
                child: _build2x3SubGrid(2, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建2x3子网格
  Widget _build2x3SubGrid(int subGridRow, int subGridCol) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemCount: 6, // 2x3 = 6个单元格
      itemBuilder: (context, index) {
        int localRow = index ~/ 3;
        int localCol = index % 3;
        
        int globalRow = subGridRow * 2 + localRow;
        int globalCol = subGridCol * 3 + localCol;
        
        return GestureDetector(
          onTap: () => _selectCell(globalRow, globalCol),
          child: Container(
            decoration: BoxDecoration(
              color: _getCellBackgroundColor(globalRow, globalCol),
              border: Border(
                right: localCol < 2
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
                bottom: localRow < 1
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: _game.board[globalRow][globalCol] != 0
                  ? Text(
                      _game.board[globalRow][globalCol].toString(),
                      style: TextStyle(
                        fontSize: _getCellFontSize(),
                        fontWeight: FontWeight.w400,
                        color: _getCellTextColor(globalRow, globalCol),
                        fontFamily: 'SF Pro Display',
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  /// 构建单个子网格
  Widget _buildSubGrid(int subGridRow, int subGridCol) {
    int subGridSize = _getSubGridSize();
    
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: subGridSize,
        childAspectRatio: 1.0,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemCount: subGridSize * subGridSize,
      itemBuilder: (context, index) {
        int localRow = index ~/ subGridSize;
        int localCol = index % subGridSize;
        
        int globalRow = subGridRow * subGridSize + localRow;
        int globalCol = subGridCol * subGridSize + localCol;
        
        return GestureDetector(
          onTap: () => _selectCell(globalRow, globalCol),
          child: Container(
            decoration: BoxDecoration(
              color: _getCellBackgroundColor(globalRow, globalCol),
              border: Border(
                right: localCol < subGridSize - 1
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
                bottom: localRow < subGridSize - 1
                    ? BorderSide(color: Colors.grey[400]!, width: 0.5)
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: _game.board[globalRow][globalCol] != 0
                  ? Text(
                      _game.board[globalRow][globalCol].toString(),
                      style: TextStyle(
                        fontSize: _getCellFontSize(),
                        fontWeight: FontWeight.w400,
                        color: _getCellTextColor(globalRow, globalCol),
                        fontFamily: 'SF Pro Display',
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  /// 获取子网格大小
  int _getSubGridSize() {
    switch (_game.gridSize) {
      case 4: return 2;  // 4x4 使用 2x2 子网格
      case 6: return 2;  // 6x6 使用 2x3 子网格（需要特殊处理）
      case 9: return 3;  // 9x9 使用 3x3 子网格
      default: return 3;
    }
  }
}