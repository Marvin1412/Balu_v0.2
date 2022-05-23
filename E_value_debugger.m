clc
clear all
fid = fopen('C:\Users\marvi\Desktop\ThesisNeu\Coding\G-code Files to parse\Ausarbeitung\CE3_idd_v5_dt_tpms.gcode');
tline = fgetl(fid);
gcode_lines = cell(0,1);

last_z = [];
ii = 1;


%speichert den Gcode Zeilenweise in ein Cell-Array
while ischar(tline)
    %fget kein Zeitfresser
    gcode_lines{end+1,1} = append(tline);
    tline = fgetl(fid);
end


rgx = sprintf('\\s+E([+-]?\\d+\\.?\\d*)');
E_values = zeros(length(gcode_lines),1);
E_values_length = 1;

for i=1:length(gcode_lines)
        disp(i);
        str = gcode_lines(i);        
        tkn = regexp(str,rgx,'tokens');

        if ~isempty(tkn{1,1}) 
            E_values(E_values_length,1) = str2double(tkn{1,1}{1,1}{1,1});
            E_values_length = E_values_length + 1;
        end
end

E_values( ~any(E_values,2), : ) = [];

plot(E_values)


