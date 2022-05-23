%This function copies all X and Y Values between a start and end Point of a
%gcode file-cell-array

%input1 : start point
%input2 : end point
%input3 : gcode file as Cell

function [opt1] = get_points_nan(sp,ep,gcode_lines)

    pat1 = 'Y';
    pat2 = 'X';
    pat3 = 'G0';
    
    rgx = sprintf('\\s+%c([+-]?\\d+\\.?\\d*)','XY');
    h1 = zeros(100,2);
    h1_length = 1;
    
    %this code can be improved with pattern (see add_E) to reduce errors
    %with unexpected lines
    
    for ii=sp+1:ep-1
    
        %quelle https://de.mathworks.com/matlabcentral/answers/460610-extracting-numbers-from-a-g-code-file
        
        if contains(gcode_lines(ii),pat1) && contains(gcode_lines(ii),pat2)
    
            str = gcode_lines(ii);
            tkn = regexp(str,rgx,'tokens');
    
            %if it is a travel it inserts nan, this is essential to create
            %polys with inpoly
    
            if contains(str,pat3)

                h1(h1_length,:) = NaN;
                h1_length = h1_length+1;
                
            end
    
            h1(h1_length,1)=str2double(tkn{1,1}{1,1}{1,1});
            h1(h1_length,2)=str2double(tkn{1,1}{1,1}{1,2});
            h1_length = h1_length+1;
    
        end
    
    end
    
    if h1_length<100
    
        h1(h1_length:100,:) = [];
    
    end
    
    opt1 = h1;

end