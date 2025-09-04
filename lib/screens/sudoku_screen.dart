import 'package:flutter/material.dart';
import 'dart:async';
import '../models/sudoku_game.dart';
import '../services/sudoku_service.dart';

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
    });
  }

  void _inputNumber(int number) {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        _game = _sudokuService.placeNumber(_game, selectedRow, selectedCol, number);
        selectedNumber = number;
        
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
        // 保存游戏状态
        SudokuService.saveGame(_game);
      });
    }
  }

  void _undoMove() {
    // TODO: 实现撤消功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('撤消功能待实现')),
    );
  }

  void _toggleNoteMode() {
    setState(() {
      isNoteMode = !isNoteMode;
    });
  }

  void _showHint() {
    // 使用智能提示功能选择最容易的格子
    final hint = _sudokuService.getSmartHint(_game);
    if (hint != null) {
      setState(() {
        // 自动选中建议的格子
        selectedRow = hint['row']!;
        selectedCol = hint['col']!;
        isHintSelected = true;  // 标记为提示选中
      });
    }
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('恭喜！'),
          content: Text(
            '游戏完成！\n用时: ${_sudokuService.formatTime(_game.secondsElapsed)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop('completed'); // 返回主界面，标记游戏完成
              },
              child: const Text('返回主页'),
            ),
          ],
        );
      },
    );
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
        title: null,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              // TODO: 打开游戏设置
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 游戏信息栏
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 难度显示
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '难度: ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: _game.difficulty,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 时间显示
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '时间: ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: _sudokuService.formatTime(_game.secondsElapsed),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 使用统一的LayoutBuilder计算棋盘尺寸并限制控件宽度
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 为工具栏和数字键盘预留空间
                    double reservedSpace = 150;
                    double availableHeight = constraints.maxHeight - reservedSpace;
                    
                    // 确保availableHeight不会为负数
                    if (availableHeight < 100) {
                      availableHeight = 100;
                    }
                    
                    // 计算棋盘的实际尺寸，确保不会挤占下方控件空间
                    double availableSize = constraints.maxWidth < availableHeight 
                        ? constraints.maxWidth 
                        : availableHeight;
                    
                    // 基于棋盘占屏幕比例计算间距 - 棋盘越小间距越小
                    double boardRatio = availableSize / constraints.maxHeight;
                    double dynamicSpacing = boardRatio > 0.7 ? 8.0 : (boardRatio > 0.5 ? 12.0 : 16.0);
                    double smallSpacing = boardRatio > 0.7 ? 4.0 : (boardRatio > 0.5 ? 6.0 : 8.0);
                    
                    return Column(
                      children: [
                        // 棋盘区域 - 使用 Flexible 而不是固定尺寸
                        Flexible(
                          child: Center(
                            child: SizedBox(
                              width: availableSize,
                              height: availableSize,
                              child: _buildSudokuGrid(),
                            ),
                          ),
                        ),
                        
                        // 动态间距 - 屏幕窄时自动减小
                        SizedBox(height: dynamicSpacing),
                        
                        // 工具栏 - 宽度不超过棋盘
                        SizedBox(
                          width: availableSize,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, 
                              vertical: 8
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildToolButton(
                                  icon: Icons.undo,
                                  label: '撤消',
                                  onPressed: _undoMove,
                                ),
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
                                  icon: Icons.lightbulb_outline,
                                  label: '提示',
                                  badgeCount: 1,
                                  onPressed: _showHint,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 工具栏和键盘动态间距
                        SizedBox(height: smallSpacing),
                        
                        // 数字输入键盘 - 宽度不超过棋盘
                        SizedBox(
                          width: availableSize,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
    required VoidCallback onPressed,
    bool isActive = false,
    String? activeText,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: isActive && activeText != null
                    ? Text(
                        activeText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(
                        icon,
                        color: Colors.grey[600],
                        size: 20,
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
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
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
        
        return GestureDetector(
          onTap: () => _inputNumber(number),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
        return 28.0;  // 4x4网格较大字体
      case 6:
        return 22.0;  // 6x6网格中等字体
      case 9:
      default:
        return 16.0;  // 9x9网格较小字体
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
    
    // 如果有冲突，显示浅红色背景（最高优先级）
    if (hasConflict) {
      return const Color(0xFFFFE5E5);  // 浅红色背景
    } else if (isSelected) {
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
                        fontWeight: FontWeight.bold,
                        color: _getCellTextColor(globalRow, globalCol),
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
                        fontWeight: FontWeight.bold,
                        color: _getCellTextColor(globalRow, globalCol),
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