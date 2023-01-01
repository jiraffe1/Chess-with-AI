/*
CHESS by HAZZZA https://openprocessing.org/user/224122
 
 Thanks to:
 Sebastian Lague - for his amazing chess video https://www.youtube.com/watch?v=U4ogK0MIzqk
 Rohan Mitra - his chess game was the inspiration for this project https://openprocessing.org/sketch/309165
 
 
 NOW WITH A SELECTION OF AI PLAYERS TO PLAY AGAINST
 
 - all of them are bad
 
 
 */

//define a bitboard
int[][] board;

int[] lightSquareColour = {237, 174, 107};
int[] darkSquareColour = {122, 73, 21};
int[] lastMoveColour1 = {50, 255, 50, 40};
int[] lastMoveColour2 = {50, 255, 50, 60};
int[] selectedSquareColour = {0, 150, 255, 50};
int[] possibleMovesColour = {255, 0, 0, 60};

int squareSize = 100;

// last 3 bits indicate type
final int None = 0;
final int Pawn = 1;
final int Knight = 2;
final int Bishop = 3;
final int Rook = 4;
final int Queen = 5;
final int King = 6;
// first 2 bits indicate colour
final int White = 8;
final int Black = 16;

int turn = White;

PImage WPawn;
PImage WKnight;
PImage WBishop;
PImage WRook;
PImage WQueen;
PImage WKing;

PImage BPawn;
PImage BKnight;
PImage BBishop;
PImage BRook;
PImage BQueen;
PImage BKing;

// square that a player clicked on
coordinate selectedSquare = null;

//for castling
boolean WKingMoved = false;
boolean BKingMoved = false;
boolean WQRookMoved = false;//white queenside rook
boolean WKRookMoved = false;//white kingside rook
boolean BQRookMoved = false;//black queenside rook
boolean BKRookMoved = false;//black kingside rook

//previous move made(for en passant)
coordinate pMove1 = null;
coordinate pMove2 = null;

boolean promotion = false;
coordinate promotionPosition = null;

int movesMade = 0;

boolean menu = true;

int whitePlayerMenuIndex = 0;
int blackPlayerMenuIndex = 1;

String[] playerOptions = {"Player", "Easy AI", "Minimax 4 ply (AI)\nEasy", "Minimax 5 ply (AI)\nStill Easy", "2 ply (AI)\nBad", "3 ply (AI)\nQuite bad", "Random Move", "Materialistic (AI)\nBad", "Swarm (AI)\nBad", "Minimise opponent moves (AI)"};
int playerOptionsLength = 10;

IntList piecesTaken = new IntList();

String[] files = {"a", "b", "c", "d", "e", "f", "g", "h", };
String[] ranks = {"8", "7", "6", "5", "4", "3", "2", "1", };
String[] pieceAlgebra = {"N", "B", "R", "Q", "K"};

String gameString = "";

void setup() {
  //load piece images
  WPawn = loadImage("images/PawnW.png");
  WKnight = loadImage("images/KnightW.png");
  WBishop = loadImage("images/BishopW.png");
  WRook = loadImage("images/RookW.png");
  WQueen = loadImage("images/QueenW.png");
  WKing = loadImage("images/KingW.png");

  BPawn = loadImage("images/PawnB.png");
  BKnight = loadImage("images/KnightB.png");
  BBishop = loadImage("images/BishopB.png");
  BRook = loadImage("images/RookB.png");
  BQueen = loadImage("images/QueenB.png");
  BKing = loadImage("images/KingB.png");

  WPawn.resize(squareSize, squareSize);
  WKnight.resize(squareSize, squareSize);
  WBishop.resize(squareSize, squareSize);
  WRook.resize(squareSize, squareSize);
  WQueen.resize(squareSize, squareSize);
  WKing.resize(squareSize, squareSize);

  BPawn.resize(squareSize, squareSize);
  BKnight.resize(squareSize, squareSize);
  BBishop.resize(squareSize, squareSize);
  BRook.resize(squareSize, squareSize);
  BQueen.resize(squareSize, squareSize);
  BKing.resize(squareSize, squareSize);

  size(1000, 800);
  board = new int[8][8];
  setupBoard();

  displayBoard();
  displayMenu();
}

void changeTurn() {
  turn = turn == White ? Black : White; //alternate
}

