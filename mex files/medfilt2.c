//median filter for [m,n] window

#include "mex.h"
#include <stdio.h>
#include <stdlib.h>


void medianfilter(double *data, int fsize1, int fsize2, double *fdata, int mrows, int ncols)
{
	int m, n, i, j, k;
	int fsize1h = fsize1/2;
	int fsize2h = fsize2/2;
	int fsizesq;
	
	double *edata;
	double *rdata, *sdata, *rpdata;
	int *idata, *jdata;
	
	int emrows = mrows + fsize1 -1;
	int encols = ncols + fsize2 -1;
	
	
	fsizesq = fsize1 * fsize2;
	
	edata = calloc((emrows * encols), sizeof(double));	//expanded image, filled with 0 around
	rdata = calloc(fsizesq, sizeof(double));	// data to be sorted
	sdata = calloc(fsizesq, sizeof(double));	// sorted data
	idata = calloc(fsizesq, sizeof(int));		// index to be sorted
	jdata = calloc(fsizesq, sizeof(int));		// sorted index 

	//fill the corner areas, using the expanded image index
		
	for (n=0; n<fsize2h; n++) {
		for (m=0; m<fsize1h; m++) {
			*(edata + emrows * n + m) = *(data);
		}
	}

	for (n=0; n<fsize2h; n++) {
		for (m=emrows-fsize1h; m<emrows; m++) {
			*(edata + emrows * n + m) = *(data + (mrows-1) );
		}
	}
	for (n=encols-fsize2h; n<encols; n++) {
		for (m=0; m<fsize1h; m++) {
			*(edata + emrows * n + m) = *(data + mrows * (ncols-1) );
		}
	}
	for (n=encols-fsize2h; n<encols; n++) {
		for (m=emrows-fsize1h; m<emrows; m++) {
			*(edata + emrows * n + m) = *(data + mrows * (ncols-1) + (mrows-1) );
		}
	}

	//fill the edge areas, using the expanded image index

	for (n=0; n<fsize2h; n++) {
		for (m=fsize1h; m<emrows-fsize1h; m++) {
			*(edata + emrows * n + m) = *(data + (m -fsize1h) );
		}
	}
	for (n=fsize2h; n<encols-fsize2h; n++) {
		for (m=0; m<fsize1h; m++) {
			*(edata + emrows * n + m) = *(data + mrows * (n -fsize2h) );
		}
	}
	for (n=fsize2h; n<encols-fsize2h; n++) {
		for (m=emrows-fsize1h; m<emrows; m++) {
			*(edata + emrows * n + m) = *(data + mrows * (n -fsize2h) + (mrows-1) );
		}
	}
	for (n=encols-fsize2h; n<encols; n++) {
		for (m=fsize1h;  m<emrows-fsize1h; m++) {
			*(edata + emrows * n + m) = *(data + mrows * (ncols-1) + (m -fsize1h) );
		}
	}


	//central part of the image, using the original image index
	
	for (n=0; n<ncols; n++) {
		for (m=0; m<mrows; m++) {
			*(edata + emrows * (fsize2h + n) + fsize1h + m) = *(data + mrows * n + m);
		}
	}


	//data sorting 
	
	for (n=0; n<ncols; n++) {
		for (m=0; m<mrows; m++) {

			if (m==0) { //sort all the data of the area of size [fsize1, fsize2]
			
				for (j=0; j<fsize2; j++){
					for (i=0; i<fsize1; i++) {
						*(rdata + j*fsize1 + i) = *(edata + emrows * (n+j) + m+i);	//original data extracted for processing
						*(sdata + j*fsize1 + i) = *(rdata + j*fsize1 + i);			//sorted data
						*(idata + j*fsize1 + i) =  j*fsize1 + i;					//original index
						*(jdata + j*fsize1 + i) =  *(idata + j*fsize1 + i);			//sorted index
					}
				}
				
				for (i=0; i<fsizesq; i++) {
					for (j=0; j<i; j++) {
						if ( *(rdata +i) < *(sdata +j) ) {
							for (k=i; k>j; k--) {
								*(sdata +k) = *(sdata +k -1);
								*(jdata +k) = *(jdata +k -1);
							}
							*(sdata +j) = *(rdata +i);
							*(jdata +j) = *(idata +i);

							break;
						}
					}

				}

			} else { //sort the appended data of size [1, fsize2]
				
				j = fsize1-1; //new data, i=fsize-1 (index j in place of i)
				for (i=0; i<fsize2; i++) {
					*(rdata + j*fsize2 + i) = *(edata + emrows * (n+i) + m+j); //note i and j are exchanged
					*(sdata + j*fsize2 + i) = *(rdata + j*fsize2 + i);
					*(idata + j*fsize2 + i) = fsize2 * i + (fsize1-1);
					*(jdata + j*fsize2 + i) = *(idata + j*fsize2 + i);
				}

				// sort the appended data only
				for (i=fsize2*(fsize1-1); i<fsizesq; i++) {
					for (j=0; j<i; j++) {
						if ( *(rdata +i) < *(sdata +j) ) {
							for (k=i; k>j; k--) {
								*(sdata +k) = *(sdata +k -1);
								*(jdata +k) = *(jdata +k -1);
							}
							*(sdata +j) = *(rdata +i);
							*(jdata +j) = *(idata +i);

							break;
						}
					}
				}
				
			}
			
			//median data
			*(fdata + mrows * n + m) = *(sdata + fsizesq/2);
			
			//extract pixels for the next filtering
			for (i=fsizesq-1; i>=0; i--){
				if (! (*(jdata +i) % fsize1) ) { //original index not a multiple of fsize1
					for (k=i; k<fsizesq-1; k++) {
						*(sdata +k) = *(sdata +k +1);
						*(jdata +k) = *(jdata +k +1);
					}
				}
			}
			
			//remove indexes not used in the next filtering
			for (i=0; i<fsize2*(fsize1-1); i++) {
				*(jdata +i) = *(jdata +i) -1;
			}
			
		}
	}

	free(edata);
	free(rdata);
	free(sdata);
	free(idata);
	free(jdata);
}




