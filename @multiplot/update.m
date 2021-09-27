
function update(this)

	n = this.currentdata;
	
	figure(this.figh);

	for s=1:this.nsp
		if isempty(this.sp{s}.position)
			this.sp{p}.axh = subplot(this.nsp, 1, p);
		else
			this.sp{s}.axh = subplot('Position', this.sp{s}.position);
		end
		hold on;
	end


	for s=1:this.nsp

		cla(this.sp{s}.axh); 

		if isfield(this.sp{s}, 'pl')

			for p=1:length(this.sp{s}.pl)

				if isfield(this.sp{s}.pl{p}, 'ydata') && length(this.sp{s}.pl{p}.ydata)>=n  && ~isempty(this.sp{s}.pl{p}.ydata{n})

					if ~isfield(this.sp{s}.pl{p}, 'color') || isempty(this.sp{s}.pl{p}.color)
						plotcolor = this.defaultcolor;
					else
						plotcolor = this.sp{s}.pl{p}.color;
					end
					if ~isfield(this.sp{s}.pl{p}, 'width') || isempty(this.sp{s}.pl{p}.width)
						plotwidth = this.defaultwidth;
					else
						plotwidth = this.sp{s}.pl{p}.width;
					end

					if isfield(this.sp{s}.pl{p}, 'xdata') && length(this.sp{s}.pl{p}.xdata)>=n && ~isempty(this.sp{s}.pl{p}.xdata{n})
						plot(this.sp{s}.axh, this.sp{s}.pl{p}.xdata{n}, this.sp{s}.pl{p}.ydata{n}, 'Color', plotcolor, 'LineWidth', plotwidth);
					else
						plot(this.sp{s}.axh, this.sp{s}.pl{p}.ydata{n}, 'Color', plotcolor, 'LineWidth', plotwidth);
					end

					%ndata updated here
					this.ndata = length(this.sp{s}.pl{p}.ydata);
				end
			end
		end

		if isfield(this.sp{s}, 'axrange') && ~isempty(this.sp{s}.axrange)
			axis(this.sp{s}.axh, this.sp{s}.axrange);
		end

		if ~isempty(this.sp{s}.plottype)
			switch this.sp{s}.plottype
				case 'logy'
					set(this.sp{s}.axh, 'YScale', 'log');
				case 'logx'
					set(this.sp{s}.axh, 'XScale', 'log');
				case 'logxy'
					set(this.sp{s}.axh, 'XScale', 'log');
					set(this.sp{s}.axh, 'YScale', 'log');
			end
		end


		if this.show_title && s==1
			title(this.sp{s}.axh, [this.titlestr, ' - ', num2str(n), ' / ', num2str(this.ndata)], 'interpreter', 'none');
		end

	end


	if this.show_fbutton
		for i=1:length(this.fbuttonf)
			if length(this.fbuttonstr) >=i &&  ~isempty(this.fbuttonstr{i})
				this.fbuttonh(i) =  uicontrol(this.figh, 'Style', 'PushButton', 'String', this.fbuttonstr{i}, 'Units', 'normalized', ...
							'Position', [0.90, 0.90-0.1*(i-1), 0.09, 0.06], 'Callback', this.fbuttonf{i});
			else
				this.fbuttonh(i) =  uicontrol(this.figh, 'Style', 'PushButton', 'String', this.fbuttonf{i}, 'Units', 'normalized', ...
							'Position', [0.90, 0.90-0.1*(i-1), 0.09, 0.06], 'Callback', this.fbuttonf{i});
			end
		end
	end


	set(this.figh, 'KeyPressFcn', @keypressf);

	function keypressf(src, evnt)
		%change image
		switch evnt.Key
			case 'pageup'
				if this.currentdata >1
					this.currentdata = this.currentdata -1;
				end
			case 'pagedown'
				if this.currentdata < this.ndata
					this.currentdata = this.currentdata +1;
				end
			case 'home'
				this.currentdata = 1;
			case 'end'
				this.currentdata = this.ndata;
		end

		this.update;

	end %function keypressf

end
