void firstMove() {
  HashMap<coordinate, coordinate> legalMoves = generateLegalMoves(board, turn);
  if (legalMoves.keySet().size() != 0) {
    for (coordinate m : legalMoves.keySet()) {
      selectedSquare = m;
      board = makeUpdatingMove(board, m.i, m.j, legalMoves.get(m).i, legalMoves.get(m).j);
      
      changeTurn();
      return;
    }
  }
}
