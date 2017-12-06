%%将列表中的同一类特征写入一个txt,主要是为了训练gmm
clc
clear all
close all
fidin=fopen('train_split.txt');
delete('gmm_codebook/*positions.txt');
delete('gmm_codebook/*_relations.txt');
delete('gmm_codebook/*_trajectory.txt');

videoline=0;
while ~feof(fidin)
    tline=fgetl(fidin);
    if isempty(tline)
        continue;
    end
    videoline=videoline+1;
    file_joint_positions=sprintf('%s/hlpf_features_upper.mat',tline);
    load(file_joint_positions);
%%
norm_positions=norm_positions';
fid1 = fopen('gmm_codebook/train_norm_positions.txt', 'at+');    % Create txt if the txt not exist
[m, n] = size(norm_positions);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid1, '%.4f\n', norm_positions(i,j));    % \n: new line
        else   
            fprintf(fid1, '%.4f ', norm_positions(i,j));    % \t: horizontal tab
        end  
    end   
end   

%%
dist_relations=dist_relations';
fid2 = fopen('gmm_codebook/train_dist_relations.txt', 'at+');   
[m, n] = size(dist_relations);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid2, '%.4f\n', dist_relations(i,j));   
        else   
            fprintf(fid2, '%.4f ', dist_relations(i,j));    
        end  
    end   
end   

%%
ort_relations=ort_relations';
fid3 = fopen('gmm_codebook/train_ort_relations.txt', 'at+');    
[m, n] = size(ort_relations);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid3, '%.4f\n', ort_relations(i,j));  
        else   
            fprintf(fid3, '%.4f ', ort_relations(i,j)); 
        end  
    end   
end   


%%
angle_relations=angle_relations';
fid4 = fopen('gmm_codebook/train_angle_relations.txt', 'at+');   
[m, n] = size(angle_relations);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid4, '%.4f\n', angle_relations(i,j));   
        else   
            fprintf(fid4, '%.4f ', angle_relations(i,j));    
        end  
    end   
end   

%%
cartesian_trajectory=permute(cartesian_trajectory,[3 2 1]);
fid5 = fopen('gmm_codebook/train_cartesian_trajectory.txt', 'at+');   
[m, n,t] = size(cartesian_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid5, '%.4f\n', cartesian_trajectory(i,j,k));    
        else   
            fprintf(fid5, '%.4f ', cartesian_trajectory(i,j,k));    
        end  
    end   
end 
end

%%
radial_trajectory=permute(radial_trajectory,[3 2 1]);
fid6 = fopen('gmm_codebook/train_radial_trajectory.txt', 'at+');    
[m, n,t] = size(radial_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid6, '%.4f\n', radial_trajectory(i,j,k));    
        else   
            fprintf(fid6, '%.4f ', radial_trajectory(i,j,k));    
        end  
    end   
end   
end

%%
dist_relation_trajectory=permute(dist_relation_trajectory,[3 2 1]);
fid7 = fopen('gmm_codebook/train_dist_relation_trajectory.txt', 'at+');    
[m, n,t]= size(dist_relation_trajectory);  
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid7, '%.4f\n', dist_relation_trajectory(i,j,k));   
        else   
            fprintf(fid7, '%.4f ', dist_relation_trajectory(i,j,k));    
        end  
    end   
end   
end

%%
ort_relation_trajectory=permute(ort_relation_trajectory,[3 2 1]);
fid8 = fopen('gmm_codebook/train_ort_relation_trajectory.txt', 'at+');    
[m, n,t] = size(ort_relation_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid8, '%.4f\n', ort_relation_trajectory(i,j,k));    
        else   
            fprintf(fid8, '%.4f ', ort_relation_trajectory(i,j,k));    
        end  
    end   
end   
end

%%
angle_relation_trajectory=permute(angle_relation_trajectory,[3 2 1]);
fid9 = fopen('gmm_codebook/train_angle_relation_trajectory.txt', 'at+');   
[m, n,t] = size(angle_relation_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid9, '%.4f\n', angle_relation_trajectory(i,j,k));    
        else   
            fprintf(fid9, '%.4f ', angle_relation_trajectory(i,j,k));   
        end  
    end   
end
end


clear norm_positions dist_relations ort_relations angle_relations cartesian_trajectory radial_trajectory dist_relation_trajectory ort_relation_trajectory angle_relation_trajectory;

end

fclose(fid1);fclose(fid2);fclose(fid3);fclose(fid4);fclose(fid5);fclose(fid6);fclose(fid7);fclose(fid8);fclose(fid9);