%数値配列をRGBに変換

%入力
%data
%imagemin, imagemax　カラーコードに変換する値の上限と下限
%paramは次のいずれか 
%[input; rout; gout; bout]の数値の配列
%raibow, irainbow（rainbowの逆転）, gray, k, r, g, b, c, m, y

function imagergb = data2rgb(data, imagemin, imagemax, param)

if imagemax~=imagemin
	imagenorm  = (data' - imagemin) / (imagemax - imagemin);
	imagenorm = min(max(imagenorm, 0), 1);
else
	imagenorm = (data' - imagemin) >0;
end


imagergb = zeros(size(data', 1), size(data', 2), 3);

if isnumeric(param)
	input = param(1, :);
	rout = param(2, :);
	gout = param(3, :);
	bout = param(4, :);
end

if ischar(param)
	switch param
		
		case 'rainbow'
			input = [0		0.25	0.5		0.75	1	];	
			rout =  [0		0		0		1		1	];
			gout =  [0		1		1		1		0.1	];
			bout =  [1		1		0.2		0		0	];
			
		case 'irainbow'
			input = [1		0.75	0.5		0.25	0	];	
			rout =  [0		0		0		1		1	];
			gout =  [0		1		1		1		0.1	];
			bout =  [1		1		0.2		0		0	];
	end
end

if ischar(param) && any(strcmp(param, {'gray', 'k', 'r', 'g', 'b', 'c', 'm', 'y'}))

	switch param
		case {'gray', 'k'}
			imagergb(:,:,1) = imagenorm; imagergb(:,:,2) = imagenorm; imagergb(:,:,3) = imagenorm;
		case 'r'
			imagergb(:,:,1) = imagenorm;
		case 'g'
			imagergb(:,:,2) = imagenorm;
		case 'b'
			imagergb(:,:,3) = imagenorm;
		case 'c'
			imagergb(:,:,2) = imagenorm; imagergb(:,:,3) = imagenorm;
		case 'm'
			imagergb(:,:,1) = imagenorm; imagergb(:,:,3) = imagenorm;
		case 'y'
			imagergb(:,:,1) = imagenorm; imagergb(:,:,2) = imagenorm;

	end
	
else
	
	if imagemax~=imagemin
		imagergb(:,:,1) = interp1(input, rout, imagenorm);
		imagergb(:,:,2) = interp1(input, gout, imagenorm);
		imagergb(:,:,3) = interp1(input, bout, imagenorm);
	else
		imagergb(:,:,1) = imagenorm * rout(2) + (1-imagenorm) * rout(1);
		imagergb(:,:,2) = imagenorm * gout(2) + (1-imagenorm) * gout(1);
		imagergb(:,:,3) = imagenorm * bout(2) + (1-imagenorm) * bout(1);
	end
	
	imagergb = min(max(imagergb, 0), 1);

end

