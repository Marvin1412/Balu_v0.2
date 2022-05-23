%this function search for the next Z-Value in the given cell while
%searching upwards

%input1 : momentary line number
%input2 : cell array

function [opt1] = find_z_up(z,gcode_lines)
   i = 0; 
   ii = z;
   rgx = sprintf('\\s+Z([+-]?\\d+\\.?\\d*)');
   while i~=1
       
        %quelle https://de.mathworks.com/matlabcentral/answers/460610-extracting-numbers-from-a-g-code-file
       
        str = gcode_lines(ii);        
        tkn = regexp(str,rgx,'tokens');
        if isempty(tkn{1,1})==0
            opt1 = str2double(tkn{1,1}{1,1}{1,1});
            i = 1;            
        elseif ii ==1
            opt1 = 0;
        else
            ii = ii-1;          
        end    
   end    
end