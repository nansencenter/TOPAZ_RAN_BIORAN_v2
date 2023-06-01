module mod_read_icednc
! this routine is used to read the iced file
! and to convert the multicategory variable into the regrated ice
! satement or viable by J. Xie corrected at 15July 2019, and correct a bug of hicem at 17July 
! Update the function read_iced_nc with more constraint like Sicmin when aggeregation SIC/SIT
!
contains

   ! Only aggeregating the SIC/HICE/HSNW at present stage:
   subroutine read_iced_nc(fncname,fice,hice,hsnw,idm,jdm,kcat,undef)
      use nfw_mod
      implicit none
      !real, parameter                     :: SICmin=0.002
      real, parameter                     :: SICmin=0.01
      integer,                 intent(in) :: idm,jdm,kcat
      character(len=*),        intent(in) :: fncname
      real,                    intent(in) :: undef
      real,dimension(idm,jdm),intent(out) :: fice,hice,hsnw
      !real,dimension(idm,jdm),intent(out) :: tice,tsrf
      ! add ice salinity and snow energy as ticem but default only one layer
      !real,dimension(idm,jdm),intent(out) :: sice,tsno 
   !-----------------------------------------------
      integer ::  nc0
      integer ::  tmpid1,tmpid2,tmpid3,tmpid4
      real,dimension(idm,jdm,kcat) :: tmpvar,tmpvar1,tmpvar2,tmpvar3
      ! default 7 layers in CICE
      !real,dimension(idm,jdm,kcat) :: qice1,qice2,qice3,qice4,qice5,qice6,qice7
      !real,dimension(idm,jdm,kcat) :: sice1,sice2,sice3,sice4,sice5,sice6,sice7
      !integer                      ::  qiceid,siceid
      ! default one layer in snow 
      !real,dimension(idm,jdm,kcat) :: snow1
      !integer                      :: snowid

      real                        :: tmp0,tmp1,tmp11  
      integer :: i,j
      integer,dimension(3) :: vardims
   !-----------------------------------------------
      real    :: SIC0
      integer :: k,kk,k0
      real    :: Thkmax(5),Thkmin(5)
      data Thkmax /.64,1.39,2.47,4.57,15./ 
      data Thkmin / .0, .64,1.39,2.47, 4.57/
   !-----------------------------------------------

   ! Open input nc-file
      call nfw_open(fncname,nf_nowrite,nc0)
   
   ! fraction
      call nfw_inq_varid(fncname,nc0,'aicen',tmpid1)
      call nfw_inq_varid(fncname,nc0,'vicen',tmpid2)
      call nfw_inq_varid(fncname,nc0,'vsnon',tmpid3)

      call nfw_get_var_double(fncname,nc0,tmpid1,tmpvar)
      call nfw_get_var_double(fncname,nc0,tmpid2,tmpvar1)
      call nfw_get_var_double(fncname,nc0,tmpid3,tmpvar2)
   ! Close the nc-file
      call nfw_close(fncname,nc0);

      SIC0=SICmin*kcat
      fice=0; hice=0; hsnw=0
      do i=1,idm
         do j=1,jdm
            tmp0=sum(tmpvar(i,j,1:kcat))
            if (tmp0>=SIC0) then
               ! requirement 1:  all category aice > SICmin
               ! requirement 2:  all category hice should be in the deinfined intervals
            !   kk=0; k=1
           !    do while (k<=kcat)
           !       if (tmpvar(i,j,k)>=SICmin) then
           !         ! tmp1=tmpvar1(i,j,k)/tmpvar(i,j,k)
           !         ! if (tmp1>Thkmax(k).or.tmp1<Thkmin(k)) then
           !         !    k=kcat
           !         ! else
           !             kk=kk+1
           !         ! endif
           !       else
           !          k=kcat
           !       endif
           !       k=k+1
           !    end do
               kk=kcat
               if (kk>0) then
                  tmp0=sum(tmpvar(i,j,1:kk))  ! keep aice
                  if (tmp0>=SIC0) then
                     ! requirement 3:  the averged hice/hsnw should be 
                     !                 no more than the uplimites from a function of aice.
                     tmp1=min(sum(tmpvar1(i,j,1:kk))/tmp0,ah_limit(tmp0,1))   ! keep hice
                     tmp11=min(sum(tmpvar2(i,j,1:kk))/tmp0,ah_limit(tmp0,2))  ! keep hsnw
