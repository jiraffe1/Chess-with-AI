/*
function negamax(node, depth, α, β, color) is
 if depth = 0 or node is a terminal node then
 return color × the heuristic value of node
 
 childNodes := generateMoves(node)
 childNodes := orderMoves(childNodes)
 value := −∞
 foreach child in childNodes do
 value := max(value, −negamax(child, depth − 1, −β, −α, −color))
 α := max(α, value)
 if α ≥ β then
 break (* cut-off *)
 return value
 */

//bro this algorithm sounds super racist

void negamaxPlayer(int colour, int depth) {
  int startTime = millis();
  ArrayList<move> legalMoves = generateLegalMovesArray(board, colour);
  int bestEvaluation = Integer.MIN_VALUE;
  move bestMove = null;

  positionsSearched = 0;
  if (movesMade == 0 || movesMade == 1) {
    if (colour == White) {
      bestMove = new move(4, 6, 4, 4);
    } else {
      bestMove = new move(4, 1, 4, 3);
    }
  } else {
    for (move possibleMove : legalMoves) {
      //make that move on the board
      int[][] newBoard = makeMove(board, possibleMove.i1, possibleMove.j1, possibleMove.i2, possibleMove.j2);

      //see which move is best for me
      int evaluation = -negamax(newBoard, depth - 1, Integer.MIN_VALUE, Integer.MAX_VALUE, otherColour(colour), depth - 1);
      boolean mateInOne = false;

      if (evaluation == 64200001) {
        mateInOne = true;
      }

      if (evaluation > bestEvaluation) {
        if (evaluation >= 69420000) {
          if (mateInOne) {
            bestMove = possibleMove;
            bestEvaluation = evaluation;
            print("\nMate in one!");
            break;
          }
          if (numberOfPieces(board) <= 27) {
            //bestMove = possibleMove;
            //bestEvaluation = evaluation;
            print("\nToo early");
          }
        } else {
          bestMove = possibleMove;
          bestEvaluation = evaluation;
        }
      }
    }
  }

  print("\nEvaluation: " + bestEvaluation + " Positions searched: " + positionsSearched + " Time taken: " + str(millis() - startTime) + "ms");
  if (movesMade <= 2) {
    developPiece(colour);
  } else {
    if (bestMove != null) {
      selectedSquare = new coordinate(bestMove.i1, bestMove.j1);
      board = makeUpdatingMove(board, bestMove.i1, bestMove.j1, bestMove.i2, bestMove.j2);

      if (pMove1 !=null && pMove2 != null) {
        if (promotion && (board[pMove2.i][pMove2.j] >> 3) * 8 == colour) {
          board[promotionPosition.i][promotionPosition.j] = (turn | Queen); //it always chooses queen. why? because i said so
          promotion = false;
        }
      }

      changeTurn();
    } else {
      restrictOpponent(colour);
    }
  }
}

int negamax(int[][] boardState, int depth, int alpha, int beta, int colour, int originalDepth) {
  positionsSearched++;
  if (depth == 0) {
    int rate = rateBoard(boardState, colour);
    //print("\n"+rate);
    return rate;
  }

  ArrayList<move> childNodes = generateLegalMovesArray(boardState, colour);

  if (childNodes.size() == 0) {
    if (isCheck(boardState, colour)) {
      //print("\nM" + (originalDepth - depth));
      return -69420000 + (depth == originalDepth ? 1 : 0);//this is a genius solution
    }
    return 0;
  }

  //Order the moves

  int value = Integer.MIN_VALUE;

  for (move m : childNodes) {
    int[][] newBoard = makeMove(boardState, m.i1, m.j1, m.i2, m.j2);
    value = max(value, -negamax(newBoard, depth - 1, -beta, -alpha, otherColour(colour), originalDepth));
    alpha = max(alpha, value);

    if (alpha >= beta) {
      break;
    }
  }
  return value;
}

int rateBoard(int[][] boardState, int colour) {
  int total = 0;
  for (int j = 0; j < 8; j++) {
    for (int i = 0; i < 8; i++) {
      switch(boardState[i][j]) {
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
  return total * (colour == White ? 1 : -1);
}
