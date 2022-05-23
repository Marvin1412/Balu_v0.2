%calculation of the E Value assuming the String is a Rectangle with halves
%of a circle at each side 
%like this: 

%        * * * * * * * * * * *
%     *                         *
%    *                           *
%    *                           *
%     *                         *
%        * * * * * * * * * * *
% bad ascii Art but you get the concept 
%fd = filament_diameter

function [opt1] = calc_E(p1,p2,nom_h,nom_w,fd)
    
    length = norm(p1-p2);
    area = nom_h*nom_w - (nom_h^2 - 0.25*pi*nom_h^2);
    e_volume= length*area;    
    opt1 = e_volume/(pi*fd^2*0.25);    

end