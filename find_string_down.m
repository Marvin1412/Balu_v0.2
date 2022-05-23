% this functions search for a specific string inside an cell array of
% strings starting from a specific line

%input1 : momentary line number
%input2 : string to look for 
%input3 : cell array

function [opt1] = find_string_down(z,str,gcode_lines)
    
    pat1 = str;
    i = 0;
    ii = z;

    while i~=1
        if ii<= length(gcode_lines)
            if contains(gcode_lines(ii), pat1)
                i = 1;
                opt1 = ii;
            else
                ii = ii+1;
            end
        else
            %if it cant find the string it returns the end of the Array
            opt1 = length(gcode_lines);
            disp('err?');
            i = 1;
        end
    end
    
end