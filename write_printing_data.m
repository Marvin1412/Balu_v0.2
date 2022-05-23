function write_printing_data(sgcode,point_density_factor,nom_w,agz_base,print_speed,travel_speed,retraction_distance,retraction_speed,travel_opti,gf)
    
    sgcode = erase(sgcode,'.gcode');
    sgcode = append(sgcode,'_printData.txt');

    fid = fopen(sgcode, 'wt+');
    fprintf(fid,'point_density_factor = %s \n',num2str(point_density_factor));
    fprintf(fid,'Soll-Strangbreite = %s \n',num2str(nom_w));
    fprintf(fid,'Soll-Zellgröße = %s \n',num2str(agz_base));
    fprintf(fid,'print_speed = %s \n',num2str(print_speed));
    fprintf(fid,'travel_speed = %s \n',num2str(travel_speed));
    fprintf(fid,'retraction_distance = %s \n',num2str(retraction_distance));
    fprintf(fid,'retraction_speed = %s \n',num2str(retraction_speed));
    fprintf(fid,'travel_opti = %s \n',num2str(travel_opti));
    h1 = append('Formula: ', gf,'\n');
    fprintf(fid,h1);
    fclose(fid);   

end