package com.jieqi.ai.bot;

import com.jieqi.ai.JieqiAgent;
import com.jieqi.ai.OptimizedAlphaBeta;
import com.jieqi.ai.belief.BoardSampler;
import com.jieqi.core.Board;
import com.jieqi.core.ChessPiece;
import com.jieqi.core.Move;
import com.jieqi.core.RuleValidator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * 挑战：先以完整 Agent 编排做深搜（保底不低于标准档），再对对手仍有暗子时做信念采样精炼。
 */
public final class BeliefAlphaBetaBot implements AiBot {

    private static final double PRIMARY_BUDGET_RATIO = 0.72;
    private static final long MIN_REFINEMENT_BUDGET_MS = 400L;

    private final AiConfig config;
    private final JieqiAgent agent;
    private final Random rng = new Random(0xBE11EF01L);

    public BeliefAlphaBetaBot(AiConfig config) {
        this(config, new JieqiAgent());
    }

    BeliefAlphaBetaBot(AiConfig config, JieqiAgent agent) {
        this.config = config;
        this.agent = agent;
    }

    @Override
    public AiLevel level() {
        return AiLevel.HARD;
    }

    @Override
    public Move selectMove(Board authoritativeBoard, int color, long timeLimitMs,
                           Map<String, Integer> repetition) {
        long budget = Math.min(timeLimitMs, config.timeLimitMs());
        long startedAt = System.currentTimeMillis();
        Board publicView = authoritativeBoard.createAiPublicView(color);

        int oppHidden = countOpponentHidden(publicView, color);
        if (oppHidden == 0) {
            return legalOrFallback(authoritativeBoard, color,
                    agent.selectMove(authoritativeBoard, color, budget, repetition));
        }

        long primaryBudget = Math.max(budget / 2, (long) (budget * PRIMARY_BUDGET_RATIO));
        Move primaryMove = agent.selectMove(authoritativeBoard, color, primaryBudget, repetition);

        long elapsed = System.currentTimeMillis() - startedAt;
        long refinementBudget = budget - elapsed;
        if (refinementBudget < MIN_REFINEMENT_BUDGET_MS || oppHidden <= 1) {
            return legalOrFallback(authoritativeBoard, color, primaryMove);
        }

        Move refined = refineWithBelief(
                authoritativeBoard, publicView, color, refinementBudget, repetition, primaryMove);
        return legalOrFallback(authoritativeBoard, color, refined);
    }

    private Move refineWithBelief(Board authoritativeBoard, Board publicView, int color,
                                  long refinementBudget, Map<String, Integer> repetition,
                                  Move primaryMove) {
        List<Move> ranked = RuleValidator.generateLegalMoves(publicView, color);
        if (ranked.isEmpty()) {
            return primaryMove;
        }
        MoveOrderer.sortByHeuristic(publicView, ranked, color);

        List<Move> candidates = buildCandidateSet(ranked, primaryMove, config.maxCandidatesForBelief());
        if (candidates.size() <= 1) {
            return primaryMove != null ? primaryMove : candidates.get(0);
        }

        int samples = Math.max(1, config.beliefSamples());
        long deadline = System.currentTimeMillis() + refinementBudget;
        Map<String, Double> scores = new HashMap<>();
        OptimizedAlphaBeta search = new OptimizedAlphaBeta();

        for (int candidateIndex = 0; candidateIndex < candidates.size(); candidateIndex++) {
            if (System.currentTimeMillis() >= deadline) {
                break;
            }
            Move candidate = candidates.get(candidateIndex);
            double sum = 0;
            int used = 0;
            for (int sampleIndex = 0; sampleIndex < samples; sampleIndex++) {
                if (System.currentTimeMillis() >= deadline) {
                    break;
                }
                Board sample = BoardSampler.fromPublicView(publicView, color, rng);
                Board.MoveSnapshot snap = sample.makeMove(candidate);

                long remaining = deadline - System.currentTimeMillis();
                int remainingSamples = samples - sampleIndex
                        + (candidates.size() - candidateIndex - 1) * samples;
                long perSample = Math.max(60L, remaining / Math.max(1, remainingSamples));

                OptimizedAlphaBeta.SearchResult result =
                        search.search(sample, opp(color), perSample, repetition);
                sample.unmakeMove(snap);
                sum -= result.score;
                used++;
            }
            if (used > 0) {
                scores.put(key(candidate), sum / used);
            }
        }

        Move best = primaryMove != null ? primaryMove : candidates.get(0);
        double bestScore = scores.getOrDefault(key(best), Double.NEGATIVE_INFINITY);
        for (Move candidate : candidates) {
            double score = scores.getOrDefault(key(candidate), Double.NEGATIVE_INFINITY);
            if (score > bestScore) {
                bestScore = score;
                best = candidate;
            }
        }
        if (!RuleValidator.isMoveLegal(authoritativeBoard, best, color)) {
            return primaryMove;
        }
        return best;
    }

    private static List<Move> buildCandidateSet(List<Move> ranked, Move primaryMove, int limit) {
        int cap = Math.max(2, limit);
        Set<String> seen = new LinkedHashSet<>();
        List<Move> candidates = new ArrayList<>(cap);
        if (primaryMove != null) {
            candidates.add(primaryMove);
            seen.add(key(primaryMove));
        }
        for (Move move : ranked) {
            if (candidates.size() >= cap) {
                break;
            }
            String id = key(move);
            if (seen.add(id)) {
                candidates.add(move);
            }
        }
        return candidates;
    }

    private Move legalOrFallback(Board board, int color, Move move) {
        if (move != null && RuleValidator.isMoveLegal(board, move, color)) {
            return move;
        }
        return new AlphaBetaBot(config, agent).selectMove(board, color, config.timeLimitMs(), null);
    }

    private static int countOpponentHidden(Board publicView, int color) {
        int opp = opp(color);
        int count = 0;
        for (ChessPiece piece : publicView.getPieces(opp)) {
            if (!piece.isRevealed()) {
                count++;
            }
        }
        return count;
    }

    private static int opp(int color) {
        return color == ChessPiece.RED ? ChessPiece.BLACK : ChessPiece.RED;
    }

    private static String key(Move move) {
        return move.getSource() + ">" + move.getDestination();
    }
}
