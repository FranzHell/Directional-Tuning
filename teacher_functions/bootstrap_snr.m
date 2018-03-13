function [snr,snrm]=bootstrap_snr(xall,yall,N)
%
% (comment) Dec 08, 2010 Martin Nawrot
% bootstrap mit Zuruecklegen;
% 
% (comment) Oct 19, 2006 Martin Nawrot
% xall : values for all trials in all categories
% yall : index of category for each trial value
% N    : number of bootsraps
%
% estimates empiric SNR (snrm) and bootsraps the SNR (snr) N times. The
% bias-corrected SNR is snrm - abs(mean(snr)-snrm)
%
% by Carsten Mehring
n=length(xall);
for i=1:(N+1)
  if (i==N+1)
    ind=1:n;
  else
    ind=[];
    for m=1:max(yall)
      indm=find(yall==m);
      nm=length(indm);
      ind=[ind,indm(floor(rand(nm,1)*nm)+1)];
    end;
  end;
  x=xall(ind);
  y=yall(ind);
  
  x_=[];
  for m=1:max(y)
    ind=find(y==m);
    av(m)=mean(x(ind));

    x_=[x_;x(ind)-av(m)];
  end;
  sigma_s=var(av);
  sigma_n=var(x_);
  if (sigma_n==0) sigma_n=eps; end;
  
  if (i==N+1)
    snrm=sigma_s/sigma_n;
  else
    snr(i)=sigma_s/sigma_n;
  end;
end;