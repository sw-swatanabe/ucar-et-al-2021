%{
For fitting the histogram of a ROI
%}


tauAD_init = dt.fparamval{1};
tauD_init = dt.fparamval{2};
tauG_init = dt.fparamval{3};
t0_init = dt.fparamval{4};
offset_init = 0;


datanum = 1:mp.ndata;

for n=datanum

	xdata_all = mp.sp{1}.pl{1}.xdata{n};
	ydata_all = mp.sp{1}.pl{1}.ydata{n};

	xstep = (xdata_all(end) - xdata_all(1)) / (histlength - 1);

	if ~isempty(fitrange) 
		fit_points =  max(round(fitrange(1) / xstep),1) :  min(round(fitrange(2) / xstep), histlength);
	end
	
	if ~isempty(fit_points)
		xdata = xdata_all(fit_points);
		ydata = ydata_all(fit_points);
	else
		xdata = xdata_all;
		ydata = ydata_all;
	end


	switch fittingtype
		case 'free' %tau1 and tau2 unfixed
			[data_est{n}, params_est(:,n), sse(n), exitflag(n)] = flim_doubleexpfit_offset(xdata, ydata, 'tauD', tauD_init, 'tauAD', tauAD_init, 'tauG', tauG_init, 't0', t0_init);

		case 'fix_tauAD' %tau1 fixed
			[data_est{n}, params_est(:,n), sse(n), exitflag(n)] = flim_doubleexpfit_offset(xdata, ydata, 'tauD', tauD_init, 'tauAD_fix', tauAD_init, 'tauG', tauG_init, 't0', t0_init);

		case 'fix_tauD' %tau2 fixed
			[data_est{n}, params_est(:,n), sse(n), exitflag(n)] = flim_doubleexpfit_offset(xdata, ydata, 'tauD_fix', tauD_init, 'tauAD', tauAD_init, 'tauG', tauG_init, 't0', t0_init);

		case 'fix_tau' %tau1 and tau2 fixed
            [data_est{n}, params_est(:,n), sse(n), exitflag(n)] = flim_doubleexpfit_offset(xdata, ydata, 'tauD_fix', tauD_init, 'tauAD_fix', tauAD_init, 'tauG', tauG_init, 't0', t0_init);

		case 'single' %single exponential
			[data_est{n}, params_est(:,n), sse(n), exitflag(n)] = flim_doubleexpfit_offset(xdata, ydata, 'tauD', tauD_init, 'tauAD_fix', tauAD_init, 'tauG', tauG_init, 't0', t0_init, 'aAD_fix',0);

	end


	mp.sp{1}.pl{2}.xdata{n} = xdata;
	mp.sp{1}.pl{2}.ydata{n} = data_est{n};

	mp.sp{2}.pl{1}.xdata{n} = xdata;
	mp.sp{2}.pl{1}.ydata{n} = ydata - data_est{n};

end

mp.sp{1}.pl{2}.color = 'r';
mp.sp{2}.pl{1}.color = 'r';
mp.update;

cd(pq_datafolder);
   graphname=['hist_LSM_' num2str(pq_filenumber) 'roi_'  num2str(roinum)]; 
   saveas(gcf,graphname);
   saveas(gcf,graphname, 'jpeg');

dt.update;
%cd(pq_datafolder);
   graphname=['roi_LSM_' num2str(pq_filenumber) 'roi_' num2str(roinum)]; 
   saveas(gcf,graphname);
   saveas(gcf,graphname, 'jpeg');

dc.update;
%cd(pq_datafolder);
   graphname=['int_LSM_' num2str(pq_filenumber) ]; 
   saveas(gcf,graphname);
   saveas(gcf,graphname, 'jpeg');
   

% 		aD_est = params_est(1);
% 		aAD_est = params_est(2);
% 		tauD_est = params_est(3);
% 		tauAD_est = params_est(4);
% 		tauG_est = params_est(5);
% 		t0_est = params_est(6);
%		offset_est = params_est(7);

bindingfraction = params_est(2,:) ./ (params_est(1,:) + params_est(2,:));

%display results on the command window

for t=datanum
	fprintf('%d\t', t);
	fprintf('a1=%.4f\t', params_est(2,t));
	fprintf('a2=%.4f\t', params_est(1,t));
	fprintf('t1=%.4f\t', params_est(4,t));
	fprintf('t2=%.4f\t', params_est(3,t));
	fprintf('tG=%.4f\t', params_est(5,t));
	fprintf('t0=%.4f\t', params_est(6,t));
	fprintf('offset=%.4f\t', params_est(7,t));
	fprintf('\tbinding=%.4f\n', bindingfraction(t));
	
%below is added by Hasan
   summary.binding(pq_filenumber, roinum)=bindingfraction; % writes binding fraction to "summary.binding" 
   summary.a1(pq_filenumber, roinum)= params_est(2,t);
   summary.a2(pq_filenumber, roinum)= params_est(1,t);
   summary.tG(pq_filenumber, roinum)= params_est(5,t);
   summary.offset(pq_filenumber, roinum)= params_est(6,t);
end



