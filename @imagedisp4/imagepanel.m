%110512 bleach setting added
%110607 image rotation added, however, bleach points cannot be rotated
%120213 bleach point default setting modified

%under construction (show roi)

function imagepanel = imagepanel(imgobj, varargin)
	nvarargin = length(varargin);
	
	fignum = [];
	datanum = [];
	nx = []; ny = 1;
	gapx = 0.03;
	gapy = 0.05;
	roinum = [];
	
	angle = 0;
	
	show_scalebar = 1;
	scalebarpos = [5 2];
	scalebarlength = 1;
	scalebarcolor = 'w';
	scalebaralignment = 'left';
	
	show_bleachpt = 1;
	bleachpanel = 1; %0 for all images
	bleachset = [];
	bleachset = 1:length(imgobj.bleachpt);
	
	show_roi = 0;
	
	show_time = 1;
 	timepos = 'r';
 	timesize = 10;
	timedecimal = 0;
	
    returndata = 0;

	for i=1:nvarargin
		if ischar(varargin{i})
			switch varargin{i}
				case 'fig'
					fignum = varargin{i+1};
				case 'nx'
					nx = varargin{i+1};
				case 'ny'
					ny = varargin{i+1};
				case 'gapx'
					gapx = varargin{i+1} /2;
				case 'gapy'
					gapy = varargin{i+1} /2;
					
				case 'datanum'
					datanum = varargin{i+1};
				case 'roi'
					roinum = varargin{i+1};
					
				case 'angle'
					angle = round(varargin{i+1} / 90);
				case {'rot90', 'rot', 'tr'}
					angle = 1;
				case {'rot-90', '-rot', '-tr'}
					angle = -1;
					
				case 'showscalebar'
					show_scalebar = 1;
				case 'hidescalebar'
					show_scalebar = 0;
				case 'scalebarpos'
					scalebarpos = varargin{i+1};
				case 'scalebarlength'
					scalebarlength = varargin{i+1};
				case 'scalebarcolor'
					scalebarcolor = varargin{i+1};
					
				case 'showbleachpt'
					show_bleachpt = 1;
				case 'hidebleachpt'
					show_bleachpt = 0;
			%	case 'bleachpanel'
			%		bleachpanel = varargin{i+1};
				case 'bleachset'
					bleachset = varargin{i+1};
				case 'bleachall'
					bleachpanel = 0;
					
				case 'showroi'
					show_roi = 1;
				case 'hideroi'
					show_roi = 0;
				case 'roipanel'
					roipanel = 0;
					
				case 'showtime'
					show_time = 1;
				case 'hidetime'
					show_time = 0;
				case 'timepos'
					timepos = varargin{i+1};
				case 'timesize'
					timesize = varargin{i+1};
				case 'timedecimal'
					timedecimal = varargin{i+1};
                    
                case 'returndata'
                    returndata = 1;
					
			end
		end
	end
	
	if isempty(fignum)
		figure;
	else
		figure(fignum);
	end
	clf;

	if isempty(datanum)
% 		datanum = 1:imgobj.ndata;
		datanum = 1:imgobj.sizet;
	end
	ndata = length(datanum);

	if isempty(bleachset)
		nbleachsets = length(imgobj.bleachpt);
	else
		nbleachsets = length(bleachset);
	end
	
	if isempty(bleachpanel)
		for i=1:nbleachsets
			bleachpaneltemp = find(datanum==imgobj.bleachimage(bleachset(i)));
			if ~isempty(bleachpaneltemp)
				bleachpanel(i) = bleachpaneltemp;
			else
				bleachpanel(i) = 0;
			end
		end
	end

	if imgobj.bleachimage==0
		imgobj.bleachimage =1;
	end
	
	
	if isempty(nx)
		nx = ceil(ndata / ny);
    else
		ny = ceil(ndata / nx);
    end
    

	%
	axmin = 1; axmax = imgobj.sizex;
	aymin = 1; aymax = imgobj.sizey;
	if ~isempty(roinum)
