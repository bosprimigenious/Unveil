package com.jieqi.ai.agent;

import com.jieqi.ai.tactical.TacticalAdvisor;
import com.jieqi.core.Move;

/** 战术快路径：将杀一步、唯一应将等，优先于概率/搜索 Agent。 */
public final class TacticalAgent implements JieqiSubAgent {

    @Override
    public int priority() {
        return 5;
    }

    @Override
    public boolean supports(AgentContext ctx) {
        return true;
    }

    @Override
    public Move contribute(AgentContext ctx) {
        return TacticalAdvisor.findInstantMove(
                ctx.getBoard(), ctx.getColor(), ctx.getRepetitionCount());
    }
}
