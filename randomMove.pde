void randomMove(int colour) {
  HashMap<coordinate, coordinate> legalMoves = generateLegalMoves(board, colour);
  //way more difficult than it needed to be
  //additionally it causes a StackOverflowError sometimes which is really really bad

  ArrayList<coordinate> moves1 = new ArrayList<coordinate>();

  for (coordinate m : legalMoves.keySet()) {
    moves1.add(m);
  }
  if (moves1.size() != 0) {
    int rand = floor(random(moves1.size()));
    coordinate randomCoordinate1 = moves1.get(rand);
    //print("\n" + randomCoordinate1.i + ", " + randomCoordinate1.j);
    coordinate randomCoordinate2 = legalMoves.get(randomCoordinate1);
    //print("\n" + randomCoordinate2.i + ", " + randomCoordinate2.j);
    selectedSquare = randomCoordinate1;
    board = makeUpdatingMove(board, randomCoordinate1.i, randomCoordinate1.j, randomCoordinate2.i, randomCoordinate2.j);
    if (promotion && (board[pMove2.i][pMove2.j] >> 3 )* 8 == colour) {
      float randy = random(10);
      board[promotionPosition.i][promotionPosition.j] = randy > 5 ? (turn | Queen) : (turn | Knight);
      gameString += randy > 5 ? "Q" : "N";
      promotion = false;
    }
    changeTurn();
  }
}
