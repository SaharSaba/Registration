

function [eta, ddx, ddy , ddz ,Force,imsmall]=similarity(main)



imsmall = main.imsmall(:,:,:,1);
dd=imsmall-main.refimsmall;


%   [eta, dd]=mirt_MI(main.refimsmall,imsmall,64);

Y = uint8(imsmall);
X = uint8(main.refimsmall);

U(:,1) = double(X(:)) ; 
U(:,2) = double(Y(:)) ;
[V m] = hist3(U,[256 256]);

Jpdf= V/sum(V(:));

% marginal pdf of template image

[pixelCountsT, grayLevelsT] = imhist(Y(:));
margY= pixelCountsT / numel(Y);


%% marginal pdf of refrence image
[pixelCountsR, grayLevelsR] = imhist(X(:));
margX = pixelCountsR / numel(X);

%% correlation ratio of random variable

% 1- eta (Y|X) = 1- eta (T|R)

% calculation of Denominator:  sigma.^2 = var(T) or var(Y)
sum0=0;
sigma0=0;
for j=1: 256
    
    sum0 =sum0+(j* margY(j,1)) ;
    
end

m = sum0.^2;

for j=1: 256
    j2=j.^2;
    sigma0 =  sigma0+(j2* margY(j,1));
    
end
varY  = sigma0 - m ; % ����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sum1=0;
for x=1:256
    for y=1:256
        
        sum1 = sum1+ (y*Jpdf(x,y));
        
        
    end
    if( margX(x,1)>0)
        
        mi(x,1) = sum1 /margX(x,1);
    else
        mi(x,1) = 0;
    end
    sum1= 0;
    
end



mi = mi.^2;

sum2=0;
for x=1:256
    for y=1:256
        
        y2=y.^2;
        sum2 = sum2+ (y2*Jpdf(x,y));
        
        
    end
    
    if( margX(x,1)>0)
        
        sigmai(x,1) = sum2 /margX(x,1);
    else
        sigmai(x,1) = 0;
        
    end
    sum2= 0;
    
    
end


vari = sigmai - mi;


sumf=0;
for x=1:256
    
    
    sumf = sumf+ (vari(x,1) * margX(x,1));
    
    
end


eta = sqrt(1-( sumf /varY ));



% Multiply by interpolated image gradients
ddx=dd.*main.imsmall(:,:,:,2); ddx(isnan(ddx))=0;
ddy=dd.*main.imsmall(:,:,:,3); ddy(isnan(ddy))=0;
ddz=dd.*main.imsmall(:,:,:,4); ddz(isnan(ddz))=0;

Force = cat(4, ddx , ddy ,ddz);