% 		axmin = min(imgobj.roipt{roinum}(:, 1));
% 		axmax = max(imgobj.roipt{roinum}(:, 1));
% 		aymin = min(imgobj.roipt{roinum}(:, 2));
% 		aymax = max(imgobj.roipt{roinum}(:, 2));
		axmin = min(imgobj.roi{roinum}.pt(:, 1));
		axmax = max(imgobj.roi{roinum}.pt(:, 1));
		aymin = min(imgobj.roi{roinum}.pt(:, 2));
		aymax = max(imgobj.roi{roinum}.pt(:, 2));
	end
	
% 	widthp = round(axmax - axmin + 1);
% 	heightp = round(aymax - aymin + 1);
% 	gapxp = round(widthp * gapx);
% 	gapyp = round(heightp * gapy);

% 	panelsizex = widthp * nx + gapxp * (nx -1);
% 	panelsizey = heightp * ny + gapyp * (ny -1);
	
% 	clear imagepanel;
% 	imagepanel = ones(panelsizey, panelsizex, 3);

	
	for i=1:ndata
	%for i=1:5

		if isempty(roinum)
% 			tempimgseq = imgobj.rgbdatars{datanum(i)}; 
			tempimgseq = imgobj.rgbdatars{imgobj.ztarget(datanum(i)), datanum(i)}; 
			tempimg = tempimgseq;
		else
 			tempimgseq = imgobj.roiimage(roinum); 
% 			tempimg = tempimgseq{datanum(i)};
			tempimg = tempimgseq{imgobj.ztarget(datanum(i)), datanum(i)};
		end
		
% 		if i==1
% 			[heightp, widthp] = size(rot90(tempimg(:,:,1), angle));
% 			gapxp = max(round(widthp * gapx), 1);
% 			gapyp = max(round(heightp * gapy), 1);
% 			panelsizex = widthp * nx + gapxp * (nx -1);
% 			panelsizey = heightp * ny + gapyp * (ny -1);
% 			imagepanel = ones(panelsizey, panelsizex, 3);
% 		end
			spgapx = 0.1;
			spgapy = 0.1;
			spleft = (mod(i-1, nx) /nx) + spgapx/nx/2;
			spbottom = 1 - (floor((i-1) / nx) +1) / ny + spgapy/ny/2;
			spwidth = 1/nx * (1-spgapx);
			spheight = 1/ny * (1-spgapy);
		
% 		bottomp(i) = (widthp + gapxp) * mod(i-1, nx) +1;
% 		leftp(i) = floor((i-1) / nx) * (heightp + gapyp) +1;

		for col=1:3
% 			imagepanel(leftp(i):leftp(i)+heightp-1, bottomp(i):bottomp(i)+widthp-1, col) = rot90(tempimg(:,:,col), angle);
			tempimgr(:,:,col) = rot90(tempimg(:,:,col), angle);
		end
		
		sp(i) = subplot('Position', [spleft, spbottom, spwidth, spheight]);
		image(tempimgr); hold on;
		axis image; axis ij; axis off;
% 	end
	
% 	image(imagepanel); hold on;

% 	axis image; axis ij; axis off;
	
% 	for i=1:ndata

		if show_bleachpt
			
			if any(i==bleachpanel) || (length(bleachpanel)==1 && bleachpanel==0)
				
				for p=1:length(imgobj.bleachpt)


% 					if ~isempty(imgobj.bleachpt{p}) && (isempty(bleachset) || p==bleachset(find(bleachpanel==i)) )
					if ~isempty(imgobj.bleachpt{p}) && ~isempty(bleachset)
		
						bleachroipoints = size(imgobj.bleachpt{p}, 3);

						if bleachroipoints==1
							for b=1:imgobj.nbleachpt(p)
% 								[bx, by] = imgobj.rgbptrotateshift(imgobj.bleachpt{p}(b,1), imgobj.bleachpt{p}(b,2), imgobj.bleachimage(p));
% 								[bx, by] = imgobj.shift_imagept([imgobj.bleachpt{p}(b,1), imgobj.bleachpt{p}(b,2)], imgobj.shiftx(imgobj.bleachimage(p)), imgobj.shifty(imgobj.bleachimage(p)));
								bx_all = imgobj.shift_imagept([imgobj.bleachpt{p}(b,1), imgobj.bleachpt{p}(b,2)], imgobj.shiftx(imgobj.bleachimage(p)), imgobj.shifty(imgobj.bleachimage(p)));
								bx = bx_all(1);
								by = bx_all(2);
								if bx>=axmin && bx<=axmax && by>=aymin && by<=aymax

									if imgobj.compmode{p}(imgobj.comb{p}(b))==0
										switch angle