void draw() {

  if (!menu) {
    if (checkForGameOver(board, turn) == "") {
      if (turn == White && !promotion && frameCount % 2 == 0) {
        switch(whitePlayerMenuIndex) {
        case 1:
          strategyMove(White);
          displayBoard();
          break;
        case 2:
          negamaxPlayer(White, 4);
          displayBoard();
          break;
        case 3:
          negamaxPlayer(White, 5);
          displayBoard();
          break;
        case 4:
          minimax2Move(White, 2);
          displayBoard();
          break;
        case 5:
          minimax2Move(White, 3);
          displayBoard();
          break;
        case 6:
          randomMove(White);
          displayBoard();
          break;

        case 7:
          materialMove(White);
          displayBoard();
          break;
        case 8:
          swarmMove(White);
          displayBoard();
          break;
         case 9:
         restrictOpponent(White);
         displayBoard();
         break;
        
        }
      }
      if (turn == Black && !promotion && frameCount % 2 != 0) {
        switch(blackPlayerMenuIndex) {
        case 1:
          strategyMove(Black);
          displayBoard();
          break;
        case 2:
          negamaxPlayer(Black, 4);
          displayBoard();
          break;
        case 3:
          negamaxPlayer(Black, 5);
          displayBoard();
          break;
        case 4:
          minimax2Move(Black, 2);
          displayBoard();
          break;
        case 5:
          minimax2Move(Black, 3);
          displayBoard();
          break;
        case 6:
          randomMove(Black);
          displayBoard();
          break;

        case 7:
          materialMove(Black);
          displayBoard();
          break;
        case 8:
          swarmMove(Black);
          displayBoard();
          break;
           case 9:
         restrictOpponent(Black);
         displayBoard();
         break;
        }
      }
    }
  }
}

void mousePressed() {
  if (menu) {
    if (dist(mouseX, mouseY, 225, 325) < 25) {
      whitePlayerMenuIndex -= 1;
      if (whitePlayerMenuIndex < 0) {
        whitePlayerMenuIndex = playerOptionsLength - 1;
      }
    } else if (dist(mouseX, mouseY, 475, 325) < 25) {
      whitePlayerMenuIndex += 1;
      if (whitePlayerMenuIndex >= playerOptionsLength) {
        whitePlayerMenuIndex = 0;
      }
    } else if (dist(mouseX, mouseY, 525, 325) < 25) {
      blackPlayerMenuIndex -= 1;
      if (blackPlayerMenuIndex < 0) {
        blackPlayerMenuIndex = playerOptionsLength - 1;
      }
    } else if (dist(mouseX, mouseY, 775, 325) < 25) {
      blackPlayerMenuIndex += 1;
      if (blackPlayerMenuIndex >= playerOptionsLength) {
        blackPlayerMenuIndex = 0;
      }
    } else if (dist(mouseX, mouseY, 500, 475) < 75) {
      setupBoard();
      menu = false;
    } else if (dist(mouseX, mouseY, 650, 475) < 50) {
      menu = false;
    }

    displayBoard();
    displayMenu();
  } else {
    if (promotion) {
      changeTurn();
      int choice = floor(mouseX / (width / 4));
      if (choice == 0) {
        board[promotionPosition.i][promotionPosition.j] = turn | Queen;
        gameString += "Q";
      }
      if (choice == 1) {
        board[promotionPosition.i][promotionPosition.j] = turn | Rook;
        gameString += "R";
      }
      if (choice == 2) {
        board[promotionPosition.i][promotionPosition.j] = turn | Bishop;
        gameString += "B";
      }
      if (choice == 3) {
        board[promotionPosition.i][promotionPosition.j] = turn | Knight;
        gameString += "N";
      }
      changeTurn();
      promotion = false;
    } else {
      coordinate klc = locateKing(board, White);
      if (selectedSquare == null) {
        if (mouseX > 0 && mouseX < 800 && mouseY > 0 && mouseY < 800) {
          selectedSquare = new coordinate(floor(mouseX / squareSize), floor(mouseY / squareSize));
          displayBoard();
        }
      } else {
        ArrayList<move> moves = movesFromSquare(board, selectedSquare, turn);
        for (move m : moves) {
          if (floor(mouseX / squareSize) == m.i2 && floor(mouseY / squareSize) == m.j2) {
            //make the move
            int[][] temp = makeUpdatingMove(board, m.i1, m.j1, m.i2, m.j2);
            board = temp;
            selectedSquare = null;
            changeTurn();
            displayBoard();
            break;
          }
        }
        selectedSquare = null;
      }
    }


    if (checkForGameOver(board, turn) != "" && dist(mouseX, mouseY, 900, height/2 + 100) < 100) {
      setupBoard();
    }

    displayBoard();
  }

  if (dist(mouseX, mouseY, 900, 300) < 50) {
    menu = true;
    displayBoard();
    displayMenu();
  }
  if (!menu)displayBoard();
}

