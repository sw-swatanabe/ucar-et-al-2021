// [pixcount, pixdtime] = pq_image(uint32(data), channel, frame, sizex, sizey, maxphotons_per_pix, maxphotons_per_line)

#include "mex.h"
	
void mexf(	uint32_T *data, 
			int32_T *pixcount, int16_T *pixdtime,
			int64_T n_data, int channelnumber, int framenumber, int sizex, int sizey, int maxphotons_per_pix, int maxphotons_per_line)
{
	uint32_T	channel, dtime, nsync;
	int64_T		rtime;
	int			n_overflow = 0;
	int			n_photons = 0;
	int16_T		*photondtime;
	int64_T     *photonrtime;
	
	int64_T		linestart, linestop;
	int64_T		totalphotons = 0;
	
	int fr, ln, pix;
	int x, y;
	int i, p;
	
	
	uint32_T channelbit = 0xf << 28;
	uint32_T dtimebit = 0xfff << 16;
	uint32_T nsyncbit = 0xffff;
	

	fr = -1;
	ln = -1;
	n_overflow = 0;
	n_photons = 0;
	linestart = -1;
	
	photondtime = mxCalloc(maxphotons_per_line, sizeof(int16_T));
	photonrtime = mxCalloc(maxphotons_per_line, sizeof(int64_T));
	

	for (i=0; i<n_data; i++){
		
		// 	channel = bitshift( bitand( data(i), channelbit),  -28);
		// 	dtime = bitshift( bitand( data(i), dtimebit),  -16); %in number of time resolutions, typically 32 ps
		// 	nsync =  bitand( data(i), nsyncbit);
		
		channel = ( *(data + i) & channelbit ) >> 28;
		dtime = ( *(data + i) & dtimebit ) >> 16;
		nsync =  *(data + i) & nsyncbit;
		
		rtime = nsync + 65536LL * n_overflow;
 	

		if (fr==framenumber) {
		
			if (channel==15) { //routing event
				
				switch (dtime) {
					case 0: //macro time overflow
						n_overflow++;
						break;
					case 1: //line start
						linestart = rtime;
						ln++;
						break;
					case 2: //line stop
						linestop = rtime;

						//process photon event at line end
						for (p=0; p<n_photons; p++) {
							if (linestart>=0 && *(photonrtime + p)>=linestart && *(photonrtime + p)<linestop) {
								
								pix = sizex * (*(photonrtime + p)-linestart)  / (linestop-linestart);
							
								*(pixdtime  +  *(pixcount  +  ln*sizex + pix) * (sizex*sizey) + ln*sizex + pix) = *(photondtime + p);
								*(pixcount  +  ln*sizex + pix) += 1;
							
								if (*(pixcount  +  ln*sizex + pix) == maxphotons_per_pix) {
									mexPrintf("Pixel photon count overflowed\n");
									goto end_loop;
								}
							}
						}

						n_photons = 0;
						n_overflow = 0;
						linestart = -1;
						break;
						
					case 4: //frame
						fr++;
						goto end_loop;
				}
	
				
			} else { //channel!=15 - photon event
				
				if (channel==channelnumber) {
					*(photondtime + n_photons) = dtime;
					*(photonrtime + n_photons) = rtime;
					n_photons++;
					
					if (n_photons==maxphotons_per_line) {
						mexPrintf("Line photon count overflowed\n");
						goto end_loop;
					}
				}
			}
				
		}
		
		if (fr<framenumber) { //detect frame event
			if (channel==15 && dtime==4) {
				fr++;
			}
		}
				
	}


	for (x=0; x<sizex; x++) {
		for (y=0; y<sizey; y++) {
			totalphotons += *(pixcount + y*sizex + x);
		}
	}
	mexPrintf("total photons %d\n", totalphotons);		

end_loop:
	
	mxFree(photondtime);
	mxFree(photonrtime);
	
}


/* The gateway routine */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
	uint32_T	*data;			//raw input data
	int32_T		*pixcount;	//array of sizex*sizey
	int16_T		*pixdtime;	//array of sizex*sizey
	
	int64_T		n_data;
	int			channelnumber, framenumber, sizex, sizey, maxphotons_per_pix, maxphotons_per_line;
	
	mwSize		*dims;
	
  /*  Check for proper number of arguments. */

	if (nrhs!=7)
		mexErrMsgTxt("7 inputs required");
	
// [pixcount, pixdtime] = pq_image(uint32(data), channel, frame, sizex, sizey, maxphotons_per_pix, maxphotons_per_line)

	/*  Create a pointer to the input matrix y. */
	data = mxGetPr(prhs[0]);

	n_data =  mxGetN(prhs[0]) * mxGetM(prhs[0]);
	
	channelnumber = (int)mxGetScalar(prhs[1]);
	framenumber = (int)mxGetScalar(prhs[2]) -1;
	sizex = (int)mxGetScalar(prhs[3]);
	sizey = (int)mxGetScalar(prhs[4]);
	maxphotons_per_pix = (int)mxGetScalar(prhs[5]);
	maxphotons_per_line = (int)mxGetScalar(prhs[6]);
	

	pixcount = mxCalloc (sizex * sizey,							sizeof(int32_T));	//photon count
	pixdtime = mxCalloc (sizex * sizey * maxphotons_per_pix,	sizeof(int16_T));	//micro time
	

	
	/*  Create a C pointer to a copy of the output matrix. */
	dims = mxCalloc(3, sizeof(mwSize));
	dims[0] = sizex; 
	dims[1] = sizey; 
	dims[2] = maxphotons_per_pix;
	
	plhs[0] = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL); //pixcount
	plhs[1] = mxCreateNumericArray(3, dims, mxINT16_CLASS, mxREAL); //pixdtime
	mxFree(dims);
	

	/*  Call the C subroutine. */
	mexf(	data, 
			pixcount, pixdtime,
			n_data, channelnumber, framenumber, sizex, sizey, maxphotons_per_pix, maxphotons_per_line);
	
	memcpy(mxGetPr(plhs[0]), pixcount,		sizex*sizey							* sizeof(int32_T));
	memcpy(mxGetPr(plhs[1]), pixdtime,		sizex*sizey * maxphotons_per_pix	* sizeof(int16_T));

	//
	mxFree(pixcount);
	mxFree(pixdtime);
	

}






