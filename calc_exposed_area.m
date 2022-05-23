
%calculation of the exposed Area assuming a layed down string looks like
%this:

%       + * * * * * * * * * +
%     +                        +
%    +                          +
%    +                          +
%     +                        +
%       + * * * * * * * * * +
% bad ascii Art but you get the concept 
% where the + are used to calculate the Area which is exposed (so top and
% bottom is ignored

function  [opt1] = calc_exposed_area(p1,p2,nom_h)

    opt1 = pi*nom_h*norm(p1-p2);

end