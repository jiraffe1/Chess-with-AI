void swarmMove(int colour) {
  //try and move my pieces as close as possible to the enemy king
  HashMap<coordinate, coordinate> legalMoves = generateLegalMoves(board, turn);
  float bestEval = 1000000000;
  coordinate bestV1 = null;
  coordinate bestV2 = null;

  for (coordinate c : legalMoves.keySet()) {
    coordinate v1 = c;
    coordinate v2 = legalMoves.get(c);
    float eval = swarmRateBoard(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn);
    if (eval < bestEval) {
      bestV1 = v1;
      bestV2 = v2;
      bestEval = eval;
    }
  }
  // print("\n" + (turn == White ? "White " : "Black ") + "eval: " + bestEval);
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

float swarmRateBoard(int[][] b, int colour) {
  float total = 0;
  coordinate enemyKingLocation = locateKing(b, otherColour(colour)); //
  for (int j = 0; j < 8; j++) {
    for (int i = 0; i < 8; i++) {
      if ((b[i][j] >> 3) * 8 == colour) {
        total += round(dist(i, j, enemyKingLocation.i, enemyKingLocation.j));
      }
    }
  }
  return total / numberOfPiecesColour(b, colour);
}
