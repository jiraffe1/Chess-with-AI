
ArrayList<move> generateLegalMovesArray(int[][] boardState, int colour) {
  ArrayList<move> pseudoLegal = generatePseudoLegalMovesArray(boardState, colour);
  ArrayList<move> legalMoves = new ArrayList<move>();

  for (move m : pseudoLegal) {
    //generate all pseudo legal moves but discard ones where i move into check
    int[][] nb = makeMove(boardState, m.i1, m.j1, m.i2, m.j2);

    if (boardState[m.i1][m.j1] == (White | King) || boardState[m.i1][m.j1] == (Black | King) && !isCheck(boardState, colour)) {
      if (abs(m.i1 - m.i2) == 2) {//castling
        if (!isCheck(makeMove(boardState, m.i1, m.j1, (m.i1 + m.j1) / 2, m.j2), (boardState[m.i1][m.j1] >> 3) * 8) && !isCheck(boardState, (boardState[m.i1][m.j1] >> 3) * 8)) {
          legalMoves.add(new move(m.i1, m.j1, m.i2, m.j2));
        }
      }
    }
    else if (!isCheck(nb, colour)) {
      legalMoves.add(new move(m.i1, m.j1, m.i2, m.j2));
    }
  }

  return legalMoves;
}
ArrayList<move> generatePseudoLegalMovesArray(int[][] boardState, int colour) {
  ArrayList<move> moves = new ArrayList<move>();

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
                moves.add(new move(i, j, i, j + direction));
                if (j != (pieceColour == White ? 1 : 6)) {//advance 2 ssquare
                  if (boardState[i][j + direction * 2] == None && j == (pieceColour == White ? 6 : 1)) {
                    moves.add(new move(i, j, i, j + direction * 2));
                  }
                }
              }
              if (i != 7) {
                if (enemyPiece(boardState, i + 1, j + direction, pieceColour)) {
                  moves.add(new move(i, j, i + 1, j + direction));
                }
                if (boardState[i+1][j] == (otherColour(pieceColour) | Pawn)) {//opposite coloured pawn
                  if (pMove1 != null) {
                    if (abs(pMove1.j - pMove2.j) == 2 && pMove2.j == (pieceColour == White ? 3 : 4)) {
                      //en passant


                      moves.add(new move(i, j, i + 1, j + direction));
                    }
                  }
                }
              }
              if (i != 0) {
                if (enemyPiece(boardState, i - 1, j + direction, pieceColour)) {
                  moves.add(new move(i, j, i - 1, j + direction));
                }
                if (boardState[i-1][j] == (otherColour(pieceColour) | Pawn)) {//opposite coloured pawn
                  if (pMove1 != null) {
                    if (abs(pMove1.j - pMove2.j) == 2 && pMove2.j == (pieceColour == White ? 3 : 4)) {
                      //en passant
                      moves.add(new move(i, j, i - 1, j + direction));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }
            //CASTLING

            if (pieceColour == White) {
              //kingside
              if (boardState[5][7] == None && boardState[6][7] == None) {
                if (!WKingMoved && !WKRookMoved) {
                  moves.add(new move(4, 7, 6, 7));
                }
              }
              //queenside
              if (boardState[3][7] == None && boardState[2][7] == None && boardState[1][7] == None) {
                if (!WKingMoved && !WQRookMoved) {
                  moves.add(new move(4, 7, 2, 7));
                }
              }
            } else {
              //kingside
              if (boardState[5][0] == None && boardState[6][0] == None) {
                if (!BKingMoved && !BKRookMoved) {

                  moves.add(new move(4, 0, 6, 0));
                }
              }
              //queenside
              if (boardState[3][0] == None && boardState[2][0] == None && boardState[1][0] == None) {
                if (!BKingMoved && !BQRookMoved) {
                  moves.add(new move(4, 0, 2, 0));
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
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }
            iDirection = 2;
            jDirection = -1;

            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }

            iDirection = 2;
            jDirection = 1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }
            iDirection = 1;
            jDirection = 2;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }

            iDirection = -1;
            jDirection = 2;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }

            iDirection = -2;
            jDirection = 1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }

            iDirection = -2;
            jDirection = -1;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }

            iDirection = -1;
            jDirection = -2;
            ni = i + iDirection;
            nj = j + jDirection;
            if (ni < 0 || ni > 7 || nj < 0 || nj > 7) {
            } else {
              if (boardState[ni][nj] == None) {
                moves.add(new move(i, j, ni, nj));
                moves.add(new move(i, j, ni, nj));
              }
              if (enemyPiece(boardState, ni, nj, pieceColour)) {
                moves.add(new move(i, j, ni, nj));
              }
            }
          }
        }
      }
    }
  }

  return moves;
}
