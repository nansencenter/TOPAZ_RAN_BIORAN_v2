!  Extract the SSH fields from the defined ab files
!  requires the two inputs: the first defines the model source files
!  with same format; the second defines how many sampling files;

program p_extract_ssh
   use mod_za
   use mod_xc
   use m_read_field2d
   implicit none
   logical,parameter :: skipline=.true.
   real,   parameter :: onem=9.806 
   real*4            :: UNDEF = -1.0e14

   integer*4, external :: iargc
   
   integer  :: memf

   character(len=80) :: finfo,fname, fbase
   integer :: indxa, indxb
   logical :: ex1
   integer :: k

   real(4), dimension(:,:), allocatable :: iofld4,iofld

   integer                              :: irec, reclen,ios0
   integer              :: indxl,ios
   character(len=5)     :: char5
   character(len=8)     :: char8
   character(len=80)    :: newfile,fullstring 
   real*4               :: amax,amin,bmin,bmax
   integer              :: lcoord
   logical              :: match


   if (iargc() /= 2) then
      print *,'Usage: extract2ssh Nens fmean.in'
      call exit(0)
   endif
   call getarg(1,fbase)
   read(fbase,*) memf
!   write(memf,*) trim(fbase)
   call getarg(2,finfo)
   
   inquire(file=trim(finfo),exist=ex1)

   if (memf<1.or.memf>10000.or..not.ex1) then
      print *,'Wrong inputs: #mem or #fmean.in'
      call exit(1)
   endif

   ! initial open the defined daily information file

   call xcspmd
   call zaiost
   allocate(iofld4(idm,jdm),iofld(idm,jdm))

   irec=0
   inquire(iolength=reclen) iofld4
   newfile='SSH_'//trim(finfo)//'.uf'
   open(20,file=trim(newfile),form='unformatted', STATUS='unknown',&
         recl=reclen, access='direct',IOSTAT=ios0)
   
   indxl=0
   open(10, file=trim(finfo))
     if (skipline) then
        do k=1,3
           read(10,*) fbase
        end do
     end if
     do k=1,memf
        read(10,'(a)') fname
        
        inquire(file=trim(fname),exist=ex1)
        if (ex1) then
            indxa = index(fname, '.a') - 1
            fbase = fname(1 : indxa)
            !print *, trim(fbase)//'.b'
            ! search the record according to the varname in .b file
            if (indxl==0) then
               open(11,file=trim(fbase)//'.b',status='old')
                  do while(char5/='field'.and.ios==0)
                     read(11,'(a5)',iostat=ios) char5
                  enddo 
               indxl=0
               ios=0
               match=.false.
               do while(.not.match .and. ios==0)
                  read(11,118,iostat=ios) char8,fullstring,lcoord,fullstring,bmin,bmax
                  match=(trim(char8)=='srfhgt' .and. lcoord==0)
                  if (match) then
                    write(6,118) trim(char8),fullstring,lcoord,fullstring,bmin,bmax
                  endif
                  indxl=indxl+1
               end do
               close(11)
            endif
            !print *, 'indxl=', indxl,trim(fbase)//'.a'

            call read_field2d(fbase, 'srfhgt   ',iofld4, idm, jdm, indxl, UNDEF)
            irec=irec+1
            iofld=iofld4/onem
            write(20,rec=irec,iostat=ios0) iofld
            !print '(f10.3)',iofld4(200,250)
            if (ios0 /= 0) then
                print *, 'ERROR: p_extract_ssh: I/O error = ', ios0
                print *, 'ERROR: at '//trim(newfile)//' at irec = ', irec
                stop
            end if

        end if
     end do  
   close(10)
   close(20)
   deallocate(iofld4,iofld)


 118 format (a8,' = ',a21,i3,a7,1p2e16.7)


end program p_extract_ssh 
