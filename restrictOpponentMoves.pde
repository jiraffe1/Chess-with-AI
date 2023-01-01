void restrictOppMove(int colour) {
  //least number of moves the oppoenent could make
  HashMap<coordinate, coordinate> legalMoves = generateLegalMoves(board, turn);
  float bestEval = 1000000000;
  coordinate bestV1 = null;
  coordinate bestV2 = null;
 
  for (coordinate c : legalMoves.keySet()) {
    coordinate v1 = c;
    coordinate v2 = legalMoves.get(c);
    //minimise the number of movbes my opponent can do, maximise the number i can do
    float eval = restrictOppRateBoard(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn) - generateLegalMoves(makeMove(board, v1.i, v1.j, v2.i, v2.j), turn).values().size();
    
    if(eval < bestEval) {
      bestV1 = v1;
      bestV2 = v2;
      bestEval = eval;
    }
  }
    //print("\n" + (turn == White ? "White " : "Black ") + "eval: " + (bestEval * (turn == White ? -1 : 1)));
  if(bestV1 != null && bestV2 != null) {
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

float restrictOppRateBoard(int[][] b, int colour) {
  return generateLegalMoves(b, otherColour(colour)).values().size();
}
