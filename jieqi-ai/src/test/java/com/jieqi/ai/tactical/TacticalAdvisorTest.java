package com.jieqi.ai.tactical;

import com.jieqi.core.Board;
import com.jieqi.core.ChessPiece;
import com.jieqi.core.Move;
import com.jieqi.core.RuleValidator;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class TacticalAdvisorTest {

    @Test
    void findsDirectKingCapture() {
        Board board = emptyBoard();
        board.placePiece(new ChessPiece(ChessPiece.KING, ChessPiece.BLACK, true, 0, 4), 0, 4);
        board.placePiece(new ChessPiece(ChessPiece.ROOK, ChessPiece.RED, true, 0, 0), 0, 0);

        Move move = TacticalAdvisor.findInstantMove(board, ChessPiece.RED, null);
        assertNotNull(move);
        assertEquals("e9", move.getDestination());
    }

    @Test
    void returnsSingleReplyWhenInCheck() {
        Board board = emptyBoard();
        board.placePiece(new ChessPiece(ChessPiece.KING, ChessPiece.BLACK, true, 0, 4), 0, 4);
        board.placePiece(new ChessPiece(ChessPiece.ROOK, ChessPiece.RED, true, 8, 4), 8, 4);

        Move move = TacticalAdvisor.findInstantMove(board, ChessPiece.BLACK, null);
        assertNotNull(move);
        assertTrue(RuleValidator.isMoveLegal(board, move, ChessPiece.BLACK));
    }

    @Test
    void returnsNullWhenNoTacticalForcingMove() {
        Board board = new Board();
        assertNull(TacticalAdvisor.findInstantMove(board, ChessPiece.RED, null));
    }

    private static Board emptyBoard() {
        Board board = new Board();
        board.clearAllPieces();
        return board;
    }
}
