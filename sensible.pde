void sensibleMove(int colour) {
  //try and move my pieces as close as possible to the enemy king
  HashMap<coordinate, coordinate> legalMoves = generateLegalMoves(board, turn);
  float bestEval = turn == White ? -1000000000 : 1000000000;
  coordinate bestV1 = null;
  coordinate bestV2 = null;

  for (coordinate c : legalMoves.keySet()) {
    coordinate v1 = c;
    coordinate v2 = legalMoves.get(c);
    //combine multiple evaluations
    float eval = materialRateBoard(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn) * 0.8 + (swarmRateBoard(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn) * (turn == White ? -1 : 1) * 0.2) - (restrictOppRateBoard(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn) - generateLegalMoves(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn).values().size() * colour == White ? 1 : -1); //weighted towards material 65%
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
