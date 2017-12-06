%%计算一系列样本的hlpf特征，保存到各自的mat矩阵中
clc
clear
close all
addpath(genpath('src'));
opt = struct('T',7,'s',3); %%s=3表示时间域特征每隔3帧计算。

videoline=0;
fidin=fopen('inputlist.txt');
while ~feof(fidin)
    tline=fgetl(fidin);
    if isempty(tline)
        continue;
    end
    videoline=videoline+1;
    file_joint_positions=sprintf('%s/joint_positions.mat',tline);
    A = load(file_joint_positions,'pos_world');
    
%% ----- 计算单张图像上的关节特征-空间特征 维度：?*40（40帧图像）-------- %%
% compute normalize joints 
norm_positions = positions_to_normalizepositions(A.pos_world);
%%norm_positions表示15个关节点相对躯干（脖子和腹部的中点）的位置坐标，维度30*40
%%即15joints*（x,y），40frames，取值（-1,1）
%x,y视作两种描述子，分别求相对距离；

% compute relations: distance between two joints
dist_relations = positions_to_dist_relations(A.pos_world);
%%dist_relations表示15个关节点两两关节点构成的向量距离（dx,dy），共15取2个组合即15C2=15*14/2=105个距离,维度105*40，即40帧，
%%注意是距离，即直接用sqrt(dx^2+dy^2)求距离，丢弃了arctan(dy/dx)方向，取值范围（0,1）
%（dx,dy）视作一种描述子，直接求平方和的开方求距离；

% compute relations: orientation between two joints
ort_relations = positions_to_ort_relations(A.pos_world);
% ort_relations 表示15个关节点两两关节点构成的向量方向arctan(dy/dx)，atan2(dy,dx)取值范围（-pi,pi），共15取2个组合即15C2=15*14/2=105个距离
% 第一个向量方向是neck到belly，表示躯干方向，将所有向量方向都与该方向做差值，求得关节对向量方向相对躯干方向的角度
% 维度104*40，即40帧 取值范围是（0,180）

% compute relations:angle spanned by three joints
angle_relations = positions_to_angle_relations(A.pos_world);
% angle_relations表示15个关节点中任意三个关节点构成的三角形的三个内角关系（任意两个关节向量的内角),acos()取值范围（0,pi）
% 共15取3个组合15C3=15*14*13/（3*2*1）=455个三角形，共455*3个内角，维度1365*40，即40帧图像. 取值范围是（-180,180）


%% ---- 计算每两帧（step=3）的关节轨迹特征--时间特征 维度：2*？*34（34个图像差） -----%%
% compute trajectory of positions with cartesian representation:
positions = reshape(A.pos_world,[],size(A.pos_world,3));%%将关节位置2*15*40转化为30*40;
cartesian_trajectory = X_to_trajectory(positions,opt); %cartesian_trajectory = positions_to_cartesian_trajectory(A.pos_world,opt);
% 计算每隔step=3的两帧的同一关节点的相对位移，对于40帧图像，traj_length=floor（(T-1)/3）=2,共计算了40-2*3=34，floor是向下取整
% cartesian_trajectory维度为2*30*34维，2为traj_length,分别对应1:1:34-4:3：37和4:3:37-7:3:40对应帧的图像的15个关节的轨迹差

% compute trajectory of positions with radial representation:
radial_trajectory = positions_to_radial_trajectory(A.pos_world,opt);
% 计算每隔step=3的两帧的同一关节点的相对位移方向，对cartesian_trajectory（2*30*34）计算，将30分为dx,dy，求arctan(dy/dx)
% radial_trajectory维度为2*15*34维

% compute trajectory of dist_relations
dist_relation_trajectory = X_to_trajectory(dist_relations,opt);
% dist_relations表示15个关节点中两两之间的距离105*40
% dist_relation_trajectory计算相隔帧的关节对距离差
% dist_relation_trajectory维度为2*105*34维

% compute trajectory of ort_relations
ort_relation_trajectory = X_to_trajectory(ort_relations,opt);
% ort_relations表示15个关节点两两关节点构成的向量方向arctan(dy/dx)维度104*40,
% ort_relation_trajectory计算相隔帧的关节对向量方向变化差值
% ort_relation_trajectory维度为2*104*34维


% compute trajectory of angle_relations
angle_relation_trajectory = X_to_trajectory(angle_relations,opt);
% angle_relations表示15个关节点中任意三个关节点构成的三角形的三个内角关系1365*40
% angle_relation_trajectory表示相隔帧的内角关系的变化
% angle_relation_trajectory维度为2*1365*34维 


%% save hlpf features
output_file =sprintf('%s/hlpf_features.mat',tline);
save(output_file,'norm_positions','dist_relations','ort_relations','angle_relations','cartesian_trajectory','radial_trajectory','dist_relation_trajectory','ort_relation_trajectory','angle_relation_trajectory');

clear norm_positions dist_relations ort_relations angle_relations positions cartesian_trajectory radial_trajectory dist_relation_trajectory ort_relation_trajectory angle_relation_trajectory;
end;