void displayMenu() {
  push();
  fill(100);
  stroke(10);
  strokeWeight(5);
  rectMode(CENTER);
  rect(width/2, height/2, 600, 400);

  fill(255);
  stroke(0);
  strokeWeight(2);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("White", 350, 250);
  text("Black", 650, 250);

  fill(0);
  stroke(0);
  rect(350, 325, 200, 50);
  rect(650, 325, 200, 50);

  fill(50, 100);
  noStroke();
  circle(225, 325, 50);
  circle(475, 325, 50);
  circle(525, 325, 50);
  circle(775, 325, 50);

  circle(500, 475, 150);
  circle(650, 475, 100);

  fill(255);
  stroke(255);
  text(playerOptions[whitePlayerMenuIndex], 350, 325);
  text(playerOptions[blackPlayerMenuIndex], 650, 325);

  text("<", 225, 325);
  text(">", 475, 325);
  text("<", 525, 325);
  text(">", 775, 325);
  text("New Game", 500, 475);
  text("Exit", 650, 475);

  pop();
}

int numberOfPieces(int[][] b) {
  int count = 0;
  for (int j = 0; j < 8; j++) {
    for (int i = 0; i < 8; i++) {
      if (b[i][j] != None) {
        count++;
      }
    }
  }
  return count;
}

int numberOfPiecesColour(int[][] b, int c) {
  int count = 0;
  for (int j = 0; j < 8; j++) {
    for (int i = 0; i < 8; i++) {
      if (b[i][j] != None) {
        if ((b[i][j] >> 3) * 8 == c) count++;
      }
    }
  }
  return count;
}

String checkForGameOver(int[][] b, int t) {
  HashMap<coordinate, coordinate> moves = generateLegalMoves(b, t);
  if (moves.size() == 0) {
    if (isCheck(b, t)) {
      return "CHECKMATE";
    } else {
      return "STALEMATE";
    }
  }
  if (numberOfPieces(b) == 2) {
    return "STALEMATE";
  }

  return "";
}

int[][] makeUpdatingMove(int[][] b, int i1, int j1, int i2, int j2) {
  movesMade++;
  gameString += " ";
  boolean capture = false;
  int castle = 0;
  //kingside = 1, queenside = 2



  if (b[i2][j2] != None) {
    piecesTaken.append(b[i2][j2]);
    capture = true;
  }
  int[][] temp = makeMove(b, i1, j1, i2, j2);
  if (selectedPiece(selectedSquare) == (White | King)) {
    WKingMoved = true;
    if (i1 == 4 && i2 == 6) {
      castle = 1;
    }
    if (i1 == 4 && i2 == 2) {
      castle = 2;
    }
  }
  if (selectedPiece(selectedSquare) == (Black | King)) {
    BKingMoved = true;
    if (i1 == 4 && i2 == 6) {
      castle = 1;
    }
    if (i1 == 4 && i2 == 2) {
      castle = 2;
    }
  }
  if (selectedPiece(selectedSquare) == (White | Rook) && i1 == 0) {
    WQRookMoved = true;
  }
  if (selectedPiece(selectedSquare) == (White | Rook) && i1 == 7) {
    WKRookMoved = true;
  }
  if (selectedPiece(selectedSquare) == (Black | Rook) && i1 == 0) {
    BQRookMoved = true;
  }
  if (selectedPiece(selectedSquare) == (Black | Rook) && i1 == 7) {
    BKRookMoved = true;
  }
  if (i2 == 0 && j2 == 0) {
    BQRookMoved = true;
  }
  if (i2 == 7 && j2 == 0) {
    BKRookMoved = true;
  }
  if (i2 == 0 && j2 == 7) {
    WQRookMoved = true;
  }
  if (i2 == 7 && j2 == 7) {
    WKRookMoved = true;
  }
  pMove1 = new coordinate(i1, j1);
  pMove2 = new coordinate(i2, j2);

  if (j2 == (turn == White ? 0 : 7) && (selectedPiece(selectedSquare) == (White | Pawn) || selectedPiece(selectedSquare) == (Black | Pawn))) { //promotion
    promotion = true;
    promotionPosition = new coordinate(i2, j2);
  }
  if (movesMade % 2 != 0) {
    gameString += str((movesMade + 1) / 2) + ". ";
  }
  if (castle == 0) {


    if (b[i1][j1] % 8 >= 2) {
      gameString += pieceAlgebra[(b[i1][j1] % 8) - 2];

      if (b[i1][j1] != King) {
        if (pieceInSameFile(b[i1][j1], i1, b, i2, j2)) {
          gameString += ranks[j1];
        } else {
          gameString += files[i1];
        }
      }
    }


    if (capture && b[i1][j1] % 8 != Pawn) {
      gameString += "x";
    } else if (capture) {
      gameString += files[i1];
      gameString += "x";
    }

    gameString += files[i2];
    gameString += ranks[j2];

    if (b[i1][j1] % 8 == Pawn && (j2 == 0 || j2 == 7)) {
      gameString += "=";
    }
  } else if (castle == 1) {
    gameString += "O-O";
  } else if (castle == 2) {
    gameString += "O-O-O";
  }
  if (checkForGameOver(temp, White) == "CHECKMATE" ||checkForGameOver(temp, Black) == "CHECKMATE") {
    gameString += "#";
    if (turn == White) {
      gameString += " 1-0";
    } else {
      gameString += " 0-1";
    }
  } else if (isCheck(temp, White) || isCheck(temp, Black)) {
    gameString += "+";
  }



  if (checkForGameOver(temp, White) == "STALEMATE" ||checkForGameOver(temp, Black) == "STALEMATE") {
    gameString += " 1/2-1/2";
  }


  print("\nPGN: " + gameString);
  int startTime = millis();
  //print("\nNegamax evaluation: " + negamax(board, 4, Integer.MIN_VALUE, Integer.MAX_VALUE, turn, 4));
  //print("\nTime taken: " + str(millis() - startTime) + "ms");
  return temp;
}

