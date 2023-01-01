void strategyMove(int colour) {
  ArrayList<move> moves = generateLegalMovesArray(board, colour);
  float bestEval = -10000;
  move bestMove = null;

  for (move m : moves) {
    float eval = -10000;

    boolean pieceAttacked = false;
    ArrayList<move> responses = generateLegalMovesArray(board, otherColour(colour));

    for (move response : responses) {
      if (response.i2 == m.i1 && response.j2 == m.j1) {
        pieceAttacked = true;
      }
    }

    if (pieceAttacked && (movesMade <= 16 && board[m.i1][m.j1] % 8 != Pawn)) {
      boolean stillAttacked = false;
      ArrayList<move> ifMoveMade = generateLegalMovesArray(makeMove(board, m.i1, m.j1, m.i2, m.j2), otherColour(colour));
      for (move response : ifMoveMade) {
        if (response.i2 == m.i2 && response.j2 == m.j2) {
          stillAttacked = true;
        }
      }

      if (stillAttacked) {
        eval = 0;
      } else {
        eval = pieceValue(board[m.i1][m.j1] % 8);
      }
    }
    if (board[m.i2][m.j2] >> 3 != None) {
      // take piece of higher value
      if (pieceValue(board[m.i1][m.j1] % 8) <= pieceValue(board[m.i2][m.j2] % 8)) {
        eval = pieceValue(board[m.i2][m.j2] % 8) + (pieceValue(board[m.i2][m.j2] % 8) - pieceValue(board[m.i1][m.j1] % 8));
      }
      // take a hanging piece
      boolean pieceHanging = true;
      int[][] newBoard = makeMove(board, m.i1, m.j1, m.i2, m.j2);
      ArrayList<move> oppresponses = generateLegalMovesArray(newBoard, otherColour(colour));

      for (move response : oppresponses) {
        if (response.i2 == m.i2 && response.j2 == m.j2) {
          pieceHanging = false;
        }
      }

      if (pieceHanging) {
        eval = pieceValue(board[m.i2][m.j2] % 8) * 2;
      }
    }

    if (eval > bestEval) {
      bestEval = eval;
      bestMove = m;
    }

    if (checkForGameOver(makeMove(board, m.i1, m.j1, m.i2, m.j2), otherColour(colour)) == "CHECKMATE" || checkForGameOver(makeMove(board, m.i1, m.j1, m.i2, m.j2), colour) == "CHECKMATE") {
      eval = 10000000;
      bestMove = m;
      selectedSquare = new coordinate(bestMove.i1, bestMove.j1);
      board = makeUpdatingMove(board, bestMove.i1, bestMove.j1, bestMove.i2, bestMove.j2);
      changeTurn();
      return;
    }
    if (checkForGameOver(makeMove(board, m.i1, m.j1, m.i2, m.j2), otherColour(colour)) == "STALEMATE") {
      eval = -100000;
    }
    if (checkForGameOver(makeMove(board, m.i1, m.j1, m.i2, m.j2), colour) == "STALEMATE") {
      eval = 0;
    }
  }
  if (movesMade < 5) {
    developPiece(colour);
  } else {
    if (bestMove != null) {
      //print("\nEvaluation score: " + bestEval);
      selectedSquare = new coordinate(bestMove.i1, bestMove.j1);
      board = makeUpdatingMove(board, bestMove.i1, bestMove.j1, bestMove.i2, bestMove.j2);
      changeTurn();
    } else {
      if (numberOfPieces(board) >= 14 && numberOfPiecesColour(board, otherColour(colour)) >= 3) {
        //print("\nDeveloped a piece");
        developPiece(colour);
      } else {
        //print("\nENDGAME: Restricted opponent");
        restrictOpponent(colour);
      }
    }
  }

  if (pMove1 !=null && pMove2 != null) {
    if (promotion && (board[pMove2.i][pMove2.j] >> 3) * 8 == colour) {
      board[promotionPosition.i][promotionPosition.j] = (colour | Queen); //it always chooses queen. why? because i said so
      gameString += "Q";
      promotion = false;
    }
  }
}

float pieceValue(int pieceType) {
  switch( pieceType) {
  case Pawn:
    return 10;
  case Knight:
    return 30;
  case Bishop:
    return 30;
  case Rook:
    return 50;
  case Queen:
    return 90;
  case King:
    return 10;
  }

  return 0;
}
