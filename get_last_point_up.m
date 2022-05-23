% This function looks for the next point up from a starting point and is
% very usefull

function [opt1] = get_last_point_up(sp,gcode_lines)     

    rgx = sprintf('\\s+%c([+-]?\\d+\\.?\\d*)','XY');
    str = gcode_lines(sp);                                 
    tkn = regexp(str,rgx,'tokens');    

    if isempty(tkn{1,1})        
        opt1 = get_last_point_up(sp-1,gcode_lines);        
    else        
        opt1(1,1)=str2double(tkn{1,1}{1,1}{1,1});
        opt1(1,2)=str2double(tkn{1,1}{1,1}{1,2});        
    end
          
end