boolean pieceInSameRank(int type, int rank, int[][] boardState, int i2, int j2) {
  int piecesOfType = 0;

  for (int file = 0; file < 8; file++) {
    if (boardState[file][rank] == type) {
      ArrayList<move> movesFromPiece = movesFromSquare(boardState, new coordinate(file, rank), turn);
      for (move m : movesFromPiece) {
        if (m.i2 == i2 && m.j2 == j2) {
          piecesOfType ++;
        }
      }
    }
  }

  return piecesOfType >= 2;
}

boolean pieceInSameFile(int type, int file, int[][] boardState, int i2, int j2) {
  int piecesOfType = 0;

  for (int rank = 0; rank < 8; rank++) {
    if (boardState[file][rank] == type) {
      ArrayList<move> movesFromPiece = movesFromSquare(boardState, new coordinate(file, rank), turn);
      for (move m : movesFromPiece) {
        if (m.i2 == i2 && m.j2 == j2) {
          piecesOfType ++;
        }
      }
    }
  }

  return piecesOfType >= 2;
}


coordinate locateKing(int[][] boardState, int kingColour) {
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      if (boardState[i][j] == (kingColour | King)) {
        return new coordinate(i, j);
      }
    }
  }

  return new coordinate(11111, 11111);
}

boolean isCheck(int[][] boardState, int kingColour) {
  HashMap<coordinate, coordinate> pseudoLegal = generatePseudoLegalMoves(boardState, otherColour(kingColour));
  coordinate kingLocation = locateKing(boardState, kingColour);
  for (coordinate c : pseudoLegal.values()) {
    if (c.i == kingLocation.i && c.j == kingLocation.j

      ) {
      //the king is being targeted by an enemy piece
      return true;
    }
  }

  return false;
}

HashMap<coordinate, coordinate> generateLegalMoves(int[][] boardState, int colour) {
  HashMap<coordinate, coordinate> pseudoLegal = generatePseudoLegalMoves(boardState, colour);
  HashMap<coordinate, coordinate> legalMoves = new HashMap<coordinate, coordinate>();

  for (coordinate c1 : pseudoLegal.keySet()) {
    //generate all pseudo legal moves but discard ones where i move into check
    coordinate c2 = pseudoLegal.get(c1);
    int[][] nb = makeMove(boardState, c1.i, c1.j, c2.i, c2.j);

    if (boardState[c1.i][c1.j] == (White | King) || boardState[c1.i][c1.j] == (Black | King) && !isCheck(boardState, colour)) {
      if (abs(c1.i - c2.i) == 2) {//castling
        if (!isCheck(makeMove(boardState, c1.i, c1.j, (c1.i + c1.j) / 2, c2.j), (boardState[c1.i][c1.j] >> 3) * 8) && !isCheck(boardState, (boardState[c1.i][c1.j] >> 3) * 8)) {
          legalMoves.put(new coordinate(c1.i, c1.j), new coordinate(c2.i, c2.j));
        }
      } else if (!isCheck(nb, colour)) {
        legalMoves.put(new coordinate(c1.i, c1.j), new coordinate(c2.i, c2.j));
      }
    } else if (!isCheck(nb, colour)) {
      legalMoves.put(new coordinate(c1.i, c1.j), new coordinate(c2.i, c2.j));
    }
  }


  return legalMoves;
}

