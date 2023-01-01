int positionsSearched = 0; //<>// //<>//
int checkmatesFound = 0;
int moveSameness = 0;

//is absolutely amazing playing as black, is AWFUL playing as black

void minimax2Move(int colour, int searchDepth) {
  //try and move my pieces as close as possible to the enemy king
  ArrayList<move> legalMoves = generateLegalMovesArray(board, turn);
  float bestEval = colour == White ? -100000000 : 100000000;
  move bestMove = null;
  int sd = searchDepth;
  checkmatesFound = 0;
  if (numberOfPieces(board) <= 14) {
      //endgame
      print("\nWe're in the endgame now");
    // sd += 2; 
    }

  positionsSearched = 0;
  if (movesMade == 0 || movesMade == 1) {
    if (colour == White) {
      bestMove = new move(4, 6, 4, 4);
    } else {
      bestMove = new move(4, 1, 4, 3);
    }
  } else if (colour == White && movesMade == 2) {
    bestMove = new move(3, 7, 5, 5);
  } else {
    for (move m : legalMoves) {
      float eval = 0;
      //if (colour == Black) {
        eval = minimax2Search(makeMove(board, m.i1, m.j1, m.i2, m.j2), sd - 1, otherColour(colour), -100000000, 100000000);
      //} else {
      //  eval = minimaxSearch(makeMove(board, m.i1, m.j1, m.i2, m.j2), sd - 1, otherColour(colour), -100000000, 100000000);
      //}
      if (eval == bestEval) {
        moveSameness ++;
      }
      if (colour == White) {
        
        if (eval > bestEval) {
          bestMove = m;
          bestEval = eval;
          moveSameness = 0;
        }
      }
      if (colour == Black) {
        if (eval < bestEval) {
          bestMove = m;
          bestEval = eval;
          moveSameness = 0;
        }
      }
    }
  }
  print("\n" + (turn == White ? "White " : "Black ") + "eval: " + bestEval + " Positions searched: " + positionsSearched + " Checkmates found: " + checkmatesFound + " Move similarity: " + moveSameness);

  if (bestMove != null) {

    if (moveSameness > ((searchDepth - 1) * 10) - 5 && searchDepth <= 3) {
      //changeTurn();

      developPiece(colour);

      print("\nDeveloping piece");
    } else {
      selectedSquare = new coordinate(bestMove.i1, bestMove.j1);
      board = makeUpdatingMove(board, bestMove.i1, bestMove.j1, bestMove.i2, bestMove.j2);

      if (pMove1 !=null && pMove2 != null) {
        if (promotion && (board[pMove2.i][pMove2.j] >> 3) * 8 == colour) {
          board[promotionPosition.i][promotionPosition.j] = (turn | Queen); //it always chooses queen. why? because i said so
          promotion = false;
        }
      }

      changeTurn();
    }
  } else {
    //changeTurn();
    randomMove(colour);
    print("\nCouldnt decide???");
  }
  // changeTurn();
}

int minimax2Search(int[][] b, int depth, int colour, int alpha, int beta) {
  positionsSearched++;
  if (checkForGameOver(b, colour) == "CHECKMATE") {
    checkmatesFound++;
    print("czech mate");

    return -69420000;
  }

  if (checkForGameOver(b, colour) == "STALEMATE") {

    return - 10;
  }

  if (depth == 0) {
    return minimaxEvaluate(b);
  }
  ArrayList<move> moves = generateLegalMovesArray(b, colour);

  int bestEval = -1000000;

  for (move m : moves) {

    int eval = - minimax2Search(makeMove(b, m.i1, m.j1, m.i2, m.j2), depth -1, otherColour(colour), -beta, -alpha);
    bestEval = max(eval, bestEval);
    if (eval >= beta && eval != 69420000) {
      return beta;
    }

    alpha = max(alpha, eval);
  }


  return alpha;
}


int minimaxEvaluate(int[][] b) {
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
  return total;
}
