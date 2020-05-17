function [A, B] = ABmeasures(PrHit, PrFA)  % Not vectorized
    % Compute the nonparametric measures of sensitivity & bias A & B
    % from the probabilities of hits and false alarms.
    % A ranges from  0 (100% wrong discrimination) through 0.5 (chance) to +1 (perfect discrimination)
    % B ranges from +1 (extreme bias to say "no") to -1 (extreme bias to say "yes")
    
    % Compute A, from Aaronson & Watts, 1987, Equations 2 & 9
    if PrHit >= PrFA
        if (PrFA == 1.0) || (PrHit == 0.0)
            A = 0.5; % PrHit and PrFA are equal at 0 or 1.
        else
            A = 0.5 + (PrHit - PrFA) * (1 + PrHit - PrFA) / ( 4 * PrHit * (1 - PrFA) );
        end
    else
        A = 0.5 - (PrFA - PrHit) * (1 + PrFA - PrHit) / ( 4 * PrFA * (1 - PrHit) );
    end
    
    % Compute B from Aaronson & Watts, 1987, Equations 4 & 12
    if ( (PrHit == 0) || (PrHit == 1) ) && ( (PrFA  == 0) || (PrFA  == 1) )
        B = 0;
    elseif PrHit >= PrFA
        B = ( PrHit * (1 - PrHit) - PrFA * (1 - PrFA) ) / ...
            ( PrHit * (1 - PrHit) + PrFA * (1 - PrFA) );
    else
        B = ( PrFA * (1 - PrFA) - PrHit * (1 - PrHit) ) /  ...
            ( PrFA * (1 - PrFA) + PrHit * (1 - PrHit) );
    end
    
end