int otherColour(int c) {
  return(c==White ? Black : White);
}

//-------source-------destination
HashMap<coordinate, coordinate> generatePseudoLegalMoves(int[][] boardState, int colour) {
  HashMap<coordinate, coordinate> moves = new HashMap<coordinate, coordinate>();

  for (var j = 0; j < 8; j++) {
    for (var i = 0; i < 8; i++) {
      int pieceAt = boardState[i][j];

      if (pieceAt != None) {
        //if there is a piece there find its colour
        int pieceColour = (pieceAt >> 3) << 3; //shift 3 bits to get 1st 2 bits indicating colour
        int pieceType = pieceAt - pieceColour;

        if (pieceColour == colour) {
          if (pieceType == Pawn) {
            int direction = pieceColour == White ? -1 : 1;

            if (j != (pieceColour == White ? 0 : 7)) { //not on the back rank
              if (boardState[i][j + direction] == None) { //empty square in front
                //push pawn
                moves.put(new coordinate(i, j), new coordinate(i, j + direction));
                if (j != (pieceColour == White ? 1 : 6)) {//advance 2 ssquare
                  if (boardState[i][j + direction * 2] == None && j == (pieceColour == White ? 6 : 1)) {
                    moves.put(new coordinate(i, j), new coordinate(i, j + direction * 2));
                  }
                }
              }
              if (i != 7) {
                if (enemyPiece(boardState, i + 1, j + direction, pieceColour)) {
                  moves.put(new coordinate(i, j), new coordinate(i + 1, j + direction));
                }
                if (boardState[i+1][j] == (otherColour(pieceColour) | Pawn)) {//opposite coloured pawn
                  if (pMove1 != null) {
                    if (abs(pMove1.j - pMove2.j) == 2 && pMove2.j == (pieceColour == White ? 3 : 4)) {
                      //en passant


                      moves.put(new coordinate(i, j), new coordinate(i + 1, j + direction));
                    }
                  }
                }
              }
              if (i != 0) {
                if (enemyPiece(boardState, i - 1, j + direction, pieceColour)) {
                  moves.put(new coordinate(i, j), new coordinate(i - 1, j + direction));
                }
                if (boardState[i-1][j] == (otherColour(pieceColour) | Pawn)) {//opposite coloured pawn
                  if (pMove1 != null) {
                    if (abs(pMove1.j - pMove2.j) == 2 && pMove2.j == (pieceColour == White ? 3 : 4)) {
                      //en passant
                      moves.put(new coordinate(i, j), new coordinate(i - 1, j + direction));
                    }
                  }
                }
              }
            }
          }
          if (pieceType == Rook || pieceType == Queen) { //orthogon al
            int iDirection = 0;
            int jDirection = 1;
            //DOWN
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
            //UP
            iDirection = 0;
            jDirection = -1;
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
            //RIGHT
            iDirection = 1;
            jDirection = 0;
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
            //LEFT
            iDirection = -1;
            jDirection = 0;
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
          }
          if (pieceType == Bishop || pieceType == Queen) { //diagonal
            int iDirection = 1;
            int jDirection = 1;
            //right down
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
            //RIGHTY UP
            iDirection = 1;
            jDirection = -1;
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
            //lEFT UP
            iDirection = -1;
            jDirection = -1;
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (emptySquare(boardState, ni, nj)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
            //LEFT DOWN
            iDirection = -1;
            jDirection = 1;
            for (int r = 1; r < 8; r++) {
              int ni = i + (r * iDirection);
              int nj = j + (r * jDirection);
              if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
                break;
              }
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
                break;
              }
              if (boardState[ni][nj] != None && !enemyPiece(boardState, ni, nj, pieceColour)) {
                //it's not empty and it's not an enemy therefore it has to be one of my own pieces
                break;
              }
            }
          }
          if (pieceType == King) {
            int iDirection = 1;
            int jDirection = 1;
            //right down
            int ni = i + iDirection;
            int nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            iDirection = 0;
            jDirection = 1;
            //down
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            //left down
            iDirection = -1;
            jDirection = 1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            //left
            iDirection = -1;
            jDirection = 0;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            //left up
            iDirection = -1;
            jDirection = -1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            //up
            iDirection = 0;
            jDirection = -1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            //right up
            iDirection = 1;
            jDirection = -1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            //right
            iDirection = 1;
            jDirection = 0;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            //CASTLING

            if (pieceColour == White) {
              //kingside
              if (boardState[5][7] == None && boardState[6][7] == None) {
                if (!WKingMoved && !WKRookMoved) {
                  moves.put(new coordinate(4, 7), new coordinate(6, 7));
                }
              }
              //queenside
              if (boardState[3][7] == None && boardState[2][7] == None && boardState[1][7] == None) {
                if (!WKingMoved && !WQRookMoved) {
                  moves.put(new coordinate(4, 7), new coordinate(2, 7));
                }
              }
            } else {
              //kingside
              if (boardState[5][0] == None && boardState[6][0] == None) {
                if (!BKingMoved && !BKRookMoved) {
                  moves.put(new coordinate(4, 0), new coordinate(6, 0));
                }
              }
              //queenside
              if (boardState[3][0] == None && boardState[2][0] == None && boardState[1][0] == None) {
                if (!BKingMoved && !BQRookMoved) {
                  moves.put(new coordinate(4, 0), new coordinate(2, 0));
                }
              }
            }
          }
          if (pieceType == Knight) {
            int iDirection = 1;
            int jDirection = -2;

            int ni = i + iDirection;
            int nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            iDirection = 2;
            jDirection = -1;

            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }

            iDirection = 2;
            jDirection = 1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
            iDirection = 1;
            jDirection = 2;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }

            iDirection = -1;
            jDirection = 2;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }

            iDirection = -2;
            jDirection = 1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }

            iDirection = -2;
            jDirection = -1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }

            iDirection = -1;
            jDirection = -2;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.put(new coordinate(i, j), new coordinate(ni, nj));
              }
            }
          }
        }
      }
    }
  }

  return moves;
}