! no up limites
!                     tmp1=sum(tmpvar1(i,j,1:kk))/tmp0   ! keep hice
!                     tmp11=sum(tmpvar2(i,j,1:kk))/tmp0  ! keep hsnw

                     ! requirement 4:  minimal limit for the averged hice > 0.002 m.
                     if (tmp1>SICmin) then
                        fice(i,j)=tmp0; hice(i,j)=tmp1; hsnw(i,j)=tmp11
                     endif
                  endif
                  !if (kk<kcat) then
                  !endif
               else
                  continue
               endif
            endif
         end do
      end do
   end subroutine




   ! Upper threshold for SIT/Hsnw from the function of aice based on the daily output of CICE during 1993-2016
   ! added at 21th April 2022
   real function ah_limit(x,Itype)
      implicit none     
      real,      parameter :: SIC0=0.55, SIC1=0.8
      real,    intent (in) :: x
      integer, intent (in) :: Itype
      real     :: tmpy
      ah_limit=9999
      if (Itype==1) then  ! for sea ice thickness
         if (x>SIC0.and.x<SIC1) then
            ah_limit=1.3+exp(8.0*(x-0.76))
         elseif (x>0.and.x<SIC0) then
            ah_limit=0.09+2.5*x
         endif
      else                ! for snow depth
         if (x>SIC0.and.x<SIC1) then
            ah_limit=.2+exp(2.0*(x-1.3))
         elseif (x>0.and.x<SIC0) then
            ah_limit=0.03+.7*x
         endif
      endif
   end function







   subroutine read_iced_nc0(fncname,fice,hice,hsnw,tice,sice,tsno,tsrf,idm,jdm,kcat,undef)
      use nfw_mod
      implicit none
      integer,                 intent(in) :: idm,jdm,kcat
      character(len=*),        intent(in) :: fncname
      real,                    intent(in) :: undef
      real,dimension(idm,jdm),intent(out) :: fice,hice,hsnw
      real,dimension(idm,jdm),intent(out) :: tice,tsrf
      ! add ice salinity and snow energy as ticem but default only one layer
      real,dimension(idm,jdm),intent(out) :: sice,tsno 
   !-----------------------------------------------
      integer ::  nc0
      integer ::  tmpid1,tmpid2,tmpid3,tmpid4
      real,dimension(idm,jdm,kcat) :: tmpvar,tmpvar1,tmpvar2,tmpvar3
      ! default 7 layers in CICE
      real,dimension(idm,jdm,kcat) :: qice1,qice2,qice3,qice4,qice5,qice6,qice7
      real,dimension(idm,jdm,kcat) :: sice1,sice2,sice3,sice4,sice5,sice6,sice7
      integer                      ::  qiceid,siceid
      ! default one layer in snow 
      real,dimension(idm,jdm,kcat) :: snow1
      integer                      :: snowid

      real                        :: tmp0,tmp1,tmp00,tmp11  
      integer :: i,j,k,kk,l0
      integer,dimension(3) :: vardims
   !-----------------------------------------------

   ! Open input nc-file
      call nfw_open(fncname,nf_nowrite,nc0)
   
   ! fraction
      call nfw_inq_varid(fncname,nc0,'aicen',tmpid1)
      call nfw_inq_varid(fncname,nc0,'vicen',tmpid2)
      call nfw_inq_varid(fncname,nc0,'vsnon',tmpid3)
      call nfw_inq_varid(fncname,nc0,'Tsfcn',tmpid4)

      call nfw_inq_varid(fncname,nc0,'qice001',qiceid)
      call nfw_get_var_double(fncname,nc0,qiceid,qice1)
      call nfw_inq_varid(fncname,nc0,'qice002',qiceid)
      call nfw_get_var_double(fncname,nc0,qiceid,qice2)
      call nfw_inq_varid(fncname,nc0,'qice003',qiceid)
      call nfw_get_var_double(fncname,nc0,qiceid,qice3)
      call nfw_inq_varid(fncname,nc0,'qice004',qiceid)
      call nfw_get_var_double(fncname,nc0,qiceid,qice4)
      call nfw_inq_varid(fncname,nc0,'qice005',qiceid)
      call nfw_get_var_double(fncname,nc0,qiceid,qice5)
      call nfw_inq_varid(fncname,nc0,'qice006',qiceid)
      call nfw_get_var_double(fncname,nc0,qiceid,qice6)
      call nfw_inq_varid(fncname,nc0,'qice007',qiceid)
      call nfw_get_var_double(fncname,nc0,qiceid,qice7)

      call nfw_inq_varid(fncname,nc0,'sice001',siceid)
      call nfw_get_var_double(fncname,nc0,siceid,sice1)
      call nfw_inq_varid(fncname,nc0,'sice002',siceid)
      call nfw_get_var_double(fncname,nc0,siceid,sice2)
      call nfw_inq_varid(fncname,nc0,'sice003',siceid)
      call nfw_get_var_double(fncname,nc0,siceid,sice3)
      call nfw_inq_varid(fncname,nc0,'sice004',siceid)
      call nfw_get_var_double(fncname,nc0,siceid,sice4)
      call nfw_inq_varid(fncname,nc0,'sice005',siceid)
      call nfw_get_var_double(fncname,nc0,siceid,sice5)
      call nfw_inq_varid(fncname,nc0,'sice006',siceid)
      call nfw_get_var_double(fncname,nc0,siceid,sice6)
      call nfw_inq_varid(fncname,nc0,'sice007',siceid)
      call nfw_get_var_double(fncname,nc0,siceid,sice7)

      call nfw_inq_varid(fncname,nc0,'qsno001',snowid)
      call nfw_get_var_double(fncname,nc0,snowid,snow1)

