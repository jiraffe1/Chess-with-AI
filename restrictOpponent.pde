void restrictOpponent(int colour) {
  //least number of moves the oppoenent could make
  ArrayList<move> legalMoves = generateLegalMovesArray(board, turn);
  float bestEval = 100000;
  move bestMove = null;

  for (move m : legalMoves) {
    ArrayList<move> responses = generateLegalMovesArray(makeMove(board, m.i1, m.j1, m.i2, m.j2), otherColour(colour));
    float eval = abs(responses.size());
    for (move response : responses) {
      if (response.i2 == m.i2 && response.j2 == m.j2) {
        eval = 100000;
      }
    }
    if (checkForGameOver(makeMove(board, m.i1, m.j1, m.i2, m.j2), otherColour(colour)) == "STALEMATE") {
      eval = 100000;
    }
    if (eval < bestEval) {
      bestMove =m;
      bestEval = eval;
    }
  }
  //print("\n" + (turn == White ? "White " : "Black ") + "development: " + (bestEval * (turn == White ? -1 : 1)));
  if (bestMove != null) {
    /*
    if (promotion && (board[pMove2.i][pMove2.j] >> 3) * 8 == colour) {
     board[promotionPosition.i][promotionPosition.j] = (turn | Queen); //it always chooses queen. why? because i said so
     promotion = false;
     }
     */
    selectedSquare = new coordinate(bestMove.i1, bestMove.j1);
    board = makeUpdatingMove(board, bestMove.i1, bestMove.j1, bestMove.i2, bestMove.j2);
    if (promotion && (board[pMove2.i][pMove2.j] >> 3) * 8 == colour) {
      board[promotionPosition.i][promotionPosition.j] = (turn | Queen); //it always chooses queen. why? because i said so
      gameString += "Q";
      promotion = false;
    }
    changeTurn();
  }
  else {
    print("\nRANDOM MOVE");
    randomMove(colour);
  }
}
