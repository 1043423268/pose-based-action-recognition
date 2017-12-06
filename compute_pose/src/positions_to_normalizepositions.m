function positions = positions_to_normalizepositions(positions)% compute normalize joints 

	% between neck and belly
    torso_positions = (positions(:,2,:)+positions(:,1,:))/2;
    positions = positions-repmat(torso_positions,[1 9 1]);%%����ɵ�xy���ѵ�15��
	% seperate two coordinates
	positions = reshape(positions,18,[]);%%��2*15*40ת��Ϊ30*40