!      call nfw_inq_vardimid(fncname,nc0,tmpid1,vardims)
!      do i=1,3
!         call nfw_inq_dimlen(fncname,nc0,vardims(i),l0)   
!         print *, l0
!      end do

      ! accumulate fraction of sea-ice in cell
      call nfw_get_var_double(fncname,nc0,tmpid1,tmpvar)
      call nfw_get_var_double(fncname,nc0,tmpid2,tmpvar1)
      call nfw_get_var_double(fncname,nc0,tmpid3,tmpvar2)
      call nfw_get_var_double(fncname,nc0,tmpid4,tmpvar3)
      fice=0; hice=0; hsnw=0
      tsrf=0; tice=0;
      sice=0; tsno=0;
      do i=1,idm
         do j=1,jdm
            tmp0=sum(tmpvar(i,j,1:kcat))
            if (tmp0>=0.01) then
               fice(i,j)=sum(tmpvar(i,j,1:kcat))
               hice(i,j)=sum(tmpvar1(i,j,1:kcat))/fice(i,j);
               hsnw(i,j)=sum(tmpvar2(i,j,1:kcat))/fice(i,j);
               do kk=1,kcat
                 tsrf(i,j)=tsrf(i,j)+tmpvar3(i,j,kk)*tmpvar(i,j,kk)
               end do
               tsrf(i,j)=tsrf(i,j)/fice(i,j)
               tmp0=0; tmp00=0;
               tmp1=0; tmp11=0;
               do k=1,5
                  tmp0=tmp0+(qice1(i,j,k)+qice2(i,j,k)+qice3(i,j,k) &
                  +qice4(i,j,k)+qice5(i,j,k)+qice6(i,j,k)+qice7(i,j,k))*tmpvar1(i,j,k)/7

                  tmp00=tmp00+(sice1(i,j,k)+sice2(i,j,k)+sice3(i,j,k) &
                  +sice4(i,j,k)+sice5(i,j,k)+sice6(i,j,k)+sice7(i,j,k))*tmpvar1(i,j,k)/7

                  tmp1=tmp1+tmpvar(i,j,k)*tmpvar3(i,j,k)
                  tmp11=tmp11+snow1(i,j,k)*tmpvar2(i,j,k)
               end do
               tice(i,j)=tmp0;
               sice(i,j)=tmp00;
               tsno(i,j)=tmp11;
               tsrf(i,j)=tmp1/fice(i,j);
            endif
         end do
      end do

   end subroutine





end module
