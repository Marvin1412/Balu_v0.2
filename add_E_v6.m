%Takes a Cell Array of GCode lines and adds up the e-values so
%absolute extrusion possible, cause it is better for small unit-cells

function [opt1] = add_E_v6 (gcode_lines,sp,ep,E_last,E_abs)
    
    pat1 = whitespacePattern + ("E"|"E-") + digitsPattern;
    pat2 = whitespacePattern + ("E"|"E-") + digitsPattern + "." + digitsPattern;
    pat3 = whitespacePattern + ("E"|"E-");
    
    for i=sp:ep
    
        str = gcode_lines(i,1);
    
        if contains(str,pat1)
    
            %changing E-Step the slow but reliable way
            Ev = extractAfter(str,pat3);
            Ev = Ev{1,1};
            Ev = sscanf(Ev,'%f');
            gcode_line_new = erase(str,pat2);
            gcode_line_new = erase(gcode_line_new,pat1);
            Ev = Ev - E_last + E_abs;
            Ev = sprintf('%6f',Ev);
            gcode_lines(i,1) = append(gcode_line_new,' E',Ev);
    
        end   
    
    end       
    
    opt1 = gcode_lines;

end