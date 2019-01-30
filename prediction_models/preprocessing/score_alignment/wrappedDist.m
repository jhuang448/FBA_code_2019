function D = wrappedDist(midi, pitchcontour , N)

% check if inputs are vectors or not
midi = checkVect(midi);
pitchcontour = checkVect(pitchcontour);

D = zeros(numel(midi), numel(pitchcontour));
for i = 1:numel(midi)
    for j = 1:numel(pitchcontour)
        diff = abs(midi(i) - pitchcontour(j));
        D(i,j) = mod(diff, N);
        D(i,j) = min(D(i,j), 12-D(i,j)) + min(1, floor(diff/N));
    end
end

end

function vect = checkVect(vect)
    [r,c] = size(vect);
    if c ~= 1
        if r == 1
            vect = vect';
        else
            disp('Only works for vectors!')
        end
    end
end