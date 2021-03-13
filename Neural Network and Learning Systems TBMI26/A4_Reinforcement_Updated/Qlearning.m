%% Initialization
%  Init world
world = 4;
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
epsillon = 0.1;
nbrEpisodes = 2000;



%% Training loop
%  Train the agent using the Q-learning algorithm.

for episode = 1:nbrEpisodes % Iterate over all episodes (2000)
    gwinit(world);
    startState = gwstate; % Initialize startingState
    currentState = startState; % Set startingState to currentState
    epsillon = getepsilon(episode, nbrEpisodes); % Epsillon changes based on episodes iterated (gets smaller over time, explore -> exploit)  
    while ~currentState.isterminal
        [a, oa] = chooseaction(Q, currentState.pos(1), currentState.pos(2), actions, probs, epsillon); % Choose action based on position, possible moves and probabilities
        nextState = gwaction(a); % Get nextState based on chosen action
        while ~nextState.isvalid
            [a, oa] = chooseaction(Q, currentState.pos(1), currentState.pos(2), actions, probs, epsillon);
            nextState = gwaction(a);
        end
        % Update estimated Q-function
        Q(currentState.pos(1), currentState.pos(2), a) = (1 - epsillon)* Q(currentState.pos(1), currentState.pos(2), a) + ...
            epsillon * (nextState.feedback + discount * max(Q(nextState.pos(1), nextState.pos(2), :)));
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
