%{
fitting FLIM histogram

useage
flim_doubleexpfit_offset(xdata, ydata, options)
or
flim_doubleexpfit_offset(ydata, options)
%}

function [data_est, params_est_all, sse, exitflag] = flim_doubleexpfit_offset(data_in, varargin)

	params_all = 1:7;
	
	params_fit = params_all;
	params_fix = [];
	
	nvarargin = length(varargin);
	
	
	if nvarargin>=1 && isnumeric(varargin{1}) && length(varargin{1})>1	
		%flimdflim_doubleexpfit_offsetoubleexpfit(xdata, ydata, options)
		t = data_in;
		data_raw = varargin{1};
	else
		%flim_doubleexpfit_offset(ydata, options)
		t = 1:length(data);
		data_raw = data_in;
	end
	

	%default values
	aD_init = max(data_raw)/2;
	aAD_init = max(data_raw)/2;
	tauD_init = 3;
	tauAD_init = 0.5;
	tauG_init = 0.1;
	t0_init = 1;
	offset_init = 0;

	Tp = 12.5;
	
	
	for i=1:nvarargin
		
		if ischar(varargin{i})
			
			switch varargin{i}
				%fixed parameters
				case 'aD_fix'
					aD_init = varargin{i+1};
					params_fix = [params_fix, 1];
				case 'aAD_fix'
					aAD_init = varargin{i+1};
					params_fix = [params_fix, 2];
				case 'tauD_fix'
					tauD_init = varargin{i+1};
					params_fix = [params_fix, 3];
				case 'tauAD_fix'
					tauAD_init = varargin{i+1};
					params_fix = [params_fix, 4];
				case 'tauG_fix'
					tauG_init = varargin{i+1};
					params_fix = [params_fix, 5];
				case 't0_fix'
					t0_init = varargin{i+1};
					params_fix = [params_fix, 6];
				case 'offset_fix'
					offset_init = varargin{i+1};
					params_fix = [params_fix, 7];

				%free parameters
				case 'aD'
					aD_init = varargin{i+1};
				case 'aAD'
					aAD_init = varargin{i+1};
				case 'tauD'
					tauD_init = varargin{i+1};
				case 'tauAD'
					tauAD_init = varargin{i+1};
				case 'tauG'
					tauG_init = varargin{i+1};
				case 't0'
					t0_init = varargin{i+1};
				case 'offset'
					offset_init = varargin{i+1};
					
			end
		end
	end

	
	params_fit(params_fix) = [];
	

	options.Display = 'off';
	params_init_all = [aD_init, aAD_init, tauD_init, tauAD_init, tauG_init, t0_init, offset_init];
	params_init = params_init_all(params_fit);
	
	[params_est, sse, exitflag] = fminsearch(@fittingf, params_init, options);
	
	params_est_all = params_init_all;
	params_est_all(params_fit) = params_est;
	
	data_est = doubleexpf(params_est_all);
	
	
	%function for fitting
	function sse = fittingf(params)

		params_fit_all = params_init_all;
		params_fit_all(params_fit) = params;

		data_fit = doubleexpf(params_fit_all);
		
		sse = mean( (data_raw - data_fit) .^2 );
	end


	function data = doubleexpf(params)
		
		aD = params(1);
		aAD = params(2);
		tauD = params(3);
		tauAD = params(4);
		tauG = params(5);
		t0 = params(6);
		offset = params(7);
		
		data =	  aD  * exp( tauG ^2 / (2*tauD^2) - (t - t0) / tauD ) ...
				*(1/2) .* erfc( (tauG^2 - tauD  * (t - t0)) / (sqrt(2) * tauD * tauG) ) ...
				+ aAD * exp( tauG^2 / (2*tauAD^2) - (t - t0) / tauAD ) ...
				*(1/2) .* erfc( (tauG^2 - tauAD * (t - t0)) / (sqrt(2) * tauAD * tauG) ) ...
				+ aD  * exp( tauG^2 / (2*tauD^2)  - (t - t0) / tauD )  / ( exp(Tp / tauD)  - 1) ...
				+ aAD * exp( tauG^2 / (2*tauAD^2) - (t - t0) / tauAD ) / ( exp(Tp / tauAD) - 1) ...
				+ offset;
	end

end

