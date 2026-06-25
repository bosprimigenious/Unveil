package com.jieqi.ai.tactical;

import com.jieqi.core.Board;
import com.jieqi.core.ChessPiece;
import com.jieqi.core.Move;
import com.jieqi.core.RuleValidator;

import java.util.List;
import java.util.Map;

/**
 * 零搜索战术快路径：一步将杀、唯一应将等。
 */
public final class TacticalAdvisor {

    private TacticalAdvisor() {}

    /**
     * @return 命中则返回着法，否则 {@code null} 交给搜索
     */
    public static Move findInstantMove(Board board, int color, Map<String, Integer> repetition) {
        Move kingCapture = findKingCapture(board, color);
        if (kingCapture != null) {
            return kingCapture;
        }

        List<Move> legal = RuleValidator.generateLegalMoves(board, color);
        if (legal.isEmpty()) {
            return null;
        }

        Move mate = findMateInOne(board, color, legal, repetition);
        if (mate != null) {
            return mate;
        }

        if (RuleValidator.isInCheck(board, color) && legal.size() == 1) {
            return legal.get(0);
        }
        return null;
    }

    private static Move findKingCapture(Board board, int color) {
        for (Move move : RuleValidator.generateAllMoves(board, color)) {
            ChessPiece target = board.getPiece(move.getDestination());
            if (target == null || target.getColor() == color) {
                continue;
            }
            if (target.isRevealed() && target.getType() == ChessPiece.KING
                    && RuleValidator.isValidMove(board, move, color)) {
                return move;
            }
        }
        return null;
    }

    private static Move findMateInOne(Board board, int color, List<Move> legal,
                                      Map<String, Integer> repetition) {
        int oppColor = opponent(color);
        Move bestMate = null;

        for (Move move : legal) {
            ChessPiece captured = board.executeMove(move);
            boolean mate = false;

            if (captured != null && captured.isRevealed() && captured.getType() == ChessPiece.KING) {
                mate = true;
            } else if (RuleValidator.isInCheck(board, oppColor)
                    && RuleValidator.generateLegalMoves(board, oppColor).isEmpty()) {
                mate = true;
            }

            board.undoMove(move, captured);
            if (!mate) {
                continue;
            }
            if (repetitionBlocksMate(board, oppColor, repetition, move)) {
                continue;
            }
            bestMate = move;
            if (captured != null && captured.isRevealed() && captured.getType() == ChessPiece.KING) {
                return move;
            }
        }
        return bestMate;
    }

    private static boolean repetitionBlocksMate(Board board, int oppColor,
                                                Map<String, Integer> repetition, Move move) {
        if (repetition == null) {
            return false;
        }
        ChessPiece captured = board.executeMove(move);
        boolean blocked = false;
        if (RuleValidator.isInCheck(board, oppColor)) {
            String key = Board.positionKey(board, oppColor);
            blocked = repetition.getOrDefault(key, 0) + 1 >= 5;
        }
        board.undoMove(move, captured);
        return blocked;
    }

    private static int opponent(int color) {
        return color == ChessPiece.RED ? ChessPiece.BLACK : ChessPiece.RED;
    }
}
