%% Initialization
%  Init world
world = 2;
gridWorld = gwinit(world);

% Define possible actions and associated probabilities
actions = [1, 2, 3, 4];
probs = [1, 1, 1, 1];

Q = rand(gridWorld.ysize, gridWorld.xsize, length(actions)); % Init Q = [[M x N], [M x N], [M x N], [M x N]]
Q(gridWorld.ysize,:,1) = -inf; % Set first Matrix in Q last row to -Inf
Q(1,:,2) = -inf; % Set second Matrix in Q first row to -Inf
Q(:,gridWorld.xsize,3) = -inf; % Set third Matrix in Q last column to -Inf
Q(:,1,4) = -inf; % Set fourth Matrix in Q first column to -Inf

% Define hyperparameters
discount = 0.9; 
learning = 0.9;
nbrEpisodes = 1500;



%% Training loop
%  Train the agent using the Q-learning algorithm.

for episode = 1:nbrEpisodes % Iterate over all episodes (2000)
    gwinit(world);
    startState = gwstate; % Initialize startingState
    currentState = startState; % Set startingState to currentState
    epsilon = getepsilon(episode, nbrEpisodes); % Epsilon changes based on episodes iterated (gets smaller over time, explore -> exploit)  
    % epsilon = 0.9; % for report
    while ~currentState.isterminal
        [a, oa] = chooseaction(Q, currentState.pos(1), currentState.pos(2), actions, probs, epsilon); % Choose action based on position, possible moves and probabilities
        nextState = gwaction(a); % Get nextState based on chosen action
        while ~nextState.isvalid
            [a, oa] = chooseaction(Q, currentState.pos(1), currentState.pos(2), actions, probs, epsilon);
            nextState = gwaction(a);
        end
        % Update estimated Q-function
        Q(currentState.pos(1), currentState.pos(2), a) = (1 - learning)* Q(currentState.pos(1), currentState.pos(2), a) + ...
            learning * (nextState.feedback + discount * max(Q(nextState.pos(1), nextState.pos(2), :)));
        currentState = nextState; % Set nextState to currentState
    end
end
    

%% Test loop
%  Test the agent (subjectively) by letting it use the optimal policy
%  to traverse the gridworld. Do not update the Q-table when testing.
%  Also, you should not explore when testing, i.e. epsilon=0; always pick
%  the optimal action.

optPolicy = getpolicy(Q); % Get optimal policies
gwinit(world); 
gwdraw

currentState = gwstate;
while ~currentState.isterminal
    optimalAction = optPolicy(currentState.pos(1), currentState.pos(2));
    nextState = gwaction(optimalAction);
    gwdraw
    gwplotarrow(currentState.pos, optimalAction);
    currentState = nextState;
end
%% Report plotting
%Plot V function landscape
V = getvalue(Q);
surf(V)
% Plot policy in all states
P = getpolicy(Q);
gwdraw
gwdrawpolicy(P)
