function printtime(this)

	if isempty(this.time)
		time = (0:this.ndata-1) * this.frametime / 1000;
	else
		time = this.time;
	end
	%fprintf('\t\t\t');
	
	fprintf('%f\t', time);
	fprintf('\n');
	
end
