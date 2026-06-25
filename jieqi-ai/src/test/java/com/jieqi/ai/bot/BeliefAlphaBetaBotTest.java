package com.jieqi.ai.bot;

import com.jieqi.ai.JieqiAgent;
import com.jieqi.core.Board;
import com.jieqi.core.ChessPiece;
import com.jieqi.core.Move;
import com.jieqi.core.RuleValidator;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class BeliefAlphaBetaBotTest {

    @Test
    void returnsLegalMoveOnOpening() {
        Board board = new Board();
        AiConfig config = AiConfig.forLevel(AiLevel.HARD, 2_000L);
        BeliefAlphaBetaBot bot = new BeliefAlphaBetaBot(config);
        Move move = bot.selectMove(board, ChessPiece.RED, 2_000L, null);
        assertNotNull(move);
        assertTrue(RuleValidator.isMoveLegal(board, move, ChessPiece.RED));
    }

    @Test
    void skipsBeliefRefinementWhenOpponentHasNoHiddenPieces() {
        Board board = endgameWithRevealedPieces();
        AiConfig config = AiConfig.forLevel(AiLevel.HARD, 800L);
        RecordingAgent recordingAgent = new RecordingAgent();
        BeliefAlphaBetaBot bot = new BeliefAlphaBetaBot(config, recordingAgent);

        Move move = bot.selectMove(board, ChessPiece.RED, 800L, null);

        assertNotNull(move);
        assertEquals(1, recordingAgent.calls);
        assertTrue(RuleValidator.isMoveLegal(board, move, ChessPiece.RED));
    }

    @Test
    void hardBotDoesNotReturnNullWithTightBudget() {
        Board board = new Board();
        AiBot bot = AiBotFactory.create(AiLevel.HARD, 600L);
        Move move = AiBotFactory.selectWithFallback(bot, board, ChessPiece.BLACK, 600L, null);
        assertNotNull(move);
        assertTrue(RuleValidator.isMoveLegal(board, move, ChessPiece.BLACK));
    }

    private static Board endgameWithRevealedPieces() {
        Board board = new Board();
        board.clearAllPieces();
        board.placePiece(new ChessPiece(ChessPiece.KING, ChessPiece.RED, true, 9, 4), 9, 4);
        board.placePiece(new ChessPiece(ChessPiece.KING, ChessPiece.BLACK, true, 0, 4), 0, 4);
        board.placePiece(new ChessPiece(ChessPiece.ROOK, ChessPiece.RED, true, 9, 0), 9, 0);
        board.placePiece(new ChessPiece(ChessPiece.ROOK, ChessPiece.BLACK, true, 0, 0), 0, 0);
        return board;
    }

    private static final class RecordingAgent extends JieqiAgent {
        int calls;

        @Override
        public Move selectMove(Board board, int color, long timeLimitMs,
                               java.util.Map<String, Integer> repetition) {
            calls++;
            return super.selectMove(board, color, timeLimitMs, repetition);
        }
    }
}
