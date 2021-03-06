clc
clear all
close all
videoline=0;
fidin=fopen('/inputlist.txt');
while ~feof(fidin)
    tline=fgetl(fidin);
    if isempty(tline)
        continue;
    end
    videoline=videoline+1;
    file_joint_positions=sprintf('%s/hlpf_features.mat',tline);
    load(file_joint_positions);
    
    
    total_min = [ min(norm_positions,[],2)' , min(dist_relations,[],2)' , min(ort_relations,[],2)' , min(angle_relations,[],2)'  ...
        min(min(cartesian_trajectory,[],3),[],1) , min(min(radial_trajectory,[],3),[],1) ...
        min(min(dist_relation_trajectory,[],3),[],1) , min(min(ort_relation_trajectory,[],3),[],1) ...
        min(min(angle_relation_trajectory,[],3),[],1)];    
    l1_total_min= bsxfun(@times,total_min,1./(sum(total_min)));%% l1正则化
    l2_total_min= bsxfun(@times,total_min,1./sqrt(sum(total_min.^2)));%%l2正则化
        
    
    total_max = [ max(norm_positions,[],2)' , max(dist_relations,[],2)' , max(ort_relations,[],2)' , max(angle_relations,[],2)'  ...
        max(max(cartesian_trajectory,[],3),[],1) , max(max(radial_trajectory,[],3),[],1) ...
        max(max(dist_relation_trajectory,[],3),[],1) , max(max(ort_relation_trajectory,[],3),[],1) ...
        max(max(angle_relation_trajectory,[],3),[],1)];
    l1_total_max= bsxfun(@times,total_max,1./(sum(total_max)));
    l2_total_max= bsxfun(@times,total_max,1./sqrt(sum(total_max.^2)));
    
    
    total_mean = [ mean(norm_positions,2)' , mean(dist_relations,2)' , mean(ort_relations,2)' , mean(angle_relations,2)'  ...
        mean(mean(cartesian_trajectory,3),1) , mean(mean(radial_trajectory,3),1) ...
        mean(mean(dist_relation_trajectory,3),1) , mean(mean(ort_relation_trajectory,3),1) ...
        mean(mean(angle_relation_trajectory,3),1)];
    l1_total_mean= bsxfun(@times,total_mean,1./(sum(total_mean)));
    l2_total_mean= bsxfun(@times,total_mean,1./sqrt(sum(total_mean.^2)));

    
    
    total_var = [ var(norm_positions,[],2)' , var(dist_relations,[],2)' , var(ort_relations,[],2)' , var(angle_relations,[],2)'  ...
        var(var(cartesian_trajectory,[],3),[],1) , var(var(radial_trajectory,[],3),[],1) ...
        var(var(dist_relation_trajectory,[],3),[],1) , var(var(ort_relation_trajectory,[],3),[],1) ...
        var(var(angle_relation_trajectory,[],3),[],1)];
    l1_total_var= bsxfun(@times,total_var,1./(sum(total_var)));
    l2_total_var= bsxfun(@times,total_var,1./sqrt(sum(total_var.^2)));
    
    
    
    l1_total3= [l1_total_min,l1_total_max,l1_total_mean];
    l2_total3= [l2_total_min,l2_total_max,l2_total_mean];
    
    l1_total= [l1_total_min,l1_total_max,l1_total_mean,l1_total_var];
    l2_total= [l2_total_min,l2_total_max,l2_total_mean,l2_total_var];
    
    feature={l1_total_min;l2_total_min;l1_total_max;l2_total_max;l1_total_mean;l2_total_mean;l1_total_var;l2_total_var;l1_total3;l2_total3;l1_total;l2_total};
    
    
    %%%%%%%%%%%%%%%%%%%%%%%
    feattype={'l1_total_min','l2_total_min','l1_total_max','l2_total_max','l1_total_mean','l2_total_mean',...
        'l1_total_var','l2_total_var','l1_total3','l2_total3','l1_total','l2_total'};
    for k=1:length(feattype)
        fid = fopen([tline,'/',feattype{k},'.txt'], 'wt');    %加权特征并l2归一化保存到txt
        [m, n] = size(feature{k});   
        for i = 1 : m  
            for j = 1 : n  
                if j == n  
                    fprintf(fid, '%g\n',feature{k}(i,j));    % \n: new line
                else   
                    fprintf(fid, '%g ', feature{k}(i,j));    % \t: horizontal tab
                end  
            end   
        end   
        fclose(fid);   
    
    end
    %%%%%%%%%%%%%%%%%%%%%%
    
end
