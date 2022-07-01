

function [opt1] = del_points (del_factor,points)
    
    points1 = points;
    del_factor = floor(del_factor);

    for i=1:length(points)
    
        if mod(i,del_factor) ~= 0
        
            points(i,:) = 0;

        end

    end

    points( ~any(points,2), : ) = [];

    opt1 = points;

end

