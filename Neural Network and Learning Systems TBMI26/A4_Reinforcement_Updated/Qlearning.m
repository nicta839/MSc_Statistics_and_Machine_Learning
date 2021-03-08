%% Initialization
%  Initialize the world, Q-table, and hyperparameters
world_nb = 2;
gwinit(world_nb);
state = gwstate;

% param and Q table
action = [1, 2, 3, 4];
prob = [1, 1, 1, 1];

Q = rand(state.ysize, state.xsize, size(action, 2));
Q(1,:,2) = -inf;
Q(state.ysize,:,1) = -inf;
Q(:,1,4) = -inf;
Q(:,state.xsize,3) = -inf;

discount = 0.9; %or gamma
learn_rate = 0.3; %or alpha
max_step = 100;
episodes = 2000;




%% Training loop
%  Train the agent using the Q-learning algorithm.

for t = 1:episodes
        gwinit(world_nb);
        start_state = gwstate;
        explor_factor = getepsilon(t, episodes);
        
        for i = 1:max_step
            [a, oa] = chooseaction(Q, start_state.pos(1), start_state.pos(2), action, prob, explor_factor);
            state_i = gwaction(a);
            while ~state_i.isvalid
                [a, oa] = chooseaction(Q, start_state.pos(1), start_state.pos(2), action, prob, explor_factor);
                state_i = gwaction(a);
            end
            
            Q(start_state.pos(1), start_state.pos(2), a) = (1 - learn_rate)* Q(start_state.pos(1), start_state.pos(2), a) + ...
                learn_rate * (state_i.feedback + discount * max(Q(state_i.pos(1), state_i.pos(2), :)));
            
            
           if state_i.isterminal
               break
           else
               start_state = state_i;
           end
        end
end

    

%% Test loop
%  Test the agent (subjectively) by letting it use the optimal policy
%  to traverse the gridworld. Do not update the Q-table when testing.
%  Also, you should not explore when testing, i.e. epsilon=0; always pick
%  the optimal action.

optim_policy = getpolicy(Q);
gwinit(world_nb);
i = 1;
max_step = 100;
gwdraw

while i < max_step
    step_cur = gwstate;
    a = optim_policy(step_cur.pos(1), step_cur.pos(2));
    gwplotarrow(step_cur.pos, a);
    next = gwaction(a);
    gwdraw
    if next.isterminal
        break
    else
        i = i + 1;
    end
end

V_test = getvalue(Q);
% surf(V_test)



