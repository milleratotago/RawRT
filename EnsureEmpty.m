function EnsureEmpty(LeftOverArgs)
    % Halt if there are any left-over arguments:
    if numel(LeftOverArgs)>0
        disp('These arguments could not be processed:');
        for i=1:numel(LeftOverArgs)
            disp(LeftOverArgs{i});
        end
        assert(false,'Must halt');
    end
end
