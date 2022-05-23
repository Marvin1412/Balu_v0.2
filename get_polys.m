
%this function is used to identify unique polys and filter those created by
%multiple walls
%number of Regions should always be one

function [opt1] = get_polys(point_mat)
    
    warning('off','all')
   
    %use polyshape to clean point_mat
    pgon = polyshape(point_mat);
    point_mat = pgon.Vertices;
    
    %generate poly-Cell
    polys = cell(0,1);
    polys{1,1} = [];
    poly_counter = 1;
    
    for i=1:length(point_mat)
    
        if isnan(point_mat(i))
            poly_counter = poly_counter + 1;
            polys{poly_counter,1} = [];
        end
    
        l = size(polys{poly_counter,1});
        l = l(1,1)+1;
        polys{poly_counter,1}(l,:) = point_mat(i,:);
    
    end
    
    if length(polys)>1
    
        % pos1: X-Center
        % pos2: Y-Center
        % pos3: Area
        % pos4: position in polys
    
        %gather necesarry Informations about the Polys to determine if they
        %are unique or not
        %primary marker is the Center point, secondary marker is the Area
        %secondary marker is not implemented yet
    
        for i=1:length(polys)
    
            pgon = polyshape(polys{i,1});
            [pgon_info(i,1),pgon_info(i,2)] = centroid(pgon);
            pgon_info(i,3) = area(pgon);
            pgon_info(i,4) = i;
    
        end
    
        X = [pgon_info(:,1),pgon_info(:,2)];
        idx = dbscan(X,1,1);
        cluster_counter = max(idx);
        
        %now keep the Pgon with the smallest Area, cause it is the most
        %inside one
    
        del_total = [];
    
        for i=1:cluster_counter
    
            del_info = [];
    
            for ii=1:length(idx)
    
                if idx(ii) == i
    
                    ldel = size(del_info);
                    ldel = ldel(1,1)+1;
                    del_info(ldel,1) = pgon_info(ii,3);
                    del_info(ldel,2) = pgon_info(ii,4);
    
                end
    
            end
    
            [del_min(:,1),del_min(:,1)] = min(del_info,[],1);
            del_info(del_min(1,1),:) = [];
    
            ldel = size(del_info);
            ldel = ldel(1,1);
    
            for iii=1:ldel
                del = size(del_total);
                del = del(1,1)+1;
                del_total(del,1) = del_info(iii,2);
            end
    
        end
        
        for i=1:length(del_total)
    
            polys{del_total(i),1} = [];
    
        end
        
    end
    
    polys = polys(~cellfun('isempty',polys));
    opth = [];

    for i=1:length(polys)
        
        %after second poly insert NaN to split them
        if i>1
            opths = size(opth);
            opths = opths(1,1)+1;
            opth(opths,:) = NaN;
        end

        for ii=1:length(polys{i,1})

            opths = size(opth);
            opths = opths(1,1)+1;
            opth(opths,:) = polys{i,1}(ii,:);

        end

    end

    warning('on','all')
    opt1 = opth;

end