boolean emptySquare(int[][] b, int i, int j) {
  return b[i][j] == None;
}

boolean enemyPiece(int[][] b, int i, int j, int friendly) {
  if (pieceColour(b[i][j]) != friendly && b[i][j] != None) {
    return true;
  }
  return false;
}

int[][] makeMove(int[][] b, int i1, int j1, int i2, int j2) { //board, start position, end position
  int[][] newBoard = new int[8][8];
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      newBoard[i][j] = b[i][j];
    }
  }
  if (newBoard[i1][j1] == (White | King)) {
    if (i1 == 4 && i2 == 6) {//kingside castle

      //also move the rook
      newBoard[7][7] = None;
      newBoard[5][7] = White | Rook;
    }
    if (i1 == 4 && i2 == 2) {//queensside castle

      //also move the rook
      newBoard[0][7] = None;
      newBoard[3][7] = White | Rook;
    }
  }
  if (newBoard[i1][j1] == (Black | King)) {
    if (i1 == 4 && i2 == 6) {//kingside castle

      //also move the rook
      newBoard[7][0] = None;
      newBoard[5][0] = Black | Rook;
    }
    if (i1 == 4 && i2 == 2) {//queensside castle

      //also move the rook
      newBoard[0][0] = None;
      newBoard[3][0] = Black | Rook;
    }
  }
  if (newBoard[i1][j1] == (White | Pawn) || newBoard[i1][j1] == (Black | Pawn)) {
    if (i1 != i2 && j1 != j2) {
      if (newBoard[i2][j2] == None) { // moved diagonally to an empty square, must be en passant
        newBoard[i2][j1] = None;
      }
    }
  }
  int temp = b[i1][j1];
  newBoard[i1][j1] = None;
  newBoard[i2][j2] = temp;


  return newBoard;
}

