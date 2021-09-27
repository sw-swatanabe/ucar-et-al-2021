%set the same axis range as an image object

function axrange(this, data, varargin)
	nvarargin = length(varargin);
	
	update = 1;
	roinum = [];
	
	for i=1:nvarargin
		if ischar(varargin{i})
			switch varargin{i}
				case 'update'
					update = 1;
				case 'noupdate'
					update = 0;
			end
		end
	end
	
	if isobject(data)
		imageobj = data;
		
		this.axmin = imageobj.axmin;
		this.axmax = imageobj.axmax;
		this.aymin = imageobj.aymin;
		this.aymax = imageobj.aymax;
	end
	
	if isnumeric(data)
		if length(data)==4
			this.axmin = data(1);
			this.axmax = data(2);
			this.aymin = data(3);
			this.aymax = data(4);
		end
		
		if length(data) ==1
			this.axmin = min( this.roi{data}.pt(:,1) );
			this.axmax = max( this.roi{data}.pt(:,1) );
			this.aymin = min( this.roi{data}.pt(:,2) );
			this.aymax = max( this.roi{data}.pt(:,2) );
		end
	end	
	
	if update
		this.update;
	end
	
end