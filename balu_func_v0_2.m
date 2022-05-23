function balu_func_v0_2(print_speedf,travel_speedf,retraction_distancef,retraction_speedf,nom_hf,nom_wf,alphaf,filament_diameterf,min_pointf,agzf,db_radiusf,point_density_factorf,meshSizef,filepathf,gfunctionf,travel_optif,direction_downf,inner_wallf)

%FILE HAS TO USE M38!
%OPTIMATE WALL PRINTING ORDER HAS TO BE TURNED OFF!

nom_h = nom_hf; %nominelle Höhe
nom_w = nom_wf; %nominelle Breite
point_num = min_pointf;%minpoint für DBSCAN
inner_wall = inner_wallf;
direction_down = direction_downf;
travel_opti = travel_optif;

alpha = alphaf; %Bastelfaktor
filament_diameter = filament_diameterf;
E_abs = 0;

add_E_data = [];

fill_area = 0;
agz_base = agzf; %Zellgröße in mm 1.4 müsste 0.2mmm loch sein bis 0.1mm 
meshSize = meshSizef; %
radius_base = db_radiusf;%radius für DBSCAN
point_density_factor = point_density_factorf; % n points per mm^2

prev_z = 100000;

print_speed = print_speedf; %mm/min
travel_speed = travel_speedf; %mm/min

retraction_speed = retraction_speedf; %mm/min
retraction_distance = retraction_distancef; %mm

%z scaling parameter
enable_z_scaling = 0;
z_scaling_formula = '@(z) 2-z';


z_f = eval(append(z_scaling_formula),'*agz_base');
r_f = eval(append(z_scaling_formula),'*radius_base');
z_scaling_start = 0;
z_scaling_end = 0.8;

%tpms function has to be put here 
%Gyroid
gf = gfunctionf;

%.gcode file to edit has to be input here
sgcode = filepathf;

fid = fopen(sgcode);
tline = fgetl(fid);
gcode_lines = cell(100000000,1);
gcode_lines_length = 1;

last_z = [];
ii = 1;
del_marker = [];
del_factor = [];


%saving gcode to cell-array
while ischar(tline)
    gcode_lines{gcode_lines_length,1} = append(tline);
    tline = fgetl(fid);
    gcode_lines_length = gcode_lines_length +1;
end

gcode_lines = gcode_lines(~cellfun('isempty',gcode_lines));
ia = 1;

