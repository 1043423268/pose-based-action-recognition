function X = positions_to_relations(positions,T)% compute relations:angle spanned by three joints

Nframes = size(positions,3);
angle_pairs = cell(1);
p = 0;
for i = 1:9
    for j = 1:9
        for k = 1:9
            add = 1;
            if (i==j | j==k | i==k)
                add = 0;
            end
            for m = 1:p
                if sum(abs(angle_pairs{m}-[k,j,i]))==0
                    add = 0;
                    break;
                end
            end
            if (add==1)
             	p = p + 1;
                angle_pairs{p} = [i,j,k];
	       end
        end
    end
end

ngroups = p;
npointsPerGroup = length(angle_pairs{1});
X = zeros(ngroups,Nframes);
for iframe = 1:Nframes
	p = zeros(2,npointsPerGroup, ngroups);
	for ig = 1:ngroups
		for ip = 1:npointsPerGroup
			p(:,ip, ig) = positions(:,angle_pairs{ig}(ip),iframe);
		end
	end
	X(:,iframe) = compute_angle_features(p);
end

function angle = compute_angle_features(p)
	%[ndim,npoints, ngroups] = size(p);
    [p1, p2, p3] = deal(squeeze(p(:,1, :)), squeeze(p(:,2, :)), squeeze(p(:,3,:)));
	
	% angle between the vector from p2 to p1 and the vector from p2 to p3
    % ���������ļнǣ�cos=p2p1*p2p3/(|p2p1|*|p2p3|)=(x1x2+y1y2)/(sqrt(x1^2+y1^2)*sqrt(x2^2+y2^2))
    
    dx21 = p1(1, :)-p2(1, :);
    dy21 = p1(2, :)-p2(2, :);

    dx23 = p3(1, :)-p2(1, :);
    dy23 = p3(2, :)-p2(2, :);

    d = sqrt((dx21.*dx21+dy21.*dy21).*(dx23.*dx23+dy23.*dy23));
    ndp = (dx21.*dx23+dy21.*dy23)./(0.000000001+d);
    angle = acos(ndp)*180/pi;
    
