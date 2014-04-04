import 'dart:html';
import 'dart:math' as math;
import 'dart:convert' show JSON;

class Piskvorky {
  int _width;
  int _height;
  int _canvasWidth;
  int _canvasHeight;
  int _x;
  int _y;
  int _player;
  int _required_to_win;
  bool _end;
  String _container;
  Element _turn;
  Element _new_game_button;
  CanvasRenderingContext2D _context;
  
  List<List<int>> _board;
  
  Piskvorky(String container, int width, int height, int canvasWidth, int canvasHeight, int toWin) {
    _width = width;
    _height = height;
    _canvasWidth = canvasWidth;
    _canvasHeight = canvasHeight;
    _container = container;
    _player = 1;
    _end = false;
    _required_to_win = toWin;
    
    setupBoard();
    
    _turn = new Element.div();
    _turn.innerHtml = "Player " + _player.toString() + "'s turn.";
    
    _new_game_button = new InputElement(type: "submit");
    _new_game_button.attributes['value'] = "New Game";
    
    addHtml();
    
    _context.canvas.onMouseUp.listen((e) {
      addPoint(e);
    });
    
    _new_game_button.onClick.listen((e) {
      _width = width;
      _height = height;
      _player = 1;
      _end = false;
      _required_to_win = 5;
      
      setupBoard();
      
      _turn.innerHtml = "Player " + _player.toString() + "'s turn.";
      
      draw(new List<Point>());
    });
  }
  
  static void fromJSON(String input) {
    Map json = JSON.decode(input);
    Piskvorky p = new Piskvorky(json["container"], json["cols"], json["rows"], json["width"], json["height"], json["toWin"]);
  }
  
  void setupBoard() {
    _board = new List<List<int>>();
    
    for (int i = 0; i < _height; i++) {
      _board.add(new List<int>());
      for (int j = 0; j < _width; j++) {
        _board[i].add(0);
      }
    }  
  }
  
  void addPoint(MouseEvent e) {
    if (!_end) { 
      Point p = e.offset;
      int i = (p.y / _y).floor();
      int j = (p.x / _x).floor();
      
      if (_board[i][j] == 0) { 
        _board[i][j] = _player;
        List<Point> points = check(i, j);
        
        if (_end) {
          _turn.innerHtml = "Player " + _player.toString() + " wins!";        
        } else {
          changePlayer();
        }
        if ((i == 0) || (i == _board.length - 1) || (j == 0) || (j == _board[i].length-1)) {
          addFields(i, j);
        }
        
        draw(points);
      }
    }
  }
  
  void addFields(int y, int x) {
    bool rowStart = (y == 0);
    bool rowEnd = (y == _board.length - 1);
    bool colStart = (x == 0);
    bool colEnd = (x == _board[y].length - 1);
    
    if (y == 0) {
      _board.insert(0, new List<int>());
      for (int i = 0; i < _width; i++) {
        _board[0].add(0);
      }
      _height++;
    } else if ((y == _board.length - 1) || colStart || colEnd) {
      _board.add(new List<int>());
      for (int i = 0; i < _width; i++) {
        _board[_board.length-1].add(0);
      }
      _height++;
    }
    
    if (x == 0) {
      for (int i = 0; i < _board.length; i++) {
        _board[i].insert(0, 0);
      }
      _width++;
    } else if (x == _board[y].length - 1 || rowStart || rowEnd) {
      for (int i = 0; i < _board.length; i++) {
        _board[i].add(0);
      }
      _width++;
    }
  }
  
  void changePlayer() {
    _player = (_player == 1) ? 2 : 1;
    _turn.innerHtml = "Player " + _player.toString() + "'s turn.";
  }
  
  void addHtml() {
    querySelector(_container)
        ..append(_turn)
        ..append(_new_game_button)
        ..append(generateElement());
  }
  
