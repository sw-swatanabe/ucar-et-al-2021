//binning data

#include "mex.h"


void 	mexf(int32_T *fdata, 
			int32_T *data, int binsize, 
			int sizex, int sizey, int offsetx, int offsety)
{
	int x, y;
	int fsizex, fsizey;
	
	fsizex = (sizex - offsetx) / binsize;
	fsizey = (sizey - offsety) / binsize;

				
	for (y=offsety; y < offsety + fsizey * binsize; y++) {
		for (x=offsetx; x < offsetx + fsizex * binsize; x++) {
			*(fdata + fsizex * ((y-offsety) /binsize) + ((x-offsetx)/binsize)) += *(data + sizex * y + x);
		}
	}
}



/* The gateway routine */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
	int32_T	*data, *fdata;
	int		binsize;
	int sizex, sizey, fsizex, fsizey, offsetx, offsety;
	int m, n;
  
  /*  Check for proper number of arguments. */
  /* NOTE: You do not need an else statement when using
     mexErrMsgTxt within an if statement. It will never
     get to the else statement if mexErrMsgTxt is executed.
     (mexErrMsgTxt breaks you out of the MEX-file.) 
 */

	if((nrhs<2) || (nrhs>4))
		mexErrMsgTxt("2-4 inputs required.");
  
	/*  Create a pointer to the input matrix y. */
	data = mxGetPr(prhs[0]);
  
	/*  Get the scalar input x. */
	binsize = (int)mxGetScalar(prhs[1]);
	
	offsetx = 0; offsety = 0;
	if (nrhs==3) {
		offsetx = (int)mxGetScalar(prhs[2]);
		offsety = offsetx;
	}
	if (nrhs==4) {
		offsetx = (int)mxGetScalar(prhs[2]);
		offsety = (int)mxGetScalar(prhs[3]);
	}
	
	/*  Get the dimensions of the matrix input y. */
	sizex = mxGetM(prhs[0]);
	sizey = mxGetN(prhs[0]);
	
	fsizex = (sizex - offsetx) / binsize;
	fsizey = (sizey - offsety) / binsize;
  
	/*  Set the output pointer to the output matrix. */
	plhs[0] = mxCreateNumericMatrix(fsizex, fsizey,  mxINT32_CLASS, mxREAL); 
  
	fdata = mxCalloc (fsizex * fsizey, sizeof(int32_T));
	
  
	/*  Call the C subroutine. */
	mexf(fdata, 
		data, binsize, 
		sizex, sizey, offsetx, offsety);
  
	memcpy(mxGetPr(plhs[0]), fdata,  fsizex * fsizey * sizeof(int32_T));

	mxFree(fdata);
	
}

