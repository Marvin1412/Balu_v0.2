% this functions search for a specific string inside an cell array of
% strings starting from a specific line

%input1 : momentary line number
%input2 : string to look for 
%input3 : cell array

function [opt1] = find_no_down(z,gcode_lines)
    pat1 = 'G0';
    pat2 = 'G1';
    i = 0;
    ii = z;
   while i~=1 
       if contains(gcode_lines(ii), pat1) == 0 && contains(gcode_lines(ii), pat2) == 0
            i = 1;
            opt1 = ii;
       else
            ii = ii+1;
       end
   end  
end