% 											case 0
% 												plot(bottomp(i) + bx-axmin, leftp(i) + by-aymin, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
% 											case {-1, 3}
% 												plot(bottomp(i) + aymax-by, leftp(i) + bx-axmin, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
% 											case 1
% 												plot(bottomp(i) + by-aymin, leftp(i) + axmax-bx, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
											case 0
												plot(sp(i), bx-axmin, by-aymin, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
											case {-1, 3}
												plot(sp(i), aymax-by, bx-axmin, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
											case 1
												plot(sp(i), by-aymin, axmax-bx, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
										end
									else
										
										compsize = round(sqrt(imgobj.compmode{p}(imgobj.comb{p}(b))) );
										compint = imgobj.compint{p}(imgobj.comb{p}(b));

										switch angle
											case 0
												for x=1:compsize
													for y=1:compsize
% 														plot(bottomp(i) + bx-axmin + (x-1)*compint, leftp(i) + by-aymin + (y-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
														plot(sp(i), bx-axmin + (x-1)*compint, by-aymin + (y-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
													end
												end
												
											case {-1, 3}
												for x=1:compsize
													for y=1:compsize
% 														plot(bottomp(i) + aymax-by - (y-1)*compint, leftp(i) + bx-axmin + (x-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
														plot(sp(i), aymax-by - (y-1)*compint, bx-axmin + (x-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
													end
												end
												
											case 1
												for x=1:compsize
													for y=1:compsize
% 														plot(bottomp(i) + by-aymin + (y-1)*compint, leftp(i) + axmax-bx - (x-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
														plot(sp(i), by-aymin + (y-1)*compint, axmax-bx - (x-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
													end
												end
										end
									end
								end
							end
							
						else
							for bpr = 1:bleachroipoints
% 								[bx(bpr), by(bpr)] = imgobj.rgbptrotateshift(imgobj.bleachpt{p}(1,1, bpr), imgobj.bleachpt{p}(1,2, bpr), imgobj.bleachimage(p));
								[bx(bpr), by(bpr)] = imgobj.shift_imagept([imgobj.bleachpt{p}(1,1, bpr), imgobj.bleachpt{p}(1,2, bpr)], imgobj.shiftx(imgobj.bleachimage(p)), mgobj.shifty(imgobj.bleachimage(p)));
							end
							
							if all(bx>=axmin) && all(bx<=axmax) && all(by>=aymin) && all(by<=aymax)
								switch angle
% 									case 0
% 										plot(bottomp(i) + [bx, bx(1)]-axmin, leftp(i) + [by, by(1)]-aymin, '-', 'LineWidth', 1,  'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
% 									case {-1, 3}
% 										plot(bottomp(i) + aymax-[by, by(1)], leftp(i) + [bx, bx(1)]-axmin, '-', 'LineWidth', 1, 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
% 									case 1
% 										plot(bottomp(i) + [by, by(1)]-aymin, leftp(i) + axmax-[bx, bx(1)], '-', 'LineWidth', 1, 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
									case 0
										plot(sp(i), [bx, bx(1)]-axmin, [by, by(1)]-aymin, '-', 'LineWidth', 1,  'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
									case {-1, 3}
										plot(sp(i), aymax-[by, by(1)], [bx, bx(1)]-axmin, '-', 'LineWidth', 1, 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
									case 1
										plot(sp(i), [by, by(1)]-aymin, axmax-[bx, bx(1)], '-', 'LineWidth', 1, 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
								end
							end
							
						end
					end

				end
			end
		end
%{		
		if show_roi
			
			if any(i==roipanel) || (length(roipanel)==1 && roipanel==0)
				
				for p=imgobj.roilist

% 					if ~isempty(imgobj.bleachpt{p}) && isempty(bleachset)
		
						bleachroipoints = size(imgobj.bleachpt{p}, 3);
						
						if bleachroipoints==1
							for b=1:imgobj.nbleachpt(p)
								[bx, by] = imgobj.rgbptrotateshift(imgobj.bleachpt{p}(b,1), imgobj.bleachpt{p}(b,2), imgobj.bleachimage(p));
								
								if bx>=axmin && bx<=axmax && by>=aymin && by<=aymax

									if imgobj.compmode{p}(imgobj.comb{p}(b))==0
										switch angle
											case 0
												plot(bottomp(i) + bx-axmin, leftp(i) + by-aymin, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
											case {-1, 3}
												plot(bottomp(i) + aymax-by, leftp(i) + bx-axmin, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
											case 1
												plot(bottomp(i) + by-aymin, leftp(i) + axmax-bx, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
										end
										
									else
										
										compsize = round(sqrt(imgobj.compmode{p}(imgobj.comb{p}(b))) );
										compint = imgobj.compint{p}(imgobj.comb{p}(b));

										switch angle
											case 0
												for x=1:compsize
													for y=1:compsize
														plot(bottomp(i) + bx-axmin + (x-1)*compint, leftp(i) + by-aymin + (y-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 4);
													end
												end
												
											case {-1, 3}
												for x=1:compsize
													for y=1:compsize
														plot(bottomp(i) + aymax-by - (y-1)*compint, leftp(i) + bx-axmin + (x-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 4);
													end
												end
												
											case 1
												for x=1:compsize
													for y=1:compsize
														plot(bottomp(i) + by-aymin + (y-1)*compint, leftp(i) + axmax-bx - (x-1)*compint, '.', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 4);
													end
												end
										end
									end
								end
							end
							
						else
							for bpr = 1:bleachroipoints
								[bx(bpr), by(bpr)] = imgobj.rgbptrotateshift(imgobj.bleachpt{p}(1,1, bpr), imgobj.bleachpt{p}(1,2, bpr), imgobj.bleachimage(p));
							end
							
							if all(bx>=axmin) && all(bx<=axmax) && all(by>=aymin) && all(by<=aymax)
							%plot([bx, bx(1)]-axmin, [by, by(1)]-aymin, '-', 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
								switch angle
									case 0
										plot(bottomp(i) + [bx, bx(1)]-axmin, leftp(i) + [by, by(1)]-aymin, '-', 'LineWidth', 1,  'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
									case {-1, 3}
										plot(bottomp(i) + aymax-[by, by(1)], leftp(i) + [bx, bx(1)]-axmin, '-', 'LineWidth', 1, 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
									case 1
										plot(bottomp(i) + [by, by(1)]-aymin, leftp(i) + axmax-[bx, bx(1)], '-', 'LineWidth', 1, 'color', imgobj.bleachcolor{p}, 'MarkerSize', 5);
								end
							
							end
						end

				end
			end
		end
%}		
		if show_time
			if ischar(timepos)
				switch timepos
					case 'l'
						switch angle
% 							case 0
% 								timepos = [leftp(i) + (axmax-axmin)*0.03,  bottomp(i) + (aymax-aymin)*0.10];
% 							case 1
% 								timepos = [bottomp(i) + (aymax-aymin)*0.03,  leftp(i) + (axmax-axmin)*0.10];
							case 0
								timepos = [(axmax-axmin)*0.03,  (aymax-aymin)*0.10];
							case 1
								timepos = [(aymax-aymin)*0.03,  (axmax-axmin)*0.10];
						end
						
						timealignment = 'left';
						
					case 'r'
						switch angle
% 							case 0
% 								timepos = [leftp(i) + (axmax-axmin)*0.97,  bottomp(i) + (aymax-aymin)*0.10];
% 							case 1
% 								timepos = [bottomp(i) + (aymax-aymin)*0.97,  leftp(i) + (axmax-axmin)*0.10];
							case 0
								timepos = [(axmax-axmin)*0.97,  (aymax-aymin)*0.10];
							case 1
								timepos = [(aymax-aymin)*0.97,  (axmax-axmin)*0.10];
						end
						timealignment = 'right';
				end
			end
			

			if ~isempty(imgobj.timestamp)
				%text(timepos(1), timepos(2), imgobj.timestamp(i), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', 'center');
				if ischar(imgobj.timestamp(datanum(i)))
% 					text(bottomp(i) + timepos(1),  leftp(i) + timepos(2), imgobj.timestamp(datanum(i)), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', timealignment);
					text(timepos(1),  timepos(2), imgobj.timestamp(datanum(i)), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', timealignment);
				else
% 					text(bottomp(i) + timepos(1),  leftp(i) + timepos(2), num2str(imgobj.timestamp(datanum(i))), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', timealignment);
					text(timepos(1),  timepos(2), num2str(imgobj.timestamp(datanum(i))), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', timealignment);
				end
			end
			
			if ~isempty(imgobj.time)
				%text(timepos(1), timepos(2), num2str(imgobj.time(datanum(i)), '%.1f'), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', timealignment);
				timedicimalstr = ['%.', num2str(timedecimal), 'f'];
% 				text(bottomp(i) + timepos(1), leftp(i) + timepos(2), num2str(imgobj.time(datanum(i)), timedicimalstr), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', timealignment);
				text(timepos(1), timepos(2), num2str(imgobj.time(datanum(i)), timedicimalstr), 'Color', 'w', 'FontSize', timesize, 'HorizontalAlignment', timealignment);
			end
		end
		
		if i==1
			if show_scalebar && ~isempty(imgobj.pixelsize)
				if ischar(scalebarpos)
					switch scalebarpos
						case 'tl'
% 							scalebarpos = [leftp(i) + (axmax-axmin)*0.03, bottomp(i) + (aymax-aymin)*0.03];
							scalebarpos = [(axmax-axmin)*0.03, (aymax-aymin)*0.03];
							scalebaralignment = 'left';
						case 'tr'
% 							scalebarpos = [leftp(i) + (axmax-axmin)*0.93, bottomp(i) + (aymax-aymin)*0.03];
							scalebarpos = [(axmax-axmin)*0.93, (aymax-aymin)*0.03];
							scalebaralignment = 'right';
						case 'bl'
% 							scalebarpos = [leftp(i) + (axmax-axmin)*0.07, bottomp(i) + (aymax-aymin)*0.97];
							scalebarpos = [(axmax-axmin)*0.07, (aymax-aymin)*0.97];
							scalebaralignment = 'left';
						case 'br'
% 							scalebarpos = [leftp(i) + (axmax-axmin)*0.97, bottomp(i) + (aymax-aymin)*0.97];
							scalebarpos = [(axmax-axmin)*0.97, (aymax-aymin)*0.97];
							scalebaralignment = 'right';
					end
				end
				
				switch scalebaralignment
					case 'left'
% 						plot(bottomp(i) + [scalebarpos(1), scalebarpos(1) + scalebarlength / imgobj.pixelsize], leftp(i) + [scalebarpos(2), scalebarpos(2)], 'Color', scalebarcolor, 'Linewidth', 2);
						plot([scalebarpos(1), scalebarpos(1) + scalebarlength / imgobj.pixelsize], [scalebarpos(2), scalebarpos(2)], 'Color', scalebarcolor, 'Linewidth', 2);
					case 'right'
% 						plot(bottomp(i) + [scalebarpos(1), scalebarpos(1) - scalebarlength / imgobj.pixelsize], leftp(i) + [scalebarpos(2), scalebarpos(2)], 'Color', scalebarcolor, 'Linewidth', 2);
						plot([scalebarpos(1), scalebarpos(1) - scalebarlength / imgobj.pixelsize], [scalebarpos(2), scalebarpos(2)], 'Color', scalebarcolor, 'Linewidth', 2);
				end	
			end

			if any(imgobj.filepath=='\')
				filepathstr = imgobj.filepath(find(imgobj.filepath=='\', 1, 'last') +1 : end);
			else
				filepathstr = imgobj.filepath;
			end
				
			filename = '';
			if length(imgobj.filename) >= 1
				filename = imgobj.filename{1};
			end
		end
		
		if i==1
			if ~strcmp(imgobj.titlestr, '')
				title([filepathstr ' - ' filename ' - ' imgobj.titlestr], 'interpreter', 'none');
				title(imgobj.titlestr, 'interpreter', 'none');
			else
				title([filepathstr ' - ' filename]);
			end
		end
		
	end

	if ~returndata
        imagepanel = [];
    end
    
end