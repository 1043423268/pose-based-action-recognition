clc
clear all
close all

inputlist='./inputlist.txt';
type={'norm_positions','dist_relations','ort_relations','angle_relations','cartesian_trajectory',...
     'radial_trajectory','dist_relation_trajectory','ort_relation_trajectory','angle_relation_trajectory'};
s=3;
D=[30,105,104,1365,30,15,105,104,1365];
K=20;
typeDimension=2*K*D; % typelength =[1200,4200,4160,54600,1200,600,4200,4160,54600];
trainlist='./train_split3.txt';
labelorder{1}=[1,29;30,63;64,94;95,122;123,152;153,179;180,204;205,232;233,271;272,310;311,340;341,369;370,398;399,436;437,475;476,502;503,527;528,566;567,601;602,630;631,660];%%split1
labelorder{2}=[1,29;30,63;64,94;95,122;123,152;153,181;182,205;206,233;234,272;273,311;312,341;342,370;371,398;399,436;437,476;477,503;504,528;529,566;567,599;600,628;629,658];%%split2
labelorder{3}=[1,29;30,62;63,93;94,121;122,151;152,181;182,207;208,235;236,274;275,313;314,343;344,371;372,401;402,439;440,478;479,506;507,531;532,570;571,604;605,633;634,663];%%split3
trainlistlength=max(max(labelorder{s}));
for i=1:length(type)
    fvweight{i}=train_weight(trainlist,trainlistlength,labelorder{s},type{i},typeDimension(i));%%训练权重
end

for i=1:length(type)
    compute_weight_fv(inputlist,type{i},fvweight{i},'s3_weight_fv');%%特征加权
end
fv_combination(inputlist,type,'s3_weight_fv','s3_weight_total_fv');%%特征组合


%%    ------------------------------      %%

function fvweight=train_weight(inputlist,listlength,labelorder,fvtype,fvDimension)%计算权值
    line=0;
    fidin=fopen(inputlist);%%所有样本的fv特征进行权重训练
    fv_features=zeros(listlength,fvDimension);
    while ~feof(fidin)
        tline=fgetl(fidin);
        if isempty(tline)
            continue;
        end
        line=line+1;
        feature_path=sprintf('%s/%s_fv.txt',tline,fvtype);
        fv_features(line,:)=load(feature_path);

    end


    mean_feature=zeros(size(labelorder,1),fvDimension);
    var_feature=zeros(size(labelorder,1),fvDimension);
    for i=1:size(labelorder,1)
        mean_feature(i,:) = mean(fv_features(labelorder(i,1):labelorder(i,2),:));
         var_feature(i,:) =  var(fv_features(labelorder(i,1):labelorder(i,2),:));
    end

    within_var(1,:)=mean(var_feature);
    between_var(1,:)=var(mean_feature);

    weight=between_var./within_var;
    fvweight(1:0.5*fvDimension)=weight(1:0.5*fvDimension)/sum(weight(1:0.5*fvDimension));   
    fvweight(1+0.5*fvDimension:fvDimension)=weight(1+0.5*fvDimension:fvDimension)/sum(weight(1+0.5*fvDimension:fvDimension));
end
%%    ------------------------------      %%

function compute_weight_fv(inputlist,fvtype,fvweight,out_extension)%

    fidin=fopen(inputlist);
    while ~feof(fidin)
        tline=fgetl(fidin);
        if isempty(tline)
            continue;
        end

        feature_path=sprintf('%s/%s_fv.txt',tline,fvtype);
        feature=load(feature_path);

        weight_feature=feature.*fvweight;


        n=0.5*length(fvweight);
        l2_weight_feature(1:n)= bsxfun(@times,weight_feature(1:n),1./sqrt(sum(weight_feature(1:n).^2)));
        l2_weight_feature(1+n:2*n)=bsxfun(@times,weight_feature(1+n:2*n),1./sqrt(sum(weight_feature(1+n:2*n).^2)));
        fid = fopen([tline,'/',fvtype, '_',out_extension,'.txt'], 'wt');    %加权特征并l2归一化保存到txt
        [m, n] = size(l2_weight_feature);   
        for i = 1 : m  
            for j = 1 : n  
                if j == n  
                    fprintf(fid, '%g\n', l2_weight_feature(i,j));    % \n: new line
                else   
                    fprintf(fid, '%g ', l2_weight_feature(i,j));    % \t: horizontal tab
                end  
            end   
        end   
        fclose(fid);   

    end
end
%%    ------------------------------      %%

function fv_combination(inputlist,type,in_extension,out_extension)%%in='s1_weight_fv';out='weight_total_fv';

    fidin=fopen(inputlist);
    while ~feof(fidin)
        tline=fgetl(fidin);
        if isempty(tline)
            continue;
        end
        delete([tline,'/',out_extension,'.txt']);
        fidout = fopen([tline,'/',out_extension,'.txt'], 'at+');  
        for i=1:length(type)         
            line = importdata([tline,'/',type{i}, '_',in_extension,'.txt']);   
            [m, n] = size(line);   
            for k = 1 : m  
                for j = 1 : n  
                    fprintf(fidout, '%g ', line(k,j));
                end   
            end

        end
        fclose(fidout);
    end
end

