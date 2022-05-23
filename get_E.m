%copy from ii Up n Points and find the biggest E-Value

function [opt1] = get_E(sp,ep,gcode_lines)

    rgx = sprintf('\\s+E([+-]?\\d+\\.?\\d*)');
    E_values = zeros((ep-sp),1);
    E_values_length = 1;
    
    for i=sp:ep
        str = gcode_lines(i);
        tkn = regexp(str,rgx,'tokens');
        if ~isempty(tkn{1,1})
            E_values(E_values_length,1) = str2double(tkn{1,1}{1,1}{1,1});
            E_values_length = E_values_length + 1;
        end
    end
    
    if max(E_values)==0
        opt1 = get_E(sp-10,ep,gcode_lines);
    else
        opt1 = max(E_values);
    end
end