void setupBoard() {
  board = new int[8][8];
  board[0][0] = Black | Rook;
  board[1][0] = Black | Knight;
  board[2][0] = Black | Bishop;
  board[3][0] = Black | Queen;
  board[4][0] = Black | King;
  board[5][0] = Black | Bishop;
  board[6][0] = Black | Knight;
  board[7][0] = Black | Rook;
  board[0][1] = Black | Pawn;
  board[1][1] = Black | Pawn;
  board[2][1] = Black | Pawn;
  board[3][1] = Black | Pawn;
  board[4][1] = Black | Pawn;
  board[5][1] = Black | Pawn;
  board[6][1] = Black | Pawn;
  board[7][1] = Black | Pawn;

  board[0][7] = White | Rook;
  board[1][7] = White | Knight;
  board[2][7] = White | Bishop;
  board[3][7] = White | Queen;
  board[4][7] = White | King;
  board[5][7] = White | Bishop;
  board[6][7] = White | Knight;
  board[7][7] = White | Rook;
  board[0][6] = White | Pawn;
  board[1][6] = White | Pawn;
  board[2][6] = White | Pawn;
  board[3][6] = White | Pawn;
  board[4][6] = White | Pawn;
  board[5][6] = White | Pawn;
  board[6][6] = White | Pawn;
  board[7][6] = White | Pawn;
  selectedSquare = null;
  WKingMoved = false;
  BKingMoved = false;
  WQRookMoved = false;//white queenside rook
  WKRookMoved = false;//white kingside rook
  BQRookMoved = false;//black queenside rook
  BKRookMoved = false;//black kingside rook

  pMove1 = null;
  pMove2 = null;

  selectedSquare = null;
  movesMade = 0;
  piecesTaken = new IntList();
  gameString = "";
  turn = White;
}

int selectedPiece(coordinate sq) {
  return board[sq.i][sq.j];
}

int pieceColour(int p) {
  //bit shifting (magic)
  return (p >> 3) * 8;
}

