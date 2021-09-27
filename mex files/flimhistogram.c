//flim histogram

#include "mex.h"

/*
	int16 pixdtimeb[sizexb][sizeyb][nphotons*tbinsize*binsize^2]	
	int32 dtval_hist[sizexb][sizeyb][histlength]	
 
 
	This program calculates the following:
	for y=1:sizeyb
		for x=1:sizexb
			dtval = pixdtimeb(x,y,:);  
			dtval_hist(x,y, :) = histc(dtval(dtval >=0), dtime); 
		end
	end
*/


void 	mexf(int16_T *pixdtimeb,
			int32_T *hist,
			int sizex, int sizey, int maxphotons, int histlength)
{
	int x, y, p;
	int dtime;
	
	int minuscount=0;

	for (p=0; p<maxphotons; p++) {
		for (y=0; y<sizey; y++) {
			for (x=0; x<sizex; x++) {
				
				dtime = *(pixdtimeb + p*sizex*sizey + y*sizex + x);
				
				if (0 <= dtime && dtime < histlength) {
					*(hist + histlength * (sizex * y + x) + dtime ) += 1;
				}
				if (dtime==-1) {
					minuscount++;
				}
			}
		}
	}
		
	
// 	mexPrintf("minus count %d\n", minuscount);
	
}



/* The gateway routine */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
	int16_T	*pixdtimeb;
	int32_T	*hist;
	int sizex, sizey, maxphotons, histlength;
  
	int *dtimedims, *histdims;
	int dtime_ndims;
  /*  Check for proper number of arguments. */

	if(nrhs!=2) mexErrMsgTxt("Error - 2 inputs required");
  
	/*  Create a pointer to the input matrix y. */
	pixdtimeb = mxGetPr(prhs[0]);
  
	/*  Get the scalar input x. */
	histlength = (int)mxGetScalar(prhs[1]);
	
	dtime_ndims = mxGetNumberOfDimensions(prhs[0]);
	

	if(dtime_ndims!=3) mexErrMsgTxt("Error - Data must have 3 dimensions");
	
	dtimedims = mxGetDimensions(prhs[0]);
	
	/*  Get the dimensions of the matrix input y. */
	sizex = dtimedims[0];
	sizey = dtimedims[1];
	maxphotons = dtimedims[2];
	
//	mexPrintf("%d %d %d\n", sizex, sizey, maxphotons);	
  
	/*  Set the output pointer to the output matrix. */
	histdims = mxCalloc(3, sizeof(int));
	histdims[0] = histlength;
	histdims[1] = sizex;
	histdims[2] = sizey;
	plhs[0] = mxCreateNumericArray(3, histdims, mxINT32_CLASS, mxREAL); 
  
	hist = mxCalloc (sizex * sizey * histlength, sizeof(int32_T));
  
	/*  Call the C subroutine. */
	mexf(pixdtimeb, hist, sizex, sizey, maxphotons, histlength);
  
	memcpy(mxGetPr(plhs[0]), hist,  sizex * sizey * histlength * sizeof(int32_T));

	mxFree(histdims);
	mxFree(hist);
	
}

