
%
addpath('/cluster/home/xiejp/TOPAZ/TP5a0.06/topo');
idm=800; jdm=760;
mlon=loada('regional.grid.a',1,idm,jdm);
mlat=loada('regional.grid.a',2,idm,jdm);
mdep=loada('regional.depth.a',1,idm,jdm);

tmpuf=mdep; tmpuf(find(abs(tmpuf))>20000)=0;
Fuf=['depths' num2str(idm) 'x' num2str(jdm) '.uf']
fid=fopen(Fuf,'w','ieee-be');
   stat=fseek(fid,4,'bof');
   fwrite(fid,8*idm*jdm,'integer*4');
   fwrite(fid,tmpuf,'double');
   fwrite(fid,8*idm*jdm,'integer*4');
fclose(fid);

Fuf2=['newpos.uf']
fid=fopen(Fuf2,'w','ieee-be');
   stat=fseek(fid,4,'bof');
   fwrite(fid,8*idm*jdm*2,'integer*4');
   fwrite(fid,mlat,'double');
   fwrite(fid,mlon,'double');
   fwrite(fid,8*idm*jdm*2,'integer*4');

  % fwrite(fid,8*idm*jdm,'integer*4');
  % fwrite(fid,tmpuf,'double');
  % fwrite(fid,8*idm*jdm,'integer*4');
   %fwrite(fid,mlat,'double');
   %fwrite(fid,mlon,'double');
   %fwrite(fid,tmpuf,'double');
fclose(fid);