/* The gateway routine */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
	double	*data, *fdata;
	int		fsize1, fsize2;
	double	*fsizedp;
	int     status, mrows, ncols;
	
	int m, n;
  
  /*  Check for proper number of arguments. */

	if(nrhs!=2) 
		mexErrMsgTxt("Two inputs required.");
 
	/*  Get the scalar input x. */
	fsizedp = mxGetPr(prhs[1]);

	fsize1 = (int)(*fsizedp);
	if ((mxGetM(prhs[1]) * mxGetN(prhs[1])) ==2) {
		fsize2 =  (int)(*(fsizedp +1));
	} else {
		fsize2 = fsize1;
	}
	
	if( !(fsize1 % 2) || !(fsize2 % 2)) {
		mexErrMsgTxt("Input fsize must be an odd number.");
	}
	
	
	
	/*  Create a pointer to the input matrix y. */
	data = mxGetPr(prhs[0]);
  
	/*  Get the dimensions of the matrix input y. */
	mrows = mxGetM(prhs[0]);
	ncols = mxGetN(prhs[0]);
  
	/*  Set the output pointer to the output matrix. */
	plhs[0] = mxCreateDoubleMatrix(mrows, ncols, mxREAL);
  
	/*  Create a C pointer to a copy of the output matrix. */
	fdata =calloc(mrows * ncols , sizeof(double));
	
  
	/*  Call the C subroutine. */
	medianfilter(data, fsize1, fsize2, fdata, mrows, ncols);
  
	memcpy(mxGetPr(plhs[0]), fdata,  mrows * ncols * sizeof(double));
	
	free(fdata);
	
}