current_layer_pos = [];
next_layer_pos = [];
i = 0;
while i~=1

    if strcmp(gcode_lines(ii),';TYPE:FILL')==1

        disp('Infill found at line');
        disp(ii);
        disp('Infill layer height');
        z = find_z_up(ii,gcode_lines);
        disp(z);
       
        
        %collecting necesarry Information for parsing
                
        l2 = find_no_down(ii+2,gcode_lines);
               
        %Look for the E-Values
        %get_E returns MAX-Value 

        E_last = get_E(ii,l2,gcode_lines);
        E_abs = get_E(ii-50,ii,gcode_lines);

        gcode_infill_lines_all = {};
        z = find_z_up(ii,gcode_lines);

        if z == 0
            errordlg('could not find Z-Value')
        end
        
        %extract outer Wall points for Travel route
        if travel_opti ==1 || inner_wall == 0
            outer_wall = [];
            if direction_down == 1
                h1 = find_string_down(ii,'WALL-OUTER',gcode_lines);
                h2 = find_no_down(h1+1,gcode_lines);
                outer_wall = get_points_nan(h1+1,h2,gcode_lines);
            elseif direction_down == 0
                h1 = find_string_up(ii,'WALL-OUTER',gcode_lines);
                h1 = find_string_up(h1-1,'WALL-OUTER',gcode_lines);
                h2 = find_no_down(h1+1,gcode_lines);
                outer_wall = get_points_nan(h1+1,h2,gcode_lines);
            end
        end

        %save last infill point to have the correct start point for the
        %wall
        last_infill_point = get_last_point_up(l2,gcode_lines);

        %deleting Infill, works good
        gcode_lines(ii+1:l2-1) =[];

        %creating point_mat for Infill border, its sometimes convenient to
        %use a outer Wall as boder

        if inner_wall == 1
            if direction_down == 1
                h1 = find_string_down(ii,';TYPE:WALL-INNER',gcode_lines);
                h2 = find_no_down(h1+2,gcode_lines);
                point_mat = get_points_nan(h1,h2,gcode_lines);
                point_mat = get_polys(point_mat);
            elseif direction_down ==0
                h1 = find_string_up(ii,';TYPE:WALL-INNER',gcode_lines);
                h2 = find_no_down(h1+2,gcode_lines);
                point_mat = get_points_nan(h1,h2,gcode_lines);
                point_mat = get_polys(point_mat);
            end
        elseif inner_wall == 0
            point_mat = get_polys(outer_wall);
        end

        %generate Points
        
        if enable_z_scaling == 1
            if z >= z_scaling_start && z<= z_scaling_end
                agz = z_f(z);
                radius = radius_base*4;
            else 
                agz = agz_base;
                radius = radius_base;
            end
        else
            agz = agz_base;
            radius = radius_base;
        end

        z_step = z;
        g = eval(gf);
        h = fimplicit(g,[0 agz]);
        h.MeshDensity = meshSize;
        XY_Data = zeros(length(h.XData),2);
        XY_Data(:,1) = h.XData(1,:);
        XY_Data(:,2) = h.YData(1,:);

        %to multiplicate the right amount of points a rectangle space using
        %the min/max X and Y-Coordinates of point_mat
        %Calculating n and m factor
       
        XY_Max = max(point_mat,[],1);
        XY_Min = min(point_mat,[],1);

        X_dist = XY_Max(1,1)-XY_Min(1,1);
        Y_dist = XY_Max(1,2)-XY_Min(1,2);

        n = ceil(X_dist/agz)+3;
        m = ceil(Y_dist/agz)+3;

        %Shift base-cell to bottem left corner of rectangle(both min Values)
        
        if z == prev_z
            XY_diff = XY_Min - prev_XY_Min;
            XY_steps = floor(XY_diff/agz)-2;
            XY_Min = prev_XY_Min + agz*XY_steps;
            XY_Data = XY_Data + XY_Min;
        else
            XY_Data = XY_Data + XY_Min;
        end

        prev_XY_Min = XY_Min;
        XY_Data_Multi = zeros(length(XY_Data)*n*m,2);
        XY_Data_Multi_length = 1;

        %multiplicate
        for i3=0:n-1
            for i8=0:m-1
                for i7=1:length(XY_Data)
                    XY_Data_Multi(XY_Data_Multi_length,1) = XY_Data(i7,1)+(i3*agz);
                    XY_Data_Multi(XY_Data_Multi_length,2) = XY_Data(i7,2)+(i8*agz);
                    XY_Data_Multi_length = XY_Data_Multi_length+1;
                end
            end
        end

        XY_Data = XY_Data_Multi;
        clear XY_Data_Multi;
        
        %End of generating points
        
        in = 0;
        warning('off','all')
        pgon = polyshape(point_mat);
        in = isinterior(pgon,XY_Data);
        warning('on','all')

        for i=1:length(XY_Data)
            if in(i) == 0
                XY_Data(i,:) = 0;
            end
        end

        in = 0;
       
        %Delete Zero rows
        XY_Data( ~any(XY_Data,2), : ) = [];

        %now starts the Clustering and gcode-write process

        idx = [];
        idx = dbscan(XY_Data,radius,point_num);

        cluster_counter = max(idx(:));
              
        for i4=1:cluster_counter
            %prelocatingforspeed
            zws = zeros(length(XY_Data),2);
            zws_length = 1;
            %save points of ONE cluster to zws
            for i5=1:length(XY_Data)
                if idx(i5,1) == i4
                    zws(zws_length,:) = XY_Data(i5,:);
                    zws_length = zws_length+1;
                end
            end

            %Nullen löschen
            zws = zws(any(zws,2),:);

            % reduce points of a cluster if they exceed the
            % point_density_factor
            zws_min = min(zws);
            zws_max = max(zws);
            zws_area = (zws_max(1,1)-zws_min(1,1))*(zws_max(1,2)-zws_min(1,2));
               
            if length(zws)> 30 && length(zws)/zws_area > point_density_factor
                del_factor = (length(zws)/zws_area)/point_density_factor;
                zws = del_points(del_factor,zws);
                zws_length = length(zws);
            end
          
            %if it crashes here your point_density_factor is too low and it
            %deletes all but one point from a Cluster

            zws = sortrows(zws,1);
            x_d = zws(length(zws),1) - zws(1,1);

            zws = sortrows(zws,2);
            y_d = zws(length(zws),2) -zws(1,2);

            zws2 = zeros(length(zws),2);
            zws2_length = 1;

            gcode_infill_lines = cell(length(zws),1);
            gcode_infill_lines_length = 1;
            
            %decide X-or Y-dominance
            if x_d > y_d 
                zws = sortrows(zws,1);
                PQ = zws(1,:);
                zws(1,:)=[];
                zws2(zws2_length,:) = PQ;
                zws2_length = zws2_length+1;
                for i6=1:length(zws2)-1
                    k = dsearchn(zws,PQ);
                    PQ = zws(k,:);
                    zws(k,:)=[];
                    zws2(zws2_length,:) = PQ;
                    zws2_length = zws2_length+1;
                end

                %write Gcode for cluster to cell-array

                for i =1:length(zws2)
                    if i == 1 %first point of cluster is a travel moove
                        h1 = zws2(i,:);
                        %first cluster doesnt need an optimized Travel
                        %route

                        %retraction
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f E%6f',retraction_speed,E_abs-retraction_distance);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;
                        if i4 >1
                            if travel_opti == 1
                                travel_route = [];
                                travel_route = get_travel_route_v2(last_point,h1,outer_wall);
                                %set travel speed
                                gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f',travel_speed);
                                gcode_infill_lines_length = gcode_infill_lines_length +1;
                                %travel path
                                travel_route_size = size(travel_route);
                                for i100=1:travel_route_size(1,1)
                                    gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 X%6.5f Y%6.5f',travel_route(i100,1),travel_route(i100,2));
                                    gcode_infill_lines_length = gcode_infill_lines_length +1;
                                end
                            else
                                gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f X%6.5f Y%6.5f',travel_speed,h1);
                                gcode_infill_lines_length = gcode_infill_lines_length +1;
                            end
                        else
                            gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f X%6.5f Y%6.5f',travel_speed,h1);
                            gcode_infill_lines_length = gcode_infill_lines_length +1;
                        end
            
                        %Extrude
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f E%6f',retraction_speed,E_abs);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;

                        %switching back to print speed
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f',print_speed);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;
                    else %all other points are Print mooves
                        %it is possible to place a travel-moove Catcher
                        %here that inserts a travel moove if the distance
                        %is to long which can happen for multiple reasons
                        h1 = zws2(i,:);
                        h1(1,3) = calc_E(zws2(i-1,:),zws2(i,:),nom_h,nom_w,filament_diameter)*alpha+E_abs;
                        E_abs = h1(1,3);
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G1 X%6.5f Y%6.5f E%2.10f',h1);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;
                        fill_area = fill_area + calc_exposed_area(zws2(i-1,:),zws2(i,:),nom_h);
                    end
                end
            else
                PQ = zws(1,:);
                zws(1,:)=[];
                zws2(zws2_length,:) = PQ;
                zws2_length = zws2_length+1;
                for i6=1:length(zws2)-1
                    k = dsearchn(zws,PQ);
                    PQ = zws(k,:);
                    zws(k,:)=[];
                    zws2(zws2_length,:) = PQ;
                    zws2_length = zws2_length+1;
                end
                for i =1:length(zws2)
                    if i == 1 
                        h1 = zws2(i,:);
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f E%6f',retraction_speed,E_abs-retraction_distance);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;
                        if i4 >1
                            if travel_opti ==1
                                travel_route = [];
                                travel_route = get_travel_route_v2(last_point,h1,outer_wall);

                                %set travel speed
                                gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f',travel_speed);
                                gcode_infill_lines_length = gcode_infill_lines_length +1;

                                %travel path
                                travel_route_size = size(travel_route);
                                for i100=1:travel_route_size(1,1)
                                    gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 X%6.5f Y%6.5f',travel_route(i100,1),travel_route(i100,2));
                                    gcode_infill_lines_length = gcode_infill_lines_length +1;
                                end
                            else
                                gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f X%6.5f Y%6.5f',travel_speed,h1);
                                gcode_infill_lines_length = gcode_infill_lines_length +1;
                            end
                        else
                            gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f X%6.5f Y%6.5f',travel_speed,h1);
                            gcode_infill_lines_length = gcode_infill_lines_length +1;
                        end

                        %Extrude
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f E%6f',retraction_speed,E_abs);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;

                        %switching back to print speed
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G0 F%6f',print_speed);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;

                    else 
                        h1 = zws2(i,:);
                        h1(1,3) = calc_E(zws2(i-1,:),zws2(i,:),nom_h,nom_w,filament_diameter)*alpha+E_abs;
                        E_abs = h1(1,3);
                        gcode_infill_lines{gcode_infill_lines_length,1} = sprintf('G1 X%6.5f Y%6.5f E%2.10f',h1);
                        gcode_infill_lines_length = gcode_infill_lines_length +1;
                        fill_area = fill_area + calc_exposed_area(zws2(i-1,:),zws2(i,:),nom_h);
                    end
                end
            end

            %Append Gcdoe lines to gcdoe lines all
            gcode_infill_lines_all = vertcat(gcode_infill_lines_all,gcode_infill_lines);
            last_point(1,:) = zws2(length(zws2),:);
        end
        
        %adding last point from old Infill cause it is the Start point for
        %first wall

        gcode_last_point = cell(1,1);
        gcode_last_point_length = 1;
        h1 = last_infill_point(1,:);

        %adding retraction moove        
        gcode_last_point{gcode_last_point_length,1} = sprintf('G0 F%6f E%6f',retraction_speed,E_abs-retraction_distance);
        gcode_last_point_length = gcode_last_point_length +1;

        %travel Moove
        gcode_last_point{gcode_last_point_length,1} = sprintf('G0 F%6f X%6.5f Y%6.5f',travel_speed, h1);
        gcode_last_point_length = gcode_last_point_length +1;
     
        %extract again
        gcode_last_point{gcode_last_point_length,1} = sprintf('G0 F%6f E%6f',retraction_speed,E_abs);
        gcode_last_point_length = gcode_last_point_length +1;

        %switching back to print speed
        gcode_last_point{gcode_last_point_length,1} = sprintf('G0 F%6f',print_speed);
        gcode_last_point_length = gcode_last_point_length +1;
        

        %Append last point
        gcode_infill_lines_all = vertcat(gcode_infill_lines_all,gcode_last_point);

        %before Adding gcode_infill_lines_all add the E-Steps to the other
        %lines till next infill is found 
        
        ep = [];
        ep = find_string_down(ii+1,';TYPE:FILL',gcode_lines);
        gcode_lines = add_E_v6(gcode_lines,ii,ep,E_last,E_abs);
        
        %now all left is adding the new Infill
        %splittling the Gcode in two halfes at ii
        %append Gcode_lines_full to first half
        %append second half to first append

        gh1 = gcode_lines(1:ii,1);
        gh2 = gcode_lines(ii+1:length(gcode_lines),1);
        gh1 = vertcat(gh1,gcode_infill_lines_all);
        gcode_lines = vertcat(gh1,gh2);
        gh1 = [];
        gh2 = [];
        ii = ii + length(gcode_infill_lines_all);
        ia = ia + 1;
        ii=ii+2;
        disp('layer finished')
        prev_z = z;
    elseif ii == length(gcode_lines)
        disp('Cannot find more Infill');
        i =1;
    else
        ii=ii+1;
    end

end

%Write the Cell to a .txt doc
sgcode = erase(sgcode,'.gcode');
sgcode = append(sgcode,'_tpms.gcode');
fid = fopen(sgcode, 'wt+');

%does the same as a for loop running through all lines of gcode and
%printing them line by line, but faster

fprintf(fid,'%s \n',gcode_lines{:});
fclose(fid);
%write_printing_data(sgcode,point_density_factor,nom_w,agz_base,print_speed,travel_speed,retraction_distance,retraction_speed,travel_opti,gf);
disp('Berechnete Oberfläche des Infills;')
disp(fill_area)
disp('Parsingvorgang abgeschlossen.')

end