  List<Point> check(int y, int x) {
    List<Point> winning_points = new List<Point>();
    //horizontally
    winning_points.addAll(checkDirection(y, x, 0, -1));
    winning_points.addAll(checkDirection(y, x, 0, 1));
    //count = checkDirection(y, x, 0, -1) + checkDirection(y, x, 0, 1); 
    if (winning_points.length == _required_to_win - 1) {
      _end = true;
      winning_points.add(new Point(y, x));
      return winning_points;
    }
    
    //vertically
    winning_points = new List<Point>();
    winning_points.addAll(checkDirection(y, x, -1, 0));
    winning_points.addAll(checkDirection(y, x, 1, 0));
    //count = checkDirection(y, x, -1, 0) + checkDirection(y, x, 1, 0); 
    if (winning_points.length == _required_to_win - 1) {
      _end = true;
      winning_points.add(new Point(y, x));
      return winning_points;
    } 
    
    //diagonally 1
    //count = checkDirection(y, x, -1, -1) + checkDirection(y, x, 1, 1); 
    winning_points = new List<Point>();
    winning_points.addAll(checkDirection(y, x, -1, -1));
    winning_points.addAll(checkDirection(y, x, 1, 1));
    if (winning_points.length == _required_to_win - 1) {
      _end = true;
      winning_points.add(new Point(y, x));
      return winning_points;
    }
    
    //diagonally 2
    //count = checkDirection(y, x, -1, 1) + checkDirection(y, x, 1, -1); 
    winning_points = new List<Point>();
    winning_points.addAll(checkDirection(y, x, -1, 1));
    winning_points.addAll(checkDirection(y, x, 1, -1));
    if (winning_points.length == _required_to_win - 1) {
      _end = true;
      winning_points.add(new Point(y, x));
      return winning_points;
    }
    
    winning_points = new List<Point>();
    winning_points.add(new Point(y, x));
    return winning_points;
  }
  
  List<Point> checkDirection(int y, int x, int dy, int dx) {
    List<Point> points = new List<Point>();
    int i = y + dy;
    int j = x + dx;
    if ((i == -1) || (j == -1) || (i == _board.length) || (j == _board[y].length)) {
      return points;
    }
    while (_board[i][j] == _player) {
      points.add(new Point(i, j));
      i += dy;
      j += dx;
      if ((i == -1) || (j == -1) || (i == _board.length) || (j == _board[y].length)) {
        return points;
      }
    }
    return points;
  }
  
  CanvasElement generateElement() {
    CanvasElement canvas = new CanvasElement();
    canvas.width = _canvasWidth;
    canvas.height = _canvasHeight;
    
    _context = canvas.getContext('2d');
    
    _x = (canvas.width / _width).floor();
    _y = (canvas.height / _height).floor();
    for (int i = 0; i < _board.length; i++) {
      for (int j = 0; j < _board[i].length; j++) {
        //context.fillText(this.plocha[i][j].toString(), x*j, y*i);
        //context.fillText((x*j).toString() + " " + (y*i).toString(), x*j, y*i);
        _context.strokeRect(_x*j, _y*i, _x, _y);
      }
    }
    
    return _context.canvas;
  }
  
  void draw(List<Point> points) {
    _x = (_context.canvas.width / _width).floor();
    _y = (_context.canvas.height / _height).floor();
    
    _context.clearRect(0, 0, _context.canvas.width, _context.canvas.height);
    for (int i = 0; i < _board.length; i++) {
        for (int j = 0; j < _board[i].length; j++) {
          _context.strokeStyle = "#000000";
          _context.strokeRect(_x*j, _y*i, _x, _y);
          if (points.any((Point it) => (it.x == i) && (it.y == j))) {
            _context.strokeStyle = "#00AA00";  
          }
          if (_board[i][j] == 1) {
            _context.beginPath();
            _context.arc(_x*j + _x/2, _y*i + _y/2, _x / 3, 0, math.PI*2);
            _context.closePath();
            _context.stroke();
          } if (_board[i][j] == 2) {
            _context.beginPath();
            _context.moveTo(_x*j + _x/5, _y*i + _y/5);
            _context.lineTo(_x*(j+1) - _x/5, _y*(i+1) - _y/5);
            _context.moveTo(_x*(j+1) - _x/5, _y*i + _y/5);
            _context.lineTo(_x*j + _x/5, _y*(i+1) - _y/5);
            _context.closePath();
            _context.stroke();
          }
        }
      }
  }
}

void main() { 
  Piskvorky.fromJSON('{"rows": 15, "cols": 15, "width": 800, "height": 800, "container": "#container", "toWin": 5}');
}