void displayBoard() {
  background(70);
  fill(lightSquareColour[0], lightSquareColour[1], lightSquareColour[2]);
  noStroke();
  rect(0, 0, 800, 800);
  for (int j = 0; j < 8; j++) {
    for (int i = 0; i < 8; i++) {

      if (i % 2 == 0) {
        if (j % 2 != 0) {
          fill(darkSquareColour[0], darkSquareColour[1], darkSquareColour[2]);
          rect(i * squareSize, j * squareSize, squareSize, squareSize);
        }
      } else {
        if (j % 2 == 0) {
          fill(darkSquareColour[0], darkSquareColour[1], darkSquareColour[2]);
          rect(i * squareSize, j * squareSize, squareSize, squareSize);
        }
      }
      boolean highlighted = false;
      if (pMove1 != null) {
        if (pMove1.i == i && pMove1.j == j) {
          fill(lastMoveColour1[0], lastMoveColour1[1], lastMoveColour1[2], lastMoveColour1[3]);
          rect(pMove1.i * squareSize, pMove1.j * squareSize, squareSize, squareSize);
          highlighted = true;
        }
        if (pMove2 != null) {
          if (pMove2.i == i && pMove2.j == j) {
            fill(lastMoveColour2[0], lastMoveColour2[1], lastMoveColour2[2], lastMoveColour2[3]);
            rect(pMove2.i * squareSize, pMove2.j * squareSize, squareSize, squareSize);
            highlighted = true;
          }
        }
      }
      if (!highlighted) {
        if (i % 2 == 0) {
          if (j % 2 != 0) {
            fill(darkSquareColour[0], darkSquareColour[1], darkSquareColour[2]);
            rect(i * squareSize, j * squareSize, squareSize, squareSize);
          }
        } else {
          if (j % 2 == 0) {
            fill(darkSquareColour[0], darkSquareColour[1], darkSquareColour[2]);
            rect(i * squareSize, j * squareSize, squareSize, squareSize);
          }
        }
      }
      push();
      PImage pieceImg = null;
      switch(board[i][j]) {
      case White | Pawn:
        pieceImg = WPawn;
        break;
      case White | Knight:
        pieceImg = WKnight;
        break;
      case White | Bishop:
        pieceImg = WBishop;
        break;
      case White | Rook:
        pieceImg = WRook;
        break;
      case White | Queen:
        pieceImg = WQueen;
        break;
      case White | King:
        pieceImg = WKing;
        break;
      case Black | Pawn:
        pieceImg = BPawn;
        break;
      case Black | Knight:
        pieceImg = BKnight;
        break;
      case Black | Bishop:
        pieceImg = BBishop;
        break;
      case Black | Rook:
        pieceImg = BRook;
        break;
      case Black | Queen:
        pieceImg = BQueen;
        break;
      case Black | King:
        pieceImg = BKing;
        break;
      }
      if (pieceImg != null)image(pieceImg, i * squareSize, j * squareSize);


      pop();
    }
  }


  if (selectedSquare != null) {
    push();
    fill(selectedSquareColour[0], selectedSquareColour[1], selectedSquareColour[2], selectedSquareColour[3]);
    noStroke();
    rect(selectedSquare.i * squareSize, selectedSquare.j * squareSize, squareSize, squareSize);
    pop();

    if (selectedPiece(selectedSquare) != None) {
      //check what moves this piece can do
      ArrayList<move> moves = movesFromSquare(board, selectedSquare, turn);

      //draw the spaces

      for (move m : moves) {
        push();
        noStroke();
        fill(possibleMovesColour[0], possibleMovesColour[1], possibleMovesColour[2], possibleMovesColour[3]);
        rect(m.i2 * squareSize, m.j2 * squareSize, squareSize, squareSize);
        pop();
      }
    }
  }


  String gameOver = checkForGameOver(board, turn);
  push();

  textSize(30);
  strokeWeight(3);
  stroke(0);
  fill(255);
  if (gameOver != "") {
    gameOver = gameOver + "\n\nClick here\nfor new game";
  }
  text(gameOver, 805, height / 2);

  if (turn == White) {
    text("White to move", 805, 700);
  }

  if (turn == Black) {
    text("Black to move", 805, 100);
  }
  pop();

  //back to menu button
  push();
  fill(255, 0, 0, 60);
  noStroke();
  circle(900, 300, 100);
  pop();
  push();
  fill(255);
  textAlign(CENTER);
  text("Menu", 900, 300);
  pop();
  textAlign(BASELINE);
  //show taken pieces
  int wpt = 0;
  int bpt = 0;
  float smallImageSize = 35;
  for (int piece : piecesTaken) {
    PImage pieceImg = null;
    switch(piece) {
    case White | Pawn:
      pieceImg = WPawn;
      wpt++;
      break;
    case White | Knight:
      pieceImg = WKnight;
      wpt++;
      break;
    case White | Bishop:
      pieceImg = WBishop;
      wpt++;
      break;
    case White | Rook:
      pieceImg = WRook;
      wpt++;
      break;
    case White | Queen:
      pieceImg = WQueen;
      wpt++;
      break;
    case Black | Pawn:
      pieceImg = BPawn;
      bpt++;
      break;
    case Black | Knight:
      pieceImg = BKnight;
      bpt++;
      break;
    case Black | Bishop:
      pieceImg = BBishop;
      bpt++;
      break;
    case Black | Rook:
      pieceImg = BRook;
      bpt++;
      break;
    case Black | Queen:
      pieceImg = BQueen;
      bpt++;
      break;
    }
    if (pieceImg != null) {
      push();
      imageMode(CENTER);
      float imgX = 790 + ((smallImageSize-10) * (pieceColour(piece) == White ? wpt : bpt));
      float imgY = pieceColour(piece) == White ? 25 : height-55;
      if (imgX > width) {
        imgX -= 200;
        imgY += smallImageSize;
      }
      image(pieceImg, imgX, imgY, smallImageSize, smallImageSize);
      pop();
    }
  }

  if (promotion) {
    changeTurn();
    push();
    noStroke();
    fill(50, 40);
    rect(0, 0, width, height);
    pop();
    if (turn == White) {
      push();
      imageMode(CENTER);
      image(WQueen, 0.125 * width, height/2);
      image(WRook, 0.375 * width, height/2);
      image(WBishop, 0.625 * width, height/2);
      image(WKnight, 0.875 * width, height/2);
      pop();
    }
    if (turn == Black) {
      push();
      imageMode(CENTER);
      image(BQueen, 0.125 * width, height/2);
      image(BRook, 0.375 * width, height/2);
      image(BBishop, 0.625 * width, height/2);
      image(BKnight, 0.875 * width, height/2);
      pop();
    }
    changeTurn();
  }
}
ArrayList<move> movesFromSquare(int[][] b, coordinate sq, int whoseTurn) {
  ArrayList<move> moves = new ArrayList<move>();
  HashMap<coordinate, coordinate> plm = generateLegalMoves(b, whoseTurn);
  for (coordinate c : plm.keySet()) {
    coordinate v1 = c;
    coordinate v2 = plm.get(c);
    if (v1.i == sq.i && v1.j == sq.j)moves.add(new move(v1.i, v1.j, v2.i, v2.j));
  }

  return moves;
}

//stores 2 sets of coordinates
class move {
  int i1;
  int j1;
  int i2;
  int j2;

  move(int i1_, int j1_, int i2_, int j2_) { //this probably could have been done with two coordinates but who cares
    this.i1 = i1_;
    this.i2 = i2_;
    this.j1 = j1_;
    this.j2 = j2_;
  }
}

//represents a place on the board
class coordinate {
  int i;
  int j;

  coordinate(int i_, int j_) {
    this.i = i_;
    this.j = j_;
  }
}
