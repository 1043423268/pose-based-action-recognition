%%打开样本的保存hlpf特征的mat矩阵，将9类特征分别写入对应目录下的txt文件中
clc
clear all
close all
videoline=0;
fidin=fopen('./inputlist.txt');
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
fid = fopen([tline, '/norm_positions.txt'], 'wt');    % Create txt if the txt not exist
[m, n] = size(norm_positions);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', norm_positions(i,j));    % \n: new line
        else   
            fprintf(fid, '%.4f ', norm_positions(i,j));    % \t: horizontal tab
        end  
    end   
end   
fclose(fid);
%%
dist_relations=dist_relations';
fid = fopen([tline, '/dist_relations.txt'], 'wt');    % Create txt if the txt not exist
[m, n] = size(dist_relations);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', dist_relations(i,j));    % \n: new line
        else   
            fprintf(fid, '%.4f ', dist_relations(i,j));    % \t: horizontal tab
        end  
    end   
end   
fclose(fid);
%%
ort_relations=ort_relations';
fid = fopen([tline, '/ort_relations.txt'], 'wt');    % Create txt if the txt not exist
[m, n] = size(ort_relations);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', ort_relations(i,j));    % \n: new line
        else   
            fprintf(fid, '%.4f ', ort_relations(i,j));    % \t: horizontal tab
        end  
    end   
end   
fclose(fid);

%%
angle_relations=angle_relations';
fid = fopen([tline, '/angle_relations.txt'], 'wt');    % Create txt if the txt not exist
[m, n] = size(angle_relations);   
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', angle_relations(i,j));    % \n: new line
        else   
            fprintf(fid, '%.4f ', angle_relations(i,j));    % \t: horizontal tab
        end  
    end   
end   
fclose(fid);
%%
cartesian_trajectory=permute(cartesian_trajectory,[3 2 1]);
fid = fopen([tline, '/cartesian_trajectory.txt'], 'wt');    % Create txt if the txt not exist
[m, n,t] = size(cartesian_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', cartesian_trajectory(i,j,k));    % \n: new line
        else   
            fprintf(fid, '%.4f ', cartesian_trajectory(i,j,k));    % \t: horizontal tab
        end  
    end   
end 
end
fclose(fid);
%%
radial_trajectory=permute(radial_trajectory,[3 2 1]);
fid = fopen([tline, '/radial_trajectory.txt'], 'wt');    % Create txt if the txt not exist
[m, n,t] = size(radial_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', radial_trajectory(i,j,k));    % \n: new line
        else   
            fprintf(fid, '%.4f ', radial_trajectory(i,j,k));    % \t: horizontal tab
        end  
    end   
end   
end
fclose(fid);
%%
dist_relation_trajectory=permute(dist_relation_trajectory,[3 2 1]);
fid = fopen([tline, '/dist_relation_trajectory.txt'], 'wt');    % Create txt if the txt not exist
[m, n,t]= size(dist_relation_trajectory);  
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', dist_relation_trajectory(i,j,k));    % \n: new line
        else   
            fprintf(fid, '%.4f ', dist_relation_trajectory(i,j,k));    % \t: horizontal tab
        end  
    end   
end   
end
fclose(fid);
%%
ort_relation_trajectory=permute(ort_relation_trajectory,[3 2 1]);
fid = fopen([tline, '/ort_relation_trajectory.txt'], 'wt');    % Create txt if the txt not exist
[m, n,t] = size(ort_relation_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', ort_relation_trajectory(i,j,k));    % \n: new line
        else   
            fprintf(fid, '%.4f ', ort_relation_trajectory(i,j,k));    % \t: horizontal tab
        end  
    end   
end   
end
fclose(fid);
%%
angle_relation_trajectory=permute(angle_relation_trajectory,[3 2 1]);
fid = fopen([tline, '/angle_relation_trajectory.txt'], 'wt');    % Create txt if the txt not exist
[m, n,t] = size(angle_relation_trajectory);   
for k=1:t
for i = 1 : m  
    for j = 1 : n  
        if j == n  
            fprintf(fid, '%.4f\n', angle_relation_trajectory(i,j,k));    % \n: new line
        else   
            fprintf(fid, '%.4f ', angle_relation_trajectory(i,j,k));    % \t: horizontal tab
        end  
    end   
end
end
fclose(fid);

clear norm_positions dist_relations ort_relations angle_relations cartesian_trajectory radial_trajectory dist_relation_trajectory ort_relation_trajectory angle_relation_trajectory;

end



