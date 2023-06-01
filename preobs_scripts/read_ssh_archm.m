
clear all;
close all;

idm=800; jdm=760;
addpath('/cluster/home/xiejp/REANALYSIS_TP5/FILES')
mlon=loada('regional.grid.a',1,idm,jdm);
mlat=loada('regional.grid.a',2,idm,jdm);
mdep=loada('regional.depth.a',1,idm,jdm);

Vali0=ones(size(mlon));  Vali0(find(mdep>20000|mdep<1))=0;
mask_1=find(Vali0==1);

Sourdir='/cluster/work/users/xiejp/work_2022/TP5_prepare/archm/';
Sourdir0='/cluster/work/users/xiejp/work_2022/TP5_prepare/';

idebug=0;
Y1=0;  Y2=0;
for iy=1994:2012
   Fmat0=[Sourdir0 'SSH_TP5_' num2str(iy) '.mat'];
   if exist(Fmat0,'file')~=2
      DD=datenum(iy+1,1,1)-datenum(iy,1,1);
      i0=0;
      for i=1:DD
         Sdate=[num2str(iy) '_' num2str(i,'%03d') '_12'];
         Fab=[Sourdir 'archm.' Sdate '.a'];
         if exist(Fab,'file')==2
            i0=i0+1;
            %disp(Sdate);
            tmp=loada(Fab,2,idm,jdm);
	    var=nan(size(mlon)); var(mask_1)=tmp(mask_1);
	    if idebug==1
	       % test to show ssh:
	       figure('color',[1 1 1]);
	         P0=pcolor(var'); set(P0,'linestyle','none');
	         grid on;  set(gca,'GridLineStyle','--','fontsize',12);
	         lb=colorbar;  colormap(jet(25));
	    end
	    TP5ssh(i0,:)=var(mask_1);
	    TP5date(i0)=datenum(iy,1,0)+i0;
         end

      end
      if i0==DD
	 save(Fmat0,'Vali0','mask_1','TP5ssh','TP5date');
      end
   else
      if Y1==0
	 Y1=iy;
      else
	 Y2=iy;
      end
   end
end

% calculate the time-lag variance of SSH
if Y1>0&Y2>=Y1
   % contiune 7 days:
   Nb=zeros(7,1);  
   for iy=Y1:Y2
      Fmat0=[Sourdir0 'SSH_TP5_' num2str(iy) '.mat'];
      if exist(Fmat0,'file')==2
         load(Fmat0);
         if Nb(1)==0
	    N0=length(mask_1);
            var_resla=zeros(7,N0);
         end
         Nt=size(TP5ssh,1);
         for j=1:N0
            for idy=1:7
               tmp1=TP5ssh(1:Nt-idy,j);
	       tmp2=TP5ssh(1+idy:Nt,j);
	       tmp0=tmp1-tmp2;
	       nn=Nb(idy); n1=length(tmp0); 
	       var_resla(idy,j)=(var_resla(idy,j)*nn+sum(tmp0.*tmp0))/(nn+n1);
               Nb(idy)=nn+n1;
            end
         end
      end

   end


   for idy=1:7
      var0=nan(size(mlon)); var0(mask_1)=sqrt(var_resla(idy,:));
      % test to show ssh:

      var=100*var0;   % unit: cm
      figure('color',[1 1 1]);
         P0=pcolor(var'); set(P0,'linestyle','none');
         grid on;  set(gca,'GridLineStyle','--','fontsize',12);
         lb=colorbar;  colormap(jet(25)); 
	 caxis([0 1])
         title(['Time lag in ' num2str(Y1) '~' num2str(Y2) '(' num2str(idy)  '; unit:cm)'], 'fontsize',14);
   end
   % rms:
   var0=zeros(size(mlon)); 
   var1=zeros(N0,1); 
   for j=1:N0
     var1(j)=sum(var_resla(:,j).*Nb(:))/sum(Nb); 
   end
   var0(mask_1)=var1;

   var=100*sqrt(var0);   % unit: cm
   figure('color',[1 1 1]);
      P0=pcolor(var'); set(P0,'linestyle','none');
      grid on;  set(gca,'GridLineStyle','--','fontsize',12);
      lb=colorbar;  colormap(jet(25)); caxis([0 1])
      title(['Time lag in ' num2str(Y1) '~' num2str(Y2) '(mean; unit:cm)'], 'fontsize',14);
      cb=colorbar;  

  % [r0]=my_savevar2nc1(mlon,mlat,mdep,var0,'re_sla','representative error variance of sla in TP5','re_sla.nc');
  % [r0]=savevar2nc1(mlon,mlat,mdep,var0,'re_sla','representative error variance of sla in TP5','re_sla.nc','');
 

  nccreate('re_sla.nc','re_sla', ...
	  'Dimensions',{'idm',800,'jdm',760}, ...
	  'FillValue','disable');
  ncwrite('re_sla.nc','re_sla',var0);
  %ncwrite('re_sla.nc','var0',idm*jmd,[idm,jdm]);

end
