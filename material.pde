void materialMove(int colour) {
  //try and move my pieces as close as possible to the enemy king
  HashMap<coordinate, coordinate> legalMoves = generateLegalMoves(board, turn);
  float bestEval = turn == White ? -1000000000 : 1000000000;
  coordinate bestV1 = null;
  coordinate bestV2 = null;

  for (coordinate c : legalMoves.keySet()) {
    coordinate v1 = c;
    coordinate v2 = legalMoves.get(c);
    float eval = materialRateBoard(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn); 
    if (turn == White) {
      if (eval > bestEval) {
        bestV1 = v1;
        bestV2 = v2;
        bestEval = eval;
      }
    }
    if (turn == Black) {
      if (eval < bestEval) {
        bestV1 = v1;
        bestV2 = v2;
        bestEval = eval;
      }
    }
  }
  
  //print("\n" + (turn == White ? "White " : "Black ") + "eval: " + bestEval);

  if (bestV1 != null && bestV2 != null) {
    selectedSquare = new coordinate(bestV1.i, bestV1.j);
    board = makeUpdatingMove(board, bestV1.i, bestV1.j, bestV2.i, bestV2.j);

    if (promotion && (board[pMove2.i][pMove2.j] >> 3) * 8 == colour) {
      board[promotionPosition.i][promotionPosition.j] = (turn | Queen); //it always chooses queen. why? because i said so
      gameString += "Q";
      promotion = false;
    }

    changeTurn();
  }
}

int materialRateBoard(int[][] b, int colour) {
  int total = 0;
  for (int j = 0; j < 8; j++) {
    for (int i = 0; i < 8; i++) {
      switch(b[i][j]) {
      case White | Pawn:
        total += 1;
        break;
      case White | Knight:
        total += 3;
        break;
      case White | Bishop:
        total += 3;
        break;
      case White | Rook:
        total += 5;
        break;
      case White | Queen:
        total += 9;
        break;
      case Black | Pawn:
        total -= 1;
        break;
      case Black | Knight:
        total -= 3;
        break;
      case Black | Bishop:
        total -= 3;
        break;
      case Black | Rook:
        total -= 5;
        break;
      case Black | Queen:
        total -= 9;
        break;
      }
    }
  }

  if (checkForGameOver(b, otherColour(colour)) == "Checkmate") {
    total += 10000 * (turn == White ? 1 : -1);
  }
  if (checkForGameOver(b, otherColour(colour)) == "Stalemate") {
    total -= 10000* (turn == White ? 1 : -1);
  }
  return total;
}
