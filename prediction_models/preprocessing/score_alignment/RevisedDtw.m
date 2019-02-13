% ======================================================================
%> @brief computes path through a distance matrix with simple Dynamic Time
%> Warping
%>
%> @param D: distance matrix
%>
%> @retval p path with matrix indices
%> @retval C cost matrix
% ======================================================================
function [p, C, jump, cost] = RevisedDtw(D, idx)
 
    % cost initialization
    C               = zeros(size(D));
    C(1,:)          = cumsum(D(1,:));
    C(:,1)          = cumsum(D(:,1));
    % traceback initialization
    DeltaP          = zeros(size(D));
    DeltaP(1,2:end) = 3; % (0,-1)
    DeltaP(2:end,1) = 2; % (-1,0)
    
    jump = zeros(2,1);
    cost = zeros(3,1);
    % penalty for jumping
    penalty = mean(D(:))*5;
    % flag: if allow jump
    flag = 0;
    
    % recursion
    for (n_A = 2:size(D,1))
        if (isempty(find(idx == n_A)))
            flag = 0;
        else
            flag = 1;
        end
        for (n_B = 2:size(D,2))
            % find preceding min (diag, column, row)
            % no continual jumps
            if (flag == 1 && n_B < size(D,2)-2 && max([DeltaP(n_A-1, n_B+1), DeltaP(n_A-1, n_B+2)]) < 4) %°æ°ø
                [fC_min, DeltaP(n_A,n_B)]   = min([C(n_A-1,n_B-1), C(n_A-1,n_B), C(n_A,n_B-1), C(n_A-1, n_B+1)+penalty, C(n_A-1, n_B+2)+penalty]);
            else
                [fC_min, DeltaP(n_A,n_B)]   = min([C(n_A-1,n_B-1), C(n_A-1,n_B), C(n_A,n_B-1)]);
            end
            C(n_A, n_B)                 = D(n_A,n_B) + fC_min;
        end
    end
    
    % traceback
    iDec= [-1 -1; -1 0; 0 -1; -1 1; -1 2; -1 3; -1 4]; % compare DeltaP contents: diag, vert, hori
    p   = size(D);  % start with the last element
    n   = [size(D,1), size(D,2)]; %[n_A, n_B];
    cmp = p(2)+1; % cmp is used to record the jump position
    cost(3) = D(end, end);
    while ((n(1) > 1) || (n(2) > 1))

        if DeltaP(n(1),n(2)) >= 4 % update jump
            jump(1) = jump(1) + 1;
            jump(2) = jump(2) + iDec(DeltaP(n(1),n(2)),2);
            cmp = n(2);
        end
        
        % update path (final length unknown)
        n = n + iDec(DeltaP(n(1),n(2)),:);
        if (n(2) < cmp)
            cost(3) = cost(3) + D(n(1),n(2));
        else
            cost(2) = cost(2) + D(n(1),n(2));
        end
        p   = [n; p];
    end   
    
    cost(1) = C(end,end);
end
