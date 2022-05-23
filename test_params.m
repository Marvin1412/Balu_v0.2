function [opt1] = test_params(gf,agz,nom_h,min_point,meshSize,dbr,min_cluster, max_cluster,show_clusters)
    
    gf = gf{1,1};
    a = agz;
    bad_counter_min = 0;
    bad_counter_max = 0;

    
    for i = 1:(a/nom_h)
    
        z_step = i*nom_h;
        g = eval(gf);
        h = fimplicit(g,[0 a]);
        h.MeshDensity = meshSize;
        
        XY_Data = [];
        XY_Data = zeros(length(h.XData),2);
        XY_Data(:,1) = h.XData(1,:);
        XY_Data(:,2) = h.YData(1,:);

        idx = dbscan(XY_Data,dbr,min_point);

        cluster_counter = max(idx(:));

        if cluster_counter < min_cluster

            if show_clusters==1
                figure
                gscatter(XY_Data(:,1),XY_Data(:,2),idx);
                figure
            end
            bad_counter_min = bad_counter_min + 1;

        elseif cluster_counter > max_cluster

            if show_clusters==1
                figure
                gscatter(XY_Data(:,1),XY_Data(:,2),idx);
            end
            bad_counter_max = bad_counter_max + 1;

        end

    
    end

    if bad_counter_min > 0 && bad_counter_max > 0
        opt1 = append('You have ',num2str(bad_counter_min),' bad Layers, with not enough clusters and',num2str(bad_counter_max),' with too many Clusters :/');
    elseif bad_counter_min > 0
        opt1 = append('You have',num2str(bad_counter_min),' bad Layers, with not enough clusters.');
    elseif bad_counter_max > 0
        opt1 = append('You have ',num2str(bad_counter_max),' bad Layers, with too many clusters.');
    elseif bad_counter_min == 0 && bad_counter_max == 0
        opt1 = 'You are good to go.';
    else
        opt1 = 'There appears to be an error';
    end

end