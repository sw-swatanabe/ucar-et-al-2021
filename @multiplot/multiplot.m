%multiplot class
%{

sp (cell array)
	position
	axrange		
	axh
	plottype
	pl (cell array)		
		color
		width
		xdata (cell array)
		ydata (cell array)

%}

classdef multiplot < handle
	
	properties
		
		figh;

		sp; %plot area, cell array
		nsp;
		
		ndata =0;
		currentdata = 1;
		
		defaultcolor = 'k';
		defaultwidth = 1;
		
		show_title = 1;
		titlestr = '';
	
		show_fbutton = 1
		fbuttonf;
		fbuttonstr;
		fbuttonh;
		
	end

	methods

		function this = multiplot(varargin)
			
			nvarargin = size(varargin, 2);
			
			fignum = [];
			xdata = [];
			ydata = [];
			nsp = 1;
			position = [];
			plottype = 'linear';
			
			if isnumeric(varargin{1}) && isnumeric(varargin{2})
				xdata = varargin{1};
				ydata = varargin{2};
			end

			if isnumeric(varargin{1}) && ~isnumeric(varargin{2})
				ydata = varargin{1};
			end
				
			for i=1:nvarargin
				if ischar(varargin{i})
					switch varargin{i}
						case 'fig'
							fignum = varargin{i+1};
						case 'position'
							position = varargin{i+1};
						case 'plottype'
							plottype = varargin{i+1};
						case 'nsp'
							nsp = varargin{i+1};
					end
				end
				
			end
			
		
			
			if ~isempty(fignum)
				this.figh = figure(fignum);
			else
				this.figh = figure;
			end
			
			clf;
			
			%2d arrangement of plots not supported yet
			
			this.nsp = max(nsp, length(position));
			
			if ~isempty(position)
				if iscell(position)
					for s=1:length(position)
						this.sp{s}.position = position{s};
					end
				else
					this.sp{1}.position = position;
				end
			end
			
			if iscell(plottype)
				for s=1:length(plottype)
					this.sp{s}.plottype = plottype{s};
				end
			else
				for s=1:length(plottype)
					this.sp{s}.plottype = plottype;
				end
			end
			
			
			
			
%{			
			if isempty(this.position)
				if isempty(this.nsp)
					this.sp{1}.axh{1} = axes;
				else
					if length(nsp)==1
						for p=1:nsp
							this.sp{p}.axh = subplot(nsp, 1, p);
						end
					else
						for p=1:prod(nsp)
							this.sp{p}.axh = subplot(nsp(1), nsp(2), p);
						end
					end
				end
				
			else
				if iscell(position)
					for s=1:length(position)

						this.sp{s}.axh = subplot('Position', position{s});
						hold on;
						this.sp{s}.position = position{s};
					end
				else
					this.sp{1}.axh = axes('Position', position);
					this.sp{1}.position = position;
					hold on;
				end
			end
			
			if iscell(plottype)
				for s=1:length(plottype)
					this.sp{s}.plottype = plottype{s};
				end
			else
				for s=1:length(plottype)
					this.sp{s}.plottype = plottype;
				end
			end
			
			
			this.nsp = length(this.sp);
			
%}
			
% 			if ~isempty(ydata)
% 				this.append(varargin{:});
% 			end
		end
		
		function deletedata(this)
			for s=1:this.nsp
				this.sp{s}.pl = [];
				if isfield(this.sp{s}, 'axh')
					cla(this.sp{s}.axh);
				end
			end
			
			this.ndata = 0;
		end

		
		function append(this, varargin)
			nvarargin = length(varargin);
			
			s = 1;
			p = 1;
			n = this.ndata+1;
			xdata = [];
			ydata = [];
			axrange = [];
			color = this.defaultcolor;
			width = this.defaultwidth;
			update = 1;

			if isnumeric(varargin{1}) && length(varargin{1})==1
				if this.nsp==1
					p = varargin{1};
				else
					s = varargin{1};
				end
				
				if isnumeric(varargin{2}) && length(varargin{2})==1
					if this.nsp==1
						n = varargin{2};
					else
						p = varargin{2};
					end

					if isnumeric(varargin{3}) && length(varargin{3})==1
						if this.nsp>1
							n = varargin{3};
						end
						firstdata = 4;
					else
						firstdata = 3;
					end

				else
					firstdata = 2;
				end
					
				if isnumeric(varargin{firstdata})
					if isnumeric(varargin{firstdata+1})
						xdata = varargin{firstdata};
						ydata = varargin{firstdata+1};
					else
						ydata = varargin{firstdata};
					end
				end
			end

			
			if isnumeric(varargin{1}) && length(varargin{1})>1
				if isnumeric(varargin{2}) && length(varargin{2})>1
					xdata = varargin{1};
					ydata = varargin{2};
				else
					ydata = varargin{1};
				end
			end
			

			for i=1:nvarargin
				
				if ischar(varargin{i})
					switch varargin{i}
						case {'s', 'sp','subplot'}
							s = varargin{i+1};
						case {'p', 'pl'}
							p = varargin{i+1};
						case {'n'}
							n = varargin{i+1};
						case 'axrange'
							axrange = varargni{i+1};

						case {'data','ydata'}
							ydata = varargin{i+1};
						case 'xdata'
							xdata= varargin{i+1};
						case 'color'
							color= varargin{i+1};
						case 'width'
							width= varargin{i+1};
							
						case 'update'
							update = 1;
						case 'noupdate'
							update = 0;
					end
				end
				
			end

			this.sp{s}.pl{p}.xdata{n} = xdata;
			this.sp{s}.pl{p}.ydata{n} = ydata;
			this.sp{s}.pl{p}.color = color;
			this.sp{s}.pl{p}.width = width;
			this.sp{s}.axrange = axrange;
		
			this.ndata = max(this.ndata, n);
			
			if update
				this.currentdata = this.ndata;
				this.update;
			end
		end

		
	end
	
end
